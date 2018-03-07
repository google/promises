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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Executes the given work block asynchronously after time interval.
 */
static inline void FBLDelay(NSTimeInterval interval, void (^work)(void)) {
  int64_t const timeToWait = (int64_t)(interval * NSEC_PER_SEC);
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeToWait),
                 dispatch_get_main_queue(), ^{
                   work();
                 });
}

/**
 Executes the given block multiple times according to the count variable and then returns
 the average number of nanoseconds per execution. Isn't listed in any public libdispatch header,
 although comes with a man page, so declaring manually here.
 */
FOUNDATION_EXTERN uint64_t dispatch_benchmark(size_t count, void (^block)(void));

NS_ASSUME_NONNULL_END
