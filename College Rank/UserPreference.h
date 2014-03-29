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
    int weight;
    int preferredPrefValue;

}
@property (nonatomic, retain) Preference* pref;
@property bool locked;

//index of the preferred list value in the Preference

-(id) initWithPreference: (Preference*) preference andWeight: (int) wt;
-(void) setWeight:(int)wt;
-(void) changeLock;
-(bool) getLock;
-(int) getWeight;
-(int) getPrefVal;
-(void) setPrefVal: (int) prf;
-(NSString*) getName;
-(Preference*) getPref;

@end
