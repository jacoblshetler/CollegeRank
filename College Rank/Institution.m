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
     return [self.data valueForKey:@"zip_code"][0];
 }

 - (NSString*) type{
 return nil;
 }/*
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
 
 }*/
 - (NSString*) size{
     return [self.data valueForKey:@"size"][0];
 }
- (NSString*) cost: (NSString*)type{
    //acceptable values for parameter "type" are:
    //cost_alone_in
    //cost_alone_out
    //cost_fam_in
    //cost_fam_out
    //cost_on_in
    //cost_in_out
     return [self.data valueForKey:type][0];
 }
 - (NSString*) selectivity{
     return [self.data valueForKey:@"selectivity"][0];
 }
 - (NSString*) sat{
     int mathAverage = ([[self.data valueForKey:@"sat_math_25"][0] intValue]+[[self.data valueForKey:@"sat_math_75"][0] intValue])/2;
     int readAverage = ([[self.data valueForKey:@"sat_read_25"][0] intValue]+[[self.data valueForKey:@"sat_read_75"][0] intValue])/2;
     return [[NSString alloc] initWithFormat:@"%d",mathAverage+readAverage];
 }
/* - (NSArray*) demographics{
 
 }
 */
 - (NSNumber *) studentFacultyRatio{
     return [self.data valueForKey:@"stud_to_fac"][0];
 }


@end

