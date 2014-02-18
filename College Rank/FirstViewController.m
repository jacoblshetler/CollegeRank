//
//  FirstViewController.m
//  College Rank
//
//  Created by Jacob Levi Shetler on 2/13/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "FirstViewController.h"
#import "DataRetreiver.h"
#import "Calculations.h"
@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //quick testing normalize
    NSMutableArray* ns = [[NSMutableArray alloc] init];
    [ns addObject:[NSDecimalNumber decimalNumberWithString:@"5.0"]];
    [ns addObject:[NSDecimalNumber decimalNumberWithString:@"6.0"]];
    [ns addObject:[NSDecimalNumber decimalNumberWithString:@"1.3"]];
    [ns addObject:[NSDecimalNumber decimalNumberWithString:@"20.0"]];
    NSLog(@"%@",[Calculations normalize:ns]);
    
    
    //Philip crap
    NSLog(@"I made a change");
    
    //test data retriever
    NSLog(@"%@",GetInstitutions());
    NSArray *colleges = [[NSArray alloc] initWithObjects: @"Goshen College", @"Shiloh University", nil];
    NSLog(@"%@", GetPreferences(colleges));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
