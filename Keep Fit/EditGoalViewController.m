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

@property UIDatePicker *editDateField;
@property UIDatePicker *editStartDateField;
@property NSDateFormatter *formatter;
@property NSMutableArray *presetImages;
@property NSMutableArray *presetLabels;


@end

@implementation EditGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.editTitleField.delegate = self;
    
    // Set the minimum date of the date pickers to the current time
    // or stored time from the Testing object.
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 800)];
    
    // Set the navigation bar title.
    self.navigationItem.title = [NSString stringWithFormat:@"Edit %@", self.editGoal.goalName];
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"dd MMMM yyyy HH:mm"];
    
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
            [self enableStepper:self.stepsStepper];
            [self disableStepper:self.stairsStepper];
            [self enableSegement:self.conversionTypeSelector];
            [self enableSegement:self.editTypeField];
            self.editTypeField.selectedSegmentIndex = 0;
            self.goalSelectionLabel.text = @"Custom Goal";
            break;
        case Pluto:
            [self disableStepper:self.stepsStepper];
            [self disableStepper:self.stairsStepper];
            [self disableSegement:self.conversionTypeSelector];
            [self disableSegement:self.editTypeField];
            self.editTypeField.selectedSegmentIndex = 0;
            self.goalSelectionLabel.text = @"Walk Around Pluto";
            break;
        case Stairs:
            [self disableStepper:self.stepsStepper];
            [self enableStepper:self.stairsStepper];
            [self enableSegement:self.conversionTypeSelector];
            [self enableSegement:self.editTypeField];
            self.editTypeField.selectedSegmentIndex = 1;
            self.goalSelectionLabel.text = @"Custom Goal";
            break;
        case Everest:
            [self disableStepper:self.stepsStepper];
            [self disableStepper:self.stairsStepper];
            [self disableSegement:self.conversionTypeSelector];
            [self disableSegement:self.editTypeField];
            self.editTypeField.selectedSegmentIndex = 1;
            self.goalSelectionLabel.text = @"Climb Mount Everest";
            break;
        case Nevis:
            [self disableStepper:self.stepsStepper];
            [self disableStepper:self.stairsStepper];
            [self disableSegement:self.conversionTypeSelector];
            [self disableSegement:self.editTypeField];
            self.editTypeField.selectedSegmentIndex = 1;
            self.goalSelectionLabel.text = @"Climb Ben Nevis";
            break;
        case Both:
            [self enableStepper:self.stepsStepper];
            [self enableStepper:self.stairsStepper];
            [self enableSegement:self.conversionTypeSelector];
            [self enableSegement:self.editTypeField];
            self.editTypeField.selectedSegmentIndex = 2;
            self.goalSelectionLabel.text = @"Custom Goal";
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
        self.conversionTypeSelector.selectedSegmentIndex = 0;
    }
    else if (self.editGoal.goalConversion == Imperial) { //imperial
        self.numStepsTitleLabel.text = @"Number of Miles to walk";
        self.numStairsTitleLabel.text = @"Number of Feet to climb";
        self.numStepsLabel.text = [NSString stringWithFormat:@"%.0f",(long)self.editGoal.goalAmountSteps/[[self.editGoal.conversionTable objectAtIndex:1] doubleValue]];
        self.stepsStepper.value = [self.numStepsLabel.text intValue];
        self.numStairsLabel.text = [NSString stringWithFormat:@"%.0f",(long)self.editGoal.goalAmountStairs/[[self.editGoal.conversionTable objectAtIndex:3] doubleValue]];
        self.stairsStepper.value = [self.numStairsLabel.text intValue];
        self.conversionTypeSelector.selectedSegmentIndex = 1;
    }
    else { //metric
        self.numStepsTitleLabel.text = @"Number of Kilometers to walk";
        self.numStairsTitleLabel.text = @"Number of Meters to climb";
        self.numStepsLabel.text = [NSString stringWithFormat:@"%.0f",(long)self.editGoal.goalAmountSteps/[[self.editGoal.conversionTable objectAtIndex:2] doubleValue]];
        self.stepsStepper.value = [self.numStepsLabel.text intValue];
        self.numStairsLabel.text = [NSString stringWithFormat:@"%.0f",(long)self.editGoal.goalAmountStairs/[[self.editGoal.conversionTable objectAtIndex:4] doubleValue]];
        self.stairsStepper.value = [self.numStairsLabel.text intValue];
        self.conversionTypeSelector.selectedSegmentIndex = 2;
    }
    
    self.stepsStepper.maximumValue = 1000000;
    self.stairsStepper.maximumValue = 1000000;
    
    [self updateStepsStepperValue];
    [self updateStairsStepperValue];
    
    // Set the minimum date of the date pickers to the current time
    // or stored time from the Testing object.
    self.editStartDateField = [[UIDatePicker alloc] init];
    [self.editStartDateField setDate:self.editGoal.goalStartDate];
    self.editDateField = [[UIDatePicker alloc] init];
    [self.editDateField setDate:self.editGoal.goalCompletionDate];
    
    self.editStartDateField.datePickerMode = UIDatePickerModeDateAndTime;
    [self.editStartDateField addTarget:self action:@selector(updateTextField:)
                   forControlEvents:UIControlEventValueChanged];
    [self.startDateTextField setInputView:self.editStartDateField];
    
    self.editDateField.datePickerMode = UIDatePickerModeDateAndTime;
    [self.editDateField addTarget:self action:@selector(updateTextField:)
              forControlEvents:UIControlEventValueChanged];
    [self.endDateTextField setInputView:self.editDateField];
    
    if (self.editGoal.goalStatus == Active) {
        [self disableTextField:self.startDateTextField];
    }
    else if (self.editGoal.goalStatus == Overdue) {
        [self disableTextField:self.startDateTextField];
        [self disableTextField:self.endDateTextField];
    }
    
    self.startDateTextField.text = [self.formatter stringFromDate:self.editGoal.goalStartDate];
    self.endDateTextField.text = [self.formatter stringFromDate:self.editGoal.goalCompletionDate];
    
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
    
    [self.presetGoalPicker selectRow:(self.editGoal.goalType-2) inComponent:0 animated:YES];
    
    if (self.editGoal.goalProgressSteps > 0 || self.editGoal.goalProgressStairs > 0) {
        [self disablePicker:self.presetGoalPicker];
        [self disableStepper:self.stepsStepper];
        [self disableStepper:self.stairsStepper];
        [self disableSegement:self.conversionTypeSelector];
        [self disableSegement:self.editTypeField];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// TapGestureRecognizer method for closing the keyboard if there is a tap off of it.
// Code from http://stackoverflow.com/questions/5306240/iphone-dismiss-keyboard-when-touching-outside-of-textfield
-(void)dismissKeyboard {
    [self.editTitleField resignFirstResponder];
    [self.startDateTextField resignFirstResponder];
    [self.endDateTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)updateTextField:(UIDatePicker *)sender {
    if (sender == self.editStartDateField) {
        self.startDateTextField.text = [self.formatter stringFromDate:sender.date];
    }
    else if (sender == self.editDateField) {
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
            self.editTypeField.selectedSegmentIndex = 0;
            self.numStepsTitleLabel.text = @"Number of Steps";
            self.numStairsTitleLabel.text = @"Number of Stair";
            
            [self enableStepper:self.stepsStepper];
            [self enableStepper:self.stairsStepper];
            [self enableSegement:self.conversionTypeSelector];
            [self enableSegement:self.editTypeField];
            
            break;
        case 1:
            self.numStepsLabel.text = @"0";
            self.numStairsLabel.text = @"29029";
            self.stepsStepper.value = 0.0;
            self.stairsStepper.value = 29029.0;
            self.conversionTypeSelector.selectedSegmentIndex = 1;
            self.editTypeField.selectedSegmentIndex = 1;
            self.numStepsTitleLabel.text = @"Number of Miles to walk";
            self.numStairsTitleLabel.text = @"Number of Feet to climb";
            
            [self disableStepper:self.stepsStepper];
            [self disableStepper:self.stairsStepper];
            [self disableSegement:self.conversionTypeSelector];
            [self disableSegement:self.editTypeField];
            break;
        case 2:
            self.numStepsLabel.text = @"0";
            self.numStairsLabel.text = @"4409";
            self.stepsStepper.value = 0.0;
            self.stairsStepper.value = 4409.0;
            self.conversionTypeSelector.selectedSegmentIndex = 1;
            self.editTypeField.selectedSegmentIndex = 1;
            self.numStepsTitleLabel.text = @"Number of Miles to walk";
            self.numStairsTitleLabel.text = @"Number of Feet to climb";
            
            [self disableStepper:self.stepsStepper];
            [self disableStepper:self.stairsStepper];
            [self disableSegement:self.conversionTypeSelector];
            [self disableSegement:self.editTypeField];
            break;
        case 3:
            self.numStepsLabel.text = @"7232";
            self.numStairsLabel.text = @"0";
            self.stepsStepper.value = 7232.0;
            self.stairsStepper.value = 0.0;
            self.conversionTypeSelector.selectedSegmentIndex = 2;
            self.editTypeField.selectedSegmentIndex = 0;
            self.numStepsTitleLabel.text = @"Number of Kilometers to walk";
            self.numStairsTitleLabel.text = @"Number of Meters to climb";
            
            [self disableStepper:self.stepsStepper];
            [self disableStepper:self.stairsStepper];
            [self disableSegement:self.conversionTypeSelector];
            [self disableSegement:self.editTypeField];
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


#pragma mark - Segmented Control

// Action from Type Selector to change the goal type between Steps, Stairs and Both.
- (IBAction)typeSelecterAction:(id)sender {
    // If selector at 0.
    if(self.editTypeField.selectedSegmentIndex == 0) {
        // Set only the Steps stepper to enabled.
        // Set Stairs stepper to 0.
        [self enableStepper:self.stepsStepper];
        [self disableStepper:self.stairsStepper];
        self.numStairsLabel.text = @"0";
        self.stairsStepper.value = 0;
    }
    else if (self.editTypeField.selectedSegmentIndex == 1) {
        // Set only the Stairs stepper to enabled.
        // Set Steps stepper to 0.
        [self disableStepper:self.stepsStepper];
        [self enableStepper:self.stairsStepper];
        self.numStepsLabel.text = @"0";
        self.stepsStepper.value = 0;
    }
    else {
        // Set both the Steps and Stairs stepper to enabled.
        [self enableStepper:self.stepsStepper];
        [self enableStepper:self.stairsStepper];
    }
}

#pragma mark - Stepper Control

// Action from Steps Stepper to change the value shown in the Steps label.
- (IBAction)stepsStepperAction:(id)sender {
    [self updateStepsStepperValue];
    self.numStepsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}

-(void) updateStepsStepperValue {
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
}

// Action from Stairs Stepper to change the value shown in the Stairs label.
- (IBAction)stairsStepperAction:(id)sender {
    [self updateStairsStepperValue];
    self.numStairsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}

-(void) updateStairsStepperValue {
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
        if (self.editGoal.goalStatus == Pending) {
            if (self.settings.notifications) {
                [self updateLocalNotification:[NSString stringWithFormat:@"%@start",self.editGoal.goalName] type:@"start"];
            }
            if (self.settings.notifications) {
                [self updateLocalNotification:[NSString stringWithFormat:@"%@end",self.editGoal.goalName] type:@"end"];
            }
        }
        else if (self.editGoal.goalStatus == Active) {
            if (self.settings.notifications) {
                [self updateLocalNotification:[NSString stringWithFormat:@"%@end",self.editGoal.goalName] type:@"end"];
            }
        }
        self.wasEdit = YES;
    }
    // If the goal type is different set to the new value.
    int pickerRow = [self.presetGoalPicker selectedRowInComponent:0];
    if (pickerRow == 0) {
        if (self.editTypeField.selectedSegmentIndex != self.editGoal.goalType) {
            self.editGoal.goalType = self.editTypeField.selectedSegmentIndex;
            NSLog(@"Type - Save: %d",self.editGoal.goalType);
            self.wasEdit = YES;
        }
    }
    else {
        //test presets
        if ((pickerRow+2) != self.editGoal.goalType) {
            self.editGoal.goalType = (pickerRow+2);
            NSLog(@"Type - Save: %d",self.editGoal.goalType);
            self.wasEdit = YES;
        }
    }
    // If the goal converstion is different set to the new value.
    if (self.conversionTypeSelector.selectedSegmentIndex != self.editGoal.goalConversion) {
        self.editGoal.goalConversion = self.conversionTypeSelector.selectedSegmentIndex;
        NSLog(@"Converstion - Save: %d",self.editGoal.goalConversion);
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
        self.editGoal.goalStartDate = [self dateWithZeroSeconds:self.editStartDateField.date];
        NSLog(@"Start Date - Save: %@",self.editGoal.goalStartDate);
        if (self.settings.notifications) {
            [self updateLocalNotification:[NSString stringWithFormat:@"%@start",self.editGoal.goalName] type:@"start"];
        }
        self.wasEdit = YES;
    }
    // If the end date is different set to the new value.
    if (!([self.editGoal.goalCompletionDate isEqualToDate:self.editDateField.date])) {
        self.editGoal.goalCompletionDate = [self dateWithZeroSeconds:self.editDateField.date];
        NSLog(@"Completion Date - Save: %@",self.editGoal.goalCompletionDate);
        if (self.settings.notifications) {
            [self updateLocalNotification:[NSString stringWithFormat:@"%@end",self.editGoal.goalName] type:@"end"];
        }
        self.wasEdit = YES;
    }
}

- (void)updateLocalNotification:(NSString*)notificationID type:(NSString*)typeString {
    //loop through all scheduled notifications and cancel the one we're looking for
    UILocalNotification *cancelThisNotification = nil;
    BOOL hasNotification = NO;
    
    for (UILocalNotification *someNotification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if([[someNotification.userInfo objectForKey:notificationID] isEqualToString:notificationID]) {
            cancelThisNotification = someNotification;
            hasNotification = YES;
            break;
        }
    }
    if (hasNotification == YES) {
        NSLog(@"%@ ",cancelThisNotification);
        [[UIApplication sharedApplication] cancelLocalNotification:cancelThisNotification];
    }
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    if ([typeString isEqualToString:@"start"]) {
        localNotification.fireDate = self.editGoal.goalStartDate;
        localNotification.alertBody = [NSString stringWithFormat:@"Goal %@ is now Active.",self.editGoal.goalName];
    }
    else {
        localNotification.fireDate = self.editGoal.goalCompletionDate;
        localNotification.alertBody = [NSString stringWithFormat:@"Goal %@ is now Overdue.",self.editGoal.goalName];
    }
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@%@",self.editGoal.goalName,typeString] forKey:[NSString stringWithFormat:@"%@%@",self.editGoal.goalName,typeString]];
    localNotification.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
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
        for (int i=0; i<[self.listGoalNames count]; i++) {
            if ([trimmedString isEqualToString:[self.listGoalNames objectAtIndex:i]]) {
                if (!([trimmedString isEqualToString:self.currentName])) {
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
