//
//  Institution.h
//  College Rank
//
//  Created by Philip Bontrager on 3/11/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Institution : NSObject

-(id)initWithName: (NSString *) InstitutionName;

@property   NSString* name;  	//Will use synthesize
@property   NSDictionary* data;	//dictionary of all preference data related to the institution

//These functions are used to grab data out of the dataDictionary and return it
- (NSString*) location;
- (NSString*) type;
- (NSArray*) urbanization;
- (NSString*) religiousAffiliation;
- (BOOL) studyAbroad;
- (BOOL) dayCare;
- (BOOL) football;
- (BOOL) basketball;
- (BOOL) baseball;
- (BOOL) xCountryAndTrack;
- (NSString*) degree;
- (NSString*) size;
- (NSString*) cost: (NSString*) type;
- (NSString*) selectivity;
- (NSString*) sat;
- (NSArray*) demographics;
- (NSNumber*) studentFacultyRatio;

@end

