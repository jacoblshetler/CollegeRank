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
        NSLog(@"%@",dataFromWeb);
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
     return [self.data valueForKey:@"ownership"][0];
 }
 - (NSArray*) urbanization{
     return [self.data valueForKey:@"urbanization"][0];
 }

 - (NSString*) religiousAffiliation{
     return [self.data valueForKey:@"religion"][0];
 }

 - (NSString*) studyAbroad{
     return [[NSString alloc] initWithFormat:@"%d",([[self.data valueForKey:@"study_abroad"][0] isEqual:@"1"])];
 }

 - (NSString*) dayCare{
     return [[NSString alloc] initWithFormat:@"%d",([[self.data valueForKey:@"day_care"][0] isEqual:@"1"])];
 }

 - (NSString*) football{
     return [[NSString alloc] initWithFormat:@"%d",([[self.data valueForKey:@"football_memb"][0] isEqual:@"1"])];
 }

 - (NSString*) basketball{
     return [[NSString alloc] initWithFormat:@"%d",([[self.data valueForKey:@"basketball_memb"][0] isEqual:@"1"])];
 }

 - (NSString*) baseball{
     return [[NSString alloc] initWithFormat:@"%d",([[self.data valueForKey:@"baseball_memb"][0] isEqual:@"1"])];
 }

 - (NSString*) xCountryAndTrack{
     return [[NSString alloc] initWithFormat:@"%d",([[self.data valueForKey:@"xc_memb"][0] isEqual:@"1"])];
 }

 - (NSString*) degree{
     return [self.data valueForKey:@"degree"][0];
 }

 - (NSString*) size{
     return [self.data valueForKey:@"size"][0];
 }

- (NSString*) cost{
    NSArray* tempArr = [[NSArray alloc] initWithObjects:
                        [self.data valueForKey:@"cost_alone_in"][0],
                        [self.data valueForKey:@"cost_alone_out"][0],
                        [self.data valueForKey:@"cost_fam_in"][0],
                        [self.data valueForKey:@"cost_fam_out"][0],
                        [self.data valueForKey:@"cost_on_in"][0],
                        [self.data valueForKey:@"cost_on_out"][0], nil];
    
    int count = 0;
    int terriblePracticeArr = 0;
    for(id object in tempArr)
    {
        if([object isEqual:[NSNull null]]){
            continue;
        }
        if(![object isEqualToString:@"<null>"])
        {
            count += 1;
            terriblePracticeArr += (int)object;
        }
    }
    if (count==0) {
        return [[NSString alloc] initWithFormat:@"<null>"];
    }
    terriblePracticeArr = terriblePracticeArr/count;
    return [[NSString alloc] initWithFormat:@"%i",terriblePracticeArr];
 }

 - (NSString*) selectivity{
     return [self.data valueForKey:@"selectivity"][0];
 }

 - (NSString*) sat{
     int mathLow = 0;
     int mathHigh = 0;
     int readLow = 0;
     int readHigh = 0;
     @try{
         mathLow = [[self.data valueForKey:@"sat_math_25"][0] intValue];
         mathHigh = [[self.data valueForKey:@"sat_math_75"][0] intValue];
         readLow = [[self.data valueForKey:@"sat_read_25"][0] intValue];
         readHigh = [[self.data valueForKey:@"sat_read_75"][0] intValue];
     }
     @catch (NSException *e) {
         //NSLog(@"SAT Error: %@",e.description);
         return [[NSString alloc] initWithFormat:@"<null>"];
     }
     int mathAverage = (mathLow+mathHigh)/2;
     int readAverage = (readLow+readHigh)/2;
     return [[NSString alloc] initWithFormat:@"%d",mathAverage+readAverage];
 }

- (NSDictionary*) demographics{
    return @{@"asian":[self.data valueForKey:@"asian_perc"],
             @"black":[self.data valueForKey:@"black_perc"],
             @"hispanic":[self.data valueForKey:@"hispanic_perc"],
             @"native":[self.data valueForKey:@"native_perc"],
             @"pacific":[self.data valueForKey:@"pac_isl_perc"],
             @"white":[self.data valueForKey:@"white_perc"]
             };
 }


 - (NSNumber *) studentFacultyRatio{
     return [self.data valueForKey:@"stud_to_fac"][0];
 }

-(NSString*) femaleRatio
{
    int females = 0;
    BOOL crashed = false;
    @try{
        females = [[self.data valueForKey:@"women_perc"][0] intValue];
    }
    @catch (NSException *e) {
        NSLog(@"Female Error: %@",e.description);
        crashed = true;
    }
    if (crashed) return [[NSString alloc] initWithFormat:@"<null>"];
    return [[NSString alloc] initWithFormat:@"%i",females];
}
@end

