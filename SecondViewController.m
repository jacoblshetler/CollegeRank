//
//  SecondViewController.m
//  College Rank
//
//  Created by Philip Bontrager on 3/23/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "SecondViewController.h"
#import "InstitutionManager.h"
#import "PreferenceManager.h"
#import "Calculations.h"
#import "UserPreference.h"
#import "Preference.h"
#import "DataRetreiver.h"
#import "MissingDataViewController.h"//Do we need these two?
#import "AcceptableValueViewController.h"

@interface SecondViewController ()

@property InstitutionManager* institutions;
@property PreferenceManager* preferences;
@property UISlider* slider;
@property UIButton* button;
@property NSArray* searchResults;
@property NSArray* colors;
@property int chartHeight;
@property int cellHeight;
@property int screenWidth;

- (void) preferenceNavigate: (NSIndexPath *) indexPath;
-(UIImage*) drawPieChart:(NSArray*) weights;
- (IBAction)sliderDragAction:(id)sender;
- (IBAction)lockPressAction:(id)sender;
- (void)buttonImage:(BOOL)lockState;
-(void) updateInputControllers:(int) row;
-(void)goToAcceptableValues:(NSString*)entry;
-(void)goToMissingData:(NSString*)entry;

@end

@implementation SecondViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"JUST LOADED");
    _institutions = [InstitutionManager sharedInstance];
    _preferences = [PreferenceManager sharedInstance];
    [self canGoToTabs];
    
    //Define graphic dimensions
    _chartHeight = 200;
    _cellHeight = 45;
    _screenWidth = self.view.frame.size.width;
    
    //Define Graphic Colors
    NSString* colorFile = [[NSBundle mainBundle] pathForResource: @"Colors" ofType: @"plist"];
    NSArray* colorRGB = [[NSArray alloc] initWithContentsOfFile:colorFile];
    
    NSMutableArray* tempArray = [NSMutableArray new];
    CGFloat r, g, b;
    for (NSArray* rgb in colorRGB) {
        r = [[rgb objectAtIndex:0] floatValue]/255;
        g = [[rgb objectAtIndex:1] floatValue]/255;
        b = [[rgb objectAtIndex:2] floatValue]/255;
        [tempArray addObject:[UIColor colorWithRed:r green:g blue:b alpha:1.0]];
    }
    _colors = [[NSArray alloc] initWithArray:tempArray];

    //Define UISlider
    if (_slider==nil) {
        _slider = [UISlider new];
        [_slider addTarget:self action:@selector(sliderDragAction:) forControlEvents:UIControlEventTouchDragInside];
        _slider.bounds = CGRectMake(0, 0, _screenWidth*.7, _slider.bounds.size.height);
        _slider.center = CGPointMake((_screenWidth/2)*.7 + 15, _cellHeight/2);
        _slider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    //Define UIButton
    if (_button==nil) {
        _button = [UIButton new];
        [_button addTarget:self action:@selector(lockPressAction:) forControlEvents:UIControlEventTouchUpInside];
        _button.bounds = CGRectMake(0,0, _slider.bounds.size.height,_slider.bounds.size.height);
        _button.center = CGPointMake(_screenWidth - (_slider.bounds.size.height/2 + 15), _cellHeight/2);
        _button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self buttonImage:FALSE];
    }
    
    // Display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.tableView.allowsSelectionDuringEditing = YES;

}

-(void) viewWillAppear:(BOOL)animated{
    _institutions = [InstitutionManager sharedInstance];
    _preferences = [PreferenceManager sharedInstance];
    [self canGoToTabs];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) canGoToTabs{
    if (![_preferences canGoToRank]) {
        [[[[self.tabBarController tabBar]items]objectAtIndex:2]setEnabled:FALSE];
    } else {
        [[[[self.tabBarController tabBar]items]objectAtIndex:2]setEnabled:TRUE];
    }
}

#pragma mark - Search Results

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    //Inserts a carriage return to activate the UISearchDisplayController
    self.searchDisplayController.searchBar.text = @"\n";
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    //If the user has not entered anything, show all unselected preference options
    if ([searchText isEqualToString:@"\n"]){
        _searchResults = [_preferences newPreferenceChoices];
    } else {
        //Predicate to filter out search results
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"Self contains[c] %@", searchText];
        _searchResults = [[_preferences newPreferenceChoices] filteredArrayUsingPredicate:resultPredicate];
    }
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    //Inserts a carriage return to activate the UISearchDisplayController after user cancels the results
    self.searchDisplayController.searchBar.text = @"\n";
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //If the search was activated with carriage return, remove it so the user input is not skewed
    if ([searchString isEqualToString:@"\n"])
    {
        self.searchDisplayController.searchBar.text = @"";
    }

    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                    selectedScopeButtonIndex]]];
    
    return YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_searchResults count];
    }
    else if ([[_preferences userPrefs] count] < 2){
        return [[_preferences userPrefs] count];
    }
    else {
        return [[_preferences userPrefs] count] + 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [_searchResults objectAtIndex:indexPath.row];
    } else if ([[_preferences userPrefs] count] < 2){
        UserPreference* usrPref = [[_preferences userPrefs] objectAtIndex:indexPath.row];
        cell.textLabel.text = usrPref.pref.name;
    } else {
        if (indexPath.row == 0) {
            NSArray* weights = [_preferences getAllPrefWeights];
            UIImageView* pieChart = [[UIImageView alloc] initWithImage:[self drawPieChart:weights]];
            [cell.contentView addSubview:pieChart];
        } else if (indexPath.row == 1) {
            [cell.contentView addSubview:_slider];
            [cell.contentView addSubview:_button];
        } else {
            UserPreference* usrPref = [[_preferences userPrefs] objectAtIndex:indexPath.row - 2];
            cell.textLabel.text = usrPref.pref.name;
            cell.textLabel.textColor = [_colors objectAtIndex:indexPath.row - 2];
        }
    }
    return cell;
}


#pragma Selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //For edits
    if (self.tableView.editing==YES) {
        NSLog(@"True");
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    //Add code for normal table view, when > 1 preferences set the selected prefernces equal to a variable that gets edited
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([[_preferences userPrefs] count] == 10)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Maximum Reached" message:@"Sorry, but you can only add up to 10 Preferences." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert setAlertViewStyle:UIAlertViewStyleDefault];
            [alert show];
            [self.searchDisplayController setActive:NO animated:YES];

        }
        [self preferenceNavigate:indexPath];
        //[self.tableView reloadData]; Run from Save button
        [self canGoToTabs]; //Run from Save button
    } else if (indexPath.row >= 2) {
        //Update slider data and lock button to match data for select preference
        [self updateInputControllers:indexPath.row - 2];
    }
}
#pragma Navigate
- (void) preferenceNavigate: (NSIndexPath *) indexPath
{
    NSString* values = [[NSBundle mainBundle] pathForResource: @"AcceptableValues" ofType: @"plist"];
    NSDictionary *valuesDict = [[NSDictionary alloc] initWithContentsOfFile:values];
    
    NSString* entry = [_searchResults objectAtIndex:[indexPath row]];
    
    //If the entry is a custom preference, skip the rest of the function
    NSPredicate* memberPredicate = [NSPredicate predicateWithFormat:@"Self Like[cd] %@",entry];
    if ([[[_preferences getAllPrefNames] filteredArrayUsingPredicate:memberPredicate] count] == 0) {
        [self goToAcceptableValues:entry];
    }
    else {
    
        NSString *entryDecoded = [[valuesDict valueForKeyPath:entry] objectAtIndex:0];
    
        NSMutableArray * missingDataInst = [_institutions getMissingDataInstitutionsForPreference:entryDecoded];
        if ([missingDataInst count]!= 0) {
            [self goToMissingData:entry];
        } else {
            [self goToAcceptableValues:entry];
        }
    }
}
-(void)goToAcceptableValues:(NSString*)entry
{
    AcceptableValueViewController* userPrefView = [self.storyboard instantiateViewControllerWithIdentifier:@"UserPrefsView"];
    UINavigationController* userPrefViewNav = [self.storyboard instantiateViewControllerWithIdentifier:@"UserPrefsViewNav"];
    userPrefView.prefName = entry;
    [userPrefViewNav setViewControllers:@[userPrefView]];
    [self presentViewController:userPrefViewNav animated:YES completion:nil];
}
-(void)goToMissingData:(NSString*)entry
{
    AcceptableValueViewController* missingDataView = [self.storyboard instantiateViewControllerWithIdentifier:@"MissingDataView"];
    UINavigationController* missingDataViewNav = [self.storyboard instantiateViewControllerWithIdentifier:@"MissingDataViewNav"];
    missingDataView.prefName = entry;
    [missingDataViewNav setViewControllers:@[missingDataView]];
    [self presentViewController:missingDataViewNav animated:YES completion:nil];
}

#pragma Pie Chart and Controllers
-(IBAction)sliderDragAction:(id)sender
{
    //Check if a Preference is selected, if one isn't, select one.
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath == nil || indexPath.row < 2) {
        indexPath = [NSIndexPath indexPathForRow:[[_preferences userPrefs] count]+1 inSection:0];
        [self.tableView
         selectRowAtIndexPath:indexPath
         animated:NO
         scrollPosition:UITableViewScrollPositionNone];
        
        [self updateInputControllers:[[_preferences userPrefs] count] - 1];

    }
    //Update Weights
    updateWeights(indexPath.row - 2, _slider.value);
    
    //Update Pie Chart
    NSIndexPath *chartPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[chartPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)lockPressAction:(id)sender
{
    //Check if a Preference is selected, if one isn't, select one.
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath == nil || indexPath.row < 2) {
        indexPath = [NSIndexPath indexPathForRow:[[_preferences userPrefs] count] + 1 inSection:0];
        [self.tableView
         selectRowAtIndexPath:indexPath
         animated:NO
         scrollPosition:UITableViewScrollPositionNone];
        
        [self updateInputControllers:[[_preferences userPrefs] count] - 1];
    }
    //Update Preference Lock
    UserPreference* selectedPref = [[_preferences userPrefs] objectAtIndex:indexPath.row - 2];
    [selectedPref changeLock];
    [self buttonImage:[selectedPref getLock]];
}

//Update slider data and lock button to match data for select preference
-(void)updateInputControllers:(int) row
{
    NSArray* range = weightToWorkWith(row);
    UserPreference* selectedPref = [[_preferences userPrefs] objectAtIndex:row];
    _slider.value = [selectedPref getWeight];
    _slider.minimumValue = [[range objectAtIndex:0] floatValue];
    _slider.maximumValue = [[range objectAtIndex:1] floatValue];
    
    [self buttonImage:[selectedPref getLock]];
}

//Returns locked image if the input is true, otherwise an unlocked image
- (void)buttonImage:(BOOL)lockState
{
    if (lockState) {
        [_button setImage:[UIImage imageNamed:@"lockImage"] forState:UIControlStateNormal];
    }else {
        [_button setImage:[UIImage imageNamed:@"unlockImage"] forState:UIControlStateNormal];
    }
}

-(UIImage*) drawPieChart:(NSArray*) weights
{
    //Get image size and location
    CGFloat width = _screenWidth;
    CGFloat height = _chartHeight;
    CGFloat radius = MIN(width, height)/2.1;
    CGPoint center = CGPointMake(width/2, height/2);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), FALSE, 1.f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    //Create the bezier path for each wedge
    CGFloat startAngle = 3*M_PI/2.0;
    for (int i=0; i < [weights count]; i++)
    {
        CGContextSetFillColorWithColor(context, [[_colors objectAtIndex:i] CGColor]);
        
        //Draw Wedge
        UIBezierPath *wedge = [UIBezierPath bezierPath];
        wedge.lineWidth = 2;
        
        [wedge moveToPoint:center];
        CGFloat endAngle = startAngle + 2*M_PI*[[weights objectAtIndex:i] floatValue];
        [wedge addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        startAngle = endAngle;
        [wedge closePath];
        
        [wedge fill];
        [wedge stroke];
    }
    
    UIImage *bezierImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return bezierImage;
}

#pragma Extra
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[_preferences userPrefs] count] > 1 && indexPath.row < 2) {
        return NO;
    }
    else {
        return YES;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isSearchDisplay = (tableView == self.searchDisplayController.searchResultsTableView);
    BOOL hasPieChart = ([[_preferences userPrefs] count]>1);
    if (indexPath.row==0 && !isSearchDisplay && hasPieChart){
        return _chartHeight;
    }
    else{
        return _cellHeight;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
#warning Double check that custom settings aren't added to the missing data dictionary
#warning Fully test deleting custom preferences
        // Delete the row from the data source
        [_preferences removeUserPrefAtIndex:indexPath.row - 2];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //Try adding code to delete these rows
        
#warning Do this only if the pie chart is not disappearing
        //Update Pie Chart
        NSIndexPath *chartPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[chartPath] withRowAnimation:UITableViewRowAnimationNone];
        
        [self canGoToTabs];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
