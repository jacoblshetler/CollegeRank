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
@property NSMutableArray* choices;
@property NSMutableArray* translations;
@property UITextField* currentEditingTextField;
@property UIGestureRecognizer *tapper;
@property BOOL usingKeyboard;

@end

@implementation MissingDataViewController

@synthesize missingInstitutions;
@synthesize prefKeysInDictionary;
@synthesize prefName; //long name of the preference

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

-(BOOL) value:(NSString*)val EnteredByKeyboardIsOkayForPrefType:(NSString*)prefType{
    //TODO: use regular expressions, etc. to check the value the user typed in with the keyboard. Most will be checking to see if it is number.
    NSRegularExpression *regex;
    NSString* errorMsg;
    
    if ([prefType isEqualToString:@"location"]) {
        //TODO: must be a zip code
        
        //TODO: this can't really be rigorously "checked". Even if we do use the location finder. I think if they enter 5 digits, that's good enough
        //if they're dumb enough to enter a zip code that doesn't exist, then good for them!
        //Also see: http://stackoverflow.com/questions/578406/what-is-the-ultimate-postal-code-and-zip-regex/12453440#12453440
    }
    else if ([prefType isEqualToString:@"size"]) {
        //must be a positive number
        regex = [[NSRegularExpression alloc] initWithPattern:@"^[1-9]\\d*$" options:0 error:nil];
        errorMsg = @"Must be a postitive integer";
    }
    else if ([prefType isEqualToString:@"cost"]) {
        //must be positive number
        regex = [[NSRegularExpression alloc] initWithPattern:@"^[1-9]\\d*$" options:0 error:nil];
        errorMsg = @"Must be a postitive integer";
    }
    else if ([prefType isEqualToString:@"selectivity"]) {
        //must be between 0 and 100
        regex = [[NSRegularExpression alloc] initWithPattern:@"^(100)|(0*\\d{1,2})$" options:0 error:nil];
        errorMsg = @"Must be an integer between 0 and 100";
    }
    else if ([prefType isEqualToString:@"sat"]) {
        //must be between 0 and 1600
        regex = [[NSRegularExpression alloc] initWithPattern:@"(^1600$|^(1?[0-5]?|[0-9]?)[0-9]?[0-9]$)" options:0 error:nil];
        errorMsg = @"Must be an integer between 0 and 1600";
    }
    else if ([prefType isEqualToString:@"studentFacultyRatio"]) {
        //must be a postitive number
        regex = [[NSRegularExpression alloc] initWithPattern:@"^[1-9]\\d*$" options:0 error:nil];
        errorMsg = @"Must be a postitive integer";
    }
    else if ([prefType isEqualToString:@"femaleRatio"]) {
        //must be between 0 and 100
        regex = [[NSRegularExpression alloc] initWithPattern:@"^(100)|(0*\\d{1,2})$" options:0 error:nil];
        errorMsg = @"Must be an integer between 0 and 100";
    }
    
    int numMatches = [regex numberOfMatchesInString:val options:0 range:NSMakeRange(0, [val length])];
    return numMatches==1;
}

#pragma mark - Picker Wheel Functions

-(void) setInputType:(NSString*)prefType{
    //Set type to pickerWheel or keyboard
    NSArray* useKeyboard = @[@"location",@"size",@"cost",@"selectivity",@"sat",@"studentFacultyRatio",@"femaleRatio"];
    
    if ([useKeyboard containsObject:prefType]) {
        //keep keyboard. aka don't make any changes.
        for (UITextField* text in _arrayOfTextFields){
            text.inputView = nil;
        }
        _usingKeyboard = true;
        return;
    }
    _usingKeyboard = false;
    
    //if we're not using the keyboard, then we need to set up a pickerWheel to do input.
    //First read in the options for the picker from the missingDataOptions plist
    NSString *values = [[NSBundle mainBundle] pathForResource: @"missingDataOptions" ofType: @"plist"];
    NSDictionary *valuesDict = [[NSDictionary alloc] initWithContentsOfFile:values];
    NSArray* prefChoicesAndTranslations = [valuesDict objectForKey:prefType];
    
    _choices = [[NSMutableArray alloc] init];
    _translations = [[NSMutableArray alloc] init];
    for (NSArray* curArr in prefChoicesAndTranslations) {
        [_choices addObject:[curArr objectAtIndex:0]];
        [_translations addObject:[curArr objectAtIndex:1]];
    }
    
    NSLog(@"Choices: %@",_choices);
    NSLog(@"Translations: %@",_translations);
    
    //use the choices array to set up the picker
    UIPickerView* picker = [[UIPickerView alloc]init];
    [picker setDataSource:self];
    [picker setDelegate:self];
    [picker setShowsSelectionIndicator:YES];
    
    for (UITextField* text in _arrayOfTextFields){
        text.inputView = picker;
    }

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //handle selecting a row
    NSString* selection = [_choices objectAtIndex:row];
    NSLog(@"Choice made: %@",selection);
    _currentEditingTextField.text = selection;
    
    //make the picker disappear
    [_currentEditingTextField resignFirstResponder];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 200;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_choices objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_choices count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    _currentEditingTextField = textField;
}

- (IBAction)selection:(id)sender {
    NSLog(@"HERE");
    [self resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view resignFirstResponder];
}

#pragma mark - View Events

- (void)viewDidLoad
{
    [super viewDidLoad];
    _arrayOfTextFields = [[NSMutableArray alloc] init];
    //get the name of the type of preference
    NSString *values = [[NSBundle mainBundle] pathForResource: @"AcceptableValues" ofType: @"plist"];
    NSDictionary *valuesDict = [[NSDictionary alloc] initWithContentsOfFile:values];
    NSString *prefDecoded = [[valuesDict valueForKeyPath:prefName] objectAtIndex:0];
    
    //set each text field's delegate to self and show all of the ones we need to
    //also set the placeholder text for each of the inputs that we show
    int counter = 0;
    for (UITextField *text in [self.view subviews]) {
        if(text.tag ==1){
            text.delegate = self;
            
            if (counter<[missingInstitutions count]) {
#warning can't test the prepping of text fields until we get the edit functionality working.
                [_arrayOfTextFields addObject:text];
                text.hidden = false;
                //set placeholder and text
                text.placeholder = [NSString stringWithFormat:@"%@",missingInstitutions[counter]];
                SEL s = NSSelectorFromString(prefDecoded);
                NSString* prepText = [[[InstitutionManager sharedInstance] getUserInstitutionForString:missingInstitutions[counter]] performSelector:s];
                if (!([prepText isEqual:[NSNull null]] || [[NSString stringWithFormat:@"%@",prepText] isEqual:@"<null>"])) {
                    //Then we need to set the text of the text field to what was in the Institution class
                    text.text = prepText;
                }
                counter++;
            }
            else{
                text.hidden = true;
            }
        }
    }
    
    //set the header
    self.header.text = [NSString stringWithFormat:@"Enter missing data for '%@'",prefName];
    
    //set the input type based on the preference type
    prefDecoded = @"religiousAffiliation"; //uncomment to see picker wheel
    [self setInputType:prefDecoded];
    //set the keys to update later
    [self translatePrefTypeToKeys:[[valuesDict valueForKeyPath:prefName] objectAtIndex:0]];
    
    //set up the gesture recognizer. this dismisses keyboard when they click away from the text field
    _tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    _tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tapper];
}

//dismiss keyboard when clicking on the background
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}


//Makes keyboard disappear whenever user hits the "Done" button in bottom-right.
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
    /*
    Update all keys in the Institution from what the user generated and what keys were passed in
     */
    InstitutionManager* institutionManager = [InstitutionManager sharedInstance];
    for (int i=0; i<[missingInstitutions count]; i++){
        //get ahold of the Institutions in the InstitutionManager that need to change and change them
        Institution* curInst = [institutionManager getUserInstitutionForString:[missingInstitutions objectAtIndex:i]];
        for (NSString* curKey in prefKeysInDictionary) {
            NSString* updateString = [[NSString alloc] init];
            
            //if using the keyboard, then just put in whatever they typed in
            UITextField* curText = [_arrayOfTextFields objectAtIndex:i];
            updateString = curText.text;
            //if we're using a picker and need to translate what's in the text field
            if (!_usingKeyboard) {
                updateString = [_translations objectAtIndex:[_choices indexOfObject:updateString]];
            }
            
            //update the value
            [curInst setValue:updateString ForKeyInDataDictionary:curKey];
        }
    }
    
    /*
     Segue to the Choose An Acceptable Value view controller once we have saved the data.
     */
    AcceptableValueViewController* userPrefView = [self.storyboard instantiateViewControllerWithIdentifier:@"UserPrefsView"];
    userPrefView.prefName = prefName;
    userPrefView.institutionsMissingData = missingInstitutions;
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
