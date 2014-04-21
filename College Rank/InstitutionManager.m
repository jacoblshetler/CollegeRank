//
//  InstitutionManager.m
//  College Rank
//
//  Created by Jacob Levi Shetler on 3/13/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "InstitutionManager.h"
#import "DataRetreiver.h"
#import "Institution.h"

@implementation InstitutionManager

@synthesize allInstitutions;
@synthesize userInstitutions;

- (id) init{
    //set allInstitutions
    if (self = [super init]){
        NSMutableArray *myArrI = GetInstitutions();
        allInstitutions = [[NSArray alloc] initWithArray:myArrI copyItems:TRUE];
        userInstitutions = [NSMutableArray new];
    }
    return self;
}

+ (id)sharedInstance
{
    static InstitutionManager* instance = nil;
    if (instance == nil)
    {
        instance = [[self alloc] init];
    }
    return instance;
}

//Initializes and adds an Institution to the userInstitutions
- (void) addInstitution: (NSString *) newInstitutionName{
    Institution* newInst = [[Institution alloc] initWithName:newInstitutionName];
    [userInstitutions addObject:newInst];
}


//Removes an institution with the specified name from the userInstitutions.
- (void) removeInstitution: (NSString *) institutionName{
    Institution* deleteInst = nil;
    for (Institution* curInst in userInstitutions){
        if ([curInst.name caseInsensitiveCompare:institutionName]==NSOrderedSame) {
            deleteInst = curInst;
        }
    }
    if (deleteInst!= nil) {
        [userInstitutions removeObject:deleteInst];
    }
}


//Used to see if the institutions have enough data to navigate away from the first screen
- (BOOL) canGoToPreferences{
    return (userInstitutions.count > 1);
}


//Searches the list of all institutions for the specified query. Returns all results that contain the query
- (NSArray *) searchInstitutions: (NSString *)query{
    NSMutableArray* containsQuery = [NSMutableArray array];
    
    for (NSString* item in allInstitutions)
    {
        if ([item rangeOfString:query].location != NSNotFound)
            [containsQuery addObject:item];
    }
    
    return containsQuery;
}

-(Institution*) getUserInstitutionForString: (NSString*) name{
    for(Institution* inst in self.userInstitutions)
    {
        if([inst.name caseInsensitiveCompare:name] == NSOrderedSame)
        {
            return inst;
        }
    }
    return nil;

}

#warning Need to test this
-(NSMutableArray*) getValuesForPreference: (NSString*) pref
{
    NSMutableArray* tempArr = [NSMutableArray new];
    for (Institution* curInst in userInstitutions)
    {
        SEL s = NSSelectorFromString(pref);
        [tempArr addObject:[curInst performSelector:s]];
    }
    return tempArr;
}

-(NSMutableArray*) getUserInstitutionNames
{
    NSMutableArray* tempArr = [NSMutableArray new];
    for (Institution* curInst in userInstitutions)
    {
        [tempArr addObject:curInst.name];
    }
    return tempArr;
}

- (NSMutableArray*) getMissingDataInstitutionsForPreference: (NSString*) prefName{
    NSMutableArray* dataArr = [self getValuesForPreference:prefName];
    NSMutableArray* instNames = [self getUserInstitutionNames];
    NSMutableArray* missingDataArr = [[NSMutableArray alloc] init];
    for (int i =0; i<[dataArr count]; i++) {
        id obj = [dataArr objectAtIndex:i];
        if ([obj isEqual:[NSNull null]] || [[NSString stringWithFormat:@"%@",obj] isEqual:@"<null>"] || [[NSString stringWithFormat:@"%@",obj] isEqual:@""]){
            [missingDataArr addObject:[ instNames objectAtIndex:i]];
        }
    }
    
    return missingDataArr;
}

-(NSMutableArray*) getAllUserInstitutions
{
    return self.userInstitutions;
}

//<<<<<<< HEAD
#pragma mark - Serialization Code
//get ready for serialization
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.allInstitutions forKey:@"all"];
    [coder encodeObject:self.userInstitutions forKey:@"user"];
}

//init with serialized data
- (id)initWithCoder:(NSCoder *)coder {
    self = [InstitutionManager sharedInstance];
    if (self) {
        self.allInstitutions = [coder decodeObjectForKey:@"all"];
        self.userInstitutions = [coder decodeObjectForKey:@"user"];
    }
    return self;
}
//=======
-(NSMutableArray*) getCustomValuesForPreference: (NSString*) pref
{
    NSMutableArray* tempArr = [NSMutableArray new];
    for (Institution* curInst in userInstitutions)
    {
        [tempArr addObject:[curInst customValueForKey:pref]];
    }
    return tempArr;
    
}

//>>>>>>> 4d1f9348c13d4900b9b561db7b108901c7ffa583

@end