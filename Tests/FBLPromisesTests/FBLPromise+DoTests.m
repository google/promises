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

#import "FBLPromise+Do.h"
#import "FBLPromise+Testing.h"
#import "FBLPromisesTestHelpers.h"

@interface FBLPromiseDoTests : XCTestCase
@end

@implementation FBLPromiseDoTests

- (void)testPromiseDoFulfill {
  // Arrange & Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise do:^id {
    return @42;
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseDoReject {
  // Arrange & Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise do:^id {
    return [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
  XCTAssertNil(promise.value);
}

- (void)testPromiseDoThrow {
  // Arrange & Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise do:^id {
    @throw [NSException exceptionWithName:@"name" reason:@"reason" userInfo:nil];  // NOLINT
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, FBLPromiseErrorCodeException);
  XCTAssertEqualObjects(promise.error.userInfo[FBLPromiseErrorUserInfoExceptionNameKey], @"name");
  XCTAssertEqualObjects(promise.error.userInfo[FBLPromiseErrorUserInfoExceptionReasonKey],
                        @"reason");
}

/**
 Promise created with `do` should not deallocate until it gets resolved.
 */
- (void)testPromiseDoNoDeallocUntilFulfilled {
  // Arrange.
  FBLPromise __weak *weakExtendedPromise1;
  FBLPromise __weak *weakExtendedPromise2;

  // Act.
  @autoreleasepool {
    XCTAssertNil(weakExtendedPromise1);
    XCTAssertNil(weakExtendedPromise2);
    FBLPromise *promise1 = [FBLPromise do:^{
      return @42;
    }];
    FBLPromise *promise2 = [FBLPromise do:^{
      return @42;
    }];
    FBLPromise *extendedPromise1 = promise1;
    FBLPromise *extendedPromise2 = promise2;
    weakExtendedPromise1 = extendedPromise1;
    weakExtendedPromise2 = extendedPromise2;
    XCTAssertNotNil(weakExtendedPromise1);
    XCTAssertNotNil(weakExtendedPromise2);
  }

  // Assert.
  XCTAssertNotNil(weakExtendedPromise1);
  XCTAssertNotNil(weakExtendedPromise2);
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertNil(weakExtendedPromise1);
  XCTAssertNil(weakExtendedPromise2);
}

@end
