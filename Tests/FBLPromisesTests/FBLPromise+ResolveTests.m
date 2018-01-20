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

#import "FBLPromise+Resolve.h"

#import <XCTest/XCTest.h>

#import "FBLPromise+Catch.h"
#import "FBLPromise+Testing.h"
#import "FBLPromise+Then.h"
#import "FBLPromisesTestHelpers.h"

@interface FBLPromiseResolveTests : XCTestCase
@end

@implementation FBLPromiseResolveTests

- (void)testPromiseResolveWithVoidCompletionFulfillsWithNilValue {
  // Act.
  FBLPromise *promise = [FBLPromise resolveWhenCompleted:^(FBLPromiseCompletion completion) {
    FBLDelay(0.1, ^{
      [self resolverHarnessWithCompletionHandler:completion];
    });
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertTrue(promise.isFulfilled);
  XCTAssertNil(promise.value);
  XCTAssertNil(promise.error);
}

- (void)testPromiseResolveWithObjectCompletionFulfillsOnValueReturned {
  // Act.
  FBLPromise<NSNumber *> *promise =
      [FBLPromise resolveWithObjectWhenCompleted:^(FBLPromiseObjectCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithObject:@42 completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseResolveWithObjectCompletionFulfillsWithNilValue {
  // Act.
  FBLPromise<NSNumber *> *promise =
      [FBLPromise resolveWithObjectWhenCompleted:^(FBLPromiseObjectCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithObject:nil completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertTrue(promise.isFulfilled);
  XCTAssertNil(promise.value);
  XCTAssertNil(promise.error);
}

- (void)testPromiseResolveWithErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise =
      [FBLPromise resolveWithErrorWhenCompleted:^(FBLPromiseErrorCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithError:error completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseResolveWithErrorCompletionFulfillsWithNilValue {
  // Act.
  FBLPromise<NSNumber *> *promise =
      [FBLPromise resolveWithErrorWhenCompleted:^(FBLPromiseErrorCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithError:nil completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertTrue(promise.isFulfilled);
  XCTAssertNil(promise.value);
  XCTAssertNil(promise.error);
}

- (void)testPromiseResolveWithObjectOrErrorCompletionFulfillsOnValueReturned {
  // Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise
      resolveWithObjectOrErrorWhenCompleted:^(FBLPromiseObjectOrErrorCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithObject:@42 error:nil completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseResolveWithErrorOrObjectCompletionFulfillsOnValueReturned {
  // Arrange.
  XCTestExpectation *expectation = [self expectationWithDescription:@""];

  // Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise
      resolveWithErrorOrObjectWhenCompleted:^(FBLPromiseErrorOrObjectCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithError:nil object:@42 completionHandler:completion];
          [expectation fulfill];
        });
      }];

  // Assert.
  [self waitForExpectationsWithTimeout:10 handler:nil];
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseResolveWithObjectOrErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise
      resolveWithObjectOrErrorWhenCompleted:^(FBLPromiseObjectOrErrorCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithObject:nil error:error completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseResolveWithErrorOrObjectCompletionRejectsOnErrorReturned {
  // Arrange.
  XCTestExpectation *expectation = [self expectationWithDescription:@""];
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise
      resolveWithErrorOrObjectWhenCompleted:^(FBLPromiseErrorOrObjectCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithError:error object:nil completionHandler:completion];
          [expectation fulfill];
        });
      }];

  // Assert.
  [self waitForExpectationsWithTimeout:10 handler:nil];
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseResolveWithObjectOrErrorCompletionRejectsOnValueAndErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise
      resolveWithObjectOrErrorWhenCompleted:^(FBLPromiseObjectOrErrorCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithObject:@42 error:error completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseResolveWithErrorOrObjectCompletionRejectsOnValueAndErrorReturned {
  // Arrange.
  XCTestExpectation *expectation = [self expectationWithDescription:@""];
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise
      resolveWithErrorOrObjectWhenCompleted:^(FBLPromiseErrorOrObjectCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithError:error object:@42 completionHandler:completion];
          [expectation fulfill];
        });
      }];

  // Assert.
  [self waitForExpectationsWithTimeout:10 handler:nil];
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseResolveWith2ObjectsOrErrorCompletionFulfillsOnValueReturned {
  // Arrange.
  NSArray<NSNumber *> *expectedValues = @[ @42, @13 ];

  // Act.
  FBLPromise<NSArray *> *promise = [FBLPromise
      resolveWith2ObjectsOrErrorWhenCompleted:^(FBLPromise2ObjectsOrErrorCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithObject:@42 object:@13 error:nil completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, expectedValues);
  XCTAssertNil(promise.error);
}

- (void)testPromiseResolveWith2ObjectsOrErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSArray *> *promise = [FBLPromise
      resolveWith2ObjectsOrErrorWhenCompleted:^(FBLPromise2ObjectsOrErrorCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithObject:nil object:nil error:error completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseResolveWith2ObjectsOrErrorCompletionRejectsOnValueAndErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSArray *> *promise = [FBLPromise
      resolveWith2ObjectsOrErrorWhenCompleted:^(FBLPromise2ObjectsOrErrorCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithObject:@42 object:@13 error:error completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseResolveWithBoolOrErrorCompletionFulfillsOnValueReturned {
  // Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise
      resolveWithBoolOrErrorWhenCompleted:^(FBLPromiseBoolOrErrorCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithBool:YES error:nil completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @YES);
  XCTAssertNil(promise.error);
}

- (void)testPromiseResolveWithBoolOrErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise
      resolveWithBoolOrErrorWhenCompleted:^(FBLPromiseBoolOrErrorCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithBool:YES error:error completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseResolveWithBoolCompletionFulfillsOnValueReturned {
  // Act.
  FBLPromise<NSNumber *> *promise =
      [FBLPromise resolveWithBoolWhenCompleted:^(FBLPromiseBoolCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithBool:YES completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @YES);
  XCTAssertNil(promise.error);
}

- (void)testPromiseResolveWithIntegerOrErrorCompletionFulfillsOnValueReturned {
  // Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise
      resolveWithIntegerOrErrorWhenCompleted:^(FBLPromiseIntegerOrErrorCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithInteger:42 error:nil completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseResolveWithIntegerOrErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise
      resolveWithIntegerOrErrorWhenCompleted:^(FBLPromiseIntegerOrErrorCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithInteger:42 error:error completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseResolveWithIntegerCompletionFulfillsOnValueReturned {
  // Act.
  FBLPromise<NSNumber *> *promise =
      [FBLPromise resolveWithIntegerWhenCompleted:^(FBLPromiseIntegerCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithInteger:42 completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseResolveWithDoubleOrErrorCompletionFulfillsOnValueReturned {
  // Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise
      resolveWithDoubleOrErrorWhenCompleted:^(FBLPromiseDoubleOrErrorCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithDouble:42.0 error:nil completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42.0);
  XCTAssertNil(promise.error);
}

- (void)testPromiseResolveWithDoubleOrErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise
      resolveWithDoubleOrErrorWhenCompleted:^(FBLPromiseDoubleOrErrorCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithDouble:42.0 error:error completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseResolveWithDoubleCompletionFulfillsOnValueReturned {
  // Act.
  FBLPromise<NSNumber *> *promise =
      [FBLPromise resolveWithDoubleWhenCompleted:^(FBLPromiseDoubleCompletion completion) {
        FBLDelay(0.1, ^{
          [self resolverHarnessWithDouble:42.0 completionHandler:completion];
        });
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42.0);
  XCTAssertNil(promise.error);
}

#pragma mark - Private

- (void)resolverHarnessWithCompletionHandler:(FBLPromiseCompletion)completionHandler {
  completionHandler();
}

- (void)resolverHarnessWithObject:(id __nullable)value
                completionHandler:(FBLPromiseObjectCompletion)completionHandler {
  completionHandler(value);
}

- (void)resolverHarnessWithError:(NSError *__nullable)error
               completionHandler:(FBLPromiseErrorCompletion)completionHandler {
  completionHandler(error);
}

- (void)resolverHarnessWithObject:(id __nullable)value
                            error:(NSError *__nullable)error
                completionHandler:(FBLPromiseObjectOrErrorCompletion)completionHandler {
  completionHandler(value, error);
}

- (void)resolverHarnessWithError:(NSError *__nullable)error
                          object:(id __nullable)value
               completionHandler:(FBLPromiseErrorOrObjectCompletion)completionHandler {
  completionHandler(error, value);
}

- (void)resolverHarnessWithObject:(id __nullable)value1
                           object:(id __nullable)value2
                            error:(NSError *__nullable)error
                completionHandler:(FBLPromise2ObjectsOrErrorCompletion)completionHandler {
  completionHandler(value1, value2, error);
}

- (void)resolverHarnessWithBool:(BOOL)value
                          error:(NSError *__nullable)error
              completionHandler:(FBLPromiseBoolOrErrorCompletion)completionHandler {
  completionHandler(value, error);
}

- (void)resolverHarnessWithBool:(BOOL)value
              completionHandler:(FBLPromiseBoolCompletion)completionHandler {
  completionHandler(value);
}

- (void)resolverHarnessWithInteger:(NSInteger)value
                             error:(NSError *__nullable)error
                 completionHandler:(FBLPromiseIntegerOrErrorCompletion)completionHandler {
  completionHandler(value, error);
}

- (void)resolverHarnessWithInteger:(NSInteger)value
                 completionHandler:(FBLPromiseIntegerCompletion)completionHandler {
  completionHandler(value);
}

- (void)resolverHarnessWithDouble:(double)value
                            error:(NSError *__nullable)error
                completionHandler:(FBLPromiseDoubleOrErrorCompletion)completionHandler {
  completionHandler(value, error);
}

- (void)resolverHarnessWithDouble:(double)value
                completionHandler:(FBLPromiseDoubleCompletion)completionHandler {
  completionHandler(value);
}

@end
