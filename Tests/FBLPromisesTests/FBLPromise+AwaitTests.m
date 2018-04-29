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

#import "FBLPromise+Await.h"

#import <XCTest/XCTest.h>

#import "FBLPromise+Async.h"
#import "FBLPromise+Do.h"
#import "FBLPromise+Catch.h"
#import "FBLPromise+Testing.h"
#import "FBLPromise+Then.h"
#import "FBLPromisesTestHelpers.h"

@interface FBLPromiseAwaitTests : XCTestCase
@end

@implementation FBLPromiseAwaitTests

- (void)testPromiseAwaitFulfill {
  // Arrange & Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise
      onQueue:dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT)
           do:^id {
             NSError *error;
             NSNumber *minusFive = FBLPromiseAwait([self awaitHarnessNegate:@5], &error);
             if (error) {
               return error;
             }
             XCTAssertEqualObjects(minusFive, @-5);
             NSNumber *twentyFive =
                 FBLPromiseAwait([self awaitHarnessMultiply:minusFive by:minusFive], &error);
             if (error) {
               return error;
             }
             XCTAssertEqualObjects(twentyFive, @25);
             NSNumber *twenty =
                 FBLPromiseAwait([self awaitHarnessAdd:twentyFive to:minusFive], &error);
             if (error) {
               return error;
             }
             XCTAssertEqualObjects(twenty, @20);
             NSNumber *five =
                 FBLPromiseAwait([self awaitHarnessSubtract:twentyFive from:twenty], &error);
             if (error) {
               return error;
             }
             XCTAssertEqualObjects(five, @5);
             NSNumber *zero = FBLPromiseAwait([self awaitHarnessAdd:minusFive to:five], &error);
             if (error) {
               return error;
             }
             XCTAssertEqualObjects(zero, @0);
             NSNumber *result = FBLPromiseAwait([self awaitHarnessMultiply:zero by:five], &error);
             if (error) {
               return error;
             }
             return result;
           }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @0);
  XCTAssertNil(promise.error);
}

- (void)testPromiseAwaitReject {
  // Arrange
  NSError *expectedError = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise =
      [FBLPromise onQueue:dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT)
                       do:^id {
                         NSError *error;
                         id value = FBLPromiseAwait([self awaitHarnessFail:expectedError], &error);
                         XCTAssertNil(value);
                         XCTAssertEqualObjects(error.domain, FBLPromiseErrorDomain);
                         XCTAssertEqual(error.code, 42);
                         return value ?: error;
                       }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertNil(promise.value);
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
}

#pragma mark - Private

- (FBLPromise<NSNumber *> *)awaitHarnessNegate:(NSNumber *)number {
  return [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
    FBLDelay(0.1, ^{
      fulfill(@(-number.integerValue));
    });
  }];
}

- (FBLPromise<NSNumber *> *)awaitHarnessAdd:(NSNumber *)number to:(NSNumber *)number2 {
  return [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
    FBLDelay(0.1, ^{
      fulfill(@(number.integerValue + number2.integerValue));
    });
  }];
}

- (FBLPromise<NSNumber *> *)awaitHarnessSubtract:(NSNumber *)number from:(NSNumber *)number2 {
  return [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
    FBLDelay(0.1, ^{
      fulfill(@(number.integerValue - number2.integerValue));
    });
  }];
}

- (FBLPromise<NSNumber *> *)awaitHarnessMultiply:(NSNumber *)number by:(NSNumber *)number2 {
  return [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
    FBLDelay(0.1, ^{
      fulfill(@(number.integerValue * number2.integerValue));
    });
  }];
}

- (FBLPromise<NSNumber *> *)awaitHarnessFail:(NSError *)error {
  return [FBLPromise async:^(FBLPromiseFulfillBlock __unused _, FBLPromiseRejectBlock reject) {
    FBLDelay(0.1, ^{
      reject(error);
    });
  }];
}

@end
