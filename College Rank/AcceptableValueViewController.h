//
//  AcceptableValueViewController.h
//  College Rank
//
//  Created by Michael John Yoder on 4/7/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Preference;
@interface AcceptableValueViewController : UIViewController<UIPickerViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@property (nonatomic, retain) Preference* pref;
@property (nonatomic, retain) IBOutlet UIButton* save;
@property (nonatomic, retain) IBOutlet UIButton* cancel;
@property (nonatomic, retain) IBOutlet UIButton* missingData;
@property (nonatomic, retain) IBOutlet UITextField* dumbField;
@property (nonatomic, retain) IBOutlet UINavigationItem* stupidBar;

@property NSString* prefName;



@end
