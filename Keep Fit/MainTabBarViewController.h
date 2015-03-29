//
//  MainTabBarViewController.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 07/03/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Testing.h"
#import "TestSettings.h"
#import "Settings.h"

@interface MainTabBarViewController : UITabBarController

@property Testing *testing;
@property TestSettings *testSettings;
@property Settings *settings;

@end
