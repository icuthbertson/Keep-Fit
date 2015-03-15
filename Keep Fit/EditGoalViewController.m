//
//  EditGoalViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 11/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "EditGoalViewController.h"

@interface EditGoalViewController ()

// UI Outlet and Action declarations.
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *editTitleField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *editTypeField;
- (IBAction)typeSelecterAction:(id)sender;
- (IBAction)stepsStepperAction:(id)sender;
- (IBAction)stairsStepperAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIDatePicker *editDateField;
@property (weak, nonatomic) IBOutlet UIDatePicker *editStartDateField;
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

@implementation EditGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the minimum date of the date pickers to the current time
    // or stored time from the Testing object.
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 800)];
    
    // Set the navigation bar title.
    self.navigationItem.title = [NSString stringWithFormat:@"Edit %@", self.editGoal.goalName];
    
    // TapGestureRecognizer declaration for closing the keyboard if there is a tap off of it.
    // Code from http://stackoverflow.com/questions/5306240/iphone-dismiss-keyboard-when-touching-outside-of-textfield
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // Set up the fields in the view with the values from the goal to be editted.
    self.editTitleField.text = self.editGoal.goalName;
    self.editTypeField.selectedSegmentIndex = self.editGoal.goalType;
    switch (self.editGoal.goalType) {
        case Steps:
            self.stepsStepper.userInteractionEnabled = YES;
            self.stairsStepper.userInteractionEnabled = NO;
            break;
        case Stairs:
            self.stepsStepper.userInteractionEnabled = NO;
            self.stairsStepper.userInteractionEnabled = YES;
            break;
        default:
            break;
    }
    
    if (self.editGoal.goalConversion == StepsStairs) { //steps and stairs
        self.numStepsTitleLabel.text = @"Number of Steps";
        self.numStairsTitleLabel.text = @"Number of Stair";
        self.numStepsLabel.text = [NSString stringWithFormat:@"%ld",(long)self.editGoal.goalAmountSteps];
        self.stepsStepper.value = [self.numStepsLabel.text intValue];
        self.numStairsLabel.text = [NSString stringWithFormat:@"%ld",(long)self.editGoal.goalAmountStairs];
        self.stairsStepper.value = [self.numStairsLabel.text intValue];
    }
    else if (self.editGoal.goalConversion == Imperial) { //imperial
        self.numStepsTitleLabel.text = @"Number of Miles to walk";
        self.numStairsTitleLabel.text = @"Number of Feet to climb";
        self.numStepsLabel.text = [NSString stringWithFormat:@"%.0f",(long)self.editGoal.goalAmountSteps/[[self.editGoal.conversionTable objectAtIndex:1] doubleValue]];
        self.stepsStepper.value = [self.numStepsLabel.text intValue];
        self.numStairsLabel.text = [NSString stringWithFormat:@"%.0f",(long)self.editGoal.goalAmountStairs/[[self.editGoal.conversionTable objectAtIndex:3] doubleValue]];
        self.stairsStepper.value = [self.numStairsLabel.text intValue];
    }
    else { //metric
        self.numStepsTitleLabel.text = @"Number of Kilometers to walk";
        self.numStairsTitleLabel.text = @"Number of Meters to climb";
        self.numStepsLabel.text = [NSString stringWithFormat:@"%.0f",(long)self.editGoal.goalAmountSteps/[[self.editGoal.conversionTable objectAtIndex:2] doubleValue]];
        self.stepsStepper.value = [self.numStepsLabel.text intValue];
        self.numStairsLabel.text = [NSString stringWithFormat:@"%.0f",(long)self.editGoal.goalAmountStairs/[[self.editGoal.conversionTable objectAtIndex:4] doubleValue]];
        self.stairsStepper.value = [self.numStairsLabel.text intValue];
    }
    
    // Set the date pickers to be active depending on the status of the goal.
    self.editTitleField.userInteractionEnabled = NO;
    if (self.editGoal.goalStatus == Active) {
        self.editStartDateField.userInteractionEnabled = NO;
    }
    else if (self.editGoal.goalStatus == Overdue) {
        self.editDateField.userInteractionEnabled = NO;
        self.editStartDateField.userInteractionEnabled = NO;
    }
    
    [self.editStartDateField setDate:self.editGoal.goalStartDate];
    [self.editDateField setDate:self.editGoal.goalCompletionDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// TapGestureRecognizer method for closing the keyboard if there is a tap off of it.
// Code from http://stackoverflow.com/questions/5306240/iphone-dismiss-keyboard-when-touching-outside-of-textfield
-(void)dismissKeyboard {
    [self.editTitleField resignFirstResponder];
}

#pragma mark - Segmented Control

// Action from Type Selector to change the goal type between Steps, Stairs and Both.
- (IBAction)typeSelecterAction:(id)sender {
    // If selector at 0.
    if(self.editTypeField.selectedSegmentIndex == 0) {
        // Set only the Steps stepper to enabled.
        // Set Stairs stepper to 0.
        self.stepsStepper.userInteractionEnabled = YES;
        self.stairsStepper.userInteractionEnabled = NO;
        self.numStairsLabel.text = @"0";
        self.stairsStepper.value = 0;
    }
    else if (self.editTypeField.selectedSegmentIndex == 1) {
        // Set only the Stairs stepper to enabled.
        // Set Steps stepper to 0.
        self.stepsStepper.userInteractionEnabled = NO;
        self.stairsStepper.userInteractionEnabled = YES;
        self.numStepsLabel.text = @"0";
        self.stepsStepper.value = 0;
    }
    else {
        // Set both the Steps and Stairs stepper to enabled.
        self.stepsStepper.userInteractionEnabled = YES;
        self.stairsStepper.userInteractionEnabled = YES;
    }
}

#pragma mark - Stepper Control

// Action from Steps Stepper to change the value shown in the Steps label.
- (IBAction)stepsStepperAction:(id)sender {
    self.numStepsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}

// Action from Stairs Stepper to change the value shown in the Stairs label.
- (IBAction)stairsStepperAction:(id)sender {
    self.numStairsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Steps: %d",[self.numStepsLabel.text intValue]);
    NSLog(@"Stairs: %d",[self.numStairsLabel.text intValue]);
    NSLog(@"Date: %@",self.editDateField.date);
    // If the Cancel button was pressed (ie. not the save button)
    // Just return.
    if (sender != self.saveButton) return;
    
    // Set wasEdit to NO initially.
    self.wasEdit = NO;
    // If the goal name is different set to the new value.
    if (![self.editTitleField.text isEqualToString:self.editGoal.goalName]) {
        self.editGoal.goalName = self.editTitleField.text;
        NSLog(@"Name - Save: %@",self.editGoal.goalName);
        self.wasEdit = YES;
    }
    // If the goal type is different set to the new value.
    if (self.editTypeField.selectedSegmentIndex != self.editGoal.goalType) {
        self.editGoal.goalType = self.editTypeField.selectedSegmentIndex;
        NSLog(@"Type - Save: %d",self.editGoal.goalType);
        self.wasEdit = YES;
    }
    // If the steps amount is different set to the new value.
    if (self.editGoal.goalAmountSteps != [self.numStepsLabel.text intValue]) {
        self.editGoal.goalAmountSteps = [self.numStepsLabel.text intValue];
        if (self.conversionTypeSelector.selectedSegmentIndex == 1) {
            self.editGoal.goalAmountSteps = self.editGoal.goalAmountSteps*2112; // to miles
        }
        else if (self.conversionTypeSelector.selectedSegmentIndex == 2) {
            self.editGoal.goalAmountSteps = self.editGoal.goalAmountSteps*1312; // to km
        }
        NSLog(@"Steps - Save: %ld",(long)self.editGoal.goalAmountSteps);
        self.wasEdit = YES;
    }
    // If the stairs amount is different set to the new value.
    if (self.editGoal.goalAmountStairs != [self.numStairsLabel.text intValue]) {
        self.editGoal.goalAmountStairs = [self.numStairsLabel.text intValue];
        if (self.conversionTypeSelector.selectedSegmentIndex == 1) {
            self.editGoal.goalAmountStairs = self.editGoal.goalAmountStairs*1.385; // to feet
        }
        else if (self.conversionTypeSelector.selectedSegmentIndex == 2) {
            self.editGoal.goalAmountStairs = self.editGoal.goalAmountStairs*4.545; // to meters
        }
        NSLog(@"Stairs - Save: %ld",(long)self.editGoal.goalAmountStairs);
        self.wasEdit = YES;
    }
    // If the start date is different set to the new value.
    if (!([self.editGoal.goalStartDate isEqualToDate:self.editStartDateField.date])) {
        self.editGoal.goalStartDate = self.editStartDateField.date;
        NSLog(@"Start Date - Save: %@",self.editGoal.goalStartDate);
        self.wasEdit = YES;
    }
    // If the end date is different set to the new value.
    if (!([self.editGoal.goalCompletionDate isEqualToDate:self.editDateField.date])) {
        self.editGoal.goalCompletionDate = self.editDateField.date;
        NSLog(@"Completion Date - Save: %@",self.editGoal.goalCompletionDate);
        self.wasEdit = YES;
    }
}

// This method is used to test the inputs and stop the prepareForSegue method from being called if No is returned.
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    // Trim the white space from the string from the goal name TextField.
    NSString *trimmedString = [self.editTitleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (sender == self.saveButton)  {
        // If the Goal name has no loength (no entered) alert with message and return NO.
        if ((trimmedString.length == 0)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Please enter a name for the goal." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        if (self.editGoal.goalStatus == Pending || self.editGoal.goalStatus == Active) {
            // If the end date/time is before the current date/time alert with message and return NO.
            if ([[self.editDateField.date earlierDate:[NSDate date]]isEqualToDate: self.editDateField.date]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Completion Date/Time must be in the future." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
        }
        if (self.editGoal.goalStatus == Pending || self.editGoal.goalStatus == Active) {
            // If the end date/time is before the start date/time alert with message and return NO.
            if ([[self.editDateField.date earlierDate:self.editStartDateField.date]isEqualToDate: self.editDateField.date]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Completion Date/Time must not be in before the Start Date/Time." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
        }
        if (self.editGoal.goalStatus == Pending) {
            // If the start date/time is before the current date/time alert with message and return NO.
            if ([[self.editStartDateField.date earlierDate:[NSDate date]]isEqualToDate: self.editStartDateField.date]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Start Date/Time must be in the future." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
        }
        // If the goal name has been used before alert with message and return NO.
        int count = 0;
        for (int i=0; i<[self.listGoalNames count]; i++) {
            if ([trimmedString isEqualToString:[self.listGoalNames objectAtIndex:i]]) {
                count++;
                if (count == 2) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Goal with the same name already exists. Please choose a different name." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                }
            }
        }
        if(self.editTypeField.selectedSegmentIndex == 0) {
            // If Steps goal and number of steps is 0 or less than any progress already made alert with message and return NO.
            if (self.editGoal.goalProgressSteps > [self.numStepsLabel.text intValue]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal Edit" message:@"Number of steps for the goal cannot be less than the curret progress." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
            if ([self.numStepsLabel.text intValue] == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal Edit" message:@"Number of steps for the goal cannot be 0." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
        }
        if (self.editTypeField.selectedSegmentIndex == 1) {
            // If Stairs goal and number of stairs is 0 or less than any progress already made alert with message and return NO.
            if (self.editGoal.goalProgressStairs > [self.numStairsLabel.text intValue]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal Edit" message:@"Number of stairs for the goal cannot be less than the curret progress." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
            if ([self.numStairsLabel.text intValue] == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal Edit" message:@"Number of stairs for the goal cannot be 0." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
        }
        if (self.editTypeField.selectedSegmentIndex == 2) {
            // If Both goal and number of steps or stairs is 0 or less than any progress already made alert with message and return NO.
            if (self.editGoal.goalProgressSteps > [self.numStepsLabel.text intValue]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal Edit" message:@"Number of steps for the goal cannot be less than the curret progress." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
            if (self.editGoal.goalProgressStairs > [self.numStairsLabel.text intValue]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal Edit" message:@"Number of stairs for the goal cannot be less than the curret progress." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
            if ([self.numStepsLabel.text intValue] == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal Edit" message:@"Number of steps for the goal cannot be 0." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
            if ([self.numStairsLabel.text intValue] == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal Edit" message:@"Number of stairs for the goal cannot be 0." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
        }
    }
    return YES;
}

- (IBAction)conversionSelector:(id)sender {
    if (self.conversionTypeSelector.selectedSegmentIndex == 0) { //steps and stairs
        self.editGoal.goalConversion = StepsStairs;
        self.numStepsTitleLabel.text = @"Number of Steps";
        self.numStairsTitleLabel.text = @"Number of Stair";
    }
    else if (self.conversionTypeSelector.selectedSegmentIndex == 1) { //imperial
        self.editGoal.goalConversion = Imperial;
        self.numStepsTitleLabel.text = @"Number of Miles to walk";
        self.numStairsTitleLabel.text = @"Number of Feet to climb";
    }
    else { //metric
        self.editGoal.goalConversion = Metric;
        self.numStepsTitleLabel.text = @"Number of Kilometers to walk";
        self.numStairsTitleLabel.text = @"Number of Meters to climb";
    }
}

@end
