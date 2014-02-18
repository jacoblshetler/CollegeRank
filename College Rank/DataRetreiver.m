//
//  DataRetreiver.m
//  College Rank
//
//  Created by Michael John Yoder on 2/17/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import "DataRetreiver.h"

NSMutableArray* GetInstitutions()
{
    NSString *url_string = @"http://199.8.232.152/college_rank/getData.php?";
    NSString *post =[[NSString alloc] initWithFormat:@"function=%@", @"getInstitutions"];

    url_string = [url_string stringByAppendingString:post];
    NSLog(@"%@", url_string);
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_string]];
    
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSMutableArray *college_list = [[NSMutableArray alloc] init];
    NSError* localError;
    id colleges = [NSJSONSerialization JSONObjectWithData:responseData
                                                            options:0
                                                              error:&localError];
    for(NSDictionary* dict in colleges){
        [college_list addObject:[dict objectForKey:@"name"]];
    }
    return college_list;
}

NSMutableArray* GetPreferences(NSArray* colleges)
{
    NSMutableArray *college_array = [[NSMutableArray alloc] init];
    for(NSString* college_name in colleges)
    {
        NSDictionary* new_dict = [NSDictionary dictionaryWithObject:college_name forKey:@"name"];
        [college_array addObject:new_dict];
    }
    //NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:colleges forKeys:keys];
    //NSLog(@"%@", jsonDictionary);
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:college_array
                                                       options:0
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData: jsonData encoding:NSUTF8StringEncoding];
    NSString *url_string = @"http://199.8.232.152/college_rank/getData.php?";
    
    url_string = [url_string stringByAppendingString:[NSString stringWithFormat:@"function=%@&institutions=%@", @"getPreferences", jsonString]];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_string]];
    NSLog(url_string);
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSMutableArray *college_list = [[NSMutableArray alloc] init];
    if(responseData != nil){
        
        NSError* localError;
        id collegeObj = [NSJSONSerialization JSONObjectWithData:responseData
                                                  options:0
                                                    error:&localError];
        for(NSDictionary* dict in collegeObj){
            [college_list addObject:dict];
        }
    }
    else{
        NSLog(@"No data!");
    }
    return college_list;

}
