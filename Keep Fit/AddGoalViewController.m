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

@end

@implementation AddGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    [self.datePicker setMinimumDate: [NSDate date]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [self.textField resignFirstResponder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender != self.saveButton) return;
    if (self.textField.text.length > 0) {
        self.goal = [[KeepFitGoal alloc] init];
        self.goal.goalName = self.textField.text;
        self.goal.completed = NO;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    //NSLog(@"Date Picker: %@",self.datePicker.date);
    //NSLog(@"NSDate date: %@",[NSDate date]);
    //NSLog(@"Earlier Date: %@",[self.datePicker.date earlierDate:[NSDate date]]);
    if (sender == self.saveButton)  {
        if ((self.textField.text.length == 0)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Please enter a name for the goal." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        else if ([[self.datePicker.date earlierDate:[NSDate date]]isEqualToDate: self.datePicker.date]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Goal" message:@"Completion Date/Time must be in the future." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
    }
    return YES;
}



@end
