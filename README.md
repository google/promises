[![Apache
License](https://img.shields.io/github/license/google/promises.svg)](LICENSE)
[![Travis](https://img.shields.io/travis/google/promises.svg)](https://travis-ci.org/google/promises)

# Promises

Promises is a modern framework that provides a synchronization construct for
Objective-C and Swift to facilitate writing asynchronous code.

*   [Introduction](g3doc/index.md)
    *   [The problem with async
        code](g3doc/index.md#the-problem-with-async-code)
    *   [Promises to the rescue](g3doc/index.md#promises-to-the-rescue)
    *   [What is a promise?](g3doc/index.md#what-is-a-promise)
*   [Framework](g3doc/index.md#framework)
    *   [Features](g3doc/index.md#features)
    *   [Benchmark](g3doc/index.md#benchmark)
*   [Getting started](g3doc/index.md#getting-started)
    *   [Add dependency](g3doc/index.md#add-dependency)
    *   [Import](g3doc/index.md#import)
    *   [Adopt](g3doc/index.md#adopt)
*   [Basics](g3doc/index.md#basics)
    *   [Creating promises](g3doc/index.md#creating-promises)
    *   [Observing fulfillment](g3doc/index.md#observing-fulfillment)
    *   [Observing rejection](g3doc/index.md#observing-rejection)
*   [Extensions](g3doc/index.md#extensions)
    *   [All](g3doc/index.md#all)
    *   [Always](g3doc/index.md#always)
    *   [Any](g3doc/index.md#any)
    *   [Recover](g3doc/index.md#recover)
    *   [Resolve](g3doc/index.md#resolve)
    *   [Timeout](g3doc/index.md#timeout)
    *   [Validate](g3doc/index.md#validate)
    *   [When](g3doc/index.md#when)
*   [Advanced topics](g3doc/index.md#advanced-topics)
    *   [Ownership and retain
        cycles](g3doc/index.md#ownership-and-retain-cycles)
    *   [Testing](g3doc/index.md#testing)
    *   [Objective-C <-> Swift
        interoperability](g3doc/index.md#objective-c---swift-interoperability)
    *   [Dot-syntax in Objective-C](g3doc/index.md#dot-syntax-in-objective-c)
*   [Anti-patterns](g3doc/index.md#anti-patterns)
    *   [Broken chain](g3doc/index.md#broken-chain)
    *   [Nested promises](g3doc/index.md#nested-promises)
