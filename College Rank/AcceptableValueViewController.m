//
//  AcceptableValueViewController.m
//  College Rank
//
//  Created by Michael John Yoder on 4/7/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "AcceptableValueViewController.h"
#import "Preference.h"
#import "UserPreference.h"
#import "InstitutionManager.h"
#import "PreferenceManager.h"
/* NOTE:
    When seguing to this view controller, we need to set pref to whatever preference we want to be operating on.  We had to 
    do this in one of the homeworks.
 */


@interface AcceptableValueViewController ()

@property PreferenceManager* preferences;
@property InstitutionManager* institutions;

@property int pickerSelection;
@property bool isNull;
@end

@implementation AcceptableValueViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.institutions = [InstitutionManager sharedInstance];
    self.preferences = [PreferenceManager sharedInstance];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //for testing
    self.pref = [self.preferences getPreferenceAtIndex:0];
    
    
    if(self.pref.getValues == nil)
    {
        //load in the selector bar
        self.isNull = true;
    }
    else{
        //load in the picker
        
        UIPickerView* pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, 320, 200)];
        pickerView.delegate = self;
        pickerView.showsSelectionIndicator = YES;
        [self.view addSubview:pickerView];
        self.isNull = false;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    self.pickerSelection = row;
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[self.pref getValues] count];
    }

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    title = [NSString stringWithFormat:@"%@", [self.pref getAcceptableValue:row]];
    
    return title;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
