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

#import <XCTest/XCTest.h>

#import "FBLPromise+Async.h"
#import "FBLPromise+Testing.h"
#import "FBLPromise+Then.h"
#import "FBLPromise+Wrap.h"
#import "FBLPromisesTestHelpers.h"

@interface FBLPromiseProgressTests : XCTestCase
@end

@implementation FBLPromiseProgressTests

- (void)testPromiseProgressCancel {
  // Arrange.
  FBLPromise *promise = [[FBLPromise
      progressUnits:10
              async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock reject,
                      NSProgress *progress) {
                NSURLSessionDataTask *task = [NSURLSession.sharedSession
                      dataTaskWithURL:[NSURL URLWithString:@"https://google.com"]
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                      if (error) {
                        reject(error);
                      } else {
                        fulfill(@[ data, response ]);
                      }
                    }];
                [progress addChild:task.progress withPendingUnitCount:progress.totalUnitCount];
                [task resume];
              }] progressUnits:10
                          then:^id(id value, NSProgress *progress) {
                            progress.completedUnitCount += 10;
                            return nil;
                          }];

  // Act.
  FBLDelay(5, ^{
    [promise cancel];
  });

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  NSLog(@"%@", promise);
}

@end
