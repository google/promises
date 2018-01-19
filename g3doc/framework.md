[TOC]

# Framework

Promises is a modern framework that implements the aforementioned
synchronization construct in Objective-C and Swift.

## Features

-   **Simple**: The framework has intuitive APIs that are well documented making
    it painless to integrate into new or existing code.
-   **Interoperable**: Supports both [Objective-C and
    Swift](advanced.md#objective-c-swift-interoperability). Promises that are
    created in Objective-C can be used in Swift and vice versa.
-   **Lightweight**: Has minimum [overhead](#benchmark) that achieves similar
    performance to GCD and completion handlers.
-   **Flexible**: Observer blocks can be dispatched on any thread or custom
    queue.
-   **Safe**: All promises and observer blocks are captured by GCD which helps
    avoid potential [retain cycles](advanced.md#ownership-and-retain-cycles).
-   **Tested**: The framework has 100% test coverage.

## Benchmark

One of the biggest concerns for all frameworks is the overhead they add on top
of the standard library
([GCD](https://developer.apple.com/documentation/dispatch) in this case).

The data below was collected by running performance tests (available under
`Tests` directory) on an iPhone 6s iOS 11.2.1 for the popular frameworks:
[PromiseKit](https://github.com/mxcl/PromiseKit),
[BrightFutures](https://github.com/Thomvis/BrightFutures),
[Hydra](https://github.com/malcommac/Hydra),
[RxSwift](https://github.com/ReactiveX/RxSwift) and plain GCD for comparison.

-   Sizes in bytes added to a binary linked with each library in release mode:

    <center>

    Framework     | Objective-C | Swift
    ------------- | :---------: | :----:
    Promises      | 74160       | 79280
    PromiseKit    | 393036      | 309248
    BrightFutures | N/A         | 83424
    Hydra         | N/A         | 111600
    RxSwift       | N/A         | 191680

    </center>

    ![](resources/benchmark-0.png)

-   Average time in seconds needed to create a resolved promise and get into a
    chained block on a serial queue (measured with 10,000 tries):

    <center>

    Framework     | Objective-C | Swift
    ------------- | :---------: | :---------:
    GCD           | 0.000022744 | 0.000021246
    Promises      | 0.000028293 | 0.000038103
    PromiseKit    | 0.000047047 | 0.000038818
    BrightFutures | N/A         | 0.000038729
    Hydra         | N/A         | 0.000061406
    RxSwift       | N/A         | 0.000053124

    </center>

    ![](resources/benchmark-1.png)

-   Average time in seconds needed to create a resolved promise, chain 2 blocks
    and get into the last chained block on a serial queue (measured with 10,000
    tries):

    <center>

    Framework     | Objective-C | Swift
    ------------- | :---------: | :---------:
    GCD           | 0.000023336 | 0.000024622
    Promises      | 0.000035536 | 0.000048412
    PromiseKit    | 0.000071271 | 0.000061765
    BrightFutures | N/A         | 0.000044416
    Hydra         | N/A         | 0.000086497
    RxSwift       | N/A         | 0.000060675

    </center>

    ![](resources/benchmark-2.png)

-   Average time in seconds needed to create a resolved promise, chain 3 blocks
    and get into the last chained block on a serial queue (measured with 10,000
    tries):

    <center>

    Framework     | Objective-C | Swift
    ------------- | :---------: | :---------:
    GCD           | 0.000024501 | 0.000025683
    Promises      | 0.000039605 | 0.000053961
    PromiseKit    | 0.000088739 | 0.000079487
    BrightFutures | N/A         | 0.000049025
    Hydra         | N/A         | 0.000108063
    RxSwift       | N/A         | 0.00006914

    </center>

    ![](resources/benchmark-3.png)

-   Total time in seconds needed to resolve 10,000 pending promises with chained
    blocks and wait for control to get into each block on a concurrent queue:

    <center>

    Framework     | Objective-C | Swift
    ------------- | :---------: | :---------:
    GCD           | 0.004818658 | 0.014513761
    Promises      | 0.020536681 | 0.041234746
    PromiseKit    | 0.074951688 | 0.067808994
    BrightFutures | N/A         | 0.083329189
    RxSwift       | N/A         | 0.160872425

    </center>

    ![](resources/benchmark-4.png)
