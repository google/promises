[TOC]

# Getting started

## Add dependency

### Bazel

In your `BUILD` file add `Promises` deps to corresponding targets:

```python
objc_library(
  # ...
  deps = [
    "//path/to/Promises:FBLPromises",
  ],
  # ...
)
```

```python
swift_library(
  # ...
  deps = [
    "//path/to/Promises",
  ],
  # ...
)
```

### Swift PM

In you `Package.swift` file add `Promises` dependency to corresponding targets:

```swift
let package = Package(
  // ...
  dependencies: [
    .package(url: "https://github.com/google/promises.git", from: "1.0"),
  ],
  // ...
)
```

## Import

Objective-C:

```objectivec
#import "<FBLPromises/FBLPromises.h>"
```

or:

```objectivec
@import FBLPromises;
```

Swift:

```swift
import Promises
```

## Adopt

Instead of taking a completion block as the last argument:

Objective-C:

```objectivec
- (void)getDataAtURL:(NSURL *)anURL completion:^(NSData *data, NSError *error)completion;
```

Swift:

```swift
func data(at url: URL, completion: @escaping (Data?, Error?) -> Void)
```

Promises based async routines return a promise object:

Objective-C:

```objectivec
- (FBLPromise<NSData *> *)getDataAtURL:(NSURL *)anURL;
```

Swift:

```swift
func data(at url: URL) -> Promise<Data>
```

Some legacy code that cannot be modified directly, can be wrapped with
[`resolve`](extensions.md#resolve) operator to return a promise.

Also, read more on [Objective-C and Swift
interoperability](advanced.md#objective-c-swift-interoperability) specifics.
