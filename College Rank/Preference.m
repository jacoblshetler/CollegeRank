//
//  Preference.m
//  College Rank
//
//  Created by Michael John Yoder on 3/17/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "Preference.h"

@implementation Preference

-(id) initWithName: (NSString*) newName andAcceptableValues: (NSArray*) values
{
    self = [super init];
    if(self){
        self.acceptableValues = values;
        self.name = newName;
        return self;
    }
    return nil;
}

-(NSString*) getAcceptableValue:(int)index
{
    return [self.acceptableValues objectAtIndex:index];
}

-(NSString*) getName
{
    return self.name;
}
-(NSArray*) getValues
{
    return self.acceptableValues;
}

#pragma mark - Serialization Code
//get ready for serialization
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.acceptableValues forKey:@"values"];
}

//init with serialized data
- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.acceptableValues = [coder decodeObjectForKey:@"values"];
    }
    return self;
}


@end
