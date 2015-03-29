//
//  Settings.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 16/03/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeepFitGoal.h"

@interface Settings : NSObject

@property Conversion goalConversionSetting;
@property BOOL notifications;
@property BOOL socialMedia;
@property BOOL pending;
@property BOOL active;
@property BOOL overdue;
@property BOOL suspended;
@property BOOL abandoned;
@property BOOL completed;

@end
