//
//  EditGoalViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 11/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "EditGoalViewController.h"

@interface EditGoalViewController ()

@end

@implementation EditGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = [NSString stringWithFormat:@"Edit %@", self.editGoal.goalName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
