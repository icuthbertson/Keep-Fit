//
//  KeepFitGoal.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 09/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeepFitGoal : NSObject

@property NSString *goalName;
@property BOOL completed;
@property (readonly) NSDate *creationDate;

@end
