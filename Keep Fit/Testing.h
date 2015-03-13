//
//  Testing.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 27/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Testing : NSObject

-(NSString *)getGoalDBName;
-(NSString *)getHistoryDBName;
-(NSString *)getStatisticsDBName;
-(NSString *)getMainpageStatsDBName;
-(NSDate *)getTime;
-(void)setTime:(NSDate *) changeDate;
-(BOOL)getTesting;
-(void)setTesting:(BOOL) isTesting;

@end
