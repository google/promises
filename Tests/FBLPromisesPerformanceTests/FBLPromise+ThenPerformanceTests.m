/**
 Copyright 2018 Google Inc. All rights reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at:

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "FBLPromise+Then.h"

#import <XCTest/XCTest.h>

#import "FBLPromisesTestHelpers.h"

static size_t const FBLPromisePerformanceTestIterationCount = 10000;

NS_INLINE void FBLLogAverageTime(uint64_t time) {
  NSLog(@"Average time: %.10lf", (double)time / NSEC_PER_SEC);
}

NS_INLINE void FBLLogTotalTime(NSTimeInterval time) {
  NSLog(@"Total time: %.10lf", time);
}

@interface FBLPromiseThenPerformanceTests : XCTestCase
@end

@implementation FBLPromiseThenPerformanceTests

#pragma mark GCD

/**
 Measures the average time needed to get into a dispatch_async block.
 */
- (void)testDispatchAsyncOnSerialQueue {
  // Arrange.
  XCTestExpectation *expectation = [self expectationWithDescription:@""];
  expectation.expectedFulfillmentCount = FBLPromisePerformanceTestIterationCount;
  dispatch_queue_t queue = dispatch_queue_create(
      __FUNCTION__,
      dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0));
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

  // Act.
  dispatch_async(dispatch_get_main_queue(), ^{
    uint64_t time = dispatch_benchmark(FBLPromisePerformanceTestIterationCount, ^{
      dispatch_async(queue, ^{
        dispatch_semaphore_signal(semaphore);
        [expectation fulfill];
      });
      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    FBLLogAverageTime(time);
  });

  // Assert.
  [self waitForExpectationsWithTimeout:10 handler:nil];
}

/**
 Measures the average time needed to get into a doubly nested dispatch_async block.
 */
- (void)testDoubleDispatchAsyncOnSerialQueue {
  // Arrange.
  XCTestExpectation *expectation = [self expectationWithDescription:@""];
  expectation.expectedFulfillmentCount = FBLPromisePerformanceTestIterationCount;
  dispatch_queue_t queue = dispatch_queue_create(
      __FUNCTION__,
      dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0));
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

  // Act.
  dispatch_async(dispatch_get_main_queue(), ^{
    uint64_t time = dispatch_benchmark(FBLPromisePerformanceTestIterationCount, ^{
      dispatch_async(queue, ^{
        dispatch_async(queue, ^{
          dispatch_semaphore_signal(semaphore);
          [expectation fulfill];
        });
      });
      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    FBLLogAverageTime(time);
  });

  // Assert.
  [self waitForExpectationsWithTimeout:10 handler:nil];
}

/**
 Measures the average time needed to get into a triply nested dispatch_async block.
 */
- (void)testTripleDispatchAsyncOnSerialQueue {
  // Arrange.
  XCTestExpectation *expectation = [self expectationWithDescription:@""];
  expectation.expectedFulfillmentCount = FBLPromisePerformanceTestIterationCount;
  dispatch_queue_t queue = dispatch_queue_create(
      __FUNCTION__,
      dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0));
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

  // Act.
  dispatch_async(dispatch_get_main_queue(), ^{
    uint64_t time = dispatch_benchmark(FBLPromisePerformanceTestIterationCount, ^{
      dispatch_async(queue, ^{
        dispatch_async(queue, ^{
          dispatch_async(queue, ^{
            dispatch_semaphore_signal(semaphore);
            [expectation fulfill];
          });
        });
      });
      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    FBLLogAverageTime(time);
  });

  // Assert.
  [self waitForExpectationsWithTimeout:10 handler:nil];
}

/**
 Measures the total time needed to perform a lot of dispatch_async blocks on a concurrent queue.
 */
- (void)testDispatchAsyncOnConcurrentQueue {
  // Arrange.
  dispatch_queue_t queue = dispatch_queue_create(
      __FUNCTION__, dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT,
                                                            QOS_CLASS_USER_INITIATED, 0));
  dispatch_group_t group = dispatch_group_create();
  NSMutableArray<dispatch_block_t> *blocks =
      [NSMutableArray arrayWithCapacity:FBLPromisePerformanceTestIterationCount];
  for (NSUInteger i = 0; i < FBLPromisePerformanceTestIterationCount; ++i) {
    dispatch_group_enter(group);
    void (^block)(void) = ^{
      dispatch_group_leave(group);
    };
    [blocks addObject:block];
  }
  NSDate *startDate = [NSDate date];

  // Act.
  for (NSUInteger i = 0; i < FBLPromisePerformanceTestIterationCount; ++i) {
    dispatch_async(queue, blocks[i]);
  }

  // Assert.
  XCTAssert(dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC)) == 0,
            @"Asynchronous wait failed: Exceeded timeout of 1 second.");
  NSDate *endDate = [NSDate date];
  FBLLogTotalTime([endDate timeIntervalSinceDate:startDate]);
}

#pragma mark FBLPromises

/**
 Measures the average time needed to create a resolved FBLPromise and get into a `then` block
 chained to it.
 */
- (void)testThenOnSerialQueue {
  // Arrange.
  XCTestExpectation *expectation = [self expectationWithDescription:@""];
  expectation.expectedFulfillmentCount = FBLPromisePerformanceTestIterationCount;
  dispatch_queue_t queue = dispatch_queue_create(
      __FUNCTION__,
      dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0));
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

  // Act.
  dispatch_async(dispatch_get_main_queue(), ^{
    uint64_t time = dispatch_benchmark(FBLPromisePerformanceTestIterationCount, ^{
      [[FBLPromise resolvedWith:@YES] onQueue:queue
                                         then:^id(id result) {
                                           dispatch_semaphore_signal(semaphore);
                                           [expectation fulfill];
                                           return result;
                                         }];
      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    FBLLogAverageTime(time);
  });

  // Assert.
  [self waitForExpectationsWithTimeout:10 handler:nil];
}

/**
 Measures the average time needed to create a resolved FBLPromise, chain two `then` blocks on it
 and get into the last `then` block.
 */
- (void)testDoubleThenOnSerialQueue {
  // Arrange.
  XCTestExpectation *expectation = [self expectationWithDescription:@""];
  expectation.expectedFulfillmentCount = FBLPromisePerformanceTestIterationCount;
  dispatch_queue_t queue = dispatch_queue_create(
      __FUNCTION__,
      dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0));
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

  // Act.
  dispatch_async(dispatch_get_main_queue(), ^{
    uint64_t time = dispatch_benchmark(FBLPromisePerformanceTestIterationCount, ^{
      [[[FBLPromise resolvedWith:@YES] onQueue:queue
                                          then:^id(id result) {
                                            return result;
                                          }] onQueue:queue
                                                then:^id(id result) {
                                                  dispatch_semaphore_signal(semaphore);
                                                  [expectation fulfill];
                                                  return result;
                                                }];
      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    FBLLogAverageTime(time);
  });

  // Assert.
  [self waitForExpectationsWithTimeout:10 handler:nil];
}

/**
 Measures the average time needed to create a resolved FBLPromise, chain three `then` blocks on it
 and get into the last `then` block.
 */
- (void)testTripleThenOnSerialQueue {
  // Arrange.
  XCTestExpectation *expectation = [self expectationWithDescription:@""];
  expectation.expectedFulfillmentCount = FBLPromisePerformanceTestIterationCount;
  dispatch_queue_t queue = dispatch_queue_create(
      __FUNCTION__,
      dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0));
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

  // Act.
  dispatch_async(dispatch_get_main_queue(), ^{
    uint64_t time = dispatch_benchmark(FBLPromisePerformanceTestIterationCount, ^{
      [[[[FBLPromise resolvedWith:@YES] onQueue:queue
                                           then:^id(id result) {
                                             return result;
                                           }] onQueue:queue
                                                 then:^id(id result) {
                                                   return result;
                                                 }] onQueue:queue
                                                       then:^id(id result) {
                                                         dispatch_semaphore_signal(semaphore);
                                                         [expectation fulfill];
                                                         return result;
                                                       }];
      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    FBLLogAverageTime(time);
  });

  // Assert.
  [self waitForExpectationsWithTimeout:10 handler:nil];
}

/**
 Measures the total time needed to resolve a lot of pending FBLPromise with chained `then` blocks
 on them on a concurrent queue and wait for each of them to get into chained block.
 */
- (void)testThenOnConcurrentQueue {
  // Arrange.
  dispatch_queue_t queue = dispatch_queue_create(
      __FUNCTION__, dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT,
                                                            QOS_CLASS_USER_INITIATED, 0));
  dispatch_group_t group = dispatch_group_create();
  NSMutableArray<FBLPromise *> *promises =
      [NSMutableArray arrayWithCapacity:FBLPromisePerformanceTestIterationCount];
  for (NSUInteger i = 0; i < FBLPromisePerformanceTestIterationCount; ++i) {
    dispatch_group_enter(group);
    FBLPromise *promise = [FBLPromise pendingPromise];
    [promise onQueue:queue
                then:^id(id result) {
                  dispatch_group_leave(group);
                  return result;
                }];
    [promises addObject:promise];
  }
  NSDate *startDate = [NSDate date];

  // Act.
  [promises makeObjectsPerformSelector:@selector(fulfill:) withObject:@YES];

  // Assert.
  XCTAssert(dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC)) == 0,
            @"Asynchronous wait failed: Exceeded timeout of 1 second.");
  NSDate *endDate = [NSDate date];
  FBLLogTotalTime([endDate timeIntervalSinceDate:startDate]);
}

@end
