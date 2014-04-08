//
//  MissingDataViewController.h
//  College Rank
//
//  Created by Philip Bontrager on 4/5/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MissingDataViewController : UIViewController
//Possibly add a poopup that explains this page's function.
//When user hit the "Next" button, give a pop-up warning saying that leaving data empty will skew the data.

@property IBOutlet UILabel* test;
@property (weak, nonatomic) IBOutlet UITextField *firstCell;

@property NSString* prefName;
@property NSMutableArray* missingInstitutions;

@end