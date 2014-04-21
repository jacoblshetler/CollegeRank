//
//  AcceptableValueViewController.m
//  College Rank
//
//  Created by Michael John Yoder on 4/7/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "AcceptableValueViewController.h"
#import "Preference.h"
#import "Institution.h"
#import "UserPreference.h"
#import "InstitutionManager.h"
#import "PreferenceManager.h"
#import "MissingDataViewController.h"
#import "Calculations.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
/* NOTE:
    When seguing to this view controller, we need to set pref to whatever preference we want to be operating on.  We had to 
    do this in one of the homeworks.
 */


@interface AcceptableValueViewController ()

@property PreferenceManager* preferences;
@property InstitutionManager* institutions;

@property int pickerSelection;
@property bool isNull;

@property int lineX;
@property int topLineY;
@property int lineHeight;
@property int markerHeight;
@property int markerWidth;
@property NSMutableArray* colorArr;
@property BOOL usingKeyboard;
@property bool isDistancePref;
@property UIGestureRecognizer* tapper;
@property (nonatomic, retain) IBOutlet UILabel* descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel* customLabel;
@property (nonatomic, retain) IBOutlet UITextField* zipLabel;

@end

@implementation AcceptableValueViewController

@synthesize prefName;

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
    
    self.dumbField.delegate = self;
    
    //set the dimensions for the custom line
    self.lineX = self.view.bounds.size.width * .9;
    self.topLineY = self.view.bounds.size.height/4;
    self.lineHeight = self.view.bounds.size.height*.55;
    self.markerHeight = 30;
    self.markerWidth = 150;
    
    //get the colors for the college markers
    self.colorArr = [[NSMutableArray alloc] init];
    NSString* colorFile = [[NSBundle mainBundle] pathForResource: @"Colors" ofType: @"plist"];
    NSArray* colorRGB = [[NSArray alloc] initWithContentsOfFile:colorFile];
    CGFloat r, g, b;
    for (NSArray* rgb in colorRGB) {
        r = [[rgb objectAtIndex:0] floatValue]/255;
        g = [[rgb objectAtIndex:1] floatValue]/255;
        b = [[rgb objectAtIndex:2] floatValue]/255;
        [self.colorArr addObject:[UIColor colorWithRed:r green:g blue:b alpha:1.0]];
    }
    
    //create the gesture recognizer for closing the keyboard
    _tapper = [[UITapGestureRecognizer alloc]
               initWithTarget:self action:@selector(handleSingleTap:)];
    _tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tapper];

    self.institutions = [InstitutionManager sharedInstance];
    self.preferences = [PreferenceManager sharedInstance];
    
    //set the title of the nav bar to the pref name
    self.stupidBar.title = self.prefName;
    
    
    /*Add the buttons at the bottom*/
    //missing data (if data is missing)
    
    //set the custom pref name to the preference name passed in
    self.dumbField.text = self.prefName;
    
    //get the preference from the name passed in
    self.pref = [self.preferences getPreferenceForString:self.prefName];
    
    //get the "short names" from the plist
    NSString *values = [[NSBundle mainBundle] pathForResource: @"AcceptableValues" ofType: @"plist"];
    NSDictionary *valuesDict = [[NSDictionary alloc] initWithContentsOfFile:values];
    NSString *prefDecoded = [[valuesDict valueForKeyPath:self.prefName] objectAtIndex:0];
    
    //if the preference is location, then set the string as the zip code
    //otherwise, hide the zip code text bar field
    if([[self.pref getName] isEqualToString:@"Location"])
    {
        self.isDistancePref = true;
        self.zipLabel.text = [self.preferences zipCode];
    }
    else{
        self.isDistancePref = false;
        self.zipLabel.hidden = true;
    }
    
    //hide the missing data button if there's no missing data
    if([[self.preferences missingInstitutionsForPreferenceShortNameDictionary] objectForKey:prefDecoded] == nil)
    {
        self.missingData.hidden = YES;
    }
    
    //create the graphics if it's a custom preference
    if(self.pref.acceptableValues == nil)
    {
        //load in the selector bar
        self.isNull = true;
        
        //add the line to snap to
        //with labels
        UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.lineX - self.markerHeight/2, self.topLineY - 20, 30, 20)];
        topLabel.text = @"Best";
        topLabel.adjustsFontSizeToFitWidth = YES;
        
        UILabel *worstLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.lineX - self.markerHeight/2, self.topLineY + self.lineHeight, 30, 20)];
        worstLabel.text = @"Worst";
        worstLabel.adjustsFontSizeToFitWidth = YES;
        
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(self.lineX, self.topLineY, 5, self.lineHeight)];
        lineView.backgroundColor = [UIColor blackColor];
        lineView.layer.cornerRadius = 5.0;
        lineView.layer.masksToBounds = YES;
        [self.view addSubview:lineView];
        [self.view addSubview:topLabel];
        [self.view addSubview:worstLabel];
        //add the markers
        int height = self.view.bounds.size.height/5;
        int i = 1;
        
        //create the markers for the institutions
        for(Institution *inst in [self.institutions getAllUserInstitutions])
        {
            CGRect boundingBox = CGRectMake(5, height, self.markerWidth, self.markerHeight);
            UIImage* basePoint = [UIImage imageNamed:@"pointer1.png"];
            UIImage* pointer = [self colorizeImage:basePoint color:[self.colorArr objectAtIndex:i-1]];
            UIImageView* imgView = [[UIImageView alloc] initWithFrame:boundingBox];
            UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.markerWidth - 10, self.markerHeight)];
            textLabel.text = [inst name];
            textLabel.adjustsFontSizeToFitWidth = YES;
            imgView.userInteractionEnabled=YES;
            UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(handlePanGestures:)];
            pan.maximumNumberOfTouches = 1;
            pan.minimumNumberOfTouches = 1;
            [imgView addGestureRecognizer:pan];
            [imgView setImage:pointer];
            [imgView addSubview:textLabel];
            
            //if the preference already exists, add the markers at the appropriate locations
            if([inst customValueForKey:[self.pref getName]] != nil && ![[inst customValueForKey:[self.pref getName]] isEqualToString:@"<null>"])
            {
                imgView.center = CGPointMake(self.lineX - self.markerWidth/2, self.topLineY + [[inst customValueForKey:self.prefName] integerValue]);
            }
            
            imgView.tag = i;
            [self.view addSubview:imgView];
            self.descriptionLabel.hidden = YES;
            height += self.markerHeight + 5;
            i++;
            
        }
    }
    else{
        //load in the picker
        self.customLabel.hidden = YES;
        NSString *values = [[NSBundle mainBundle] pathForResource: @"Description" ofType: @"plist"];
        NSDictionary *valuesDict = [[NSDictionary alloc] initWithContentsOfFile:values];
        self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
        self.descriptionLabel.text = [[valuesDict valueForKeyPath:self.prefName] objectAtIndex:0];
        self.dumbField.hidden = YES;
        UIPickerView* pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, 320, 200)];
        pickerView.delegate = self;
        pickerView.showsSelectionIndicator = YES;
        pickerView.tag = 0;
        [self.view addSubview:pickerView];
        self.isNull = false;
    }
    


	// Do any additional setup after loading the view.
}

/*
 Color an image */
-(UIImage *)colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor {
    UIGraphicsBeginImageContext(baseImage.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, baseImage.CGImage);
    [theColor set];
    CGContextFillRect(ctx, area);
    CGContextRestoreGState(ctx);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextDrawImage(ctx, area, baseImage.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}




- (void) handlePanGestures:(UIPanGestureRecognizer*)paramSender{
    
    if (paramSender.state != UIGestureRecognizerStateEnded &&
        paramSender.state != UIGestureRecognizerStateFailed){
        
        CGPoint location = [paramSender
                            locationInView:paramSender.view.superview];
        paramSender.view.center = location;
    }
    else if(paramSender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [paramSender locationInView:paramSender.view.superview];
        location.x = self.lineX;
        if(location.y < self.topLineY)
        {
            location.y = self.topLineY;
        }
        else if(location.y > self.topLineY + self.lineHeight)
        {
            location.y = self.topLineY + self.lineHeight;
        }
        location.x = location.x - paramSender.view.bounds.size.width/2;
        paramSender.view.center = location;
    }
    
}

//Check if the zip code they've put in is actually a zip
-(bool) isAcceptableZip: (NSString*) zipString
{

    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"^\\d{5}$" options:0 error:nil];
    int numMatches = [regex numberOfMatchesInString:zipString options:0 range:NSMakeRange(0, [zipString length])];
    return numMatches==1;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


-(IBAction)save:(id)sender
{
    //if it's a distance pref, check if the zip code is valid
    //otherwise, don't save and alert the user
    if(self.isDistancePref)
    {
        
        if([self isAcceptableZip:self.zipLabel.text])
        {
            self.preferences.zipCode = self.zipLabel.text;
            [self.preferences calculateLocation];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Zip" message:@"Zip code is not valid." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert setAlertViewStyle:UIAlertViewStyleDefault];
            [alert show];
            return;
            
        }
    }
    
    //set the preference name to what is in the field (that only appears for a custom pref)
    self.prefName = self.dumbField.text;
    
    //if it's a custom and the preference name is not equal to the name in the field, then
    //updat the preference name
    if(self.isNull && ![self.prefName isEqualToString:[self.pref getName]])
    {
        [self.pref setName:self.prefName];
    }
    
    //attempt to get the userPref associated with the preference name
    UserPreference* userPref = [self.preferences getUserPreferenceForString:self.prefName];
    
    //if there is no pref associated with the prefName, then create one
    if(self.pref == nil)
    {
        [self.preferences addPreferenceWithName:self.prefName andAcceptableValues:nil];
        self.pref = [self.preferences getPreferenceForString:self.prefName];
        NSLog(@"%@", [self.pref getName]);
    }
    
    //if there is a userPref, update the value
    //if there is not, create one and update the weights
    if(userPref != nil)
    {
        [userPref setPrefVal:self.pickerSelection+1];
    }
    else{
        //make a new user preference with missing data (if there is missing data)

        [self.preferences addUserPref:self.pref withAcceptableValue:self.pickerSelection+1];
        updateWeightsForNewPreference();
    }
    if(self.isNull)
    {

        //if it is a custom, update the data in the institutions
        int i = 1;
        for(Institution* inst in [self.institutions getAllUserInstitutions])
        {

            if([self.view viewWithTag:i].frame.origin.x != 5)
            {
                [inst setValue:[NSString stringWithFormat:@"%f", [self.view viewWithTag:i].center.y - self.topLineY] ForKeyInCustomDictionary:self.prefName];
            }
            else
            {
                [inst setValue:@"<null>" ForKeyInCustomDictionary:self.prefName];
            }
            i++;
            
        }
    }

    //switch back to the second view controller
    UITabBarController* back = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarView"];
    [self presentViewController:back animated:YES completion:nil];
    [back setSelectedIndex:1];

}

-(IBAction) cancel: (id) sender
{
    UITabBarController* back = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarView"];
    [self presentViewController:back animated:YES completion:nil];
    [back setSelectedIndex:1];
}

-(IBAction) missingData: (id) sender
{
    AcceptableValueViewController* missingDataView = [self.storyboard instantiateViewControllerWithIdentifier:@"MissingDataView"];
    UINavigationController* missingDataViewNav = [self.storyboard instantiateViewControllerWithIdentifier:@"MissingDataViewNav"];
    missingDataView.prefName = self.prefName;
    [missingDataViewNav setViewControllers:@[missingDataView]];
    [self presentViewController:missingDataViewNav animated:YES completion:nil];
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
- (IBAction)canceled:(id)sender
{
    UITabBarController* back = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarView"];
    [self presentViewController:back animated:YES completion:nil];
    [back setSelectedIndex:1];
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    bool error = false;
    for(NSString* name in [self.preferences getAllPrefNames])
    {
        if([textField.text isEqualToString:name])
        {
            error = true;
        }
    }
    if(error)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Name" message:@"Preference name already exists" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        //alert.tag = 2;
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
        [textField becomeFirstResponder];
    }
    else{

        [textField resignFirstResponder];

    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        [self.view resignFirstResponder];
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


@end
