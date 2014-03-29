//
//  UserPreference.m
//  College Rank
//
//  Created by Michael John Yoder on 3/17/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "UserPreference.h"
#import "Preference.h"

@implementation UserPreference

//@synthesize weight;

-(id) initWithPreference: (Preference*) preference andWeight: (int) wt
{
    self = [super init];
    if (self)
    {
        self.pref = preference;
        self.weight = wt;
        self.locked = false;
        return self;
    }
    return nil;
}

-(void) setWeight:(int)wt
{
    self.weight = wt;
}
-(int) getWeight
{
    return weight;
}


-(void) changeLock
{
    self.locked = !self.locked;
}
-(bool) getLock
{
    return self.locked;
}

-(NSString*) getName
{
    return self.pref.name;
}

-(Preference*) getPref
{
    return self.pref;
}

@end
