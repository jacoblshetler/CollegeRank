//
//  HelpViewController.m
//  College Rank
//
//  Created by Jacob Levi Shetler on 4/14/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation HelpViewController

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
	// Do any additional setup after loading the view.
    
    //load in rtf string
    NSString* path = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"];
    NSURL* url = [[NSURL alloc] initFileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    /*
    NSString* helpText = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:helpText baseURL:nil];
     */
    [_webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
