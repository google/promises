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

#import "FBLPromise+Catch.h"

#import <XCTest/XCTest.h>

#import "FBLPromise+Testing.h"
#import "FBLPromisesTestHelpers.h"

@import PromisesTestHelpers;

@interface FBLPromiseCatchInteroperabilityTests : XCTestCase
@end

@implementation FBLPromiseCatchInteroperabilityTests

- (void)testPromiseReject {
  // Arrange.
  NSError *expectedError = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise *promise = [FBLPromisesTestInteroperabilitySwift
      reject:[NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]
       delay:0.1];
  [promise catch:^(NSError *error) {
    XCTAssertEqual(error.code, 42);
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, expectedError);
  XCTAssertNil(promise.value);
}

- (void)testPromiseThrow {
  // Arrange.
  NSError *expectedError = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FBLPromise *promise = [FBLPromisesTestInteroperabilitySwift
      throw:[NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]
      delay:0.1];
  [promise catch:^(NSError *error) {
    XCTAssertEqual(error.code, 42);
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, expectedError);
  XCTAssertNil(promise.value);
}

@end
