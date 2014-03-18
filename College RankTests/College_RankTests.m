//
//  College_RankTests.m
//  College RankTests
//
//  Created by Jacob Levi Shetler on 2/13/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Institution.h"
#import "InstitutionManager.h"
#import "DataRetreiver.h"

@interface College_RankTests : XCTestCase

@end

@implementation College_RankTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testSomeShit
{
    NSMutableArray *all = GetInstitutions();
    XCTAssertEqual((int)[all count], 4904, @"Count these bitches.");
    
    for (NSString* curName in all){
        [[InstitutionManager sharedInstance] addInstitution:curName];
        Institution* curInst = [[InstitutionManager sharedInstance] getUserInstitutionForString:curName];
        //first make sure names are the same
        XCTAssertEqual(curInst.name, curName, @"Name mismatch");
        
        //check each data point to make sure it is set correctly
        NSMutableArray* curPrefsFromInterwebs = GetPreferences([[NSArray alloc] initWithObjects:curName, nil]);
        
        XCTAssertEqual([curInst location], [curPrefsFromInterwebs[0] valueForKey:@"zip_code"], @"Zip Code mismatch");
    }
}

@end
