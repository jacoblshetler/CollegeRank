//
//  MissingDataViewController.m
//  College Rank
//
//  Created by Philip Bontrager on 4/5/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "MissingDataViewController.h"
#import "AcceptableValueViewController.h"
#import "Preference.h"
#import "Institution.h"
#import "InstitutionManager.h"

@interface MissingDataViewController ()

@property NSMutableArray* arrayOfTextFields;

@end

@implementation MissingDataViewController

@synthesize missingInstitutions;
@synthesize prefKeysInDictionary;
@synthesize prefName; //name of the preference that we need to create

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) translatePrefTypeToKeys:(NSString*)prefType{
    NSString *values = [[NSBundle mainBundle] pathForResource: @"nameToDataKeys" ofType: @"plist"];
    NSDictionary *valuesDict = [[NSDictionary alloc] initWithContentsOfFile:values];
    
    prefKeysInDictionary = [valuesDict objectForKey:prefType];
}

-(void) setInputType:(NSString*)prefType{
    //set type to pickerWheel or keyboard
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _arrayOfTextFields = [[NSMutableArray alloc] init];
    //set each text field's delegate to self and show all of the ones we need to
    //also set the placeholder text for each of the inputs that we show
    int counter = 0;
    for (UITextField *text in [self.view subviews]) {
        if(text.tag ==1){
            text.delegate = self;
            
            if (counter<[missingInstitutions count]) {
                [_arrayOfTextFields addObject:text];
                text.hidden = false;
                text.placeholder = [NSString stringWithFormat:@"%@",missingInstitutions[counter]];
                counter++;
            }
            else{
                text.hidden = true;
            }
        }
    }
    
    //set the header
    self.header.text = [NSString stringWithFormat:@"Enter missing data for '%@'",prefName];
    
    //set the type of input based on the pref we're passed in
    NSString *values = [[NSBundle mainBundle] pathForResource: @"AcceptableValues" ofType: @"plist"];
    NSDictionary *valuesDict = [[NSDictionary alloc] initWithContentsOfFile:values];
    [self setInputType:[[valuesDict valueForKeyPath:prefName] objectAtIndex:0]];
    //set the keys to update later
    [self translatePrefTypeToKeys:[[valuesDict valueForKeyPath:prefName] objectAtIndex:0]];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self saveDataAndSegue];
    }
}

- (void) saveDataAndSegue{
    //do that stuff
    NSLog(@"Save Data and Segue!!");
    
    /*
    Update all keys in the Institution from what the user generated and what keys were passed in
     */
    InstitutionManager* institutionManager = [InstitutionManager sharedInstance];
    for (int i=0; i<[missingInstitutions count]; i++){
        //get ahold of the Institutions in the InstitutionManager that need to change and change them
        Institution* curInst = [institutionManager getUserInstitutionForString:[missingInstitutions objectAtIndex:i]];
        for (NSString* curKey in prefKeysInDictionary) {
            //change each key
            UITextField* curText = [_arrayOfTextFields objectAtIndex:i];
            [curInst setValue:curText.text  ForKeyInDataDictionary:curKey];
        }
        NSLog(@"%@",curInst.data);
    }
    
    /*
     Segue to the Choose An Acceptable Value view controller once we have saved the data.
     */
    AcceptableValueViewController* userPrefView = [self.storyboard instantiateViewControllerWithIdentifier:@"UserPrefsView"];
    userPrefView.prefName = prefName;
    [self presentViewController:userPrefView animated:YES completion:nil];
}

- (IBAction)pressedNext:(id)sender {
    //Check to see if all entries all filled.
    bool allFilled = true;
    for (UITextField *text in _arrayOfTextFields) {
        if(text.tag ==1){
            if([text.text isEqualToString:@""]) allFilled = false;
        }
    }
    
    if (!allFilled){
        //show warning to say that they need to enter all data. Then stop
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Data" message:@"You are still missing data. Continuing will skew end results. Are you sure you want to continue?" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:@"Go Back", nil];
        [alert show];
    }
    else{
        [self saveDataAndSegue];
    }
}

- (IBAction)canceled:(id)sender
{
    UITabBarController* back = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarView"];
    [self presentViewController:back animated:YES completion:nil];
    [back setSelectedIndex:1];
}
@end
