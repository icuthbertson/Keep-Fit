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
@property (weak, nonatomic) IBOutlet UIDatePicker *scheduleEndDatePicker;
- (IBAction)stepsStepperAction:(id)sender;
- (IBAction)stairsStepperAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 568)];
    
    switch (self.viewGoal.goalType) {
        case 0:
            self.stepsStepper.userInteractionEnabled = YES;
            self.stairsStepper.userInteractionEnabled = NO;
            break;
        case 1:
            self.stepsStepper.userInteractionEnabled = NO;
            self.stairsStepper.userInteractionEnabled = YES;
            break;
        case 2:
            self.stepsStepper.userInteractionEnabled = YES;
            self.stairsStepper.userInteractionEnabled = YES;
            
            break;
        default:
            break;
    }
    self.stepsLabel.text = @"0";
    self.stairsLabel.text = @"0";
    
    [self.scheduleDatePicker setMinimumDate:self.currentTime];
    [self.scheduleDatePicker setDate:self.currentTime];
    [self.scheduleEndDatePicker setMinimumDate:self.currentTime];
    [self.scheduleEndDatePicker setDate:self.currentTime];
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
    if ((self.viewGoal.goalProgressSteps + [self.stepsLabel.text intValue]) >= self.viewGoal.goalAmountSteps) {
        self.schedule.numSteps = (self.viewGoal.goalAmountSteps - self.viewGoal.goalProgressSteps);
    }
    else {
        self.schedule.numSteps = [self.stepsLabel.text intValue];
    }
    if ((self.viewGoal.goalProgressStairs + [self.stairsLabel.text intValue]) >= self.viewGoal.goalAmountStairs) {
        self.schedule.numStairs = (self.viewGoal.goalAmountStairs - self.viewGoal.goalProgressStairs);
    }
    else {
        self.schedule.numStairs = [self.stairsLabel.text intValue];
    }
    if (((self.viewGoal.goalProgressSteps + [self.stepsLabel.text intValue]) >= self.viewGoal.goalAmountSteps) && ((self.viewGoal.goalProgressStairs + [self.stairsLabel.text intValue]) >= self.viewGoal.goalAmountStairs)) {
        self.schedule.completed = YES;
    }
    else {
        self.schedule.completed = NO;
    }
    
    self.schedule.date = self.scheduleDatePicker.date;
    self.schedule.endDate = self.scheduleEndDatePicker.date;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (sender == self.saveButton)  {
        if ([[self.scheduleEndDatePicker.date earlierDate:self.currentTime]isEqualToDate: self.scheduleEndDatePicker.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Schedule" message:@"Completion Date/Time must be in the future." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        if ([[self.scheduleEndDatePicker.date earlierDate:self.scheduleDatePicker.date]isEqualToDate: self.scheduleEndDatePicker.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Schedule" message:@"End Date/Time must not be in before the Start Date/Time." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        if ([[self.scheduleDatePicker.date earlierDate:self.currentTime]isEqualToDate: self.scheduleDatePicker.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Schedule" message:@"Start Date/Time must be in the future." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        switch (self.viewGoal.goalType) {
            case 0: //steps
                if ([self.stepsLabel.text intValue] == 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Schedule" message:@"Number of steps cannot be zero." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                }
                break;
            case 1: //stairs
                if ([self.stairsLabel.text intValue] == 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Schedule" message:@"Number of stairs cannot be zero." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                }
                break;
            case 2: //both
                if (([self.stepsLabel.text intValue] == 0) && ([self.stairsLabel.text intValue] == 0)) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Schedule" message:@"Either Steps or Stairs must not be zero." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                }
                break;
            default:
                break;
        }
    }
    return YES;
}


@end
