//
//  MissingDataViewController.h
//  College Rank
//
//  Created by Philip Bontrager on 4/5/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Preference;

@interface MissingDataViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
//Possibly add a poopup that explains this page's function.
//When user hit the "Next" button, give a pop-up warning saying that leaving data empty will skew the data.

//@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UITextView *header;
- (IBAction)pressedNext:(id) sender;
- (IBAction)canceled:(id) sender;

@property NSString* prefName;
@property NSArray* prefKeysInDictionary;
@property NSMutableArray* missingInstitutions;

@end