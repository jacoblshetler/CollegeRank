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
        zipCode = [[NSString alloc]init];
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
        zipCode = [[NSString alloc]init];
        self.locked = false;
        preferredPrefValue = value;
        return self;
    }
    return nil;
}

-(id) initWithPreference:(Preference *)preference andPrefVal: (int) value
{
    self = [super init];
    if (self)
    {
        self.pref = preference;
        self.locked = false;
        zipCode = [[NSString alloc]init];
        preferredPrefValue = value;
        return self;
    }
    return nil;
}

-(id) initWithPreference:(Preference *)preference andPrefVal: (int) value andMissingData: (NSMutableArray*) instData
{
    self = [super init];
    if (self)
    {
        self.missingInstData = instData;
        self.pref = preference;
        self.locked = false;
        zipCode = [[NSString alloc]init];
        preferredPrefValue = value;
        return self;
    }
    return nil;
}

-(id) initWithPreference:(Preference *)preference andPrefVal: (int) value andMissingData: (NSMutableArray*) instData andZipCode: (NSString*) zipcode
{
    self = [super init];
    if (self)
    {
        self.missingInstData = instData;
        self.pref = preference;
        self.locked = false;
        zipCode = [[NSString alloc]initWithString:zipcode];
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

-(NSString*) getZipCode{
    return zipCode;
}
-(void) setZipCode:(NSString*)newZip{
    self->zipCode = newZip;
}

-(void) setMissingInstData:(NSMutableArray *)missingInstData
{
    _missingInstData = missingInstData;
}

-(NSMutableArray*) getMissingInstData
{
    return self.missingInstData;
}

#pragma mark - Serialization Code
//get ready for serialization
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeFloat:weight forKey:@"weight"];
    [coder encodeInt:preferredPrefValue forKey:@"value"];
    [coder encodeObject:self.pref forKey:@"pref"];
    [coder encodeObject:self.missingInstData forKey:@"missing"];
    [coder encodeBool:self.locked forKey:@"locked"];
}

//init with serialized data
- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        weight = [coder decodeFloatForKey:@"weight"];
        preferredPrefValue = [coder decodeIntForKey:@"value"];
        self.pref = [coder decodeObjectForKey:@"pref"];
        self.missingInstData = [coder decodeObjectForKey:@"missing"];
        self.locked = [coder decodeBoolForKey:@"locked"];
    }
    return self;
}

@end
