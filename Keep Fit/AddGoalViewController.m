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
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSelecter;
- (IBAction)typeSelecterAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIPickerView *amountPicker;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property NSArray *pickerSteps;
@property NSArray *pickerStairs;
@property NSArray *goalAmount;

@end

@implementation AddGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 600)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [self.datePicker setMinimumDate: [NSDate date]];

    self.pickerSteps = @[@500, @1000, @1500, @2000, @2500, @3000, @3500, @4000, @4500, @5000, @5500, @6000, @6500, @7000, @7500, @8000, @8500, @9000, @9500, @10000];
    self.pickerStairs = @[@5, @10, @15, @20, @25, @30, @35, @40, @45, @50, @55, @60, @65, @70, @75, @80, @85, @90, @95, @100];
    self.goalAmount = self.pickerSteps;
    self.amountPicker.dataSource = self;
    self.amountPicker.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [self.textField resignFirstResponder];
}

#pragma mark - Segmented Control

- (IBAction)typeSelecterAction:(id)sender {
    if(self.typeSelecter.selectedSegmentIndex == 0) {
        self.amountLabel.text = @"Number of Steps";
        self.goalAmount = self.pickerSteps;
    }
    else {
        self.amountLabel.text = @"Number of Stairs";
        self.goalAmount = self.pickerStairs;
    }
    [self.amountPicker reloadAllComponents];
}

#pragma mark - PickerView

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerSteps.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%@", self.goalAmount[row]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender != self.saveButton) return;
    if (self.textField.text.length > 0) {
        self.goal = [[KeepFitGoal alloc] init];
        NSString *trimmedString = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.goal.goalName = trimmedString;
        self.goal.completed = NO;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    //NSLog(@"Date Picker: %@",self.datePicker.date);
    //NSLog(@"NSDate date: %@",[NSDate date]);
    //NSLog(@"Earlier Date: %@",[self.datePicker.date earlierDate:[NSDate date]]);
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
