//
//  FirstViewController.m
//  College Rank
//
//  Created by Philip Bontrager on 3/18/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "InstitutionManager.h"
#import "Institution.h"
#import "FirstViewController.h"
#import "DataRetreiver.h"
#import "PreferenceManager.h"
#import "Calculations.h"
@interface FirstViewController ()

@property InstitutionManager* institutions;
@property PreferenceManager* preferences;
@property NSArray* searchResults;

@end

@implementation FirstViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _institutions = [InstitutionManager sharedInstance];
    _preferences = [PreferenceManager sharedInstance];
    //[self testCalculations];
    [self canGoToTabs];
    [self updateTabBarIcon];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}
-(void) viewWillAppear:(BOOL)animated{
    //do everything you would do in the viewDidLoad
    _institutions = [InstitutionManager sharedInstance];
    _preferences = [PreferenceManager sharedInstance];
    [self.tableView reloadData];
    [self canGoToTabs];
    [self updateTabBarIcon];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search Results

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"Self contains[c] %@", searchText];
    _searchResults = [[_institutions allInstitutions] filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                    selectedScopeButtonIndex]]];
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_searchResults count];
        
    } else {
        return [[_institutions userInstitutions] count];
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
    } else {
        Institution* inst = [[_institutions userInstitutions] objectAtIndex:indexPath.row];
        cell.textLabel.text = inst.name;
    }
    
    return cell;
}

#pragma actions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([[_institutions userInstitutions] count] == 10) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Maximum Reached" message:@"Sorry, but you can only add up to 10 colleges." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert setAlertViewStyle:UIAlertViewStyleDefault];
            [alert show];
            [self.searchDisplayController setActive:NO animated:YES];
        } else {
            NSString *entry = [_searchResults objectAtIndex:[indexPath row]];
            NSPredicate *memberPredicate = [NSPredicate predicateWithFormat:@"name matches %@", entry];
            if ([[[_institutions userInstitutions] filteredArrayUsingPredicate:memberPredicate] count] < 1) {
                [_institutions addInstitution:entry];
                [self.searchDisplayController setActive:NO animated:YES];
                [self.tableView reloadData];
                [self canGoToTabs];
                [self updateTabBarIcon];
            }
        }
    }
}

-(void) canGoToTabs
{
    if (![_institutions canGoToPreferences]) {
        [[[[self.tabBarController tabBar]items]objectAtIndex:1]setEnabled:FALSE];
    } else {
        [[[[self.tabBarController tabBar]items]objectAtIndex:1]setEnabled:TRUE];
    }
    if (![_preferences canGoToRank]) {
        [[[[self.tabBarController tabBar]items]objectAtIndex:2]setEnabled:FALSE];
    } else {
        [[[[self.tabBarController tabBar]items]objectAtIndex:2]setEnabled:TRUE];
    }
}

-(void) updateTabBarIcon{
    UITabBarItem* item = [self.tabBarController.tabBar.items objectAtIndex:1];
    [item setBadgeValue:getPreferenceBadgeCountString()];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [_institutions removeInstitution:[[[_institutions userInstitutions] objectAtIndex:indexPath.row] name]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self canGoToTabs];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
    [self updateTabBarIcon];
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

-(void) testCalculations
{
    //PreferenceManager* myP = [PreferenceManager sharedInstance];
    
    [_institutions addInstitution:[[_institutions searchInstitutions:@"Goshen"] objectAtIndex:0]];
    //[_institutions addInstitution:[[_institutions searchInstitutions:@"DePauw"] objectAtIndex:0]];
    //[_institutions addInstitution:[[_institutions searchInstitutions:@"Mennonite"] objectAtIndex:1]];
    //[_institutions addInstitution:[[_institutions searchInstitutions:@"Commun"] objectAtIndex:0]];
    [_institutions addInstitution:[[_institutions searchInstitutions:@"System"] objectAtIndex:0]];
    /*
    int i=0;
    for(Preference* newPref in [_preferences getAllPrefs])
    {
        if (i==0) [_preferences addUserPref:newPref withWeight:1.0 andPrefVal:0];
        else [_preferences addUserPref:newPref withWeight:0.0 andPrefVal:0];
        if(i>0){
            setANewWeight(i);
        }
        i++;
        [_preferences addUserPref:newPref withWeight:1 andPrefVal:0];
    }
    

    
    NSLog(@"Ranked list: %@", generateRankings());
    
    NSString *values = [[NSBundle mainBundle] pathForResource: @"AcceptableValues" ofType: @"plist"];
    NSDictionary *valuesDict = [[NSDictionary alloc] initWithContentsOfFile:values];
    for(NSString *key in valuesDict)
    {
        NSString* curProp = [valuesDict valueForKey:key][0];
        NSLog(@"Missing %@: %@", curProp ,[_institutions getMissingDataInstitutionsForPreference:curProp]);
    }
     */
}

@end
