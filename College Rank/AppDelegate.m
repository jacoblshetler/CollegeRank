//
//  AppDelegate.m
//  College Rank
//
//  Created by Jacob Levi Shetler on 2/13/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "AppDelegate.h"
#import "DataRetreiver.h"
#import "PreferenceManager.h"
#import "InstitutionManager.h"
#import "Calculations.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window.tintColor= [UIColor colorWithRed:255.0f/255.0f green:60.0f/255.0f blue:50.0f/255.0f alpha:1.0];
    
    InstitutionManager* testInst = [InstitutionManager sharedInstance];
    PreferenceManager* testPref = [PreferenceManager sharedInstance];
    
    [testInst addInstitution:[[testInst searchInstitutions:@"Goshen"] objectAtIndex:0]];
    [testInst addInstitution:[[testInst searchInstitutions:@"System"] objectAtIndex:0]];
    
    [testPref addUserPref:[testPref getPreferenceAtIndex:1] withWeight:.5 andPrefVal:1];
    [testPref addUserPref:[testPref getPreferenceAtIndex:2] withWeight:.5 andPrefVal:1];
    
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(^1600$|^(1?[0-5]?|[0-9]?)[0-9]?[0-9]$)" options:0 error:nil];
    BOOL okay = true;
    int bad = 0;
    for (int i=0;i<2000; i++) {
        NSString* val = [NSString stringWithFormat:@"%i",i];
        int numMatches = [regex numberOfMatchesInString:val options:0 range:NSMakeRange(0, [val length])];
        if(numMatches!=1){
            okay = false;
            bad = i;
            NSLog(@"numMatches=%i",numMatches);
            break;
        }
    }
    
    NSLog(@"everythingOkay=%d",okay);
    NSLog(@"numberItWentWrong=%i",bad);
        
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
