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
@synthesize customData;

-(id)initWithName: (NSString *) InstitutionName
{
    if (self = [super init])
    {
        //reset custom dictionary
        self.customData = [[NSMutableDictionary alloc]init];
        //set the name
        self.name = InstitutionName;
        //grab data from webservice
        NSMutableArray * dataFromWeb = GetPreferences([[NSArray alloc] initWithObjects:InstitutionName, nil]);
        NSLog(@"%@",dataFromWeb);
        //stick data into dictionary
        if (dataFromWeb){
            self.data = [dataFromWeb objectAtIndex:0][0];
            NSLog(@"%@",[dataFromWeb objectAtIndex:0][0]);
            self.data = [[NSMutableDictionary alloc] initWithDictionary:self.data copyItems:true];
        }
        else{
            return nil;
        }
    }
    return self;
}

 - (NSString *) location{
     return [self.data valueForKey:@"zip_code"];
 }

 - (NSString*) type{
     return [self.data valueForKey:@"ownership"];
 }
 - (NSArray*) urbanization{
     return [self.data valueForKey:@"urbanization"];
 }

 - (NSString*) religiousAffiliation{
     return [self.data valueForKey:@"religion"];
 }

 - (NSString*) studyAbroad{
     return [[NSString alloc] initWithFormat:@"%d",([[self.data valueForKey:@"study_abroad"] isEqual:@"1"])];
 }

 - (NSString*) dayCare{
     return [[NSString alloc] initWithFormat:@"%d",([[self.data valueForKey:@"day_care"] isEqual:@"1"])];
 }

 - (NSString*) football{
     return [[NSString alloc] initWithFormat:@"%d",([[self.data valueForKey:@"football_memb"] isEqual:@"1"])];
 }

 - (NSString*) basketball{
     return [[NSString alloc] initWithFormat:@"%d",([[self.data valueForKey:@"basketball_memb"] isEqual:@"1"])];
 }

 - (NSString*) baseball{
     return [[NSString alloc] initWithFormat:@"%d",([[self.data valueForKey:@"baseball_memb"] isEqual:@"1"])];
 }

 - (NSString*) xCountryAndTrack{
     return [[NSString alloc] initWithFormat:@"%d",([[self.data valueForKey:@"xc_memb"] isEqual:@"1"])];
 }

 - (NSString*) degree{
     return [self.data valueForKey:@"degree"];
 }

 - (NSString*) size{
     return [self.data valueForKey:@"size"];
 }

- (NSString*) cost{
    NSArray* tempArr = [[NSArray alloc] initWithObjects:
                        [self.data valueForKey:@"cost_alone_in"],
                        [self.data valueForKey:@"cost_alone_out"],
                        [self.data valueForKey:@"cost_fam_in"],
                        [self.data valueForKey:@"cost_fam_out"],
                        [self.data valueForKey:@"cost_on_in"],
                        [self.data valueForKey:@"cost_on_out"], nil];
    
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
     return [self.data valueForKey:@"selectivity"];
 }

 - (NSString*) sat{
     int mathLow = 0;
     int mathHigh = 0;
     int readLow = 0;
     int readHigh = 0;
     @try{
         mathLow = [[self.data valueForKey:@"sat_math_25"] intValue];
         mathHigh = [[self.data valueForKey:@"sat_math_75"] intValue];
         readLow = [[self.data valueForKey:@"sat_read_25"] intValue];
         readHigh = [[self.data valueForKey:@"sat_read_75"] intValue];
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
     return [self.data valueForKey:@"stud_to_fac"];
 }

-(NSString*) femaleRatio
{
    int females = 0;
    BOOL crashed = false;
    @try{
        females = [[self.data valueForKey:@"women_perc"] intValue];
    }
    @catch (NSException *e) {
        NSLog(@"Female Error: %@",e.description);
        crashed = true;
    }
    if (crashed) return [[NSString alloc] initWithFormat:@"<null>"];
    return [[NSString alloc] initWithFormat:@"%i",females];
}

-(void) setValue: (NSString*) val ForKeyInDataDictionary: (NSString*) key{
    if ([self.data valueForKey:key]) {
        //then it contains the obj, so update it
        [self.data setValue:val forKey:key];
    }
}

- (NSString*) customValueForKey: (NSString*) key{
    return [customData objectForKey:key];
}

- (void) setValue: (NSString*) val ForKeyInCustomDictionary: (NSString*) key{
    [self.customData setObject:val forKey:key];
}
- (void) deleteKeyValuePairForKey: (NSString*) key{
    [self.customData removeObjectForKey:key];
}
@end

