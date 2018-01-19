[TOC]

# Anti-patterns

Promises are very simple once you grok some basics, but there are a few gotchas
to avoid.

## Broken chain

You have code like:

Objective-C:

```objectivec
- (FBLPromise<NSData> *)asyncCall {
  FBLPromise<NSData> *promise = [self doSomethingAsync];
  [promise then:^id(NSData *result) {
    return [self processData:result];
  }];
  return promise;
}
```

Swift:

```swift
func asyncCall() -> Promise<Data> {
  let promise = doSomethingAsync()
  promise.then(process)
  return promise
}
```

The problem here is that if the promise returned from `processData` method is
rejected, there's no way to `catch` it. Promises are meant to be chained. To
fix, always return the result of the final `then`:

Objective-C:

```objectivec
- (FBLPromise<NSData> *)asyncCall {
  FBLPromise<NSData> *promise = [self doSomethingAsync];
  return [promise then:^id(NSData *result) {
    return [self processData:result];
  }];
}
```

Swift:

```swift
func asyncCall() -> Promise<Data> {
  let promise = doSomethingAsync()
  return promise.then(process)
}
```

## Nested promises

Avoid nesting promises, as this is the issue that promises are designed to
solve:

Objective-C:

```objectivec
[[self loadSomething] then:^id(NSData *something) {
  return [[self loadAnother] then:^id(NSData *another) {
    return [self doSomethingWith:something andAnother:another];
  }];
}];
```

Swift:

```swift
loadSomething().then { something in
  self.loadAnother().then { another in
    self.doSomething(with: something, and: another)
  }
}
```

The reason why this issue even appeared is because we need to do something with
the results of both promises, so we can’t chain them, since the `then` is only
passed the result of the previous return. Thankfully, there's
[`all`](extensions.md#all) operator:

Objective-C:

```objectivec
[[FBLPromise all:@[ [self loadSomething], [self loadAnother] ]] then:^id(NSArray<NSData *> *result) {
  return [self doSomethingWith:result.firstObject andAnother:result.lastObject];
}];
```

Swift:

```objectivec
Promise.all([loadSomething(), loadAnother()]).then { result in
  self.doSomething(with: result.first, and: result.last)
}
```

And if you don't like `all` (an array of heterogeneous values doesn't always
read well), just move the nested part into a separate method:

Objective-C:

```objectivec
[[self loadSomething] then:^id(NSData *something) {
  return [self loadAnotherWithSomething:something];
}];

- (FBLPromise<MyResult *> *)loadAnotherWithSomething:(NSData *)something {
  return [[self loadAnother] then:^id(NSData *another) {
    return [self doSomethingWith:something andAnother:another];
  }];
}
```

Swift:

```swift
loadSomething().then { something in
  self.loadAnother(with: something)
}

func loadAnother(with something: Data) -> Promise<MyResult> {
  loadAnother().then { another in
    self.doSomething(with: something, and: another)
  }
}
```
