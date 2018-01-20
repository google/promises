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

#import "FBLPromise+Testing.h"
#import "FBLPromisesTestHelpers.h"
#import "PromisesTestHelpers-Swift.h"

@interface FBLPromiseThenInteroperabilityTests : XCTestCase
@end

@implementation FBLPromiseThenInteroperabilityTests

- (void)testPromiseFulfillNumberNil {
  // Act.
  FBLPromise<NSNumber *> *promise =
      [FBLPromisesTestInteroperabilitySwift fulfillWithNumber:nil delay:0.1];
  [promise then:^id(NSNumber *value) {
    XCTAssertNil(value);
    return value;
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertNil(promise.value);
  XCTAssertNil(promise.error);
}

- (void)testPromiseFulfillNumberNonNil {
  // Act.
  FBLPromise<NSNumber *> *promise =
      [FBLPromisesTestInteroperabilitySwift fulfillWithNumber:@42 delay:0.1];
  [promise then:^id(NSNumber *value) {
    XCTAssertEqualObjects(value, @42);
    return value;
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

@end
