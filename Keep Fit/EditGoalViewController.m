//
//  EditGoalViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 11/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "EditGoalViewController.h"

@interface EditGoalViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *editTitleField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *editTypeField;
- (IBAction)typeSelecterAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *editStepsField;
@property (weak, nonatomic) IBOutlet UITextField *editStairsField;
@property (weak, nonatomic) IBOutlet UIDatePicker *editDateField;
@property (weak, nonatomic) IBOutlet UIDatePicker *editStartDateField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation EditGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 800)];
    
    self.navigationItem.title = [NSString stringWithFormat:@"Edit %@", self.editGoal.goalName];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    self.editTitleField.text = self.editGoal.goalName;
    self.editTypeField.selectedSegmentIndex = self.editGoal.goalType;
    switch (self.editGoal.goalType) {
        case Steps:
            self.editStepsField.userInteractionEnabled = YES;
            self.editStairsField.userInteractionEnabled = NO;
            break;
        case Stairs:
            self.editStepsField.userInteractionEnabled = NO;
            self.editStairsField.userInteractionEnabled = YES;
            break;
        default:
            break;
    }
    self.editStepsField.text = [NSString stringWithFormat:@"%ld",(long)self.editGoal.goalAmountSteps];
    self.editStairsField.text = [NSString stringWithFormat:@"%ld",(long)self.editGoal.goalAmountStairs];
    if (self.editGoal.goalStatus == Active) {
        self.editDateField.userInteractionEnabled = NO;
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

-(void)dismissKeyboard {
    [self.editTitleField resignFirstResponder];
    [self.editStepsField resignFirstResponder];
    [self.editStairsField resignFirstResponder];
}

#pragma mark - Segmented Control

- (IBAction)typeSelecterAction:(id)sender {
    if(self.editTypeField.selectedSegmentIndex == 0) {
        self.editStepsField.userInteractionEnabled = YES;
        self.editStairsField.userInteractionEnabled = NO;
        self.editStairsField.text = 0;
    }
    else if (self.editTypeField.selectedSegmentIndex == 1) {
        self.editStepsField.userInteractionEnabled = NO;
        self.editStairsField.userInteractionEnabled = YES;
        self.editStepsField.text = 0;
    }
    else {
        self.editStepsField.userInteractionEnabled = YES;
        self.editStairsField.userInteractionEnabled = YES;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Steps: %d",[self.editStepsField.text intValue]);
    NSLog(@"Stairs: %d",[self.editStairsField.text intValue]);
    NSLog(@"Date: %@",self.editDateField.date);
    if (sender != self.saveButton) return;
    self.wasEdit = NO;
    if (![self.editTitleField.text isEqualToString:self.editGoal.goalName]) {
        self.editGoal.goalName = self.editTitleField.text;
        NSLog(@"Name - Save: %@",self.editGoal.goalName);
        self.wasEdit = YES;
    }
    if (self.editTypeField.selectedSegmentIndex != self.editGoal.goalType) {
        self.editGoal.goalType = self.editTypeField.selectedSegmentIndex;
        NSLog(@"Type - Save: %d",self.editGoal.goalType);
        self.wasEdit = YES;
    }
    if (self.editGoal.goalAmountSteps != [self.editStepsField.text intValue]) {
        self.editGoal.goalAmountSteps = [self.editStepsField.text intValue];
        NSLog(@"Steps - Save: %ld",(long)self.editGoal.goalAmountSteps);
        self.wasEdit = YES;
    }
    if (self.editGoal.goalAmountStairs != [self.editStairsField.text intValue]) {
        self.editGoal.goalAmountStairs = [self.editStairsField.text intValue];
        NSLog(@"Stairs - Save: %ld",(long)self.editGoal.goalAmountStairs);
        self.wasEdit = YES;
    }
    if (!([self.editGoal.goalStartDate isEqualToDate:self.editStartDateField.date])) {
        self.editGoal.goalStartDate = self.editStartDateField.date;
        NSLog(@"Start Date - Save: %@",self.editGoal.goalStartDate);
        self.wasEdit = YES;
    }
    if (!([self.editGoal.goalCompletionDate isEqualToDate:self.editDateField.date])) {
        self.editGoal.goalCompletionDate = self.editDateField.date;
        NSLog(@"Completion Date - Save: %@",self.editGoal.goalCompletionDate);
        self.wasEdit = YES;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    //NSLog(@"Date Picker: %@",self.datePicker.date);
    //NSLog(@"NSDate date: %@",[NSDate date]);
    //NSLog(@"Earlier Date: %@",[self.datePicker.date earlierDate:[NSDate date]]);
    //NSLog(@"%ld",(long)[self.amountPicker selectedRowInComponent:0]);
    NSString *trimmedString = [self.editTitleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (sender == self.saveButton)  {
        if ((trimmedString.length == 0)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Please enter a name for the goal." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        else if ([[self.editDateField.date earlierDate:[NSDate date]]isEqualToDate: self.editDateField.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Completion Date/Time must be in the future." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        else if ([[self.editDateField.date earlierDate:self.editStartDateField.date]isEqualToDate: self.editDateField.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Completion Date/Time must not be in before the Start Date/Time." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        else if ([[self.editStartDateField.date earlierDate:[NSDate date]]isEqualToDate: self.editStartDateField.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Start Date/Time must be in the future." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
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
            if (self.editGoal.goalProgressSteps > [self.editStepsField.text intValue]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal Edit" message:@"Number of steps for the goal cannot be less than the curret progress." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
            if (0 == [self.editStepsField.text intValue]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal Edit" message:@"Number of steps for the goal cannot be 0." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
        }
        else if (self.editTypeField.selectedSegmentIndex == 1) {
            if (self.editGoal.goalProgressStairs > [self.editStairsField.text intValue]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal Edit" message:@"Number of stairs for the goal cannot be less than the curret progress." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
            if (0 == [self.editStairsField.text intValue]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal Edit" message:@"Number of stairs for the goal cannot be 0." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
        }
        else {
            if (self.editGoal.goalProgressSteps > [self.editStepsField.text intValue]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal Edit" message:@"Number of steps for the goal cannot be less than the curret progress." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
            if (self.editGoal.goalProgressStairs > [self.editStairsField.text intValue]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal Edit" message:@"Number of stairs for the goal cannot be less than the curret progress." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
            if (0 == [self.editStepsField.text intValue]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal Edit" message:@"Number of steps for the goal cannot be 0." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
            if (0 == [self.editStairsField.text intValue]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal Edit" message:@"Number of stairs for the goal cannot be 0." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
        }
    }
    return YES;
}

@end
