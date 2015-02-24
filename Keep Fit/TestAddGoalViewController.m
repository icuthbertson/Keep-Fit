//
//  TestAddGoalViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 24/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "TestAddGoalViewController.h"

@interface TestAddGoalViewController ()

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

@end

@implementation TestAddGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 800)];
    
    [self.dateStartPicker setMinimumDate:[NSDate date]];
    [self.datePicker setMinimumDate:[NSDate date]];
    self.stepsStepper.userInteractionEnabled = YES;
    self.stairsStepper.userInteractionEnabled = NO;
    self.numStepsLabel.text = @"0";
    self.numStairsLabel.text = @"0";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [self.textField resignFirstResponder];
}

#pragma mark - Stepper Control

- (IBAction)stepsStepperAction:(id)sender{
    self.numStepsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}


- (IBAction)stairsStepperAction:(id)sender{
    self.numStairsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}

#pragma mark - Segmented Control

- (IBAction)typeSelecterAction:(id)sender {
    if(self.typeSelecter.selectedSegmentIndex == 0) {
        NSLog(@"Selecter 0");
        self.stepsStepper.userInteractionEnabled = YES;
        self.stairsStepper.userInteractionEnabled = NO;
        self.numStairsLabel.text = @"0";
        self.stairsStepper.value = 0;
    }
    else if (self.typeSelecter.selectedSegmentIndex == 1) {
        NSLog(@"Selecter 1");
        self.stepsStepper.userInteractionEnabled = NO;
        self.stairsStepper.userInteractionEnabled = YES;
        self.numStepsLabel.text = @"0";
        self.stepsStepper.value = 0;
    }
    else {
        NSLog(@"Selecter 2");
        self.stepsStepper.userInteractionEnabled = YES;
        self.stairsStepper.userInteractionEnabled = YES;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender != self.saveButton) return;
    
    self.goal = [[KeepFitGoal alloc] init];
    NSString *trimmedString = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.goal.goalName = trimmedString;
    NSLog(@"Goal Name: %@",self.goal.goalName);
    self.goal.goalStatus = Pending;
    NSLog(@"Goal Status: %d",self.goal.goalStatus);
    if(self.typeSelecter.selectedSegmentIndex == 0) {
        self.goal.goalType = Steps;
        NSLog(@"Goal Type: %d",self.goal.goalType);
        self.goal.goalAmountSteps = [self.numStepsLabel.text intValue];
        NSLog(@"Goal Amount Steps: %ld",(long)self.goal.goalAmountSteps);
        self.goal.goalAmountStairs = 0;
        NSLog(@"Goal Amount Stairs: %ld",(long)self.goal.goalAmountStairs);
    }
    else if (self.typeSelecter.selectedSegmentIndex == 1) {
        self.goal.goalType = Stairs;
        NSLog(@"Goal Type: %d",self.goal.goalType);
        self.goal.goalAmountStairs = [self.numStairsLabel.text intValue];
        NSLog(@"Goal Amount: %ld Stairs",(long)self.goal.goalAmountStairs);
        self.goal.goalAmountSteps = 0;
        NSLog(@"Goal Amount: %ld Steps",(long)self.goal.goalAmountSteps);
    }
    else {
        self.goal.goalType = Both;
        NSLog(@"Goal Type: %d",self.goal.goalType);
        self.goal.goalAmountSteps = [self.numStepsLabel.text intValue];
        NSLog(@"Goal Amount Steps: %ld",(long)self.goal.goalAmountSteps);
        self.goal.goalAmountStairs = [self.numStairsLabel.text intValue];
        NSLog(@"Goal Amount Stairs: %ld",(long)self.goal.goalAmountStairs);
    }
    self.goal.goalProgressSteps = 0;
    NSLog(@"Goal Progress Steps: %ld",(long)self.goal.goalProgressSteps);
    self.goal.goalProgressStairs = 0;
    NSLog(@"Goal Progress Stairs: %ld",(long)self.goal.goalProgressSteps);
    self.goal.goalStartDate = self.dateStartPicker.date;
    NSLog(@"Goal Start Date: %@",self.goal.goalStartDate);
    self.goal.goalCompletionDate = self.datePicker.date;
    NSLog(@"Goal Completion Date: %@",self.goal.goalCompletionDate);
    self.goal.goalCreationDate = [NSDate date];
    NSLog(@"Goal Creation Date: %@",self.goal.goalCreationDate);
    self.goal.goalConversion = 0;
    NSLog(@"Goal Conversion: %d",self.goal.goalConversion);
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    //NSLog(@"Date Picker: %@",self.datePicker.date);
    //NSLog(@"NSDate date: %@",[NSDate date]);
    //NSLog(@"Earlier Date: %@",[self.datePicker.date earlierDate:[NSDate date]]);
    //NSLog(@"%ld",(long)[self.amountPicker selectedRowInComponent:0]);
    NSString *trimmedString = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (sender == self.saveButton)  {
        if ((trimmedString.length == 0)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Please enter a name for the goal." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        if ([[self.datePicker.date earlierDate:[NSDate date]]isEqualToDate: self.datePicker.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Completion Date/Time must be in the future." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        if ([[self.datePicker.date earlierDate:self.dateStartPicker.date]isEqualToDate: self.datePicker.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Completion Date/Time must not be in before the Start Date/Time." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        if ([[self.dateStartPicker.date earlierDate:[NSDate date]]isEqualToDate: self.dateStartPicker.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Start Date/Time must be in the future." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        switch (self.typeSelecter.selectedSegmentIndex) {
            case 0: //steps
                if ([self.numStepsLabel.text intValue] == 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Number of steps cannot be zero." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                }
                break;
            case 1: //stairs
                if ([self.numStairsLabel.text intValue] == 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Number of stairs cannot be zero." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                }
                break;
            case 2: //both
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
        for (int i=0; i<[self.listGoalNames count]; i++) {
            if ([trimmedString isEqualToString:[self.listGoalNames objectAtIndex:i]]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Goal with the same name already exists. Please choose a different name." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
        }
    }
    return YES;
}

@end
