//
//  PreferenceManager.m
//  College Rank
//
//  Created by Philip Bontrager on 2/15/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "PreferenceManager.h"

@implementation PreferenceManager

+ (id)sharedInstance
{
        static PreferenceManager* instance = nil;
        if (instance == nil)
        {
            instance = [[self alloc] init];
        }
        return instance;
}



/*
-(id)init
{
    if (self = [super init])
    {
        NSLog(@"I'm the only one!");
    }
    return self;
}
 */
@end
