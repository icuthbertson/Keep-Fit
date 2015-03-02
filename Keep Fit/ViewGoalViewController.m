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


@interface ViewGoalViewController () {
    NSThread *BackgroundThread; // Background thread used for holding the steps and stairs timers.
    NSTimer *timerStep; // Timer for steps.
    NSTimer *timerStair; // Timer for stairs.
}

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
@property (weak, nonatomic) IBOutlet UIButton *scheduleButton; // Schedule button outlet.
@property (weak, nonatomic) IBOutlet UIButton *timeButton; // Change date/time button outlet.

@property int progressSteps; // Holds current progress of steps in background thread.
@property int progressStairs; // Holds current progress of stairs in background thread.
@property BOOL isRecording; // Holds bool to check if goal is currently recording.

@end

@implementation ViewGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    // Goal initially not recording.
    self.isRecording = NO;
    
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
            [self.outletActiveButton setTitle:@"Start" forState:UIControlStateNormal];
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
    
    // Set up the date formatter to the required format.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    // Set the date labels to their values in the required format.
    self.viewDateCreated.text = [NSString stringWithFormat:@"Date Created: %@",[formatter stringFromDate:self.viewGoal.goalCreationDate]];
    self.viewDateStart.text = [NSString stringWithFormat:@"Start Date: %@",[formatter stringFromDate:self.viewGoal.goalStartDate]];
    self.viewDateCompletion.text = [NSString stringWithFormat:@"Completion Date: %@",[formatter stringFromDate:self.viewGoal.goalCompletionDate]];
    
    // If the goal is in testing mode, hide the active and suspend buttons
    if ([self.testing getTesting]) {
        self.outletActiveButton.hidden = YES;
        self.outletSuspendButton.hidden = YES;
    }
    else { // If the goal is not in testing mode, hide the schedule and change time button.
        self.scheduleButton.hidden = YES;
        self.timeButton.hidden = YES;
    }
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
            query = [NSString stringWithFormat:@"update %@ set goalName='%@', goalType='%d', goalAmountSteps='%ld', goalAmountStairs='%ld', goalStartDate='%f', goalDate='%f', goalConversion='%d' where goalID=%ld", self.testing.getGoalDBName, self.viewGoal.goalName, self.viewGoal.goalType, (long)self.viewGoal.goalAmountSteps, (long)self.viewGoal.goalAmountStairs, [self.viewGoal.goalStartDate timeIntervalSince1970], [self.viewGoal.goalCompletionDate timeIntervalSince1970], self.viewGoal.goalConversion, (long)self.viewGoal.goalID];
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

// Returning from the chagne time view.
-(IBAction)unwindFromChangeTime:(UIStoryboardSegue *)segue {
    ChangeTimeViewController *source = [segue sourceViewController];
    // If the NSDate object from the change time view isn't nil.
    if (source.changeDate != nil) {
        // Initialise vairables for method.
        NSDate *changeDate = source.changeDate;
        NSDate *tempStartDate = [[NSDate alloc] init];
        NSDate *tempEndDate = [[NSDate alloc] init];
        int tempSteps = 0;
        int tempStairs = 0;
        double startDate = 0.0;
        double endDate = 0.0;
        KeepFitGoal *loopGoal = [[KeepFitGoal alloc] init];
        
        // Loop through all of the goals.
        for (int i=0; i<[self.keepFitGoals count]; i++) {
            loopGoal = [self.keepFitGoals objectAtIndex:i];
            
            // Test if the goal has become Active and set if so.
            if (loopGoal.goalStatus == Pending) {
                if ([[loopGoal.goalStartDate earlierDate:changeDate]isEqualToDate: loopGoal.goalStartDate]) {
                    loopGoal.goalStatus = Active;
                }
            }
            // Test if the goal has become Overdue and set if so.
            if (loopGoal.goalStatus == Active) {
                if ([[loopGoal.goalCompletionDate earlierDate:changeDate]isEqualToDate: loopGoal.goalCompletionDate]) {
                    loopGoal.goalStatus = Overdue;
                }
            }
            
            // get history for the goal from the current date to the end date.
            NSString *query = [NSString stringWithFormat:@"select * from testHistory where (goalID='%d' and ((statusStartDate > '%f') or (statusStartDate < '%f' and statusEndDate > '%f')))",loopGoal.goalID,[[self.testing getTime] timeIntervalSince1970],[[self.testing getTime] timeIntervalSince1970],[[self.testing getTime] timeIntervalSince1970]];
            
            NSArray *historyResults;
            historyResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
            
            NSLog(@"history results: %@",historyResults);
            
            // Get indexes of columns for the history db.
            NSInteger indexOfGoalStatus = [self.dbManager.arrColumnNames indexOfObject:@"goalStatus"];
            NSInteger indexOfStatusStartDate = [self.dbManager.arrColumnNames indexOfObject:@"statusStartDate"];
            NSInteger indexOfStatusEndDate = [self.dbManager.arrColumnNames indexOfObject:@"statusEndDate"];
            NSInteger indexOfGoalProgressSteps = [self.dbManager.arrColumnNames indexOfObject:@"progressSteps"];
            NSInteger indexOfGoalProgressStairs = [self.dbManager.arrColumnNames indexOfObject:@"progressStairs"];
            
            // Loop through the history results.
            for (int i=0; i < [historyResults count]; i++) {
                // Get the dates from the history.
                tempStartDate = [NSDate dateWithTimeIntervalSince1970:[[[historyResults objectAtIndex:i] objectAtIndex:indexOfStatusStartDate] doubleValue]];
                tempEndDate = [NSDate dateWithTimeIntervalSince1970:[[[historyResults objectAtIndex:i] objectAtIndex:indexOfStatusEndDate] doubleValue]];
                tempSteps = [[[historyResults objectAtIndex:i] objectAtIndex:indexOfGoalProgressSteps] intValue];
                tempStairs = [[[historyResults objectAtIndex:i] objectAtIndex:indexOfGoalProgressStairs] intValue];
                startDate = [[[historyResults objectAtIndex:i] objectAtIndex:indexOfStatusStartDate] doubleValue];
                endDate = [[[historyResults objectAtIndex:i] objectAtIndex:indexOfStatusEndDate] doubleValue];
                
                // still in middle of scheduled progress.
                if (([[[self.testing getTime] earlierDate:tempStartDate]isEqualToDate:tempStartDate]) && ([[changeDate earlierDate:tempEndDate]isEqualToDate:changeDate])) {
                    NSLog(@"Middle");
                    NSLog(@"OLD MID - Steps: %d Stairs: %d",loopGoal.goalProgressSteps,loopGoal.goalProgressStairs);
                    loopGoal.goalProgressSteps += (tempSteps * (([changeDate timeIntervalSince1970] - [[self.testing getTime] timeIntervalSince1970])/(endDate-startDate)));
                    loopGoal.goalProgressStairs += (tempStairs * (([changeDate timeIntervalSince1970] - [[self.testing getTime] timeIntervalSince1970])/(endDate-startDate)));
                    NSLog(@"NEW MID - Steps: %d Stairs: %d",loopGoal.goalProgressSteps,loopGoal.goalProgressStairs);
                }// second half of scheduled progress.
                else if (([[[self.testing getTime] earlierDate:tempStartDate]isEqualToDate:tempStartDate]) && ([[changeDate earlierDate:tempEndDate]isEqualToDate:tempEndDate])) {
                    NSLog(@"Second Half");
                    NSLog(@"OLD MID - Steps: %d Stairs: %d",loopGoal.goalProgressSteps,loopGoal.goalProgressStairs);
                    loopGoal.goalProgressSteps += (tempSteps * ((endDate - [[self.testing getTime] timeIntervalSince1970])/(endDate-startDate)));
                    loopGoal.goalProgressStairs += (tempStairs * ((endDate - [[self.testing getTime] timeIntervalSince1970])/(endDate-startDate)));
                    NSLog(@"NEW MID - Steps: %d Stairs: %d",loopGoal.goalProgressSteps,loopGoal.goalProgressStairs);
                }// first half of scheduled progress.
                else if (([[changeDate earlierDate:tempEndDate]isEqualToDate:changeDate]) && ([[[self.testing getTime] earlierDate:tempStartDate]isEqualToDate:[self.testing getTime]])) {
                    NSLog(@"First Half");
                    NSLog(@"OLD MID - Steps: %d Stairs: %d",loopGoal.goalProgressSteps,loopGoal.goalProgressStairs);
                    loopGoal.goalProgressSteps += (tempSteps * (([changeDate timeIntervalSince1970]-startDate)/(endDate-startDate)));
                    loopGoal.goalProgressStairs += (tempStairs * (([changeDate timeIntervalSince1970]-startDate)/(endDate-startDate)));
                    NSLog(@"NEW MID - Steps: %d Stairs: %d",loopGoal.goalProgressSteps,loopGoal.goalProgressStairs);
                }// full scheduled progress.
                else if (([[[self.testing getTime] earlierDate:tempStartDate]isEqualToDate:[self.testing getTime]]) && ([[changeDate earlierDate:tempEndDate]isEqualToDate:tempEndDate]) && (endDate != 0.0)) {
                    NSLog(@"Full");
                    NSLog(@"OLD - Steps: %d Stairs: %d",loopGoal.goalProgressSteps,loopGoal.goalProgressStairs);
                    loopGoal.goalProgressSteps += tempSteps;
                    loopGoal.goalProgressStairs += tempStairs;
                    NSLog(@"NEW - Steps: %d Stairs: %d",loopGoal.goalProgressSteps,loopGoal.goalProgressStairs);
                }
                // Update status if goal is now completed.
                if ([[[historyResults objectAtIndex:i] objectAtIndex:indexOfGoalStatus] intValue] == Completed) {
                    NSLog(@"COMPLETED");
                    loopGoal.goalStatus = Completed;
                }
            }
            
            // Update goal in DB.
            query = [NSString stringWithFormat:@"update testGoals set goalStatus='%d', goalProgressSteps='%ld', goalProgressStairs='%ld' where goalID=%ld", loopGoal.goalStatus, (long)loopGoal.goalProgressSteps, (long)loopGoal.goalProgressStairs, (long)loopGoal.goalID];
            // Execute the query.
            [self.dbManager executeQuery:query];
            
            if (self.dbManager.affectedRows != 0) {
                NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
            }
            else {
                NSLog(@"Could not execute the query.");
            }
            
            // Update the persisted time in the database.
            query = [NSString stringWithFormat:@"update testDate set currentTime='%f'",[changeDate timeIntervalSince1970]];
            
            // Execute the query.
            [self.dbManager executeQuery:query];
            
            if (self.dbManager.affectedRows != 0) {
                NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
            }
            else {
                NSLog(@"Could not execute the query.");
            }
            
            if (loopGoal.goalID == self.viewGoal.goalID) {
                self.viewGoal.goalID = loopGoal.goalID;
            }
            
            
        }
        // Set the new time in the testing object.
        [self.testing setTime:changeDate];
        // Update the view.
        [self showDetails];
    }
}

// Returning from schedule view.
-(IBAction)unwindFromSchedule:(UIStoryboardSegue *)segue {
    ScheduleViewController *source = [segue sourceViewController];
    // Store new schedule to the history database.
    [self storeGoalScheduleToDB:source.schedule];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showEditGoal"]) {
        EditGoalViewController *destViewController = segue.destinationViewController;
        destViewController.editGoal = self.viewGoal;
        destViewController.listGoalNames = self.listGoalNames;
        destViewController.testing = self.testing;
    }
    else if ([segue.identifier isEqualToString:@"showHistory"]) {
        HistoryTableViewController *destViewController = segue.destinationViewController;
        destViewController.viewHistoryGoal = self.viewGoal;
        destViewController.testing = self.testing;
    }
    else if ([segue.identifier isEqualToString:@"changeTime"]) {
        ChangeTimeViewController *destViewController = segue.destinationViewController;
        destViewController.currentTime = [self.testing getTime];
    }
    else if ([segue.identifier isEqualToString:@"scheduleActivity"]) {
        ScheduleViewController *destViewController = segue.destinationViewController;
        destViewController.currentTime = [self.testing getTime];
        destViewController.viewGoal = self.viewGoal;
    }
}

#pragma mark - Buttons

- (IBAction)setActiveButton:(id)sender {
    /**********************************set active*****************************************/
    if (!self.isRecording) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now Recording" message:@"This goal is now recording." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        self.isRecording = YES;
        [self storeGoalStatusChangeToDB];
        [self hideAndDisableLeftNavigationItem];
        [self hideAndDisableRightNavigationItem];
        [self.outletActiveButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.outletHistoryButton.hidden = YES;
        [self startBackgroundThread];
    } /**********************************set pending*****************************************/
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now not recording" message:@"This goal is now not recording." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            self.isRecording = NO;
        [self storeGoalStatusChangeToDB];
        [self showAndEnableLeftNavigationItem];
        [self showAndEnableRightNavigationItem];
        [self.outletActiveButton setTitle:@"Start" forState:UIControlStateNormal];
        self.outletHistoryButton.hidden = NO;
        [self cancelBackgroundThread];
    }
}

- (IBAction)suspendButton:(id)sender {
    /**********************************Suspend*****************************************/
    if ((self.viewGoal.goalStatus == Pending) || (self.viewGoal.goalStatus == Active) || (self.viewGoal.goalStatus == Overdue)) {
        if (self.isRecording) {
            [self cancelBackgroundThread];
        }
        self.viewGoal.goalStatus = Suspended;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now suspended" message:@"This goal is now suspended." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [self storeGoalStatusChangeToDB];
        self.isRecording = NO;
        self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Suspended"];
        self.view.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
        [self showAndEnableLeftNavigationItem];
        [self hideAndDisableRightNavigationItem];
        self.outletActiveButton.hidden = YES;
        self.outletHistoryButton.hidden = NO;
        [self.outletActiveButton setTitle:@"Start" forState:UIControlStateNormal];
        [self.outletSuspendButton setTitle:@"Re-instate" forState:UIControlStateNormal];
    }/**********************************Re-instate*****************************************/
    else if (self.viewGoal.goalStatus == Suspended) {
        if ([[[self.testing getTime] earlierDate:self.viewGoal.goalStartDate]isEqualToDate: [self.testing getTime]]) {
            self.viewGoal.goalStatus = Pending;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now pending" message:@"This goal is now pending." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Pending"];
            self.view.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((178) / 255.0) blue:((255) / 255.0) alpha:1.0];
        }
        else if ([[[self.testing getTime] earlierDate:self.viewGoal.goalCompletionDate]isEqualToDate: self.viewGoal.goalCompletionDate]) {
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

/*************Background Thread***************/
-(void) startBackgroundThread {
    //create and start background thread
    BackgroundThread = [[NSThread alloc]initWithTarget:self selector:@selector(backgroundThread) object:nil];
    [BackgroundThread start];
}

-(void) backgroundThread {
    NSLog(@"performing background thread");
    
    if (((self.viewGoal.goalType == Steps) || (self.viewGoal.goalType == Both)) && (self.viewGoal.goalAmountSteps != self.viewGoal.goalProgressSteps)) {
        timerStep = [NSTimer timerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(takeStep)
                                           userInfo:nil
                                            repeats:YES ];
        [[NSRunLoop mainRunLoop] addTimer:timerStep forMode:NSRunLoopCommonModes];
    }
    if (((self.viewGoal.goalType == Stairs) || (self.viewGoal.goalType == Both)) && (self.viewGoal.goalAmountStairs != self.viewGoal.goalProgressStairs)) {
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
        self.progressSteps++;
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
        self.progressStairs++;
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
    query = [NSString stringWithFormat:@"update %@ set goalStatus='%d', goalProgressSteps='%d', goalProgressStairs='%d' where goalID=%ld", self.testing.getGoalDBName ,self.viewGoal.goalStatus, self.viewGoal.goalProgressSteps, self.viewGoal.goalProgressStairs, (long)self.viewGoal.goalID];
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
    self.isRecording = NO;
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
    [timerStep invalidate];
    timerStep = nil;
    [timerStair invalidate];
    timerStair = nil;
}

/*****************************History DB*****************************/
#pragma mark - History

-(int) getHistoryRowID:(int) goalID {
    NSString *query = [NSString stringWithFormat:@"select * from %@ where goalId='%d' and statusEndDate='%f'", self.testing.getHistoryDBName, goalID, 0.0];
    
    NSArray *historyResults;
    
    historyResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSInteger indexOfHistoryID = [self.dbManager.arrColumnNames indexOfObject:@"historyID"];
    
    return [[[historyResults objectAtIndex:0] objectAtIndex:indexOfHistoryID] intValue];
}

-(void) storeGoalStatusChangeToDB {
    NSString *query = [NSString stringWithFormat:@"update %@ set goalStatus='%d' where goalID=%ld", self.testing.getGoalDBName, self.viewGoal.goalStatus,(long)self.viewGoal.goalID];
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    NSLog(@"%d - %d",self.progressSteps, self.progressStairs);
    query = [NSString stringWithFormat:@"update %@ set statusEndDate='%f', progressSteps='%d', progressStairs='%d' where historyID=%ld", self.testing.getHistoryDBName, [[self.testing getTime] timeIntervalSince1970], self.progressSteps, self.progressStairs, (long)[self getHistoryRowID:self.viewGoal.goalID]];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    query = [NSString stringWithFormat:@"insert into %@ values(null, '%ld', '%d', '%f', '%f', '%d', '%d')", self.testing.getHistoryDBName, (long)self.viewGoal.goalID, self.viewGoal.goalStatus, [[self.testing getTime] timeIntervalSince1970], 0.0, 0, 0];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    self.progressSteps = 0;
    self.progressStairs = 0;
}

-(void) storeGoalScheduleToDB:(Schedule*) schedule {
    NSString *query = [NSString stringWithFormat:@"update %@ set statusEndDate='%f' where historyID=%ld", self.testing.getHistoryDBName, [schedule.date timeIntervalSince1970], (long)[self getHistoryRowID:self.viewGoal.goalID]];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    query = [NSString stringWithFormat:@"insert into %@ values(null, '%ld', '%d', '%f', '%f', '%d', '%d')", self.testing.getHistoryDBName, (long)self.viewGoal.goalID, self.viewGoal.goalStatus, [schedule.date timeIntervalSince1970], [schedule.endDate timeIntervalSince1970], schedule.numSteps, schedule.numStairs];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    if (schedule.completed) {
        query = [NSString stringWithFormat:@"insert into %@ values(null, '%ld', '%d', '%f', '%f', '%d', '%d')", self.testing.getHistoryDBName, (long)self.viewGoal.goalID, Completed, [schedule.endDate timeIntervalSince1970], 0.0, 0, 0];
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        }
        else {
            NSLog(@"Could not execute the query.");
        }
    }
    else {
        query = [NSString stringWithFormat:@"insert into %@ values(null, '%ld', '%d', '%f', '%f', '%d', '%d')", self.testing.getHistoryDBName, (long)self.viewGoal.goalID, self.viewGoal.goalStatus, [schedule.endDate timeIntervalSince1970], 0.0, 0, 0];
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

@end
