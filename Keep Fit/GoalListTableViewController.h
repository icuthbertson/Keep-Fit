//
//  GoalListTableViewController.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 09/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//  Base of class from https://developer.apple.com/library/ios/referencelibrary/GettingStarted/RoadMapiOS/index.html#//apple_ref/doc/uid/TP40011343-CH2-SW1
//

#import <UIKit/UIKit.h>

@interface GoalListTableViewController : UITableViewController

-(IBAction)unwindToList:(UIStoryboardSegue *)segue;
-(IBAction)unwindFromView:(UIStoryboardSegue *)segue;
-(IBAction)unwindFromSettings:(UIStoryboardSegue *)segue;
-(IBAction)unwindFromListSelection:(UIStoryboardSegue *)segue;

@property NSInteger listType;

@end
