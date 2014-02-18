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
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://199.8.232.152/college_rank/getData.php?function=getInstitutions"]];
    [request setHTTPMethod:@"POST"];
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    //NSString *str = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSMutableArray *college_list = [[NSMutableArray init] alloc];
    NSError* localError;
    id colleges = [NSJSONSerialization JSONObjectWithData:responseData
                                                            options:0
                                                              error:&localError];
    //for(NSDictionary* dict in colleges)
    
    NSLog(@"%@", colleges);
    return [[NSMutableArray init] alloc];
}