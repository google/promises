//
//  FBLPromise+ObserverTests.m
//  FBLPromisesInteroperabilityTests
//
//  Created by air on 2020/8/9.
//

#import <XCTest/XCTest.h>

#import "FBLPromise+Async.h"
#import "FBLPromise+Observer.h"
#import "FBLPromisesTestHelpers.h"

@interface FBLPromiseObserverTests : XCTestCase
@end

@implementation FBLPromiseObserverTests

- (void)testRegisterBlocks {
    FBLPromise<NSNumber *> *promise1 =
        [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
          FBLDelay(0.1, ^{
            fulfill(@42);
          });
        }];
    FBLPromise<NSString *> *promise2 =
    [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
      FBLDelay(0.5, ^{
        fulfill(@"Hello world!");
      });
    }];
    FBLPromise<NSString *> *promise3 =
        [FBLPromise async:^(FBLPromiseFulfillBlock __unused _, FBLPromiseRejectBlock reject) {
          FBLDelay(1, ^{
            reject([NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]);
          });
        }];
    
    
    FBLPromiseObserver *observer = [[FBLPromiseObserver alloc] init];
    promise1.addObserver(observer);
    promise2.addObserver(observer);
    promise3.addObserver(observer);
    
    // Receive all
    [observer registerSignalFulfill:^(id  _Nullable value) {
        XCTAssertNotNil(value);
    } reject:^(NSError * _Nonnull error) {
        XCTAssertEqual(error.code, 42);
    }];
    
    FBLDelay(2, ^{
        [observer unregister];
    });
}

@end
