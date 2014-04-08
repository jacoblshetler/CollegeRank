//
//  AcceptableValueViewController.h
//  College Rank
//
//  Created by Michael John Yoder on 4/7/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Preference;
@interface AcceptableValueViewController : UIViewController<UIPickerViewDelegate>
@property (nonatomic, retain) Preference* pref;

@end
