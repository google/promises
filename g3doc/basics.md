[TOC]

# Basics

## Creating promises

There are two ways to create a promise depending on whether you need a pending
promise that you plan to resolve after some asynchronous work is finished (usual
case), or you need an already resolved promise to wrap a value or an error (rare
case).

### Create a pending promise

Imagine we have a complex routine which produces a string after lots of
computations. It would be nice to run that asynchronously and provide a promise
of that string that the clients can observe to get the value or error eventually
when completed.

#### Async

Pass a work block to be called asynchronously in the `async` operator and invoke
`fulfill()` with a value or `reject()` with an error inside that work block when
ready:

Objective-C:

```objectivec
FBLPromise<NSString *> *promise = [FBLPromise onQueue:dispatch_get_main_queue()
                                                async:^(FBLPromiseFulfillBlock fulfill,
                                                        FBLPromiseRejectBlock reject) {
  // Called asynchronously on the dispatch queue specified.
  if (success) {
    // Resolve with a value.
    fulfill(@"Hello world.");
  } else {
    // Resolve with an error.
    reject(someError);
  }
}];
```

Swift:

```swift
let promise = Promise<String>(on: .main) { fulfill, reject
  // Called asynchronously on the dispatch queue specified.
  if success {
    // Resolve with a value.
    fulfill("Hello world.")
  } else {
    // Resolve with an error.
    reject(someError)
  }
}
```

`Promises` use the main dispatch queue by default, so the above code is actually
equivalent to:

Objective-C:

```objectivec
FBLPromise<NSString *> *promise = [FBLPromise async:^(FBLPromiseFulfillBlock fulfill,
                                                      FBLPromiseRejectBlock reject) {
  // Called asynchronously on the main queue by default.
  if (success) {
    fulfill(@"Hello world.");
  } else {
    reject(someError);
  }
}];
```

Swift:

```swift
let promise = Promise<String> { fulfill, reject
  // Called asynchronously on the main queue by default.
  if success {
    fulfill("Hello world.")
  } else {
    reject(someError)
  }
}
```

#### Do

We can make the above examples even more concise with `do` operator if the block
of code inside a promise doesn't require async fulfillment:

Objective-C:

```objectivec
FBLPromise<NSString *> *promise = [FBLPromise do:^id {
  // Called asynchronously on the main queue by default.
  return success ? @"Hello world" : someError;
}];
```

Swift:

```swift
let promise = Promise<String> {
  // Called asynchronously on the main queue by default.
  guard success else { throw someError }
  return "Hello world"
}
```

#### Pending

And in case you need a pending promise without any async block of work
associated with it, you can use `pendingPromise` class method in Objective-C or
`pending()` static func in Swift, and resolve the promise manually later on:

Objective-C:

```objectivec
FBLPromise<NSString *> *promise = [FBLPromise pendingPromise];
// ...
if (success) {
  [promise fulfill:@"Hello world"];
} else {
  [promise reject:someError];
}
```

Swift:

```swift
let promise = Promise<String>.pending()
// ...
if success {
  promise.fulfill("Hello world")
} else {
  promise.reject(someError)
}
```

Beware, though, that creating such an untethered promise may potentially lead to
tricky [retain cycles](advanced.md#ownership-and-retain-cycles).

### Create a resolved promise

Sometimes it's convenient to create an already fulfilled or rejected promise.
Pass an initial value or error to the promise's constructor for that:

Objective-C:

```objectivec
- (FBLPromise<NSData *> *)getDataAtURL:(NSURL *)anURL {
  if (anURL.absoluteString.length == 0) {
    return [FBLPromise resolvedWith:nil];
  }
  return [self loadURL:anURL];
}
```

Swift:

```swift
func data(at url: URL) -> Promise<Data?> {
  if url.absoluteString.isEmpty {
    return Promise(nil)
  }
  return load(url)
}
```

In the examples above a promise resolved with value `nil` is returned if the
given URL is empty. Othwerise, we call another routine which returns a promise.

## Observing fulfillment

To get notified when a promise is resolved with a value (i.e. is fulfilled) we
need to use the `then` operator.

You can fulfill a pending promise in many ways:

-   call `fulfill` method on a promise
-   call `fulfill()` in an [async](#async) block or return a value (not an
    error) from the [do](#do) block
-   return a value from the `then` block

Or, just [create a resolved promise](#create-a-resolved-promise) with a
non-error value.

### `then`

The `then` operator expects one argument - a block, which has the value that the
promise before it was fulfilled with as an argument, and also expects another
promise, a value, or an error to be returned. The operator itself returns
another promise that will be resolved with the same resolution that the promise
returned from the block. Any value or error returned from the block is
considered a resolved promise initialized with that value or error. For example:

Objective-C:

```objectivec
FBLPromise<NSNumber *> *numberPromise = [FBLPromise resolvedWith:@42];

// Return another promise.
FBLPromise<NSString *> chainedStringPromise = [numberPromise then:^id(NSNumber *number) {
  return [self stringFromNumber:number];
}];

// Return any value.
FBLPromise<NSString *> chainedStringPromise = [numberPromise then:^id(NSNumber *number) {
  return [number stringValue];
}];

// Return or @throw an error.
FBLPromise<NSString *> chainedStringPromise = [numberPromise then:^id(NSNumber *number) {
  return [NSError errorWithDomain:@"" code:0 userInfo:nil];
}];

// Fake void return.
FBLPromise<NSString *> chainedStringPromise = [numberPromise then:^id(NSNumber *number) {
  NSLog(@"%@", number);
  return nil;
  // OR
  return number;
}];
```

Note: Since Objective-C doesn't support method overloading, we cannot provide a
version of the `then` operator with `void` return type. Thus, if you have no
value to return from the `then` block, you can always just return `nil` or, even
better, the same value as you received. Returning an actual value makes it
easier to chain on this promise in the future.

Swift:

```swift
let numberPromise = Promise(42)

// Return another promise.
let chainedStringPromise = numberPromise.then { number in
  return self.string(from: number)
}

// Return any value.
let chainedStringPromise = numberPromise.then { number in
  return String(number)
}

// Throw an error.
let chainedStringPromise = numberPromise.then { number in
  throw NSError(domain: "", code: 0, userInfo: nil)
}

// Void return.
let chainedStringPromise = numberPromise.then { number in
  print(number)
  // Implicit 'return number' here.
}
```

Note: `chainedStringPromise` is an example of a `Void` return that is
effectively similar to returning the incoming value, i.e. `return number`.

By default, the `then` blocks are dispatched on the main thread, but they can be
easily configured to be dispatched on a custom queue:

Objective-C:

```objectivec
[numberPromise onQueue:backgroundQueue then:^id(NSNumber *number) {
  return number.stringValue;
}];
```

Swift:

```swift
numberPromise.then(on: backgroundQueue) { number in
  return String(number)
}
```

### `then` pipeline

But the most important thing, of course, is the ability to chain any number of
promises together into a pipeline to simulate synchronous execution:

Objective-C:

```objectivec
- (FBLPromise<NSString *> *)work1:(NSString *)string {
  return [FBLPromise do:^id {
    return string;
  }];
}

- (FBLPromise<NSNumber *>)work2:(NSString *)string {
  return [FBLPromise do:^id {
    return @(string.integerValue);
  }];
}

- (NSNumber *)work3:(NSNumber *)number {
  return @(number.integerValue * number.integerValue);
}

[[[[self work1:@"10"] then:^id(NSString *string) {
  return [self work2:string];
}] then:^id(NSNumber *)number {
  return [self work3:number];
}] then:^id(NSNumber* number) {
  NSLog(@"%@", number);  // 100
  return number;
}];
```

Swift:

```swift
func work1(_ string: String) -> Promise<String> {
  return Promise {
    return string
  }
}

func work2(_ string: String) -> Promise<Int> {
  return Promise {
    return Int(string) ?? 0
  }
}

func work3(_ number: Int) -> Int {
  return number * number
}

work1("10").then { string in
  return work2(string)
}.then { number in
  return work3(number)
}.then { number in
  print(number)  // 100
}
```

Since functions in Swift are first-class citizens, we can actually simplify the
previous example to:

```swift
work1("10").then(work2).then(work3).then { number in
  print(number)  // 100
}
```

## Observing rejection

To get notified when a promise is resolved with an error (i.e. is rejected), use
the `catch` operator.

You can reject a promise in many ways:

-   call `reject` method on a promise
-   call `reject()` in an [async](#async) block or return an error from the
    [do](#do) block
-   return or throw an error from the `then` block

Or, just [create a resolved promise](#create-a-resolved-promise) with an error.

Note: In Objective-C when `@throw` is invoked in `then` block with `NSException`
argument, the promise is rejected with `NSError` in `FBLPromiseErrorDomain`
domain with code `FBLPromiseErrorCodeException` and additional info about
`NSException` in `userInfo` dict. If `@throw` is invoked with `NSError`
argument, the promise is rejected with that error.

### `catch`

`catch` operator expects one argument - a block, which has the error that the
promise was rejected with as an argument. The operator itself implicitly returns
another promise, that is rejected with the same error.

Objective-C:

```objectivec
[[self numberFromString:@"abc"] catch:^(NSError *error) {
  NSLog(@"Cannot convert string to number: %@", error);
}];
```

Swift:

```swift
number(from: "abc").catch { error in
  print("Cannot convert string to number: \(error)")
}
```

### `catch` pipeline

One of the pains of nested completion handlers is the need to branch each time
the previous async task returns an error. With promises, rejection of one
promise is propagated down the pipeline automatically, ignoring any remaining
`then` blocks in the pipeline. Instead, the `catch` operator can be placed
anywhere in the chain to handle errors. For example, consider the code from
[then pipeline](#then-pipeline):

Objective-C:

```objectivec
- (FBLPromise<NSString *> *)work1:(NSString *)string {
  return [FBLPromise do:^id {
    return string;
  }];
}

- (FBLPromise<NSNumber *>)work2:(NSString *)string {
  return [FBLPromise do:^id {
    NSInteger number = string.integerValue;
    return number > 0 ? @(number) : [NSError errorWithDomain:@"" code:0 userInfo:nil];
  }];
}

- (NSNumber *)work3:(NSNumber *)number {
  return @(number.integerValue * number.integerValue);
}

[[[[[self work1:@"abc"] then:^id(NSString *string) {
  return [self work2:string];
}] then:^id(NSNumber *)number {
  return [self work3:number];  // Never executed.
}] then:^id(NSNumber* number) {
  NSLog(@"%@", number);  // Never executed.
  return number;
}] catch:^(NSError *error) {
  NSLog(@"Cannot convert string to number: %@", error);
}];
```

Note: When chaining promises in Objective-C, you can end up having a lot of
square brackets. One way to solve that is with
[dot-syntax](advanced.md#dot-syntax-in-objective-c).

Swift:

```swift
struct CustomError: Error {}

func work1(_ string: String) -> Promise<String> {
  return Promise {
    return string
  }
}

func work2(_ string: String) -> Promise<Int> {
  return Promise {
    guard let number = Int(string), number > 0 else { throw CustomError() }
    return number
  }
}

func work3(_ number: Int) -> Int {
  return number * number
}

work1("10").then { string in
  return work2(string)
}.then { number in
  return work3(number)  // Never executed.
}.then { number in
  print(number)  // Never executed.
}.catch { error in
  print("Cannot convert string to number: \(error)")
}
```
