//
//  MASStorageTests.m
//  MASStorageTests
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <MASStorage/MASStorage.h>
#import <MASFoundation/MASFoundation.h>

@interface MASStorageTests : XCTestCase

@end

@implementation MASStorageTests

/**
 *  Initial Setup to be used during tests
 *  NOTE: A copy of the msso_config.json file must be copied into the xcode bundle in order to run [MAS start]
 */
- (void)setUp
{
    [super setUp];
}


/**
 *  TearDown any object
 */
- (void)tearDown
{
    [super tearDown];
}


/**
 *  Performance sample test
 */
- (void)PerformanceExample
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


//#pragma mark - CRUD methods
//
///**
// *  Test the SaveToLocalStorageUsingKey method
// */
//- (void)testSaveToLocalStorageUsingKey
//{
//    //
//    //Enables the LocalStorage. Creates the database if it doesn't exist yet.
//    //
//    [MAS enableLocalStorage];
//
//    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"asynchronous request"];
//
//    //This can be any object that comes from NSObject
//    NSArray *myArray = @[@"Luis",@"Sanches"];
//    
//    [MASSecureStorage saveToLocalStorageObject:myArray withKey:@"Key02" andTag:@"myTag" completion:^(BOOL success, NSError *error) {
//        
//        NSLog(@"The result was: %@",[NSNumber numberWithBool:success]);
//        
//        XCTAssertTrue(success, @"Pass");
//
//        [expectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:10.0 handler:nil];
//}
//
//
///**
// *  Test the GetFromLocalStorageUsingKey method
// */
//- (void)testGetFromLocalStorageUsingKey
//{
//    //
//    //Enables the LocalStorage. Creates the database if it doesn't exist yet.
//    //
//    [MAS enableLocalStorage];
//
//    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"asynchronous request"];
//    
//    //This can be any object that comes from NSObject
//    NSArray *myArray = @[@"Luis",@"Sanches"];
//    
//    [MASSecureStorage saveToLocalStorageObject:myArray withKey:@"Key02" andTag:@"myTag" completion:^(BOOL success, NSError *error) {
//        
//        XCTAssertTrue(success, @"Pass");
//        
//        [MASSecureStorage getObjectFromLocalStorageUsingKey:@"Key02" completion:^(NSObject *object, NSString *tag, NSError *error) {
//
//            XCTAssertTrue(object, @"Pass");
//
//            XCTAssertTrue(tag, @"Pass");
//
//            [expectation fulfill];
//
//            [MASSecureStorage deleteObjectFromLocalStorageUsingKey:@"Key02" completion:^(BOOL success, NSError *error) {
//
//                NSLog(@"Deleted Objected = %d", success);
//            }];
//        }];
//    }];
//    
//    [self waitForExpectationsWithTimeout:10.0 handler:nil];
//}
//
//
///**
// *  Test the DeleteFromLocalStorageUsingKey method
// */
//- (void)testDeleteFromLocalStorageUsingKey
//{
//    //
//    //Enables the LocalStorage. Creates the database if it doesn't exist yet.
//    //
//    [MAS enableLocalStorage];
//
//    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"asynchronous request"];
//    
//    //This can be any object that comes from NSObject
//    NSArray *myArray = @[@"Luis",@"Sanches"];
//    
//    [MASSecureStorage saveToLocalStorageObject:myArray withKey:@"Key03" andTag:@"myTag" completion:^(BOOL success, NSError *error) {
//        
//        XCTAssertTrue(success, @"Pass");
//
//        [MASSecureStorage deleteObjectFromLocalStorageUsingKey:@"Key03" completion:^(BOOL success, NSError *error) {
//            
//            XCTAssertTrue(success, @"Pass");
//            
//            [expectation fulfill];
//            
//        }];
//    }];
//    
//    [self waitForExpectationsWithTimeout:10.0 handler:nil];
//}
//
@end
