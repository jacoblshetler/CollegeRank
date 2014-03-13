//
//  InstitutionManager.m
//  College Rank
//
//  Created by Jacob Levi Shetler on 3/13/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "InstitutionManager.h"
#import "DataRetreiver.h"

@implementation InstitutionManager

+ (id)sharedInstance
{
    //TODO: set allInstitutions
    static InstitutionManager* instance = nil;
    if (instance == nil)
    {
        instance = [[self alloc] init];
    }
    return instance;
}

@end
