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


@end
