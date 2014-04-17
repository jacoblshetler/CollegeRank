//
//  UserPreference.h
//  College Rank
//
//  Created by Michael John Yoder on 3/17/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Preference;

@interface UserPreference : NSObject <NSCoding>
{
    float weight;
    int preferredPrefValue;
    NSString* zipCode; //the user's zip code
}
@property (nonatomic, retain) Preference* pref;
@property (nonatomic, retain) NSMutableArray* missingInstData;
@property bool locked;

//index of the preferred list value in the Preference

-(id) initWithPreference: (Preference*) preference andWeight: (float) wt;
-(id) initWithPreference: (Preference*) preference andWeight: (float) wt andPrefVal: (int) value;
-(id) initWithPreference:(Preference *)preference andPrefVal: (int) value;
-(id) initWithPreference:(Preference *)preference andPrefVal: (int) value andMissingData: (NSMutableArray*) instData;

-(void) setWeight:(float)wt;
-(void) changeLock;
-(bool) getLock;
-(float) getWeight;
-(int) getPrefVal;
-(void) setPrefVal: (int) prf;
-(NSString*) getName;
-(Preference*) getPref;
-(NSString*) getZipCode;
-(void) setZipCode;

-(void) setMissingInstData:(NSMutableArray *)missingInstData;
-(NSMutableArray*) getMissingInstData;

@end
