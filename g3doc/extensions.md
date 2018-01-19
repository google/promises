[TOC]

# Extensions

Having [basic](basics.md) operators like [`async`](basics.md#async),
[`do`](basics.md#do), [`then`](basics.md#then) and [`catch`](basics.md#catch),
is normally sufficient to implement most sequences of async calls with promises.
Nevertheless, there're some common high-level patterns that would also be great
to provide out of the box.

## All

`all` class method waits for all the promises you give it to fulfill, and once
they have, the promise returned form `all` will be fulfilled with the array of
all fulfilled values.

Objective-C:

```objectivec
[[FBLPromise all:[contacts map:^id(MyContact *contact) {
  return [MyClient getAvatarForContact:contact];
}]] then:^id(NSArray<UIImage *> *avatars) {
  [self updateAvatars:avatars];
  return avatars;
}];
```

Swift:

```swift
all(contacts.map { MyClient.getAvatarFor(contact: $0) }).then(updateAvatars)
```

Also, see how `all` helps to avoid [nested
promises](anti-patterns.md#nested-promises).

## Always

`always` is handy when we want some piece of code to execute always down the
promises pipeline, regardless of whether or not the previous promise was
fulfilled or rejected.

Objective-C:

```objectivec
[[[[self getCurrentUserContactsAvatars] then:^id(NSArray<UIImage *> *avatars) {
  [self updateAvatars:avatars];
  return avatars;
}] catch:^(NSError *error) {
  [self showErrorAlert:error];
}] always:^{
  self.label.text = @"All done.";
}];
```

Swift:

```swift
getCurrentUserContactsAvatars().then { avatars in
  self.update(avatars)
}.catch { error in
  self.showErrorAlert(error)
}.always {
  self.label.text = "All done."
}
```

## Any

`any` class method is similar to `all`, but the promise that it returns fulfills
or rejects with the same resolution as the first promise that resolves among the
given.

## Recover

`recover` lets us `catch` an error and easily recover from it without breaking
the rest of the promise chain.

Objective-C:

```objectivec
[[[self getCurrentUserContactsAvatars] recover:^id(NSError *error) {
  NSLog(@"Fallback to default avatars due to error: %@", error);
  return [self getDefaultsAvatars];
}] then:^id(NSArray<UIImage *> *avatars) {
  [self updateAvatars:avatars];
  return avatars;
}];
```

Swift:

```swift
getCurrentUserContactsAvatars().recover { error in
  print("Fallback to default avatars due to error: \(error)")
  return self.getDefaultsAvatars()
}.then { avatars in
  self.update(avatars)
}
```

## Resolve

`resolve` class method provides a convenient way to convert other methods that
use common callback patterns (like `^(id, NSError *)`, etc.) into promises.

Objective-C:

```objectivec
- (FBLPromise<NSData*> *)newAsyncMethodReturningAPromise {
  return [FBLPromise resolveWithObjectOrErrorWhen:^(FBLPromiseObjectOrErrorCompletion handler) {
    [MyClient wrappedAsyncMethodWithTypicalCompletion:handler];
  }];
}
```

Swift:

```swift
func newAsyncMethodReturningAPromise() -> Promise<Data> {
  return Promise.resolve { handler in
    MyClient.wrappedAsyncMethodWithTypical(completion: handler)
  }
}
```

## Timeout

`timeout` allows us to wait for a promise for a time interval or reject it, if
it doesn't resolve within the given time. A timed out promise rejects with
`NSError` in `FBLPromiseErrorDomain` domain with code
`FBLPromiseErrorCodeTimedOut`.

## Validate

`validate` makes value checks trivial without breaking the promise chain. It
receives a value similar to `then`, but returns a boolean indicating if the
value is acceptable. If `validate` returns true, the promise is fulfilled with
the value. If it's false, the promise is rejected with `NSError` in
`FBLPromiseErrorDomain` domain with code `FBLPromiseErrorCodeValidationFailure`.

Objective-C:

```objectivec
[[[[self getAuthToken] validate:^BOOL(NSString *authToken) {
  return authToken.length > 0;
}] then:^id(NSString *authToken) {
  return [self getDataWithToken:authToken];
}] catch:^(NSError *error) {
  NSLog(@"Failed to get auth token: %@", error);
}];
```

Swift:

```swift
getAuthToken().validate { !$0.isEmpty }.then(getData).catch { error in
  print("Failed to get auth token: \(error))
}
```

## When

`when` is similar to `all`, but it fulfills even if some of the promises in the
provided array are rejected. The resulting array will have `NSError` objects
corresponding to the rejected promises. The promise returned from `when` rejects
only if all promises in the array were rejected with same error as the last one
rejected.
