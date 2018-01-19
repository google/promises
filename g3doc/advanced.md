[TOC]

# Advanced topics

## Ownership and retain cycles

Promises use [GCD](https://developer.apple.com/documentation/dispatch)
internally and make all APIs provide a way to specify on which dispatch queue
each block of work should be dispatched on. Main queue is the default if one
isn't specified. When chaining [fulfillment](basics.md#observing-fulfillment) or
[rejection](basics.md#observing-rejection) observers, or any other convenience
[extensions](extensions.md), the returned promise has a strong reference to the
chained work block. Once the promise gets resolved it removes any references to
observer blocks that were chained on it and schedules them on GCD. Thus, GCD is
the one which owns all blocks and everything captured in them until those blocks
are eventually executed.

Nevertheless, beware that you can create a retain cycle if you use a promise
object inside a block chained on it. That's possible if you've stored the
promise in a local var or ivar, especially if you've created a
[pending](basics.md#pending) promise without any work block associated with it.
That cycle won't be broken until the promise gets resolved. Consider the
following example:

Objective-C:

```objectivec
@implementation MyClass {
  FBLPromise<NSNumber *> *_promise;
}

- (FBLPromise<NSString *> *)doSomething {
  if (_promise == nil) {
    _promise = [FBLPromise pendingPromise];
  }
  return [_promise then:^id(id number) {
    return [self doSomethingElse:number];
  }];
}

- (NSString *)doSomethingElse:(NSNumber *)number {
  return number.stringValue;
}

@end
```

Swift:

```swift
class MyClass {
  var promise: Promise<Int>?

  func doSomething() -> Promise<String> {
    if promise == nil {
      promise = Promise<Int>.pending()
    }
    return promise?.then(doSomethingElse)
  }

  func doSomethingElse(number: Int) -> String {
    return String(number)
  }
}
```

`self` owns the `promise`, and `promise` in turn captures `self` in `then` block
until it gets eventually resolved, if ever. So we get a retain cycle. We could
resolve it with a weak reference, of course, since we're aware of code specifics
in `MyClass`. But that situation can become even more subtle:

Objective-C:

```objectivec
[[myClass doSomething] then:^id(NSString *string) {
  [myClass doSomeOtherThing];
}];
```

Swift:

```swift
myClass.doSomething().then { string in
  myClass.doSomeOtherThing()
}
```

Here we get a promise from one of `MyClass` methods and use it to chain an
observer block which in turn captures that `MyClass` instance inside. Therefore,
`myClass` owns the promise, which owns the block, which captures `myClass` to
invoke some other method. The tricky part is that the code which uses `MyClass`
may never know it has a strong reference to the promise returned from
`doSomething` method and, moreover, there's no code that's dedicated to resolve
that promise soon, because we've used [`pending`](basics.md#pending) constructor
rather than [`async`](basics.md#async) or [`do`](basics.md#do).

There's probably no silver bullet to avoid retain cycles like those and each
case should be considered individually. Just try to avoid
[`pending`](basics.md#pending) promises where possible and always resolve your
promises as soon as possible, so that the ownership of your observer blocks and
everything they may have captured can be handled by GCD.

## Testing

Unit tests are typically run in a single thread of execution. So waiting for a
bunch of async tasks to finish in a test can be tricky. To facilitate that, all
promises are dispatched in a common dispatch group (`FBLPromise.dispatchGroup`
in Objective-C or `DispatchGroup.promises` in Swift) that you can wait on with a
helper function (`FBLWaitForPromisesWithTimeout()` in Objective-C or
`waitForPromises()` in Swift):

Objective-C:

```objectivec
#import "path/to/Promises/FBLPromises.h"

// ...
- (void)testExample {
  // Arrange & Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise do:^id {
    return @42;
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(1));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}
// ...
```

Swift:

```swift
import Promises

// ...
func testExample() {
  // Arrange & Act.
  let promise = Promise<Int> { 42 }

  // Assert.
  XCTAssert(waitForPromises(timeout: 1))
  XCTAssertEqual(promise.value, 42)
  XCTAssertNil(promise.error)
}
// ...
```

Those functions take a timeout arg and return true if all promise blocks have
completed before the timeout; otherwise, they return false.

## Objective-C <-> Swift interoperability

The class `Promise` in Swift is essentially a wrapper over the Objective-C
`FBLPromise` class. Thus, as an addition to standard ways of [creating
promises](basics.md#creating-promises), in Swift you can pass `FBLPromise`
object into `Promise` constructor and also access an underlying `FBLPromise`
instance with `asObjCPromise()` method:

```objectivec
@interface ObjCTest : NSObject

- (FBLPromise<NSString *> *)getString;
- (FBLPromise<NSNumber *> *)getNumber:(NSString *)string;
- (void)asyncWith:(NSString *)string and:(NSInteger)integer completion:(void(^)())handler;
- (void)needsAPromise:(FBLPromise<NSString *> *)promise;

@end
```

Here's how we could use `ObjCTest` in Swift:

```swift
let objc = ObjCTest()

Promise<String>(objc.getString()).then { string in
  return Promise<Int>(objc.getNumber(string))
}.then { number in
  print(number)
}

Promise.resolve { handler in
  objc.async(with: "hello", and: 42, completion: handler)
}.then { _ in
  print("Success.")
}.catch { error in
  print(error)
}

let stringPromise = Promise<String> {
  return "Hello world!"
}

objc.needsAPromise(stringPromise.asObjCPromise())

@objc(providesAPromiseFromNumber:)
func providesAPromise(from number: Int) -> Promise<String>.ObjCPromise<NSString> {
  return Promise<String> {
    "The number is \(number)"
  }.asObjCPromise()
}

objc.needsAPromise(providesAPromise(42))

```

## Dot-syntax in Objective-C

When chaining promises in Objective-C, you can end up having a lot of square
brackets and other formatting concerns. To help with that, we used a trick which
lets us pass args into a method via it's return value of block type. For
example, the code in [catch pipeline](basics.md#catch-pipeline) written using
the dot-syntax would look like:

```objectivec
[self work1:@"abc"]
    .then(^id(NSString *string) {
      return [self work2:string];
    })
    .then(^id(NSNumber *number) {
      return [self work3:number];
    })
    .then(^id(NSNumber *number) {
      NSLog(@"%@", number);
      return nil;
    })
    .catch(^(NSError *error) {
      NSLog(@"Cannot convert string to number: %@", error);
    });
```

All Objective-C Promises APIs provide convenience methods for using dot-syntax.
