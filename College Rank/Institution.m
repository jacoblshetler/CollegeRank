//
//  Institution.m
//  College Rank
//
//  Created by Philip Bontrager on 3/11/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//


#import "Institution.h"
#import "DataRetreiver.h"

@implementation Institution

@synthesize name;
@synthesize data;

-(id)initWithName: (NSString *) InstitutionName
{
    if (self = [super init])
    {
        //set the name
        self.name = InstitutionName;
        //grab data from webservice
        NSMutableArray * dataFromWeb = GetPreferences([[NSArray alloc] initWithObjects:InstitutionName, nil]);
        //stick data into dictionary
        if (dataFromWeb){
            self.data = [dataFromWeb objectAtIndex:0];
        }
        else{
            return nil;
        }
    }
    return self;
}



 - (NSString *) location{
     NSLog(@"%@",[self.data valueForKey:@"zip_code"][0]);
     
     NSString *className = NSStringFromClass([[self.data valueForKey:@"zip_code"][0] class]);
     NSLog(@"%@",className);
     
     return [self.data valueForKey:@"zip_code"][0];
//     return [[self.data valueForKey:@"zip_code"] componentsJoinedByString:@""];
 }
/*
 - (NSString*) type{
 return nil;
 }
 - (NSArray*) urbanization{
 
 }
 - (NSString*) religiousAffiliation{
 
 }
 - (BOOL) studyAbroad{
 
 }
 - (BOOL) dayCare{
 
 }
 - (BOOL) football{
 
 }
 - (BOOL) basketball{
 
 }
 - (BOOL) baseball{
 
 }
 - (BOOL) xCountryAndTrack{
 
 }
 - (NSString*) degree{
 
 }
 - (int) size{
 return 0;
 }
 - (int) cost{
 return 0;
 }
 - (int) selectivity{
 return 0;
 }
 - (float) sat{
 
 }
 - (NSArray*) demographics{
 
 }
 - (int) studentFacultyRatio{
 return 0;
 }
 */

@end

