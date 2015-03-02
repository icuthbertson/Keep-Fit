//
//  TestViewGoalViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 24/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "TestViewGoalViewController.h"
#import "TestHistoryTableViewController.h"
#import "ChangeTimeViewController.h"
#import "ScheduleViewController.h"
#import "DBManager.h"
#import "GoalHistory.h"

@interface TestViewGoalViewController () {
    NSThread *BackgroundThread; // Background thread used for holding the steps and stairs timers.
    NSTimer *timerStep; // Timer for steps.
    NSTimer *timerStair; // Timer for stairs.
}

@property DBManager *dbManager;
@property (weak, nonatomic) IBOutlet UILabel *viewTitle;
@property (weak, nonatomic) IBOutlet UILabel *viewType;
@property (weak, nonatomic) IBOutlet UILabel *viewDateCreated;
@property (weak, nonatomic) IBOutlet UILabel *viewDateCompletion;
@property (weak, nonatomic) IBOutlet UIProgressView *viewProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *viewProgress;
@property (weak, nonatomic) IBOutlet UILabel *viewDateStart;
@property (weak, nonatomic) IBOutlet UIButton *outletHistoryButton;
@property (weak, nonatomic) IBOutlet UILabel *viewStatus;
@property (weak, nonatomic) IBOutlet UIButton *scheduleButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *outletActiveButton;
- (IBAction)setActiveButton:(id)sender;

@property int progressSteps; // Holds current progress of steps in background thread.
@property int progressStairs; // Holds current progress of stairs in background thread.
@property BOOL isRecording; // Holds bool to check if goal is currently recording.

@end

@implementation TestViewGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    [self showDetails];
}

-(void)showDetails {
    self.navigationItem.title = [NSString stringWithFormat:@"%@", self.viewGoal.goalName];
    switch (self.viewGoal.goalStatus) {
        case Pending:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@", self.viewGoal.goalName];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Pending"];
            self.scheduleButton.hidden = YES;
            self.timeButton.hidden = NO;
            break;
        case Active:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@", self.viewGoal.goalName];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Active"];
            self.scheduleButton.hidden = NO;
            self.timeButton.hidden = NO;
            break;
        case Overdue:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@", self.viewGoal.goalName];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Overdue"];
            self.scheduleButton.hidden = NO;
            self.timeButton.hidden = NO;
            break;
        case Suspended:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@", self.viewGoal.goalName];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Suspended"];
            self.scheduleButton.hidden = YES;
            self.timeButton.hidden = YES;
            break;
        case Abandoned:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@", self.viewGoal.goalName];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Abandoned"];
            self.scheduleButton.hidden = YES;
            self.timeButton.hidden = YES;
            break;
        case Completed:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@", self.viewGoal.goalName];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Completed"];
            self.scheduleButton.hidden = YES;
            self.timeButton.hidden = YES;
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
    self.viewDateStart.text = [NSString stringWithFormat:@"Start Date: %@",[formatter stringFromDate:self.viewGoal.goalStartDate]];
    self.viewDateCompletion.text = [NSString stringWithFormat:@"Completion Date: %@",[formatter stringFromDate:self.viewGoal.goalCompletionDate]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            
            if (loopGoal.goalStatus != Completed) {
                // get history for the goal from the current date to the end date.
                NSString *query = [NSString stringWithFormat:@"select * from testHistory where (goalID='%d' and ((statusStartDate > '%f') or (statusStartDate < '%f' and statusEndDate > '%f')))",loopGoal.goalID,[self.currentDate timeIntervalSince1970],[self.currentDate timeIntervalSince1970],[self.currentDate timeIntervalSince1970]];
                
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
                    if (([[self.currentDate earlierDate:tempStartDate]isEqualToDate:tempStartDate]) && ([[changeDate earlierDate:tempEndDate]isEqualToDate:changeDate])) {
                        NSLog(@"Middle");
                        NSLog(@"OLD MID - Steps: %d Stairs: %d",loopGoal.goalProgressSteps,loopGoal.goalProgressStairs);
                        loopGoal.goalProgressSteps += (tempSteps * (([changeDate timeIntervalSince1970] - [self.currentDate timeIntervalSince1970])/(endDate-startDate)));
                        loopGoal.goalProgressStairs += (tempStairs * (([changeDate timeIntervalSince1970] - [self.currentDate timeIntervalSince1970])/(endDate-startDate)));
                        NSLog(@"NEW MID - Steps: %d Stairs: %d",loopGoal.goalProgressSteps,loopGoal.goalProgressStairs);
                    }// second half of scheduled progress.
                    else if (([[self.currentDate earlierDate:tempStartDate]isEqualToDate:tempStartDate]) && ([[changeDate earlierDate:tempEndDate]isEqualToDate:tempEndDate])) {
                        NSLog(@"Second Half");
                        NSLog(@"OLD MID - Steps: %d Stairs: %d",loopGoal.goalProgressSteps,loopGoal.goalProgressStairs);
                        loopGoal.goalProgressSteps += (tempSteps * ((endDate - [self.currentDate timeIntervalSince1970])/(endDate-startDate)));
                        loopGoal.goalProgressStairs += (tempStairs * ((endDate - [self.currentDate timeIntervalSince1970])/(endDate-startDate)));
                        NSLog(@"NEW MID - Steps: %d Stairs: %d",loopGoal.goalProgressSteps,loopGoal.goalProgressStairs);
                    }// first half of scheduled progress.
                    else if (([[changeDate earlierDate:tempEndDate]isEqualToDate:changeDate]) && ([[self.currentDate earlierDate:tempStartDate]isEqualToDate:self.currentDate])) {
                        NSLog(@"First Half");
                        NSLog(@"OLD MID - Steps: %d Stairs: %d",loopGoal.goalProgressSteps,loopGoal.goalProgressStairs);
                        loopGoal.goalProgressSteps += (tempSteps * (([changeDate timeIntervalSince1970]-startDate)/(endDate-startDate)));
                        loopGoal.goalProgressStairs += (tempStairs * (([changeDate timeIntervalSince1970]-startDate)/(endDate-startDate)));
                        NSLog(@"NEW MID - Steps: %d Stairs: %d",loopGoal.goalProgressSteps,loopGoal.goalProgressStairs);
                    }// full scheduled progress.
                    else if (([[self.currentDate earlierDate:tempStartDate]isEqualToDate:self.currentDate]) && ([[changeDate earlierDate:tempEndDate]isEqualToDate:tempEndDate]) && (endDate != 0.0)) {
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
                
            }
            
            // Update the persisted time in the database.
            NSString *dateQuery = [NSString stringWithFormat:@"update testDate set currentTime='%f'",[changeDate timeIntervalSince1970]];
            
            // Execute the query.
            [self.dbManager executeQuery:dateQuery];
            
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
        self.currentDate = changeDate;
        // Update the view.
        [self showDetails];
    }
}
-(IBAction)unwindFromSchedule:(UIStoryboardSegue *)segue {
    ScheduleViewController *source = [segue sourceViewController];
    [self storeGoalScheduleToDB:source.schedule];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showHistoryTest"]) {
        TestHistoryTableViewController *destViewController = segue.destinationViewController;
        destViewController.viewHistoryGoal = self.viewGoal;
        destViewController.currentDate = self.currentDate;
    }
    else if ([segue.identifier isEqualToString:@"changeTime"]) {
        ChangeTimeViewController *destViewController = segue.destinationViewController;
        destViewController.currentTime = self.currentDate;
    }
    else if ([segue.identifier isEqualToString:@"scheduleActivity"]) {
        ScheduleViewController *destViewController = segue.destinationViewController;
        destViewController.currentTime = self.currentDate;
        destViewController.viewGoal = self.viewGoal;
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
        timerStep = [NSTimer timerWithTimeInterval:self.settings.stepsTime
                                            target:self
                                          selector:@selector(takeStep)
                                          userInfo:nil
                                           repeats:YES ];
        [[NSRunLoop mainRunLoop] addTimer:timerStep forMode:NSRunLoopCommonModes];
    }
    if (((self.viewGoal.goalType == Stairs) || (self.viewGoal.goalType == Both)) && (self.viewGoal.goalAmountStairs != self.viewGoal.goalProgressStairs)) {
        timerStair = [NSTimer timerWithTimeInterval:self.settings.stairsTime
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
    query = [NSString stringWithFormat:@"update testGoals set goalStatus='%d', goalProgressSteps='%d', goalProgressStairs='%d' where goalID=%ld", self.viewGoal.goalStatus, self.viewGoal.goalProgressSteps, self.viewGoal.goalProgressStairs, (long)self.viewGoal.goalID];
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

#pragma mark - History

-(int) getHistoryRowID:(int) goalID {
    NSString *query = [NSString stringWithFormat:@"select * from testHistory where goalId='%d' and statusEndDate='%f'", goalID, 0.0];
    
    NSArray *historyResults;
    
    historyResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSInteger indexOfHistoryID = [self.dbManager.arrColumnNames indexOfObject:@"historyID"];
    
    return [[[historyResults objectAtIndex:0] objectAtIndex:indexOfHistoryID] intValue];
}

-(void) storeGoalStatusChangeToDB {
    NSString *query = [NSString stringWithFormat:@"update testGoals set goalStatus='%d' where goalID=%ld", self.viewGoal.goalStatus,(long)self.viewGoal.goalID];
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    NSLog(@"%d - %d",self.progressSteps, self.progressStairs);
    query = [NSString stringWithFormat:@"update testHistory set statusEndDate='%f', progressSteps='%d', progressStairs='%d' where historyID=%ld", [self.currentDate timeIntervalSince1970], self.progressSteps, self.progressStairs, (long)[self getHistoryRowID:self.viewGoal.goalID]];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    query = [NSString stringWithFormat:@"insert into testHistory values(null, '%ld', '%d', '%f', '%f', '%d', '%d')", (long)self.viewGoal.goalID, self.viewGoal.goalStatus, [self.currentDate timeIntervalSince1970], 0.0, 0, 0];
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
    NSString *query = [NSString stringWithFormat:@"update testHistory set statusEndDate='%f' where historyID=%ld", [schedule.date timeIntervalSince1970], (long)[self getHistoryRowID:self.viewGoal.goalID]];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    query = [NSString stringWithFormat:@"insert into testHistory values(null, '%ld', '%d', '%f', '%f', '%d', '%d')", (long)self.viewGoal.goalID, self.viewGoal.goalStatus, [schedule.date timeIntervalSince1970], [schedule.endDate timeIntervalSince1970], schedule.numSteps, schedule.numStairs];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    if (schedule.completed) {
        query = [NSString stringWithFormat:@"insert into testHistory values(null, '%ld', '%d', '%f', '%f', '%d', '%d')", (long)self.viewGoal.goalID, Completed, [schedule.endDate timeIntervalSince1970], 0.0, 0, 0];
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
        query = [NSString stringWithFormat:@"insert into testHistory values(null, '%ld', '%d', '%f', '%f', '%d', '%d')", (long)self.viewGoal.goalID, self.viewGoal.goalStatus, [schedule.endDate timeIntervalSince1970], 0.0, 0, 0];
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
        self.scheduleButton.hidden = YES;
        self.timeButton.hidden = YES;
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
        self.scheduleButton.hidden = NO;
        self.timeButton.hidden = NO;
        [self cancelBackgroundThread];
    }
}

@end
