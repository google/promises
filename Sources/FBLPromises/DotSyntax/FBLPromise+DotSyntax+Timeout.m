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

#import "DotSyntax/FBLPromise+DotSyntax+Timeout.h"

@implementation FBLPromise (DotSyntax_TimeoutAdditions)

- (FBLPromise* (^)(NSTimeInterval))timeout {
  return ^(NSTimeInterval interval) {
    return [self timeout:interval];
  };
}

- (FBLPromise* (^)(dispatch_queue_t, NSTimeInterval))timeoutOn {
  return ^(dispatch_queue_t queue, NSTimeInterval interval) {
    return [self onQueue:queue timeout:interval];
  };
}

@end
