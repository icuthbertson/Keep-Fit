//
//  AddGoalViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 09/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//  Base of class from https://developer.apple.com/library/ios/referencelibrary/GettingStarted/RoadMapiOS/index.html#//apple_ref/doc/uid/TP40011343-CH2-SW1
//

#import "AddGoalViewController.h"

@interface AddGoalViewController ()

// UI Outlet and Action declarations.
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *dateStartPicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSelecter;
- (IBAction)typeSelecterAction:(id)sender;
- (IBAction)stepsStepperAction:(id)sender;
- (IBAction)stairsStepperAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *numStepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numStairsLabel;
@property (weak, nonatomic) IBOutlet UIStepper *stepsStepper;
@property (weak, nonatomic) IBOutlet UIStepper *stairsStepper;
- (IBAction)conversionSelector:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *conversionTypeSelector;
@property (weak, nonatomic) IBOutlet UILabel *numStepsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numStairsTitleLabel;

@end

@implementation AddGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up the scroll view.
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 800)];
    
    // Set the minimum date of the date pickers to the current time
    // or stored time from the Testing object.
    [self.dateStartPicker setMinimumDate:[NSDate date]];
    [self.datePicker setMinimumDate:[NSDate date]];
    
    self.conversionTypeSelector.selectedSegmentIndex = self.settings.goalConversionSetting;
    
    if (self.conversionTypeSelector.selectedSegmentIndex == 0) { //steps and stairs
        self.goal.goalConversion = StepsStairs;
        self.numStepsTitleLabel.text = @"Number of Steps";
        self.numStairsTitleLabel.text = @"Number of Stair";
        self.numStairsLabel.text = @"0";
        self.numStepsLabel.text = @"0";
        self.stepsStepper.value = 0;
        self.stairsStepper.value = 0;
    }
    else if (self.conversionTypeSelector.selectedSegmentIndex == 1) { //imperial
        self.goal.goalConversion = Imperial;
        self.numStepsTitleLabel.text = @"Number of Miles to walk";
        self.numStairsTitleLabel.text = @"Number of Feet to climb";
        self.numStairsLabel.text = @"0";
        self.numStepsLabel.text = @"0";
        self.stepsStepper.value = 0;
        self.stairsStepper.value = 0;
    }
    else { //metric
        self.goal.goalConversion = Metric;
        self.numStepsTitleLabel.text = @"Number of Kilometers to walk";
        self.numStairsTitleLabel.text = @"Number of Meters to climb";
        self.numStairsLabel.text = @"0";
        self.numStepsLabel.text = @"0";
        self.stepsStepper.value = 0;
        self.stairsStepper.value = 0;
    }
    
    // Enable default steppers enabled (steps enabled, stairs disabled)
    self.stepsStepper.userInteractionEnabled = YES;
    self.stairsStepper.userInteractionEnabled = NO;
    self.numStepsLabel.text = @"0";
    self.numStairsLabel.text = @"0";
    
    // TapGestureRecognizer declaration for closing the keyboard if there is a tap off of it.
    // Code from http://stackoverflow.com/questions/5306240/iphone-dismiss-keyboard-when-touching-outside-of-textfield
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// TapGestureRecognizer method for closing the keyboard if there is a tap off of it.
// Code from http://stackoverflow.com/questions/5306240/iphone-dismiss-keyboard-when-touching-outside-of-textfield
-(void)dismissKeyboard {
    [self.textField resignFirstResponder];
}

#pragma mark - Stepper Control

// Action from Steps Stepper to change the value shown in the Steps label.
- (IBAction)stepsStepperAction:(id)sender {
    if (self.conversionTypeSelector.selectedSegmentIndex == 0) { //steps
        if (self.stepsStepper.value >= 0 && self.stepsStepper.value < 10) {
            [self.stepsStepper setStepValue:1.0];
        } else if (self.stepsStepper.value >= 10 && self.stepsStepper.value < 50) {
            [self.stepsStepper setStepValue:5.0];
        }
        else if (self.stepsStepper.value >= 50 && self.stepsStepper.value < 250) {
            [self.stepsStepper setStepValue:25.0];
        }
        else if (self.stepsStepper.value >= 250 && self.stepsStepper.value < 1000) {
            [self.stepsStepper setStepValue:50.0];
        }
        else {
            [self.stepsStepper setStepValue:100.0];
        }
    }
    else if (self.conversionTypeSelector.selectedSegmentIndex == 1) { //miles
        [self.stepsStepper setStepValue:1.0];
    }
    else { //km
        [self.stepsStepper setStepValue:1.0];
    }
    self.numStepsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}

// Action from Stairs Stepper to change the value shown in the Stairs label.
- (IBAction)stairsStepperAction:(id)sender {
    if (self.stairsStepper.value >= 0 && self.stairsStepper.value < 10) {
        [self.stairsStepper setStepValue:1.0];
    } else if (self.stairsStepper.value >= 10 && self.stairsStepper.value < 50) {
        [self.stairsStepper setStepValue:5.0];
    }
    else if (self.stairsStepper.value >= 50 && self.stairsStepper.value < 250) {
        [self.stairsStepper setStepValue:25.0];
    }
    else if (self.stairsStepper.value >= 250 && self.stairsStepper.value < 1000) {
        [self.stairsStepper setStepValue:50.0];
    }
    else {
        [self.stairsStepper setStepValue:100.0];
    }
    self.numStairsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}

#pragma mark - Segmented Control

// Action from Type Selector to change the goal type between Steps, Stairs and Both.
- (IBAction)typeSelecterAction:(id)sender {
    // If selector at 0.
    if(self.typeSelecter.selectedSegmentIndex == 0) {
        NSLog(@"Selecter 0");
        // Set only the Steps stepper to enabled.
        // Set Stairs stepper to 0.
        self.stepsStepper.userInteractionEnabled = YES;
        self.stairsStepper.userInteractionEnabled = NO;
        self.numStairsLabel.text = @"0";
        self.stairsStepper.value = 0;
    }
    else if (self.typeSelecter.selectedSegmentIndex == 1) {
        NSLog(@"Selecter 1");
        // Set only the Stairs stepper to enabled.
        // Set Steps stepper to 0.
        self.stepsStepper.userInteractionEnabled = NO;
        self.stairsStepper.userInteractionEnabled = YES;
        self.numStepsLabel.text = @"0";
        self.stepsStepper.value = 0;
    }
    else {
        NSLog(@"Selecter 2");
        // Set both the Steps and Stairs stepper to enabled.
        self.stepsStepper.userInteractionEnabled = YES;
        self.stairsStepper.userInteractionEnabled = YES;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // If the Cancel button was pressed (ie. not the save button)
    // Just return.
    if (sender != self.saveButton) return;
    
    // Initalise Goal to be passed back to the GoalList.
    self.goal = [[KeepFitGoal alloc] init];
    // Trim the white space from the start and end of the goal title.
    NSString *trimmedString = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.goal.goalName = trimmedString;
    
    // Set the status of the new goal to Pending.
    self.goal.goalStatus = Pending;
    
    // Test the Type Selector value.
    if(self.typeSelecter.selectedSegmentIndex == 0) {
        // If the type selector is at 0.
        // Set the goal type to Steps and pull the number of steps from the stepper.
        // Set the number of stairs to zero.
        self.goal.goalType = Steps;
        self.goal.goalAmountSteps = [self.numStepsLabel.text intValue];
        self.goal.goalAmountStairs = 0;
    }
    else if (self.typeSelecter.selectedSegmentIndex == 1) {
        // If the type selector is at 1.
        // Set the goal type to Stairs and pull the number of steps from the stepper.
        // Set the number of steps to zero.
        self.goal.goalType = Stairs;
        self.goal.goalAmountStairs = [self.numStairsLabel.text intValue];
        self.goal.goalAmountSteps = 0;
    }
    else {
        // If the type selector is at 2.
        // Set the goal type to Both, pull the number of steps from the stepper
        // and pull the number of stairs from the stepper.
        self.goal.goalType = Both;
        self.goal.goalAmountSteps = [self.numStepsLabel.text intValue];
        self.goal.goalAmountStairs = [self.numStairsLabel.text intValue];
        
    }
    if (self.conversionTypeSelector.selectedSegmentIndex == 1) {
        self.goal.goalAmountSteps = self.goal.goalAmountSteps*2112; // to miles
        self.goal.goalAmountStairs = self.goal.goalAmountStairs*1.385; // to feet
    }
    else if (self.conversionTypeSelector.selectedSegmentIndex == 2) {
        self.goal.goalAmountSteps = self.goal.goalAmountSteps*1312; // to km
        self.goal.goalAmountStairs = self.goal.goalAmountStairs*4.545; // to meters
    }
    
    // Set the progress towards the goals to 0.
    self.goal.goalProgressSteps = 0;
    self.goal.goalProgressStairs = 0;
    
    // Set the start and end date of the goal to those from their respective date pickers.
    self.goal.goalStartDate = self.dateStartPicker.date;
    
    self.goal.goalCompletionDate = self.datePicker.date;
    
    // Set the creation date of the goal to the current date.
    self.goal.goalCreationDate = [NSDate date];
    
    // Set the coversion type of the goal to that of the type selector.
    self.goal.goalConversion = self.conversionTypeSelector.selectedSegmentIndex;
    
    NSLog(@"Goal Name: %@",self.goal.goalName);
    NSLog(@"Goal Status: %d",self.goal.goalStatus);
    NSLog(@"Goal Type: %d",self.goal.goalType);
    NSLog(@"Goal Amount Steps: %ld",(long)self.goal.goalAmountSteps);
    NSLog(@"Goal Amount Stairs: %ld",(long)self.goal.goalAmountStairs);
    NSLog(@"Goal Progress Steps: %ld",(long)self.goal.goalProgressSteps);
    NSLog(@"Goal Progress Stairs: %ld",(long)self.goal.goalProgressSteps);
    NSLog(@"Goal Start Date: %@",self.goal.goalStartDate);
    NSLog(@"Goal Completion Date: %@",self.goal.goalCompletionDate);
    NSLog(@"Goal Creation Date: %@",self.goal.goalCreationDate);
    NSLog(@"Goal Conversion: %d",self.goal.goalConversion);
}

// This method is used to test the inputs and stop the prepareForSegue method from being called if No is returned.
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    // Trim the white space from the string from the goal name TextField.
    NSString *trimmedString = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (sender == self.saveButton)  {
        // If the Goal name has no loength (no entered) alert with message and return NO.
        if ((trimmedString.length == 0)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Please enter a name for the goal." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        // If the end date/time is before the current date/time alert with message and return NO.
        if ([[self.datePicker.date earlierDate:[NSDate date]]isEqualToDate: self.datePicker.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Completion Date/Time must be in the future." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        // If the end date/time is before the start date/time alert with message and return NO.
        if ([[self.datePicker.date earlierDate:self.dateStartPicker.date]isEqualToDate: self.datePicker.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Completion Date/Time must not be in before the Start Date/Time." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        // If the start date/time is before the current date/time alert with message and return NO.
        if ([[self.dateStartPicker.date earlierDate:[NSDate date]]isEqualToDate: self.dateStartPicker.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Start Date/Time must be in the future." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        switch (self.typeSelecter.selectedSegmentIndex) {
            case 0: //steps
                // If Steps goal and number of steps is 0 alert with message and return NO.
                if ([self.numStepsLabel.text intValue] == 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Number of steps cannot be zero." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                }
                break;
            case 1: //stairs
                // If Stairs goal and number of stairs is 0 alert with message and return NO.
                if ([self.numStairsLabel.text intValue] == 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Number of stairs cannot be zero." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                }
                break;
            case 2: //both
                // If Both goal and number of steps or stairs is 0 alert with message and return NO.
                if ([self.numStepsLabel.text intValue] == 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Number of steps cannot be zero." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                }
                if ([self.numStairsLabel.text intValue] == 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Number of stairs cannot be zero." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                }
                break;
            default:
                break;
        }
        // If the goal name has been used before alert with message and return NO.
        for (int i=0; i<[self.listGoalNames count]; i++) {
            if ([trimmedString isEqualToString:[self.listGoalNames objectAtIndex:i]]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Goal with the same name already exists. Please choose a different name." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
        }
    }
    // If all of the sanity checks were passed return YES and go back to the Goal List.
    return YES;
}

- (IBAction)conversionSelector:(id)sender {
    if (self.conversionTypeSelector.selectedSegmentIndex == 0) { //steps and stairs
        self.goal.goalConversion = StepsStairs;
        self.numStepsTitleLabel.text = @"Number of Steps";
        self.numStairsTitleLabel.text = @"Number of Stair";
        self.numStairsLabel.text = @"0";
        self.numStepsLabel.text = @"0";
        self.stepsStepper.value = 0;
        self.stairsStepper.value = 0;
    }
    else if (self.conversionTypeSelector.selectedSegmentIndex == 1) { //imperial
        self.goal.goalConversion = Imperial;
        self.numStepsTitleLabel.text = @"Number of Miles to walk";
        self.numStairsTitleLabel.text = @"Number of Feet to climb";
        self.numStairsLabel.text = @"0";
        self.numStepsLabel.text = @"0";
        self.stepsStepper.value = 0;
        self.stairsStepper.value = 0;
    }
    else { //metric
        self.goal.goalConversion = Metric;
        self.numStepsTitleLabel.text = @"Number of Kilometers to walk";
        self.numStairsTitleLabel.text = @"Number of Meters to climb";
        self.numStairsLabel.text = @"0";
        self.numStepsLabel.text = @"0";
        self.stepsStepper.value = 0;
        self.stairsStepper.value = 0;
    }
}

@end
