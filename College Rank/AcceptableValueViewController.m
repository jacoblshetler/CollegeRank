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
@end

@implementation AcceptableValueViewController

@synthesize prefName;
@synthesize institutionsMissingData;

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
    self.lineX = self.view.bounds.size.width * .9;
    self.topLineY = self.view.bounds.size.height/5;
    self.lineHeight = self.view.bounds.size.height*.6;
    self.markerHeight = 30;
    self.markerWidth = 150;
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


	// Do any additional setup after loading the view.
}

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


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.institutions = [InstitutionManager sharedInstance];
    self.preferences = [PreferenceManager sharedInstance];
    
    /*Add the buttons at the bottom*/
    
    //save button
    self.save = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.save addTarget:self
               action:@selector(save:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.save setTitle:@"Save" forState:UIControlStateNormal];
    self.save.frame = CGRectMake(10, self.view.bounds.size.height-40, 80, 40.0);
    [self.view addSubview:self.save];
    
    //cancel button
    self.cancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.cancel addTarget:self
                  action:@selector(cancel:)
        forControlEvents:UIControlEventTouchUpInside];
    [self.cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    self.cancel.frame = CGRectMake(10, 20, 80, 40.0);
    [self.view addSubview:self.cancel];
    
    //missing data (if data is missing)
    if(self.institutionsMissingData != nil)
    {
        self.missingData = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.missingData addTarget:self
                        action:@selector(missingData:)
              forControlEvents:UIControlEventTouchUpInside];
        [self.missingData setTitle:@"Missing Data" forState:UIControlStateNormal];
        self.missingData.frame = CGRectMake(self.view.bounds.size.width-100, self.view.bounds.size.height - 40, 100, 40.0);
        [self.view addSubview:self.missingData];
    }
    self.pref = [self.preferences getPreferenceForString:self.prefName];
    
    //for testing
    //self.pref = [self.preferences getPreferenceAtIndex:0];
    
    
    if(self.pref == nil)
    {
        [self.preferences addPreferenceWithName:self.prefName andAcceptableValues:nil];
        self.pref = [self.preferences getPreferenceForString:self.prefName];
    }
    if(self.pref.acceptableValues == nil)
    {
        //load in the selector bar
        self.isNull = true;
#warning Change me to change the properties of the vertical line!
        //add the line to snap to

        UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.lineX - self.markerHeight/2, self.topLineY - 20, 30, 20)];
        topLabel.text = @"Best";
        topLabel.adjustsFontSizeToFitWidth = YES;
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(self.lineX, self.topLineY, 5, self.lineHeight)];
        lineView.backgroundColor = [UIColor blackColor];
        lineView.layer.cornerRadius = 5.0;
        lineView.layer.masksToBounds = YES;
        [self.view addSubview:lineView];
        [self.view addSubview:topLabel];
        //add the markers
        int height = self.view.bounds.size.height/5;
        int i = 1;

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
            if([inst customValueForKey:[self.pref getName]] != nil && ![[inst customValueForKey:[self.pref getName]] isEqualToString:@"<null>"])
            {
                imgView.center = CGPointMake(self.lineX - self.markerWidth/2, self.topLineY + [[inst customValueForKey:[self.pref getName]] integerValue]);
            }
            
            imgView.tag = i;
            [self.view addSubview:imgView];
            height += self.markerHeight + 5;
            i++;

        }
    }
    else{
        //load in the picker
        
        UIPickerView* pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, 320, 200)];
        pickerView.delegate = self;
        pickerView.showsSelectionIndicator = YES;
        pickerView.tag = 0;
        [self.view addSubview:pickerView];
        self.isNull = false;
    }
}


-(IBAction)save:(id)sender
{
    //if the user preference already exists, update the data
    UserPreference* userPref = [self.preferences getUserPreferenceForString:self.prefName];
    if(userPref != nil)
    {
        [userPref setPrefVal:self.pickerSelection];
        [userPref setMissingInstData:self.institutionsMissingData];
    }
    else{
        //make a new user preference with missing data (if there is missing data)

        if(self.institutionsMissingData != nil)
        {
            [self.preferences addUserPref:self.pref withAcceptableValue:self.pickerSelection andMissingData:self.institutionsMissingData];

        }
        else
        {
            [self.preferences addUserPref:self.pref withAcceptableValue:self.pickerSelection];
        }
        updateWeightsForNewPreference();
    }
    if(self.isNull)
    {
        //if it is a custom, update the data in the institutions.  The userPrefence object has already been created.
        int i = 1;
        for(Institution* inst in [self.institutions getAllUserInstitutions])
        {
            NSLog(@"Name: %@", [inst name]);

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
    MissingDataViewController* missingData = [self.storyboard instantiateViewControllerWithIdentifier:@"MissingDataView"];
    missingData.prefName = self.prefName;
    missingData.missingInstitutions = self.institutionsMissingData;
    [self presentViewController:missingData animated:YES completion:nil];
    
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

@end
