//
//  ViewGoalViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 11/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "ViewGoalViewController.h"
#import "KeepFitGoal.h"
#import "GoalListTableViewController.h"
#import "EditGoalViewController.h"


@interface ViewGoalViewController ()

@end

@implementation ViewGoalViewController

-(IBAction)unwindToView:(UIStoryboardSegue *)segue {
    //EditGoalViewController *source = [segue sourceViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@", self.viewGoal.goalName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showEditGoal"]) {
        EditGoalViewController *destViewController = segue.destinationViewController;
        destViewController.editGoal = self.viewGoal;
    }
}


@end
