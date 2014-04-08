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


@property (nonatomic, strong) NSMutableArray* imageArr;

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
    self.imageArr = [[NSMutableArray alloc] init];


	// Do any additional setup after loading the view.
}

-(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withAttributes:Nil];
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
        location.x = self.view.bounds.size.width * .75;
        if(location.y < self.view.bounds.size.height/5)
        {
            location.y = self.view.bounds.size.height/5;
        }
        else if(location.y > self.view.bounds.size.height * .75 + self.view.bounds.size.height/5)
        {
            location.y = self.view.bounds.size.height * .75 + self.view.bounds.size.height/5;
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
    [self.imageArr addObject:[UIImage imageNamed:@"pointer1.png"]];
    [self.imageArr addObject:[UIImage imageNamed:@"pointer2.png"]];

    //for testing
    //self.pref = [self.preferences getPreferenceAtIndex:0];
    
    
    if(self.pref.getValues == nil)
    {
        //load in the selector bar
        self.isNull = true;
#warning Change me to change the properties of the vertical line!
        //add the line to snap to
        UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width*.75 - 15, self.view.bounds.size.height/5 - 20, 30, 20)];
        topLabel.text = @"Best";
        topLabel.adjustsFontSizeToFitWidth = YES;
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width*.75, self.view.bounds.size.height/5, 5, self.view.bounds.size.height*.75)];
        lineView.backgroundColor = [UIColor blackColor];
        lineView.layer.cornerRadius = 5.0;
        lineView.layer.masksToBounds = YES;
        [self.view addSubview:lineView];
        [self.view addSubview:topLabel];
        //add the markers
        int height = self.view.bounds.size.height/5;
        int i = 0;
        int markerHeight = 30;
        int markerWidth = 150;
        for(NSString *institutionName in [self.institutions getUserInstitutionNames])
        {
            CGRect boundingBox = CGRectMake(5, height, markerWidth, markerHeight);
            UIImage* pointer = [self.imageArr objectAtIndex:i];
            UIImageView* imgView = [[UIImageView alloc] initWithFrame:boundingBox];
            [imgView setTintColor:[UIColor redColor]];
            imgView.userInteractionEnabled=YES;
            UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(handlePanGestures:)];
            pan.maximumNumberOfTouches = 1;
            pan.minimumNumberOfTouches = 1;
            [imgView addGestureRecognizer:pan];
            [imgView setImage:pointer];
            imgView.image = [self drawText:institutionName inImage:imgView.image atPoint:CGPointMake(0, 0)];
            [self.view addSubview:imgView];
            height += markerHeight + 5;
            i++;
        }
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
