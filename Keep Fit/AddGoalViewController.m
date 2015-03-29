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
@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *endDateTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *presetGoalPicker;
@property (weak, nonatomic) IBOutlet UILabel *goalSelectionLabel;

@property UIDatePicker *dateStartPicker;
@property UIDatePicker *datePicker;
@property NSDateFormatter *formatter;
@property NSMutableArray *presetImages;
@property NSMutableArray *presetLabels;

@end

@implementation AddGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textField.delegate = self;
    
    // Set up the scroll view.
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 800)];
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"dd MMMM yyyy HH:mm"];
    
    // Set the minimum date of the date pickers to the current time
    // or stored time from the Testing object.
    self.dateStartPicker = [[UIDatePicker alloc] init];
    [self.dateStartPicker setMinimumDate:[NSDate date]];
    self.datePicker = [[UIDatePicker alloc] init];
    [self.datePicker setMinimumDate:[NSDate date]];
    
    self.startDateTextField.text = [self.formatter stringFromDate:[NSDate date]];
    self.endDateTextField.text = [self.formatter stringFromDate:[NSDate date]];
    
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
    [self enableStepper:self.stepsStepper];
    [self disableStepper:self.stairsStepper];
    self.numStepsLabel.text = @"0";
    self.numStairsLabel.text = @"0";
    
    
    self.dateStartPicker.datePickerMode = UIDatePickerModeDateAndTime;
    [self.dateStartPicker addTarget:self action:@selector(updateTextField:)
         forControlEvents:UIControlEventValueChanged];
    [self.startDateTextField setInputView:self.dateStartPicker];
    
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [self.datePicker addTarget:self action:@selector(updateTextField:)
              forControlEvents:UIControlEventValueChanged];
    [self.endDateTextField setInputView:self.datePicker];
    
    // TapGestureRecognizer declaration for closing the keyboard if there is a tap off of it.
    // Code from http://stackoverflow.com/questions/5306240/iphone-dismiss-keyboard-when-touching-outside-of-textfield
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.presetImages = [[NSMutableArray alloc] init];
    [self.presetImages addObject:[UIImage imageNamed:@"finishline.png"]];
    [self.presetImages addObject:[UIImage imageNamed:@"everest.png"]];
    [self.presetImages addObject:[UIImage imageNamed:@"nevis.png"]];
    [self.presetImages addObject:[UIImage imageNamed:@"pluto.png"]];
    
    
    self.presetLabels = [[NSMutableArray alloc] init];
    [self.presetLabels addObject:[NSString stringWithFormat:@"Custom Goal"]];
    [self.presetLabels addObject:[NSString stringWithFormat:@"Climb Mount Everest"]];
    [self.presetLabels addObject:[NSString stringWithFormat:@"Climb Ben Nevis"]];
    [self.presetLabels addObject:[NSString stringWithFormat:@"Walk Around Pluto"]];
    
    self.presetGoalPicker.delegate = self;
    self.presetGoalPicker.dataSource = self;
    self.presetGoalPicker.showsSelectionIndicator = YES;
    
    self.goalSelectionLabel.text = @"Custom Goal";
    
    self.stepsStepper.maximumValue = 1000000;
    self.stairsStepper.maximumValue = 1000000;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// TapGestureRecognizer method for closing the keyboard if there is a tap off of it.
// Code from http://stackoverflow.com/questions/5306240/iphone-dismiss-keyboard-when-touching-outside-of-textfield
-(void)dismissKeyboard {
    [self.textField resignFirstResponder];
    [self.startDateTextField resignFirstResponder];
    [self.endDateTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)updateTextField:(UIDatePicker *)sender {
    if (sender == self.dateStartPicker) {
        self.startDateTextField.text = [self.formatter stringFromDate:sender.date];
    }
    else if (sender == self.datePicker) {
        self.endDateTextField.text = [self.formatter stringFromDate:sender.date];
    }
}

- (NSDate *)dateWithZeroSeconds:(NSDate *)date {
    NSTimeInterval time = floor([date timeIntervalSince1970] / 60.0) * 60.0;
    return  [NSDate dateWithTimeIntervalSince1970:time];
}

#pragma mark - Picker Control

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.goalSelectionLabel.text = [NSString stringWithFormat:@"%@",[self.presetLabels objectAtIndex:row]];
    
    switch (row) {
        case 0:
            self.numStepsLabel.text = @"0";
            self.numStairsLabel.text = @"0";
            self.stepsStepper.value = 0.0;
            self.stairsStepper.value = 0.0;
            self.conversionTypeSelector.selectedSegmentIndex = 0;
            self.typeSelecter.selectedSegmentIndex = 0;
            self.numStepsTitleLabel.text = @"Number of Steps";
            self.numStairsTitleLabel.text = @"Number of Stair";
            
            [self enableStepper:self.stepsStepper];
            [self enableStepper:self.stairsStepper];
            [self enableSegement:self.conversionTypeSelector];
            [self enableSegement:self.typeSelecter];
            break;
        case 1:
            self.numStepsLabel.text = @"0";
            self.numStairsLabel.text = @"29029";
            self.stepsStepper.value = 0.0;
            self.stairsStepper.value = 29029.0;
            self.conversionTypeSelector.selectedSegmentIndex = 1;
            self.typeSelecter.selectedSegmentIndex = 1;
            self.numStepsTitleLabel.text = @"Number of Miles to walk";
            self.numStairsTitleLabel.text = @"Number of Feet to climb";
            
            [self disableStepper:self.stepsStepper];
            [self disableStepper:self.stairsStepper];
            [self disableSegement:self.conversionTypeSelector];
            [self disableSegement:self.typeSelecter];
            break;
        case 2:
            self.numStepsLabel.text = @"0";
            self.numStairsLabel.text = @"4409";
            self.stepsStepper.value = 0.0;
            self.stairsStepper.value = 4409.0;
            self.conversionTypeSelector.selectedSegmentIndex = 1;
            self.typeSelecter.selectedSegmentIndex = 1;
            self.numStepsTitleLabel.text = @"Number of Miles to walk";
            self.numStairsTitleLabel.text = @"Number of Feet to climb";
            
            [self disableStepper:self.stepsStepper];
            [self disableStepper:self.stairsStepper];
            [self disableSegement:self.conversionTypeSelector];
            [self disableSegement:self.typeSelecter];
            break;
        case 3:
            self.numStepsLabel.text = @"7232";
            self.numStairsLabel.text = @"0";
            self.stepsStepper.value = 7232.0;
            self.stairsStepper.value = 0.0;
            self.conversionTypeSelector.selectedSegmentIndex = 2;
            self.typeSelecter.selectedSegmentIndex = 0;
            self.numStepsTitleLabel.text = @"Number of Kilometers to walk";
            self.numStairsTitleLabel.text = @"Number of Meters to climb";
            
            [self disableStepper:self.stepsStepper];
            [self disableStepper:self.stairsStepper];
            [self disableSegement:self.conversionTypeSelector];
            [self disableSegement:self.typeSelecter];
            break;
        default:
            break;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 90.0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView *pickerCustomView = (id)view;
    UILabel *pickerViewLabel;
    UIImageView *pickerImageView;
    
    if (!pickerCustomView) {
        pickerCustomView= [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                   [pickerView rowSizeForComponent:component].width - 10.0f, [pickerView       rowSizeForComponent:component].height)];
        pickerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 90.0f, 90.0f)];
        pickerViewLabel= [[UILabel alloc] initWithFrame:CGRectMake(95.0f, 0.0f,
                                                                   [pickerView rowSizeForComponent:component].width - 10.0f, [pickerView rowSizeForComponent:component].height)];
        
        [pickerCustomView addSubview:pickerImageView];
        [pickerCustomView addSubview:pickerViewLabel];
    }
    
    pickerImageView.image = self.presetImages[row];
    pickerViewLabel.backgroundColor = [UIColor clearColor];
    pickerViewLabel.text = self.presetLabels[row];
    return pickerCustomView;
}

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.presetImages.count;
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
        [self enableStepper:self.stepsStepper];
        [self disableStepper:self.stairsStepper];
        self.numStairsLabel.text = @"0";
        self.stairsStepper.value = 0;
    }
    else if (self.typeSelecter.selectedSegmentIndex == 1) {
        NSLog(@"Selecter 1");
        // Set only the Stairs stepper to enabled.
        // Set Steps stepper to 0.
        [self disableStepper:self.stepsStepper];
        [self enableStepper:self.stairsStepper];
        self.numStepsLabel.text = @"0";
        self.stepsStepper.value = 0;
    }
    else {
        NSLog(@"Selecter 2");
        // Set both the Steps and Stairs stepper to enabled.
        [self enableStepper:self.stepsStepper];
        [self enableStepper:self.stairsStepper];
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
        if ([self.presetGoalPicker selectedRowInComponent:0] == 0) {
            self.goal.goalType = Steps;
        }
        else if ([self.presetGoalPicker selectedRowInComponent:0] == 3) {
            self.goal.goalType = Pluto;
        }
        self.goal.goalAmountSteps = [self.numStepsLabel.text intValue];
        self.goal.goalAmountStairs = 0;
    }
    else if (self.typeSelecter.selectedSegmentIndex == 1) {
        // If the type selector is at 1.
        // Set the goal type to Stairs and pull the number of steps from the stepper.
        // Set the number of steps to zero.
        if ([self.presetGoalPicker selectedRowInComponent:0] == 0) {
            self.goal.goalType = Stairs;
        }
        else if ([self.presetGoalPicker selectedRowInComponent:0] == 1) {
            self.goal.goalType = Everest;
        }
        else if ([self.presetGoalPicker selectedRowInComponent:0] == 2) {
            self.goal.goalType = Nevis;
        }
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
    self.goal.goalStartDate = [self dateWithZeroSeconds:self.dateStartPicker.date];
    
    self.goal.goalCompletionDate = [self dateWithZeroSeconds:self.datePicker.date];
    
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
    NSDate *startDate = [self dateWithZeroSeconds:self.dateStartPicker.date];
    NSDate *endDate = [self dateWithZeroSeconds:self.datePicker.date];
    
    if (sender == self.saveButton)  {
        // If the Goal name has no loength (no entered) alert with message and return NO.
        if ((trimmedString.length == 0)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Please enter a name for the goal." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        // If the end date/time is before the current date/time alert with message and return NO.
        if ([[endDate earlierDate:[NSDate date]]isEqualToDate: endDate]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Completion Date/Time must be in the future." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        // If the end date/time is before the start date/time alert with message and return NO.
        if ([[endDate earlierDate:startDate]isEqualToDate: endDate]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Completion Date/Time must not be in before the Start Date/Time." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        // If the start date/time is before the current date/time alert with message and return NO.
        if ([[startDate earlierDate:[NSDate date]]isEqualToDate: startDate]) {
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
        NSLog(@"here %@", self.listGoalNames);
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

//disable button
-(void) disableButton:(UIButton *)button {
    [button setEnabled:NO];
    button.alpha = 0.3;
}

//enable button
-(void) enableButton:(UIButton *)button {
    [button setEnabled:YES];
    button.alpha = 1.0;
}

//disable stepper
-(void) disableStepper:(UIStepper *)stepper {
    [stepper setEnabled:NO];
    stepper.alpha = 0.3;
}

//enable stepper
-(void) enableStepper:(UIStepper *)stepper {
    [stepper setEnabled:YES];
    stepper.alpha = 1.0;
}

//disable segmentated control
-(void) disableSegement:(UISegmentedControl *)segment {
    [segment setEnabled:NO];
    segment.alpha = 0.3;
}

//enable segmented control
-(void) enableSegement:(UISegmentedControl *)segment {
    [segment setEnabled:YES];
    segment.alpha = 1.0;
}

//disable text field
-(void) disableTextField:(UITextField *)textfield {
    [textfield setEnabled:NO];
    textfield.alpha = 0.3;
}

//enable text field
-(void) enableTextField:(UITextField *)textfield {
    [textfield setEnabled:YES];
    textfield.alpha = 1.0;
}

//disable picker
-(void) disablePicker:(UIPickerView *)picker {
    picker.userInteractionEnabled = NO;
    picker.alpha = 0.3;
}

//enable picker
-(void) enablePicker:(UIPickerView *)picker {
    picker.userInteractionEnabled = YES;
    picker.alpha = 1.0;
}

@end
