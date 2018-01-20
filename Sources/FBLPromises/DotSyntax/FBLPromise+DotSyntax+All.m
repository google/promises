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

#import "DotSyntax/FBLPromise+DotSyntax+All.h"

@implementation FBLPromise (DotSyntax_AllAdditions)

+ (FBLPromise<NSArray *> * (^)(NSArray *))all {
  return ^(NSArray<FBLPromise *> *promises) {
    return [self all:promises];
  };
}

+ (FBLPromise<NSArray *> * (^)(dispatch_queue_t, NSArray *))allOn {
  return ^(dispatch_queue_t queue, NSArray<FBLPromise *> *promises) {
    return [self onQueue:queue all:promises];
  };
}

@end
