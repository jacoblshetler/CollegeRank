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
-(void) setWeight:(int)weight
{
    self.weight = weight;
}
-(int) getWeight
{
    return self.weight;
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
