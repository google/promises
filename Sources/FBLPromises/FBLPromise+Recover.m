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

#import "FBLPromise+Recover.h"

#import "FBLPromisePrivate.h"

@implementation FBLPromise (RecoverAdditions)

- (FBLPromise *)recover:(nullable id (^)(NSError *))recovery {
  return [self onQueue:FBLPromise.defaultDispatchQueue recover:recovery];
}

- (FBLPromise *)onQueue:(dispatch_queue_t)queue recover:(nullable id (^)(NSError *))recovery {
  NSParameterAssert(queue);
  NSParameterAssert(recovery);

  return [self chainOnQueue:queue
             chainedFulfill:nil
              chainedReject:^id(NSError *error) {
                return recovery(error);
              }];
}

@end

@implementation FBLPromise (DotSyntax_RecoverAdditions)

- (FBLPromise * (^)(id __nullable (^)(NSError *)))recover {
  return ^(FBLPromise * (^recovery)(NSError *)) {
    return [self recover:recovery];
  };
}

- (FBLPromise * (^)(dispatch_queue_t, id __nullable (^)(NSError *)))recoverOn {
  return ^(dispatch_queue_t queue, id __nullable (^recovery)(NSError *)) {
    return [self onQueue:queue recover:recovery];
  };
}

@end
