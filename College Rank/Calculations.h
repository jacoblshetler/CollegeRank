//
//  Calculations.h
//  College Rank
//
//  Created by Jacob Levi Shetler on 2/17/14.
//  Copyright (c) 2014 GCInformatics. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Normalizes an NSMutableArray of NSDecimalNumbers and returns it in the same order. The normalized vales will sum to 1 and will all be between 0 and 1.
 @param prefValues
 The NSMutableArray of floating point preference values
 @return NSMutableArray of normalized NSDecimalNumbers representing preference values
 */
NSMutableArray * normalize(NSMutableArray * prefValues);
double geoDistance(NSString * zip1, NSString * zip2);
NSMutableDictionary * generateRankings();
NSMutableDictionary * calculatePreferences(NSMutableArray * incomingInstitutions, NSMutableArray* weights);

void updateWeights(int index, float newWeight);
NSArray * weightToWorkWith(int index);

NSMutableArray * normalizeFromContinuum(NSMutableArray * yValues);