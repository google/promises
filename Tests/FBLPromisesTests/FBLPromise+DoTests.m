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

- (void)testPromiseDoReturnPromise {
  // Arrange & Act.
  FBLPromise<NSNumber *> *promise = [FBLPromise do:^id {
    return [FBLPromise resolvedWith:@42];
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

/**
 Promise created with `do` should not deallocate until it gets resolved.
 */
- (void)testPromiseDoNoDeallocUntilFulfilled {
  // Arrange.
  FBLPromise __weak *weakPromise1;
  FBLPromise __weak *weakPromise2;

  // Act.
  @autoreleasepool {
    XCTAssertNil(weakPromise1);
    XCTAssertNil(weakPromise2);
    weakPromise1 = [FBLPromise do:^{
      return @42;
    }];
    weakPromise2 = [FBLPromise do:^{
      return @42;
    }];
    XCTAssertNotNil(weakPromise1);
    XCTAssertNotNil(weakPromise2);
  }

  // Assert.
  XCTAssertNotNil(weakPromise1);
  XCTAssertNotNil(weakPromise2);
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertNil(weakPromise1);
  XCTAssertNil(weakPromise2);
}

@end
