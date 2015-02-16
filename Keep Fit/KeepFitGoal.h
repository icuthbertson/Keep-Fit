//
//  KeepFitGoal.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 09/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeepFitGoal : NSObject

typedef NS_ENUM(NSInteger, GoalStatus) {
    Pending = 0,
    Active,
    Overdue,
    Suspended,
    Abandoned
};

typedef NS_ENUM(NSInteger, GoalType) {
    Steps = 0,
    Stairs
};

@property NSInteger goalID;
@property NSString *goalName;
@property GoalStatus goalStatus;
@property GoalType goalType;
@property NSInteger goalAmount;
@property NSInteger goalProgress;
@property NSDate *goalCompletionDate;
@end
