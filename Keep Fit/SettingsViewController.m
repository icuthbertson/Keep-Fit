//
//  SettingsViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 23/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "SettingsViewController.h"
#import "TestGoalListTableViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *stairsLabel;
@property (weak, nonatomic) IBOutlet UIStepper *stepsStepper;
@property (weak, nonatomic) IBOutlet UIStepper *stairsStepper;
- (IBAction)stepsAction:(id)sender;
- (IBAction)stairsAction:(id)sender;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.stepsLabel.text = @"1";
    self.stairsLabel.text = @"1";
    self.stepsStepper.value = 1.0;
    self.stairsStepper.value = 1.0;
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
        destViewController.stepsTime = [self.stepsLabel.text intValue];
        destViewController.stairsTime = [self.stairsLabel.text intValue];
    }
}


- (IBAction)stepsAction:(id)sender {
    self.stepsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}

- (IBAction)stairsAction:(id)sender {
    self.stairsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}

@end
