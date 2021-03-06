//
//  DataRetreiver.m
//  College Rank
//
//  Created by Michael John Yoder on 2/17/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "DataRetreiver.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

#define ampCONSTANT "*AMP*"
#define urlCONSTANT "http://199.8.232.152/college_rank/getData.php?"

BOOL connected(){
    Reachability * reach = [Reachability reachabilityForInternetConnection];
    [reach startNotifier];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    //NSLog(@"%d",netStatus != NotReachable);
    return netStatus != NotReachable;
}

void giveError(){
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Network Failure" message:@"No internet connection: \r\nplease check your connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert setAlertViewStyle:UIAlertViewStyleDefault];
    [alert show];
}

NSMutableArray* GetInstitutions()
{
    //THIS ONLY WORKS IF THE SYSTEMCONFIGURATION FRAMEWORK HAS BEEN ADDED TO THE PROJECT.
    if (!connected()){
        giveError();
        return nil;
    }
    
    NSString *url_string = @urlCONSTANT;
    NSString *post =[[NSString alloc] initWithFormat:@"function=%@", @"getInstitutions"];
    
    
    url_string = [url_string stringByAppendingString:post];
    //NSLog(@"%@", url_string);
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_string]];
    
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSError* localError;
    NSMutableArray *college_list = [[NSMutableArray alloc] init];
    if(!responseData)
    {
        return nil;
    }
    id colleges = [NSJSONSerialization JSONObjectWithData:responseData
                                                  options:0
                                                error:&localError];
    
    for(NSDictionary* dict in colleges){
        [college_list addObject:[[dict objectForKey:@"name"] stringByReplacingOccurrencesOfString:@ampCONSTANT withString:@"&"]];
    }
    return college_list;
}

NSMutableArray* GetPreferences(NSArray* colleges)
{
    if (!connected()){
        giveError();
        return nil;
    }
    
    NSMutableArray *college_array = [[NSMutableArray alloc] init];
    for(NSString* college_name in colleges)
    {
        NSDictionary* new_dict = [NSDictionary dictionaryWithObject:[college_name stringByReplacingOccurrencesOfString:@"&" withString:@ampCONSTANT] forKey:@"name"];
        [college_array addObject:new_dict];
    }
    //NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:colleges forKeys:keys];
    //NSLog(@"%@", jsonDictionary);
    NSError *error;
    if(!college_array)
    {
        return nil;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:college_array
                                                       options:0
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData: jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url_string = @urlCONSTANT;
    
    url_string = [url_string stringByAppendingString:[NSString stringWithFormat:@"function=%@&institutions=%@", @"getPreferences", jsonString]];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_string]];
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSMutableArray *college_list = [[NSMutableArray alloc] init];
    if(responseData != nil && !err){
        NSError* localError;
        id collegeObj = [NSJSONSerialization JSONObjectWithData:responseData
                                                        options:0
                                                          error:&localError];
        
        if(localError)
        {
            NSLog(@"%@", localError);
        }
        for(NSDictionary* dict in collegeObj){
            [college_list addObject:dict];
        }
    }
    else{
        NSLog(@"%@", err);
    }
    return college_list;
}