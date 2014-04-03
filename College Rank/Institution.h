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
@property   NSMutableDictionary* data;	//dictionary of all preference data related to the institution

//These functions are used to grab data out of the dataDictionary and return it
- (NSString*) location;
- (NSString*) type;
- (NSArray*) urbanization;
- (NSString*) religiousAffiliation;
- (NSString*) studyAbroad;
- (NSString*) dayCare;
- (NSString*) football;
- (NSString*) basketball;
- (NSString*) baseball;
- (NSString*) xCountryAndTrack;
- (NSString*) degree;
- (NSString*) size;
- (NSString*) cost;
- (NSString*) selectivity;
- (NSString*) sat;
- (NSDictionary*) demographics;
- (NSNumber*) studentFacultyRatio;
- (NSString*) femaleRatio;

@end

