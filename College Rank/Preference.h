//
//  Preference.h
//  College Rank
//
//  Created by Michael John Yoder on 3/17/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preference : NSObject <NSCoding>
@property (nonatomic, retain) NSString* name;

//this will take the form of a list of values that
//the user can pick, which will represent the "best"
//value for them (e.g. near, far, high, low)
@property (nonatomic, retain) NSArray* acceptableValues;

-(id) initWithName: (NSString*) newName andAcceptableValues: (NSArray*) values;
-(NSString*) getAcceptableValue: (int) index;
-(NSString*) getName;
-(NSArray*) getValues;

@end
