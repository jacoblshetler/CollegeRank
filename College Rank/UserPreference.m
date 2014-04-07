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


-(id) initWithPreference: (Preference*) preference andWeight: (float) wt
{
    self = [super init];
    if (self)
    {
        self.pref = preference;
        weight = wt;
        self.locked = false;
        return self;
    }
    return nil;
}

-(id) initWithPreference: (Preference*) preference andWeight: (float) wt andPrefVal: (int) value
{
    self = [super init];
    if (self)
    {
        self.pref = preference;
        weight = wt;
        self.locked = false;
        preferredPrefValue = value;
        return self;
    }
    return nil;
}

-(void) setWeight:(float)wt
{
    self->weight = wt;
}
-(float) getWeight
{
    return weight;
}


-(void) changeLock
{
    self->_locked = !self.locked;
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

-(int) getPrefVal
{
    return preferredPrefValue;
}


-(void) setPrefVal: (int) prf
{
    preferredPrefValue = prf;
}

@end
