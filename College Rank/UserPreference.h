//
//  UserPreference.h
//  College Rank
//
//  Created by Michael John Yoder on 3/17/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Preference;

@interface UserPreference : NSObject
{
    float weight;
    int preferredPrefValue;

}
@property (nonatomic, retain) Preference* pref;
@property bool locked;

//index of the preferred list value in the Preference

-(id) initWithPreference: (Preference*) preference andWeight: (float) wt;
-(id) initWithPreference: (Preference*) preference andWeight: (float) wt andPrefVal: (int) value;
-(id) initWithPreference:(Preference *)preference andPrefVal: (int) value;
-(void) setWeight:(float)wt;
-(void) changeLock;
-(bool) getLock;
-(float) getWeight;
-(int) getPrefVal;
-(void) setPrefVal: (int) prf;
-(NSString*) getName;
-(Preference*) getPref;

@end
