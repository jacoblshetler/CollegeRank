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
#import "UserPreference.h"
#import "Preference.h"
#import "DataRetreiver.h"
#import "MissingDataViewController.h"
#import "AcceptableValueViewController.h"

@interface SecondViewController ()

@property InstitutionManager* institutions;
@property PreferenceManager* preferences;
@property NSArray* searchResults;

- (void) preferenceNavigate: (NSIndexPath *) indexPath;

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
    _institutions = [InstitutionManager sharedInstance];
    _preferences = [PreferenceManager sharedInstance];
    //[self canGoToTabs];


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search Results

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    
    self.searchDisplayController.searchBar.text = @"\n";
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    if ([searchText isEqualToString:@"\n"])
    {
        _searchResults = [_preferences getAllPrefNames];
    } else
    {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"Self contains[c] %@", searchText];
        _searchResults = [[_preferences getAllPrefNames] filteredArrayUsingPredicate:resultPredicate];
    }
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    self.searchDisplayController.searchBar.text = @"\n";
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
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
            cell.textLabel.text = @"";
        } else if (indexPath.row == 1) {
            UISlider* slider = [UISlider new];
            [cell.contentView addSubview:slider];
            slider.bounds = CGRectMake(0, 0, cell.contentView.bounds.size.width - 30, slider.bounds.size.height);
            slider.center = CGPointMake(CGRectGetMidX(cell.contentView.bounds), CGRectGetMidY(cell.contentView.bounds));
            slider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        } else {
            UserPreference* usrPref = [[_preferences userPrefs] objectAtIndex:indexPath.row - 2];
            cell.textLabel.text = usrPref.pref.name;
        }
    }
    return cell;
}
#pragma Selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        //[self canGoToTabs]; Run from Save button
    }
}

- (void) preferenceNavigate: (NSIndexPath *) indexPath
{
    NSString *values = [[NSBundle mainBundle] pathForResource: @"AcceptableValues" ofType: @"plist"];
    NSDictionary *valuesDict = [[NSDictionary alloc] initWithContentsOfFile:values];
    
    NSString *entry = [_searchResults objectAtIndex:[indexPath row]];
    NSString *entryDecoded = [[valuesDict valueForKeyPath:entry] objectAtIndex:0];
    
    NSPredicate *memberPredicate = [NSPredicate predicateWithFormat:@"name matches %@", entry];
    if ([[[_preferences userPrefs] filteredArrayUsingPredicate:memberPredicate] count] < 1) {
    
        NSMutableArray * missingDataInst = [_institutions getMissingDataInstitutionsForPreference:entryDecoded];
        if ([missingDataInst count]!= 0) {
            MissingDataViewController* missingData = [self.storyboard instantiateViewControllerWithIdentifier:@"MissingDataView"];
            missingData.prefName = entry;
            missingData.missingInstitutions = missingDataInst;
            [self presentViewController:missingData animated:YES completion:nil];
        } else {
            AcceptableValueViewController* userPrefView = [self.storyboard instantiateViewControllerWithIdentifier:@"UserPrefsView"];
            userPrefView.prefName = entry;
            [self presentViewController:userPrefView animated:YES completion:nil];
        }
    }
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



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[_preferences removeUserPreference:[[[_institutions userInstitutions] objectAtIndex:indexPath.row] name]];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //[self canGoToTabs];
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
