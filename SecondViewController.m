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
    } else {
        UserPreference* usrPref = [[_preferences userPrefs] objectAtIndex:indexPath.row];
        cell.textLabel.text = usrPref.pref.name;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
#warning The below comments need to be added
        //Check for number of preferences (Use alert from view controller 1)
        //Check for previously added institutions
        //[self.tableView reloadData];
        //[self canGoToTabs];
       
        NSString *values = [[NSBundle mainBundle] pathForResource: @"AcceptableValues" ofType: @"plist"];
        NSDictionary *valuesDict = [[NSDictionary alloc] initWithContentsOfFile:values];
        
        NSString *entry = [_searchResults objectAtIndex:[indexPath row]];
        NSString *entryDecoded = [[valuesDict valueForKeyPath:entry] objectAtIndex:0];
        
        NSMutableArray * missingDataInst = [_institutions getMissingDataInstitutionsForPreference:entryDecoded];
        if ([missingDataInst count]!= 0) {
            MissingDataViewController* missingData = [self.storyboard instantiateViewControllerWithIdentifier:@"MissingDataView"];
            [self presentViewController:missingData animated:YES completion:nil];
            missingData.prefType = entryDecoded;
            missingData.missingInstitutions = missingDataInst;
        } else {
            AcceptableValueViewController* userPrefView = [self.storyboard instantiateViewControllerWithIdentifier:@"UserPrefsView"];
            //[userPrefView setPref:pref];
            [self presentViewController:userPrefView animated:YES completion:nil];
            userPrefView.prefType = entryDecoded;
        }
        
        
        //Preference *pref = [self.preferences getPreferenceForString:entryDecoded];
        //NSLog(@"%@",pref.name);
        
       
       
        //missingData.test.text = @"Different";
        
    }
}



/*/This is for sending information to the detail view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"missingData"]) {
        NSIndexPath *indexPath = nil;
        //Recipe *recipe = nil;
        
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            //recipe = [searchResults objectAtIndex:indexPath.row];
        } else {
            //indexPath = [self.tableView indexPathForSelectedRow];
            //recipe = [recipes objectAtIndex:indexPath.row];
        }
        
        //ViewController *view = segue.destinationViewController;
        //RecipeDetailViewController *destViewController = segue.destinationViewController;
        //destViewController.recipe = recipe;
    }
}*/


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


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
