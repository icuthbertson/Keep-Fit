//
//  ScheduleViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 24/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "ScheduleViewController.h"

@interface ScheduleViewController ()
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *stairsLabel;
@property (weak, nonatomic) IBOutlet UIStepper *stepsStepper;
@property (weak, nonatomic) IBOutlet UIStepper *stairsStepper;
@property (weak, nonatomic) IBOutlet UIDatePicker *scheduleDatePicker;
- (IBAction)stepsStepperAction:(id)sender;
- (IBAction)stairsStepperAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.stepsStepper.userInteractionEnabled = YES;
    self.stairsStepper.userInteractionEnabled = NO;
    self.stepsLabel.text = @"0";
    self.stairsLabel.text = @"0";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Stepper Control

- (IBAction)stepsStepperAction:(id)sender{
    self.stepsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}


- (IBAction)stairsStepperAction:(id)sender{
    self.stairsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (sender != self.saveButton) return;
    
    self.schedule = [[Schedule alloc] init];
    self.schedule.numSteps = [self.stepsLabel.text intValue];
    self.schedule.numStairs = [self.stairsLabel.text intValue];
    self.schedule.date = self.scheduleDatePicker.date;
}


@end
