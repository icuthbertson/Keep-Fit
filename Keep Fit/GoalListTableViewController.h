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

-(IBAction)unwindToList:(UIStoryboardSegue *)segue; // Segue returning from add view.
-(IBAction)unwindFromView:(UIStoryboardSegue *)segue; // Segue returning from view goal view.
-(IBAction)unwindFromViewTest:(UIStoryboardSegue *)segue; // Segue returning from view goal view.
-(IBAction)unwindFromSettings:(UIStoryboardSegue *)segue; // Segue returning from settings view.
-(IBAction)unwindFromListSelection:(UIStoryboardSegue *)segue; // Segue returning from list selection.

@property NSInteger listType; // Hold integer to tell which goal type to list.

@end
