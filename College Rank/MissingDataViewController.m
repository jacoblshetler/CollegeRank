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

@interface MissingDataViewController ()

@end

@implementation MissingDataViewController

@synthesize missingInstitutions;
@synthesize pref; //actual preference to create
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

- (void)putInSomeSampleData{
    NSArray *sampleDataArr = @[@"Goshen College, 46526",@"Bluffton University",@"Eastern Mennonite University",@"Goshen College, 46526",@"Bluffton University",@"Eastern Mennonite University",@"Goshen College, 46526",@"Bluffton University",@"Eastern Mennonite University",@"Goshen College, 46526"];
    missingInstitutions = [[NSMutableArray alloc] initWithArray:sampleDataArr copyItems:true];
    pref = [[Preference alloc] initWithName:@"Student to Faculty Ratio" andAcceptableValues:@[@"Choice1",@"Choice2"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self putInSomeSampleData];
    
    //set each text field's delegate to self and show all of the ones we need to
    //also set the placeholder text for each of the inputs that we show
    int counter = 0;
    for (UITextField *text in [self.view subviews]) {
        if(text.tag ==1){
            text.delegate = self;
            
            if (counter<[missingInstitutions count]) {
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
    self.header.text = [NSString stringWithFormat:@"Enter missing data for '%@'",[pref getName]];
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
    for (int i=0; i<[prefKeysInDictionary count]; i++) {
        //update
        //TODO: do I need to update the Institutions directly in the Institution Manager? Or do I just pass the data along to the next view controller? What problems will this create when this view is called from the Preference tab without going on to the ChooseAnAcceptableValue?
        //PHILIP - When the user hits NEXT add the data to the institutions, that way if the user presses cancel nothing happens. The only thing that gets passed on the next view is the name of the preference.
    }
    
    
    /*
     Segue to the Choose An Acceptable Value view controller once we have saved the data.
     */
    AcceptableValueViewController* userPrefView = [self.storyboard instantiateViewControllerWithIdentifier:@"UserPrefsView"];
    [userPrefView setPref:pref];
    [self presentViewController:userPrefView animated:YES completion:nil];
}

- (IBAction)pressedNext:(id)sender {
    //Check to see if all entries all filled.
    bool allFilled = true;
    for (UITextField *text in [self.view subviews]) {
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
