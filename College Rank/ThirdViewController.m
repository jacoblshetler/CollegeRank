//
//  ThirdViewController.m
//  College Rank
//
//  Created by Jacob Levi Shetler on 4/11/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "ThirdViewController.h"
#import "Calculations.h"
#import <QuartzCore/QuartzCore.h>

@interface ThirdViewController ()

@property NSMutableDictionary* calculationResults;
@property NSMutableDictionary* indexToOrdinal;
@property NSArray* orderedKeys;
@property NSArray* colors;
@property int chartHeight;
@property int screenWidth;

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
    //define the height of the barchart and the width of the screen
    _chartHeight = 200;
    _screenWidth = self.view.frame.size.width;
    
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
    _orderedKeys = orderDictKeysDescending(_calculationResults);
    
    //generate the index->ordinal dictionary
    _indexToOrdinal = createOrdinalDictionary(_calculationResults,_orderedKeys);
    
    self.tableView.delegate = self;
     
}

- (void) viewDidAppear:(BOOL)animated{
    //calculate the rankings
    _calculationResults = [[NSMutableDictionary alloc] initWithDictionary:generateRankings()];
    
    //generate the ordered keys
    _orderedKeys = orderDictKeysDescending(_calculationResults);
    
    //generate the index->ordinal dictionary
    _indexToOrdinal = createOrdinalDictionary(_calculationResults,_orderedKeys);
    
    //redraw the table
    [self.tableView reloadData];
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //if cell==1, then show the bar chart
    //if cell > 1, then show the _listOfInstitutions[row-1]
    if (indexPath.row == 0) {
        [cell.contentView addSubview:[self createBarChart]];
    }
    else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@",[_indexToOrdinal objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row-1]],[_orderedKeys objectAtIndex:indexPath.row-1]];
        cell.textLabel.textColor = [_colors objectAtIndex:indexPath.row - 1];
    }
    
    return cell;
}

- (UIView*) createBarChart{
    //create the UIView to contain everything else
    UIView* containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _chartHeight)];
    
    //create the x-axis and y-axis variables
    int xAxisX = _screenWidth * .05;
    int xAxisY = _chartHeight*.90;
    int xAxisLength = _screenWidth * .9;
    int lineWidth = 2;
    
    //actually draw the xaxis and yaxis
    UIView *xAxis = [[UIView alloc] initWithFrame:CGRectMake(xAxisX, xAxisY, xAxisLength, lineWidth)];
    xAxis.backgroundColor = [UIColor blackColor];
    xAxis.layer.masksToBounds = YES;
    [self.view addSubview:xAxis];
    UIView *yAxis = [[UIView alloc] initWithFrame:CGRectMake(xAxisX, _chartHeight*.05, lineWidth, xAxisY*.95)];
    yAxis.backgroundColor = [UIColor blackColor];
    yAxis.layer.masksToBounds = YES;
    [self.view addSubview:yAxis];
    
    
    //Create the labels for the axes
    UILabel *xAxisLabel = [[UILabel alloc] initWithFrame:CGRectMake(_screenWidth*.5-50,_chartHeight*.95-11, 70, 20)];
    xAxisLabel.text = @"Colleges";
    xAxisLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:xAxisLabel];
    
    /*
    UILabel *yAxisLabel = [[UILabel alloc] initWithFrame:CGRectMake(-30, _chartHeight*.5, 70, 20)];
    yAxisLabel.text = @"Cardinal Utility"; //TODO: we should think of a more user-friendly name for this axis
    yAxisLabel.adjustsFontSizeToFitWidth = YES;
    [yAxisLabel setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    [self.view addSubview:yAxisLabel];
    */
     
    //determine the variables for the size of the working area of the bar chart
    int barChartWidth = xAxisLength;
    int barChartHeight = xAxisY*.95;
    int barChartX = xAxisX;
    int barChartY = _chartHeight*.05;
    int barSpacing = 8;
    
    //determine how wide the bars need to be
    int barWidth = (barChartWidth-(barSpacing*[_orderedKeys count]))/[_orderedKeys count];
    
    //start drawing the bars!
    UIView *barView;
    int nextX = barChartX + barSpacing;
    int firstHeight = 0;
    for (int i=0; i < [_orderedKeys count]; i++) {
        //get the value of the institution and its corresponding bar chart height
        NSString* stringValue = [_calculationResults objectForKey:[_orderedKeys objectAtIndex:i]];
        float utility = [stringValue floatValue];
        int barHeight = barChartHeight * utility;
        if (barHeight==0) {
            barHeight = barChartHeight * .01;
        }
        if (firstHeight==0) {
            firstHeight=barHeight;
        }
        
        //make the first height the total height and scale all others accordingly
        barHeight = (float)barHeight * ((float)barChartHeight/(float)firstHeight);
        
        //create the bar
        barView = [[UIView alloc] initWithFrame:CGRectMake(nextX, barChartY+((barChartHeight-barChartY)-barHeight)+8, barWidth, barHeight)];
        nextX = nextX + barWidth + barSpacing;
        
        //set its color
        barView.backgroundColor = [_colors objectAtIndex:i];
        
        //add it to the view
        [containerView addSubview:barView];
    }
    
    return containerView;
}
         
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0){
        return _chartHeight;
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
