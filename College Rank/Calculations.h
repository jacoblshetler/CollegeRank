//
//  Calculations.h
//  College Rank
//
//  Created by Jacob Levi Shetler on 2/17/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <Foundation/Foundation.h>

//TODO: We need to rethink how the methods that generate preference data are going to work
//for the different preference types, as Philip pointed out

/**
 Normalizes an NSMutableArray of NSDecimalNumbers and returns it in the same order. The normalized vales will sum to 1 and will all be between 0 and 1.
 @param prefValues
 The NSMutableArray of floating point preference values
 @return NSMutableArray of normalized NSDecimalNumbers representing preference values
 */
NSMutableArray * normalize(NSMutableArray * prefValues);
float geoDistance(NSString * zip1, NSString * zip2);
NSDictionary * generateRankings(NSMutableArray * usedInstitutions);
NSMutableArray * calculatePreferences(NSMutableArray * incomingInstitutions);
