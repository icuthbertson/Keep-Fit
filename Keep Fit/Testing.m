//
//  Testing.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 27/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "Testing.h"

@implementation Testing {
    NSDate *currentTime;
    BOOL testing;
}

-(NSString *)getGoalDBName {
    if (testing) {
        return @"testGoals";
    }
    return @"goals";
}

-(NSString *)getHistoryDBName {
    if (testing) {
        return @"testHistory";
    }
    return @"history";
}

-(NSDate *)getTime {
    if (testing) {
        return currentTime;
    }
    return [NSDate date];
}

-(void)setTime:(NSDate *) changeDate {
    currentTime = changeDate;
}

-(BOOL)getTesting {
    return testing;
}

-(void)setTesting:(BOOL)isTesting {
    testing = isTesting;
}

@end
