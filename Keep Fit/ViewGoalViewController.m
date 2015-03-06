//
//  ViewGoalViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 11/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "ViewGoalViewController.h"
#import "KeepFitGoal.h"
#import "GoalListTableViewController.h"
#import "EditGoalViewController.h"
#import "DBManager.h"
#import "HistoryTableViewController.h"
#import "ChangeTimeViewController.h"
#import "ScheduleViewController.h"


@interface ViewGoalViewController ()

@property (nonatomic, strong) DBManager *dbManager; // Database manager object.
@property (weak, nonatomic) IBOutlet UILabel *viewTitle; // Goal title label.
@property (weak, nonatomic) IBOutlet UILabel *viewType; // Goal type label.
@property (weak, nonatomic) IBOutlet UILabel *viewDateCreated; // Goal created date label.
@property (weak, nonatomic) IBOutlet UILabel *viewDateCompletion; // Goal completion data label.
@property (weak, nonatomic) IBOutlet UIProgressView *viewProgressBar; // Progress bar outlet.
@property (weak, nonatomic) IBOutlet UILabel *viewProgress; // Progress label.
- (IBAction)setActiveButton:(id)sender; // Active button action.
- (IBAction)suspendButton:(id)sender; // Suspended button action.
@property (weak, nonatomic) IBOutlet UIButton *outletActiveButton; // Active button outlet.
@property (weak, nonatomic) IBOutlet UIButton *outletSuspendButton; // Suspend button outlet.
@property (weak, nonatomic) IBOutlet UILabel *viewDateStart; // Goal start date label.
@property (weak, nonatomic) IBOutlet UIButton *outletHistoryButton; // History view button outlet.
@property (weak, nonatomic) IBOutlet UILabel *viewStatus; // Goal status label.
@property (weak, nonatomic) IBOutlet UILabel *stepperLabel;
@property (weak, nonatomic) IBOutlet UIStepper *addStepper;
- (IBAction)stepperAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *stepperStairsLabel;
@property (weak, nonatomic) IBOutlet UIStepper *addStairsStepper;
- (IBAction)stepperStairsAction:(id)sender;

@property NSInteger progressSteps;
@property NSInteger progressStairs;

@end

@implementation ViewGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    // Set up the labels and other outlet with data of goal to be viewed.
    [self showDetails];
}

// Method to set up outlets of view to show data of the goal.
-(void)showDetails {
    // Set the title of the navigation bar.
    self.navigationItem.title = [NSString stringWithFormat:@"%@", self.viewGoal.goalName];
    
    // Set the title label to the goal name.
    self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@", self.viewGoal.goalName];
    
    // Depending on the status of the goal set the status label and background accordingly.
    switch (self.viewGoal.goalStatus) {
        case Pending:
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Pending"];
            self.view.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((178) / 255.0) blue:((255) / 255.0) alpha:1.0];
            self.outletActiveButton.hidden = YES;
            self.outletSuspendButton.hidden = YES;
            break;
        case Active:
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Active"];
            self.view.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            self.outletActiveButton.hidden = NO;
            self.outletSuspendButton.hidden = NO;
            break;
        case Overdue:
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Overdue"];
            self.view.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((102) / 255.0) blue:((102) / 255.0) alpha:1.0];
            self.outletActiveButton.hidden = NO;
            self.outletSuspendButton.hidden = NO;
            break;
        case Suspended:
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Suspended"];
            self.view.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            [self.outletSuspendButton setTitle:@"Re-instate" forState:UIControlStateNormal];
            self.outletActiveButton.hidden = YES;
            self.outletSuspendButton.hidden = NO;
            [self hideAndDisableRightNavigationItem];
            break;
        case Abandoned:
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Abandoned"];
            self.view.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((102) / 255.0) blue:((102) / 255.0) alpha:1.0];
            self.outletActiveButton.hidden = YES;
            self.outletSuspendButton.hidden = YES;
            [self hideAndDisableRightNavigationItem];
            break;
        case Completed:
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Completed"];
            self.view.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            self.outletActiveButton.hidden = YES;
            self.outletSuspendButton.hidden = YES;
            [self hideAndDisableRightNavigationItem];
            break;
        default:
            break;
    }
    
    // Depending on the type of the goal set the goal type label, the progress label and the progress bar accordingly.
    switch (self.viewGoal.goalType) {
        case Steps:
            self.addStairsStepper.userInteractionEnabled = NO;
            self.viewType.text = [NSString stringWithFormat:@"Goal Type: Steps"];
            self.viewProgress.text = [NSString stringWithFormat:@"Steps: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            break;
        case Stairs:
            self.addStepper.userInteractionEnabled = NO;
            self.viewType.text = [NSString stringWithFormat:@"Goal Type: Stairs"];
            self.viewProgress.text = [NSString stringWithFormat:@"Stairs: %ld/%ld",(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            break;
        case Both:
            self.viewType.text = [NSString stringWithFormat:@"Goal Type: Steps and Stairs"];
            self.viewProgress.text = [NSString stringWithFormat:@"Steps: %ld/%ld  Stairs: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps,(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
            [self.viewProgressBar setProgress:(float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2)) animated:YES];
            break;
        default:
            break;
    }
    
    // Set up the date formatter to the required format.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    // Set the date labels to their values in the required format.
    self.viewDateCreated.text = [NSString stringWithFormat:@"Date Created: %@",[formatter stringFromDate:self.viewGoal.goalCreationDate]];
    self.viewDateStart.text = [NSString stringWithFormat:@"Start Date: %@",[formatter stringFromDate:self.viewGoal.goalStartDate]];
    self.viewDateCompletion.text = [NSString stringWithFormat:@"Completion Date: %@",[formatter stringFromDate:self.viewGoal.goalCompletionDate]];
    
    self.stepperLabel.text = @"0";
    self.stepperStairsLabel.text = @"0";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segue

// Returning from edit goal view.
-(IBAction)unwindToView:(UIStoryboardSegue *)segue {
    EditGoalViewController *source = [segue sourceViewController];
    
    // If the goal was editted.
    if (source.wasEdit) {
        self.viewGoal = source.editGoal;
        // If the goal from the edit view isn't nil.
        if (self.viewGoal != nil) {
            // update the row in the goals table with the editted goal.
            NSString *query;
            query = [NSString stringWithFormat:@"update goals set goalName='%@', goalType='%d', goalAmountSteps='%ld', goalAmountStairs='%ld', goalStartDate='%f', goalDate='%f', goalConversion='%d' where goalID=%ld", self.viewGoal.goalName, self.viewGoal.goalType, (long)self.viewGoal.goalAmountSteps, (long)self.viewGoal.goalAmountStairs, [self.viewGoal.goalStartDate timeIntervalSince1970], [self.viewGoal.goalCompletionDate timeIntervalSince1970], self.viewGoal.goalConversion, (long)self.viewGoal.goalID];
            // Execute the query.
            [self.dbManager executeQuery:query];
        
            if (self.dbManager.affectedRows != 0) {
                NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
            }
            else {
                NSLog(@"Could not execute the query.");
            }
        }
    }
    // Reload the view.
    [self showDetails];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showEditGoal"]) {
        EditGoalViewController *destViewController = segue.destinationViewController;
        destViewController.editGoal = self.viewGoal;
        destViewController.listGoalNames = self.listGoalNames;
    }
    else if ([segue.identifier isEqualToString:@"showHistory"]) {
        HistoryTableViewController *destViewController = segue.destinationViewController;
        destViewController.viewHistoryGoal = self.viewGoal;
    }
}

#pragma mark - Buttons

- (IBAction)setActiveButton:(id)sender {
    if (self.viewGoal.goalType == Steps) {
        if ([self.stepperLabel.text intValue] > 0) {
            self.progressSteps = [self.stepperLabel.text intValue];
            self.viewGoal.goalProgressSteps += self.progressSteps;
            if (self.viewGoal.goalProgressSteps > self.viewGoal.goalAmountSteps) {
                self.viewGoal.goalProgressSteps = self.viewGoal.goalAmountSteps;
            }
            [self storeGoalStatusChangeToDB];
            [self updateView];
            self.stepperLabel.text = @"0";
            self.addStepper.value = 0.0;
        }
    }
    else if (self.viewGoal.goalType == Stairs) {
        if ([self.stepperStairsLabel.text intValue] > 0) {
            self.progressStairs = [self.stepperStairsLabel.text intValue];
            self.viewGoal.goalProgressStairs += self.progressStairs;
            if (self.viewGoal.goalProgressStairs > self.viewGoal.goalAmountStairs) {
                self.viewGoal.goalProgressStairs = self.viewGoal.goalAmountStairs;
            }
            [self storeGoalStatusChangeToDB];
            [self updateView];
            self.stepperStairsLabel.text = @"0";
            self.addStairsStepper.value = 0.0;
        }
    }
    else if (self.viewGoal.goalType == Both) {
        if (([self.stepperLabel.text intValue] > 0) || ([self.stepperStairsLabel.text intValue] > 0)) {
            self.progressSteps = [self.stepperLabel.text intValue];
            self.progressStairs = [self.stepperStairsLabel.text intValue];
            self.viewGoal.goalProgressSteps += self.progressSteps;
            self.viewGoal.goalProgressStairs += self.progressStairs;
            if (self.viewGoal.goalProgressSteps > self.viewGoal.goalAmountSteps) {
                self.viewGoal.goalProgressSteps = self.viewGoal.goalAmountSteps;
            }
            if (self.viewGoal.goalProgressStairs > self.viewGoal.goalAmountStairs) {
                self.viewGoal.goalProgressStairs = self.viewGoal.goalAmountStairs;
            }
            [self storeGoalStatusChangeToDB];
            [self updateView];
            self.stepperLabel.text = @"0";
            self.addStepper.value = 0.0;
            self.stepperStairsLabel.text = @"0";
            self.addStairsStepper.value = 0.0;
        }
    }
}

-(void) updateView {
    NSLog(@"Update View");
    switch (self.viewGoal.goalType) {
        case Steps:
            if (self.viewGoal.goalAmountSteps == self.viewGoal.goalProgressSteps) {
                [self completedView];
            }
            self.viewProgress.text = [NSString stringWithFormat:@"Steps: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            break;
        case Stairs:
            if (self.viewGoal.goalAmountStairs == self.viewGoal.goalProgressStairs) {
                [self completedView];
            }
            self.viewProgress.text = [NSString stringWithFormat:@"Stairs: %ld/%ld",(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            break;
        case Both:
            if (((self.viewGoal.goalAmountSteps == self.viewGoal.goalProgressSteps) && (self.viewGoal.goalAmountStairs == self.viewGoal.goalProgressStairs))) {
                [self completedView];
            }
            self.viewProgress.text = [NSString stringWithFormat:@"Steps: %ld/%ld  Stairs: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps,(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
            [self.viewProgressBar setProgress:(float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2)) animated:YES];
            break;
        default:
            break;
    }
    NSString *query;
    query = [NSString stringWithFormat:@"update goals set goalStatus='%d', goalProgressSteps='%d', goalProgressStairs='%d' where goalID=%ld", self.viewGoal.goalStatus, self.viewGoal.goalProgressSteps, self.viewGoal.goalProgressStairs, (long)self.viewGoal.goalID];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
}

-(void) completedView {
    self.viewGoal.goalStatus = Completed;
    self.viewStatus.text = @"Completed";
    self.outletActiveButton.hidden = YES;
    self.view.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
    [self showAndEnableLeftNavigationItem];
}

- (IBAction)suspendButton:(id)sender {
    /**********************************Suspend*****************************************/
    if ((self.viewGoal.goalStatus == Pending) || (self.viewGoal.goalStatus == Active) || (self.viewGoal.goalStatus == Overdue)) {
        self.viewGoal.goalStatus = Suspended;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now suspended" message:@"This goal is now suspended." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [self storeGoalStatusChangeToDB];
        self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Suspended"];
        self.view.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
        [self showAndEnableLeftNavigationItem];
        [self hideAndDisableRightNavigationItem];
        self.outletActiveButton.hidden = YES;
        self.outletHistoryButton.hidden = NO;
        self.stepperLabel.text = @"0";
        self.addStepper.value = 0.0;
        self.stepperStairsLabel.text = @"0";
        self.addStairsStepper.value = 0.0;
        self.outletActiveButton.hidden = YES;
        self.addStepper.userInteractionEnabled = NO;
        self.addStairsStepper.userInteractionEnabled = NO;
        [self.outletActiveButton setTitle:@"Start" forState:UIControlStateNormal];
        [self.outletSuspendButton setTitle:@"Re-instate" forState:UIControlStateNormal];
    }/**********************************Re-instate*****************************************/
    else if (self.viewGoal.goalStatus == Suspended) {
        if ([[[NSDate date] earlierDate:self.viewGoal.goalStartDate]isEqualToDate: [NSDate date]]) {
            self.viewGoal.goalStatus = Pending;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now pending" message:@"This goal is now pending." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Pending"];
            self.view.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((178) / 255.0) blue:((255) / 255.0) alpha:1.0];
        }
        else if ([[[NSDate date] earlierDate:self.viewGoal.goalCompletionDate]isEqualToDate: self.viewGoal.goalCompletionDate]) {
            self.viewGoal.goalStatus = Overdue;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now overdue" message:@"This goal is now overdue." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Overdue"];
            self.view.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((102) / 255.0) blue:((102) / 255.0) alpha:1.0];
        }
        else {
            self.viewGoal.goalStatus = Active;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now Active" message:@"This goal is now Active." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Active"];
            self.view.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            
        }
        [self storeGoalStatusChangeToDB];
        self.outletActiveButton.hidden = NO;
        self.outletHistoryButton.hidden = NO;
        self.outletActiveButton.hidden = NO;
        self.addStepper.userInteractionEnabled = YES;
        self.addStairsStepper.userInteractionEnabled = YES;
        [self showAndEnableRightNavigationItem];
        [self.outletSuspendButton setTitle:@"Start" forState:UIControlStateNormal];
        [self.outletSuspendButton setTitle:@"Suspend" forState:UIControlStateNormal];
    }
}

//hide edit button
-(void) hideAndDisableRightNavigationItem {
    //[self.navigationItem.rightBarButtonItem setTintColor:[UIColor clearColor]];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

//show edit button
-(void) showAndEnableRightNavigationItem {
    //[self.navigationItem.rightBarButtonItem setTintColor:[UIColor blackColor]];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

//hide edit button
-(void) hideAndDisableLeftNavigationItem {
    //[self.navigationItem.leftBarButtonItem setTintColor:[UIColor clearColor]];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
}

//show edit button
-(void) showAndEnableLeftNavigationItem {
    //[self.navigationItem.leftBarButtonItem setTintColor:[UIColor blackColor]];
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
}

/*****************************History DB*****************************/
#pragma mark - History

-(int) getHistoryRowID:(int) goalID {
    NSString *query = [NSString stringWithFormat:@"select * from history where goalId='%d' and statusEndDate='%f'", goalID, 0.0];
    
    NSArray *historyResults;
    
    historyResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSInteger indexOfHistoryID = [self.dbManager.arrColumnNames indexOfObject:@"historyID"];
    
    return [[[historyResults objectAtIndex:0] objectAtIndex:indexOfHistoryID] intValue];
}

-(void) storeGoalStatusChangeToDB {
    NSString *query = [NSString stringWithFormat:@"update goals set goalStatus='%d' where goalID=%ld", self.viewGoal.goalStatus,(long)self.viewGoal.goalID];
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    NSLog(@"%d - %d",self.progressSteps, self.progressStairs);
    query = [NSString stringWithFormat:@"update histroy set statusEndDate='%f', progressSteps='%d', progressStairs='%d' where historyID=%ld", [[NSDate date] timeIntervalSince1970], self.progressSteps, self.progressStairs, (long)[self getHistoryRowID:self.viewGoal.goalID]];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    query = [NSString stringWithFormat:@"insert into history values(null, '%ld', '%d', '%f', '%f', '%d', '%d')", (long)self.viewGoal.goalID, self.viewGoal.goalStatus, [[NSDate date] timeIntervalSince1970], 0.0, 0, 0];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
}

- (IBAction)stepperAction:(id)sender {
    self.stepperLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}

- (IBAction)stepperStairsAction:(id)sender {
    self.stepperStairsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}
@end
