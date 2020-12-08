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

#import "FBLPromise+Wrap.h"

#import <XCTest/XCTest.h>

#import "FBLPromise+Catch.h"
#import "FBLPromise+Testing.h"
#import "FBLPromise+Then.h"
#import "FBLPromisesTestHelpers.h"

@interface FBLPromiseWrapTests : XCTestCase
@end

@implementation FBLPromiseWrapTests

- (void)testPromiseWrapVoidCompletionFulfillsWithNilValue {
  // Act.
  FBLPromise *promise = [FBLPromise wrapCompletion:^(FBLPromiseCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithCompletion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertTrue(promise.isFulfilled);
  XCTAssertNil(promise.value);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapObjectCompletionFulfillsOnValueReturned {
  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapObjectCompletion:^(FBLPromiseObjectCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithObject:@42 completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapObjectCompletionFulfillsWithNilValue {
  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapObjectCompletion:^(FBLPromiseObjectCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithObject:nil completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertTrue(promise.isFulfilled);
  XCTAssertNil(promise.value);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapErrorCompletion:^(FBLPromiseErrorCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithError:error completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrapErrorCompletionFulfillsWithNilValue {
  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapErrorCompletion:^(FBLPromiseErrorCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithError:nil completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertTrue(promise.isFulfilled);
  XCTAssertNil(promise.value);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapObjectOrErrorCompletionFulfillsOnValueReturned {
  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapObjectOrErrorCompletion:^(FBLPromiseObjectOrErrorCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithObject:@42 error:nil completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapErrorOrObjectCompletionFulfillsOnValueReturned {
  // Arrange.
  XCTestExpectation *expectation = [self expectationWithDescription:@""];

  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapErrorOrObjectCompletion:^(FBLPromiseErrorOrObjectCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithError:nil object:@42 completion:handler];
      [expectation fulfill];
    });
  }];

  // Assert.
  [self waitForExpectationsWithTimeout:10 handler:nil];
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapObjectOrErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapObjectOrErrorCompletion:^(FBLPromiseObjectOrErrorCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithObject:nil error:error completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrapErrorOrObjectCompletionRejectsOnErrorReturned {
  // Arrange.
  XCTestExpectation *expectation = [self expectationWithDescription:@""];
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapErrorOrObjectCompletion:^(FBLPromiseErrorOrObjectCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithError:error object:nil completion:handler];
      [expectation fulfill];
    });
  }];

  // Assert.
  [self waitForExpectationsWithTimeout:10 handler:nil];
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrapObjectOrErrorCompletionRejectsOnValueAndErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapObjectOrErrorCompletion:^(FBLPromiseObjectOrErrorCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithObject:@42 error:error completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrapErrorOrObjectCompletionRejectsOnValueAndErrorReturned {
  // Arrange.
  XCTestExpectation *expectation = [self expectationWithDescription:@""];
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapErrorOrObjectCompletion:^(FBLPromiseErrorOrObjectCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithError:error object:@42 completion:handler];
      [expectation fulfill];
    });
  }];

  // Assert.
  [self waitForExpectationsWithTimeout:10 handler:nil];
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrap2ObjectsOrErrorCompletionFulfillsOnValueReturned {
  // Arrange.
  NSArray *expectedValues = @[ @42, [NSNull null] ];

  // Act.
  FBLPromise<NSArray *> *promise =
  [FBLPromise wrap2ObjectsOrErrorCompletion:^(FBLPromise2ObjectsOrErrorCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithObject:@42 object:nil error:nil completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, expectedValues);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrap2ObjectsOrErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSArray *> *promise =
  [FBLPromise wrap2ObjectsOrErrorCompletion:^(FBLPromise2ObjectsOrErrorCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithObject:nil object:nil error:error completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrap2ObjectsOrErrorCompletionRejectsOnValueAndErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSArray *> *promise =
  [FBLPromise wrap2ObjectsOrErrorCompletion:^(FBLPromise2ObjectsOrErrorCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithObject:@42 object:@13 error:error completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrapBoolOrErrorCompletionFulfillsOnValueReturned {
  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapBoolOrErrorCompletion:^(FBLPromiseBoolOrErrorCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithBool:YES error:nil completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @YES);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapBoolOrErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapBoolOrErrorCompletion:^(FBLPromiseBoolOrErrorCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithBool:YES error:error completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrapBoolCompletionFulfillsOnValueReturned {
  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapBoolCompletion:^(FBLPromiseBoolCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithBool:YES completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @YES);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapIntegerOrErrorCompletionFulfillsOnValueReturned {
  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapIntegerOrErrorCompletion:^(FBLPromiseIntegerOrErrorCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithInteger:42 error:nil completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapIntegerOrErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapIntegerOrErrorCompletion:^(FBLPromiseIntegerOrErrorCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithInteger:42 error:error completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrapIntegerCompletionFulfillsOnValueReturned {
  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapIntegerCompletion:^(FBLPromiseIntegerCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithInteger:42 completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapDoubleOrErrorCompletionFulfillsOnValueReturned {
  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapDoubleOrErrorCompletion:^(FBLPromiseDoubleOrErrorCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithDouble:42.0 error:nil completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42.0);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapDoubleOrErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapDoubleOrErrorCompletion:^(FBLPromiseDoubleOrErrorCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithDouble:42.0 error:error completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrapDoubleCompletionFulfillsOnValueReturned {
  // Act.
  FBLPromise<NSNumber *> *promise =
  [FBLPromise wrapDoubleCompletion:^(FBLPromiseDoubleCompletion handler) {
    FBLDelay(0.1, ^{
      [self wrapHarnessWithDouble:42.0 completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42.0);
  XCTAssertNil(promise.error);
}

#pragma mark - Private

- (void)wrapHarnessWithCompletion:(FBLPromiseCompletion)handler {
  handler();
}

- (void)wrapHarnessWithObject:(id __nullable)value completion:(FBLPromiseObjectCompletion)handler {
  handler(value);
}

- (void)wrapHarnessWithError:(NSError *__nullable)error
                  completion:(FBLPromiseErrorCompletion)handler {
  handler(error);
}

- (void)wrapHarnessWithObject:(id __nullable)value
                        error:(NSError *__nullable)error
                   completion:(FBLPromiseObjectOrErrorCompletion)handler {
  handler(value, error);
}

- (void)wrapHarnessWithError:(NSError *__nullable)error
                      object:(id __nullable)value
                  completion:(FBLPromiseErrorOrObjectCompletion)handler {
  handler(error, value);
}

- (void)wrapHarnessWithObject:(id __nullable)value1
                       object:(id __nullable)value2
                        error:(NSError *__nullable)error
                   completion:(FBLPromise2ObjectsOrErrorCompletion)handler {
  handler(value1, value2, error);
}

- (void)wrapHarnessWithBool:(BOOL)value
                      error:(NSError *__nullable)error
                 completion:(FBLPromiseBoolOrErrorCompletion)handler {
  handler(value, error);
}

- (void)wrapHarnessWithBool:(BOOL)value completion:(FBLPromiseBoolCompletion)handler {
  handler(value);
}

- (void)wrapHarnessWithInteger:(NSInteger)value
                         error:(NSError *__nullable)error
                    completion:(FBLPromiseIntegerOrErrorCompletion)handler {
  handler(value, error);
}

- (void)wrapHarnessWithInteger:(NSInteger)value completion:(FBLPromiseIntegerCompletion)handler {
  handler(value);
}

- (void)wrapHarnessWithDouble:(double)value
                        error:(NSError *__nullable)error
                   completion:(FBLPromiseDoubleOrErrorCompletion)handler {
  handler(value, error);
}

- (void)wrapHarnessWithDouble:(double)value completion:(FBLPromiseDoubleCompletion)handler {
  handler(value);
}

@end
