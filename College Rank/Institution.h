//
//  Institution.h
//  College Rank
//
//  Created by Philip Bontrager on 3/11/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Institution : NSObject <NSCoding>

-(id)initWithName: (NSString *) InstitutionName;

@property   NSString* name;  	//Will use synthesize
@property   CLLocation* geoCoordinates; //location of the institution. Gets created when added to the list of userInstitutions.
@property   NSMutableDictionary* data;	//dictionary of all preference data related to the institution
@property   NSMutableDictionary* customData; //dictionary to hold custom data key/value pairs

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

-(void) setValue: (NSString*) val ForKeyInDataDictionary: (NSString*) key;


- (NSString*) customValueForKey: (NSString*) key;
- (void) setValue: (NSString*) val ForKeyInCustomDictionary: (NSString*) key;
- (void) deleteKeyValuePairForKey: (NSString*) key;

@end

