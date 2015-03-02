//
//  TestMenuViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 02/03/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "TestMenuViewController.h"
#import "TestGoalListTableViewController.h"

@interface TestMenuViewController ()

@end

@implementation TestMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    if ([segue.identifier isEqualToString:@"testingMode"]) {
        TestGoalListTableViewController *destViewController = segue.destinationViewController;
        // Pass the goal to be veiewed.
        destViewController.settings = self.settings;
    }
}


@end
