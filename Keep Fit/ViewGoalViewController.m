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


@interface ViewGoalViewController () {
    NSThread *BackgroundThread;
    NSTimer *timerStep;
    NSTimer *timerStair;
}

@property (nonatomic, strong) DBManager *dbManager;
@property (weak, nonatomic) IBOutlet UILabel *viewTitle;
@property (weak, nonatomic) IBOutlet UILabel *viewType;
@property (weak, nonatomic) IBOutlet UILabel *viewDateCreated;
@property (weak, nonatomic) IBOutlet UILabel *viewDateCompletion;
@property (weak, nonatomic) IBOutlet UIProgressView *viewProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *viewProgress;
- (IBAction)setActiveButton:(id)sender;
- (IBAction)suspendButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *outletActiveButton;
@property (weak, nonatomic) IBOutlet UIButton *outletSuspendButton;

@end

@implementation ViewGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    [self showDetails];
}

-(void)showDetails {
    self.navigationItem.title = [NSString stringWithFormat:@"%@", self.viewGoal.goalName];
    switch (self.viewGoal.goalStatus) {
        case Pending:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@ - Pending", self.viewGoal.goalName];
            self.outletActiveButton.hidden = NO;
            self.outletSuspendButton.hidden = NO;
            break;
        case Active:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@ - Active", self.viewGoal.goalName];
            [self.outletActiveButton setTitle:@"Stop" forState:UIControlStateNormal];
            self.outletActiveButton.hidden = NO;
            self.outletSuspendButton.hidden = NO;
            [self hideAndDisableLeftNavigationItem];
            [self hideAndDisableRightNavigationItem];
            break;
        case Overdue:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@ - Overdue", self.viewGoal.goalName];
            self.outletActiveButton.hidden = NO;
            self.outletSuspendButton.hidden = NO;
            break;
        case Suspended:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@ - Suspended", self.viewGoal.goalName];
            [self.outletSuspendButton setTitle:@"Re-instate" forState:UIControlStateNormal];
            self.outletActiveButton.hidden = YES;
            self.outletSuspendButton.hidden = NO;
            [self hideAndDisableRightNavigationItem];
            break;
        case Abandoned:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@ - Abandoned", self.viewGoal.goalName];
            self.outletActiveButton.hidden = YES;
            self.outletSuspendButton.hidden = YES;
            [self hideAndDisableRightNavigationItem];
            break;
        case Completed:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@ - Completed", self.viewGoal.goalName];
            self.outletActiveButton.hidden = YES;
            self.outletSuspendButton.hidden = YES;
            [self hideAndDisableRightNavigationItem];
            break;
        default:
            break;
    }
    
    switch (self.viewGoal.goalType) {
        case Steps:
            self.viewType.text = [NSString stringWithFormat:@"Goal Type: Steps"];
            self.viewProgress.text = [NSString stringWithFormat:@"Steps: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            break;
        case Stairs:
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
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //uncomment to get the time only
    //[formatter setDateFormat:@"hh:mm a"];
    //[formatter setDateFormat:@"MMM dd, YYYY"];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    self.viewDateCreated.text = [NSString stringWithFormat:@"Date Created: %@",[formatter stringFromDate:self.viewGoal.goalCreationDate]];
    self.viewDateCompletion.text = [NSString stringWithFormat:@"Completion Date: %@",[formatter stringFromDate:self.viewGoal.goalCompletionDate]];
    
    if (self.viewGoal.goalStatus == Active) {
        [self.outletActiveButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segue

-(IBAction)unwindToView:(UIStoryboardSegue *)segue {
    EditGoalViewController *source = [segue sourceViewController];
    
    if (source.wasEdit) {
        self.viewGoal = source.editGoal;
        if (self.viewGoal != nil) {
            NSString *query;
            query = [NSString stringWithFormat:@"update goals set goalName='%@', goalType='%d', goalAmountSteps='%ld', goalAmountStairs='%ld', goalDate='%f' where goalID=%ld", self.viewGoal.goalName, self.viewGoal.goalType, (long)self.viewGoal.goalAmountSteps, (long)self.viewGoal.goalAmountStairs, [self.viewGoal.goalCompletionDate timeIntervalSince1970], (long)self.viewGoal.goalID];
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
    
    [self showDetails];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showEditGoal"]) {
        EditGoalViewController *destViewController = segue.destinationViewController;
        destViewController.editGoal = self.viewGoal;
        destViewController.listGoalNames = self.listGoalNames;
    }
}

#pragma mark - Buttons

- (IBAction)setActiveButton:(id)sender {
    /**********************************set active*****************************************/
    if (self.activeGoal == nil) {
        self.viewGoal.goalStatus = Active;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now active" message:@"This goal is now active." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        NSString *query;
        query = [NSString stringWithFormat:@"update goals set goalStatus='%d' where goalID=%ld", self.viewGoal.goalStatus, (long)self.viewGoal.goalID];
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        }
        else {
            NSLog(@"Could not execute the query.");
        }
        self.activeGoal = self.viewGoal;
        self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@ - Active", self.viewGoal.goalName];
        [self hideAndDisableLeftNavigationItem];
        [self hideAndDisableRightNavigationItem];
        [self.outletActiveButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self startBackgroundThread];
    } /**********************************set pending*****************************************/
    else if (self.activeGoal.goalID == self.viewGoal.goalID) {
        if ([[[NSDate date] earlierDate:self.viewGoal.goalCompletionDate]isEqualToDate: self.viewGoal.goalCompletionDate]) {
            self.viewGoal.goalStatus = Overdue;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now overdue" message:@"This goal is now overdue." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@ - Overdue", self.viewGoal.goalName];
        }
        else {
            self.viewGoal.goalStatus = Pending;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now pending" message:@"This goal is now pending." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@ - Pending", self.viewGoal.goalName];
            self.activeGoal = nil;
        }
        NSString *query;
        query = [NSString stringWithFormat:@"update goals set goalStatus='%d' where goalID=%ld", self.viewGoal.goalStatus, (long)self.viewGoal.goalID];
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        }
        else {
            NSLog(@"Could not execute the query.");
        }
        [self showAndEnableLeftNavigationItem];
        [self showAndEnableRightNavigationItem];
        [self.outletActiveButton setTitle:@"Set Active" forState:UIControlStateNormal];
        [self cancelBackgroundThread];
    } else { /**********************************switch active*****************************************/
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Another goal already active" message:@"Would you like to make this goal the active goal?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert addButtonWithTitle:@"Yes"];
        [alert show];
    }
}

- (IBAction)suspendButton:(id)sender {
    /**********************************Suspend*****************************************/
    if ((self.viewGoal.goalStatus == Pending) || (self.viewGoal.goalStatus == Active) || (self.viewGoal.goalStatus == Overdue)) {
        self.viewGoal.goalStatus = Suspended;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now suspended" message:@"This goal is now suspended." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        NSString *query;
        query = [NSString stringWithFormat:@"update goals set goalStatus='%d' where goalID=%ld", self.viewGoal.goalStatus, (long)self.viewGoal.goalID];
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        }
        else {
            NSLog(@"Could not execute the query.");
        }
        self.activeGoal = nil;
        self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@ - Suspended", self.viewGoal.goalName];
        [self showAndEnableLeftNavigationItem];
        [self hideAndDisableRightNavigationItem];
        self.outletActiveButton.hidden = YES;
        [self.outletActiveButton setTitle:@"Set Active" forState:UIControlStateNormal];
        [self.outletSuspendButton setTitle:@"Re-instate" forState:UIControlStateNormal];
        if (self.viewGoal.goalStatus == Active) {
            [self cancelBackgroundThread];
        }
    }/**********************************Re-instate*****************************************/
    else if (self.viewGoal.goalStatus == Suspended) {
        if ([[[NSDate date] earlierDate:self.viewGoal.goalCompletionDate]isEqualToDate: self.viewGoal.goalCompletionDate]) {
            self.viewGoal.goalStatus = Overdue;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now overdue" message:@"This goal is now overdue." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@ - Overdue", self.viewGoal.goalName];
        }
        else {
            self.viewGoal.goalStatus = Pending;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now pending" message:@"This goal is now pending." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@ - Pending", self.viewGoal.goalName];
        }
        NSString *query;
        query = [NSString stringWithFormat:@"update goals set goalStatus='%d' where goalID=%ld", self.viewGoal.goalStatus, (long)self.viewGoal.goalID];
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        }
        else {
            NSLog(@"Could not execute the query.");
        }
        self.outletActiveButton.hidden = NO;
        [self showAndEnableRightNavigationItem];
        [self.outletSuspendButton setTitle:@"Set Active" forState:UIControlStateNormal];
        [self.outletSuspendButton setTitle:@"Suspend" forState:UIControlStateNormal];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        self.viewGoal.goalStatus = Active;

        if ([[[NSDate date] earlierDate:self.activeGoal.goalCompletionDate]isEqualToDate: self.activeGoal.goalCompletionDate]) {
            self.activeGoal.goalStatus = Overdue;
        }
        else {
            self.activeGoal.goalStatus = Pending;
        }
        NSString *query;
        query = [NSString stringWithFormat:@"update goals set goalStatus='%d' where goalID=%ld", self.viewGoal.goalStatus, (long)self.viewGoal.goalID];
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        }
        else {
            NSLog(@"Could not execute the query.");
        }
        query = [NSString stringWithFormat:@"update goals set goalStatus='%d' where goalID=%ld", self.activeGoal.goalStatus, (long)self.activeGoal.goalID];
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        }
        else {
            NSLog(@"Could not execute the query.");
        }
        self.activeGoal = self.viewGoal;
        self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@ - Active", self.viewGoal.goalName];
        [self hideAndDisableLeftNavigationItem];
        [self hideAndDisableRightNavigationItem];
        [self.outletActiveButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self startBackgroundThread];
    }
}

//hide edit button
-(void) hideAndDisableRightNavigationItem {
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor clearColor]];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

//show edit button
-(void) showAndEnableRightNavigationItem {
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor blackColor]];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

//hide edit button
-(void) hideAndDisableLeftNavigationItem {
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor clearColor]];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
}

//show edit button
-(void) showAndEnableLeftNavigationItem {
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor blackColor]];
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
}

/*************Background Thread***************/
-(void) startBackgroundThread {
    //create and start background thread
    BackgroundThread = [[NSThread alloc]initWithTarget:self selector:@selector(backgroundThread) object:nil];
    [BackgroundThread start];
}

-(void) backgroundThread {
    NSLog(@"performing background thread");
    
    if ((self.viewGoal.goalType == Steps) || (self.viewGoal.goalType == Both)) {
        timerStep = [NSTimer timerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(takeStep)
                                           userInfo:nil
                                            repeats:YES ];
        [[NSRunLoop mainRunLoop] addTimer:timerStep forMode:NSRunLoopCommonModes];
    }
    if ((self.viewGoal.goalType == Stairs) || (self.viewGoal.goalType == Both)) {
        timerStair = [NSTimer timerWithTimeInterval:3.0
                                             target:self
                                           selector:@selector(takeStair)
                                           userInfo:nil
                                            repeats:YES ];
        [[NSRunLoop mainRunLoop] addTimer:timerStair forMode:NSRunLoopCommonModes];
    }
    
    BOOL cancelThread = NO;
    while (!cancelThread) {
        cancelThread = [BackgroundThread isCancelled];
    }
    NSLog(@"Cancel");
    [self cleanUpBackgroundThread];
}

-(void) takeStep {
    NSLog(@"Take Step");
    if (self.viewGoal.goalAmountSteps != self.viewGoal.goalProgressSteps) {
        self.viewGoal.goalProgressSteps++;
        [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
    }
    else {
        [timerStep invalidate];
        timerStep = nil;
        if ((self.viewGoal.goalAmountSteps == self.viewGoal.goalProgressSteps) && (self.viewGoal.goalAmountStairs == self.viewGoal.goalProgressStairs)) {
            [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:YES];
            [self cancelBackgroundThread];
        }
    }
}

-(void) takeStair {
    NSLog(@"Take Stair");
    if (self.viewGoal.goalAmountStairs != self.viewGoal.goalProgressStairs) {
        self.viewGoal.goalProgressStairs++;
        [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
    }
    else {
        [timerStair invalidate];
        timerStair = nil;
        if ((self.viewGoal.goalAmountSteps == self.viewGoal.goalProgressSteps) && (self.viewGoal.goalAmountStairs == self.viewGoal.goalProgressStairs)) {
            [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:YES];
            [self cancelBackgroundThread];
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
    self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@ - Completed", self.viewGoal.goalName];
    self.outletActiveButton.hidden = YES;
    self.outletSuspendButton.hidden = YES;
    [self showAndEnableLeftNavigationItem];
}

-(void) cancelBackgroundThread {
    NSLog(@"Cancel BackgroundThread");
    [BackgroundThread cancel];
}

-(void) cleanUpBackgroundThread {
    NSLog(@"Clean Up BackgroundThread");
    if (timerStep) {
        [timerStep invalidate];
        timerStep = nil;
    }
    if (timerStair) {
        [timerStep invalidate];
        timerStep = nil;
    }
}

@end
