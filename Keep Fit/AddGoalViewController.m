//
//  AddGoalViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 09/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "AddGoalViewController.h"

@interface AddGoalViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *dateStartPicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSelecter;
- (IBAction)typeSelecterAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *numStepsField;
@property (weak, nonatomic) IBOutlet UITextField *numStairsField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

/*@property NSArray *pickerStepsArray;
@property NSArray *pickerStairsArray;

@property UIPickerView *stepsPicker;
@property UIPickerView *stairsPicker;*/

@end

@implementation AddGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 800)];
    
    [self.dateStartPicker setMinimumDate:[NSDate date]];
    [self.datePicker setMinimumDate:[NSDate date]];
    self.numStepsField.userInteractionEnabled = YES;
    self.numStairsField.userInteractionEnabled = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    /*self.pickerStepsArray = @[@500, @1000, @1500, @2000, @2500, @3000, @3500, @4000, @4500, @5000, @5500, @6000, @6500, @7000, @7500, @8000, @8500, @9000, @9500, @10000];
    self.pickerStairsArray = @[@5, @10, @15, @20, @25, @30, @35, @40, @45, @50, @55, @60, @65, @70, @75, @80, @85, @90, @95, @100];
    
    self.stepsPicker = [[UIPickerView alloc] init];
    [self.stepsPicker setDataSource: self];
    [self.stepsPicker setDelegate: self];
    self.stepsPicker.showsSelectionIndicator = YES;
    self.numStepsField.inputView = self.stepsPicker;
    
    self.stairsPicker = [[UIPickerView alloc] init];
    [self.stairsPicker setDataSource: self];
    [self.stairsPicker setDelegate: self];
    self.stairsPicker.showsSelectionIndicator = YES;
    self.numStairsField.inputView = self.stairsPicker;*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [self.textField resignFirstResponder];
    [self.numStepsField resignFirstResponder];
    [self.numStairsField resignFirstResponder];
}
/*
#pragma mark - PickerView

//Steps
// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.stepsPicker]) return self.pickerStepsArray.count;
    return self.pickerStairsArray.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)stepsPicker:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.stepsPicker]) return [NSString stringWithFormat:@"%@", self.pickerStepsArray[row]];
    return [NSString stringWithFormat:@"%@", self.pickerStairsArray[row]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.stepsPicker]) {
        self.numStepsField.text = [self.pickerStepsArray objectAtIndex:row];
    }
    else if ([pickerView isEqual:self.stairsPicker]) {
        self.numStairsField.text = [self.pickerStairsArray objectAtIndex:row];
    }
}*/

#pragma mark - Segmented Control

- (IBAction)typeSelecterAction:(id)sender {
    if(self.typeSelecter.selectedSegmentIndex == 0) {
        self.numStepsField.userInteractionEnabled = YES;
        self.numStairsField.userInteractionEnabled = NO;
        self.numStairsField.text = 0;
    }
    else if (self.typeSelecter.selectedSegmentIndex == 1) {
        self.numStepsField.userInteractionEnabled = NO;
        self.numStairsField.userInteractionEnabled = YES;
        self.numStepsField.text = 0;
    }
    else {
        self.numStepsField.userInteractionEnabled = YES;
        self.numStairsField.userInteractionEnabled = YES;
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
        self.goal.goalAmountSteps = [self.numStepsField.text intValue];
        NSLog(@"Goal Amount Steps: %ld",(long)self.goal.goalAmountSteps);
        self.goal.goalAmountStairs = 0;
        NSLog(@"Goal Amount Stairs: %ld",(long)self.goal.goalAmountStairs);
    }
    else if (self.typeSelecter.selectedSegmentIndex == 1) {
        self.goal.goalType = Stairs;
        NSLog(@"Goal Type: %d",self.goal.goalType);
        self.goal.goalAmountStairs = [self.numStairsField.text intValue];
        NSLog(@"Goal Amount: %ld Stairs",(long)self.goal.goalAmountStairs);
        self.goal.goalAmountSteps = 0;
        NSLog(@"Goal Amount: %ld Steps",(long)self.goal.goalAmountSteps);
    }
    else {
        self.goal.goalType = Both;
        NSLog(@"Goal Type: %d",self.goal.goalType);
        self.goal.goalAmountSteps = [self.numStepsField.text intValue];
        NSLog(@"Goal Amount Steps: %ld",(long)self.goal.goalAmountSteps);
        self.goal.goalAmountStairs = [self.numStairsField.text intValue];
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
        else if ([[self.datePicker.date earlierDate:[NSDate date]]isEqualToDate: self.datePicker.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Completion Date/Time must be in the future." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        else if ([[self.datePicker.date earlierDate:self.dateStartPicker.date]isEqualToDate: self.datePicker.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Completion Date/Time must not be in before the Start Date/Time." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        else if ([[self.dateStartPicker.date earlierDate:[NSDate date]]isEqualToDate: self.dateStartPicker.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Start Date/Time must be in the future." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        else {
            for (int i=0; i<[self.listGoalNames count]; i++) {
                if ([trimmedString isEqualToString:[self.listGoalNames objectAtIndex:i]]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Goal with the same name already exists. Please choose a different name." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    return NO;
                }
            }
        }
    }
    return YES;
}

@end
