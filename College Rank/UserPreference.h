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
@property (nonatomic, retain) Preference* pref;
@property int weight;
@property bool locked;

//index of the preferred list value in the Preference
@property int preferredPrefValue;

-(id) initWithPreference: (Preference*) preference andWeight: (int) wt;
-(void) setWeight:(int)weight;
-(void) changeLock;
-(bool) getLock;
-(int) getWeight;
-(NSString*) getName;
-(Preference*) getPref;

@end
