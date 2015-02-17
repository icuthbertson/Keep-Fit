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
@property (weak, nonatomic) IBOutlet UITextField *textTitleField;
@property (weak, nonatomic) IBOutlet UITextField *editTitleField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *editTypeField;
@property (weak, nonatomic) IBOutlet UITextField *editStepsField;
@property (weak, nonatomic) IBOutlet UITextField *editStairsField;
@property (weak, nonatomic) IBOutlet UIDatePicker *editDateField;

@end

@implementation EditGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = [NSString stringWithFormat:@"Edit %@", self.editGoal.goalName];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    self.editTitleField.text = self.editGoal.goalName;
    self.editTypeField.selectedSegmentIndex = self.editGoal.goalType;
    self.editStepsField.text = [NSString stringWithFormat:@"%d",self.editGoal.goalAmountSteps];
    self.editStairsField.text = [NSString stringWithFormat:@"%d",self.editGoal.goalAmountStairs];
    [self.editDateField setDate:self.editGoal.goalCompletionDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [self.textTitleField resignFirstResponder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender != self.saveButton) return;
    if (self.textTitleField.text.length > 0) {
        self.editGoal.goalName = self.textTitleField.text;
        self.wasEdit = YES;
    }
    else {
        self.wasEdit = NO;
    }
}


@end
