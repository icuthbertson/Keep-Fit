//
//  KeepFitGoal.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 09/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeepFitGoal : NSObject

// ENUMs of goal statuses.
typedef NS_ENUM(NSInteger, GoalStatus) {
    Pending = 0,
    Active,
    Overdue,
    Suspended,
    Abandoned,
    Completed
};

// ENUMs of goal types.
typedef NS_ENUM(NSInteger, GoalType) {
    Steps = 0,
    Stairs,
    Both
};

// ENUMs of goal conversions.
typedef NS_ENUM(NSInteger, Conversion) {
    StepsStairs = 0,
    Feet,
    Meters,
    Miles,
    Km
};

@property NSInteger goalID; // ID of goal.
@property NSString *goalName; // Name of goal.
@property GoalStatus goalStatus; // Status of goal.
@property GoalType goalType; // Type of goal.
@property NSInteger goalAmountSteps; // Steps amount for goal.
@property NSInteger goalProgressSteps; // Steps progress for goal.
@property NSInteger goalAmountStairs; // Stairs amount for goal.
@property NSInteger goalProgressStairs; // Stairs progress for goal.
@property NSDate *goalStartDate; // Start date/time for goal.
@property NSDate *goalCompletionDate; // End date/time for goal.
@property NSDate *goalCreationDate; // Creation date/time of goal.
@property Conversion goalConversion; // Conversion type for goal.
@property NSArray *conversionTable; // Conversion table that holds conversion from steps to miles, km, etc.

@end
