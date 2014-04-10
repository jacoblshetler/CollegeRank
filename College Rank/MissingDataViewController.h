//
//  MissingDataViewController.h
//  College Rank
//
//  Created by Philip Bontrager on 4/5/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Preference;

@interface MissingDataViewController : UIViewController
//Possibly add a poopup that explains this page's function.
//When user hit the "Next" button, give a pop-up warning saying that leaving data empty will skew the data.

@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UITextField *firstCell; //TODO: do we need to have these references here? Or are they worthless?
@property (weak, nonatomic) IBOutlet UITextField *secondCell;
- (IBAction)pressedNext:(id)sender;

@property Preference* pref;
@property NSMutableArray* prefKeysInDictionary;
@property NSMutableArray* missingInstitutions;

@end