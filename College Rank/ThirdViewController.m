//
//  ThirdViewController.m
//  College Rank
//
//  Created by Jacob Levi Shetler on 4/11/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "ThirdViewController.h"
#import "Calculations.h"

@interface ThirdViewController ()

@property NSMutableDictionary* calculationResults;
@property NSArray* orderedKeys;
@property NSArray* colors;

@end

@implementation ThirdViewController

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
    
    //load in the colors
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
    
    //calculate the rankings
    _calculationResults = [[NSMutableDictionary alloc] initWithDictionary:generateRankings()];
    
    //generate the ordered keys
    _orderedKeys = [[NSArray alloc] initWithArray:[_calculationResults keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return obj1 < obj2;
    }]];
    
    NSLog(@"Calculation Results:\r\n%@",_calculationResults);
    NSLog(@"College Names in Order:\r\n%@",_orderedKeys);
    
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [_orderedKeys count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //if cell==1, then show the bar chart
    //if cell > 1, then show the _listOfInstitutions[row-1]
    if (indexPath.row == 0) {
        [cell.contentView addSubview:[self createBarChart]];
        //[cell.contentView
    }
    else {
        cell.textLabel.text = [NSString stringWithFormat:@"%i. %@",indexPath.row,[_orderedKeys objectAtIndex:indexPath.row-1]];
        cell.textLabel.textColor = [_colors objectAtIndex:indexPath.row - 1];
    }
    
    return cell;
}

- (UIView*) createBarChart{
    
    return [[UIView alloc] init];
}
         
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0){
        return 200;
    }
    else{
        return 45;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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
