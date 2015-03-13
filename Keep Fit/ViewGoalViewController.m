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
#import <QuartzCore/QuartzCore.h>


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
@property (weak, nonatomic) IBOutlet UILabel *stepperLabel;
@property (weak, nonatomic) IBOutlet UIStepper *addStepper;
- (IBAction)stepperAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *stepperStairsLabel;
@property (weak, nonatomic) IBOutlet UIStepper *addStairsStepper;
- (IBAction)stepperStairsAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *mainDetailsView;
@property (weak, nonatomic) IBOutlet UIView *trackingView;
@property (weak, nonatomic) IBOutlet UIView *datesView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewSelector;
- (IBAction)viewSelectorAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *statisticsView;
@property (weak, nonatomic) IBOutlet UIView *testTrackingView;
-(IBAction)setActiveButtonTest:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *activeOutletButtonTest;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *autoStepSpinner;
@property (weak, nonatomic) IBOutlet UILabel *testTrackLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *testTrackProgress;
@property (weak, nonatomic) IBOutlet UILabel *trackLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *trackProgress;
@property (weak, nonatomic) IBOutlet UILabel *stepsPerDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepsPerWeekLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepsPerMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepsPerYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *stairsPerDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *stairsPerWeekLabel;
@property (weak, nonatomic) IBOutlet UILabel *stairsPerMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *stairsPerYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *stairsTitleLabel;

@property NSInteger progressSteps;
@property NSInteger progressStairs;
@property BOOL isRecording; // Holds bool to check if goal is currently recording.

@property NSInteger totalSteps;
@property NSInteger totalStairs;
@property double startDate;
@property double endDate;

@property double recordingStartTime;
@property double recordingEndTime;

@end

@implementation ViewGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 568)];
    
    self.trackingView.hidden = YES;
    self.statisticsView.hidden = YES;
    self.testTrackingView.hidden = YES;
    self.autoStepSpinner.hidden = YES;
    
    //line between segmented control and views
    UIBezierPath *pathDetails = [UIBezierPath bezierPath];
    [pathDetails moveToPoint:CGPointMake(0.0, 150.0)];
    [pathDetails addLineToPoint:CGPointMake(320.0, 150.0)];
    
    CAShapeLayer *detailsLine = [CAShapeLayer layer];
    detailsLine.path = [pathDetails CGPath];
    detailsLine.strokeColor = [[UIColor grayColor] CGColor];
    detailsLine.lineWidth = 0.5;
    detailsLine.fillColor = [[UIColor clearColor] CGColor];
    
    //Line between dates and progress
    UIBezierPath *pathProgress = [UIBezierPath bezierPath];
    [pathProgress moveToPoint:CGPointMake(24.0, 138.0)];
    [pathProgress addLineToPoint:CGPointMake(320.0, 138.0)];
    
    CAShapeLayer *progressLine = [CAShapeLayer layer];
    progressLine.path = [pathProgress CGPath];
    progressLine.strokeColor = [[UIColor grayColor] CGColor];
    progressLine.lineWidth = 0.5;
    progressLine.fillColor = [[UIColor clearColor] CGColor];
    
    //Line between progress bar and options
    UIBezierPath *pathOption = [UIBezierPath bezierPath];
    [pathOption moveToPoint:CGPointMake(24.0, 222.0)];
    [pathOption addLineToPoint:CGPointMake(320.0, 222.0)];
    
    CAShapeLayer *optionLine = [CAShapeLayer layer];
    optionLine.path = [pathOption CGPath];
    optionLine.strokeColor = [[UIColor grayColor] CGColor];
    optionLine.lineWidth = 0.5;
    optionLine.fillColor = [[UIColor clearColor] CGColor];
    
    //add lines to view
    [self.scrollView.layer addSublayer:detailsLine];
    [self.datesView.layer addSublayer:progressLine];
    [self.datesView.layer addSublayer:optionLine];
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    // Set up the labels and other outlet with data of goal to be viewed.
    [self loadFromDB];
    [self showDetails];
}

-(void)loadFromDB {
    self.settings = [[TestSettings alloc] init];
    NSString *query = @"select * from testSettings";
    
    NSArray *currentSettingsResults;
    currentSettingsResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSLog(@"%@",currentSettingsResults);
    
    if (currentSettingsResults.count == 0) {
        self.settings.stepsTime = 1;
        self.settings.stairsTime = 1;
        
        query = [NSString stringWithFormat:@"insert into testSettings values(%d,%d)", self.settings.stepsTime, self.settings.stairsTime];
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
        NSInteger indexOfStepsTime = [self.dbManager.arrColumnNames indexOfObject:@"stepsTime"];
        NSInteger indexOfStairsTime = [self.dbManager.arrColumnNames indexOfObject:@"stairsTime"];
        self.settings.stepsTime = [[[currentSettingsResults objectAtIndex:0] objectAtIndex:indexOfStepsTime] intValue];
        self.settings.stairsTime = [[[currentSettingsResults objectAtIndex:0] objectAtIndex:indexOfStairsTime] intValue];
        NSLog(@"Steps Time: %d",self.settings.stepsTime);
        NSLog(@"Stairs Time: %d",self.settings.stairsTime);
    }
    
    //load stats
    self.totalSteps = 0;
    self.totalStairs = 0;
    self.startDate = 1.0;
    self.endDate = 1.0;
    
    query = [NSString stringWithFormat:@"select * from %@ where endTime < '%f'", self.testing.getStatisticsDBName, [[NSDate date] timeIntervalSince1970]];
    
    NSArray *statResults;
    statResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    if ([statResults count] > 0) {
        NSInteger indexOfStartDate = [self.dbManager.arrColumnNames indexOfObject:@"startTime"];
        NSInteger indexOfSteps = [self.dbManager.arrColumnNames indexOfObject:@"steps"];
        NSInteger indexOfStairs = [self.dbManager.arrColumnNames indexOfObject:@"stairs"];
        
        self.startDate = [[[statResults objectAtIndex:0] objectAtIndex:indexOfStartDate] doubleValue];
        self.endDate = [[NSDate date] timeIntervalSince1970];
        
        for (int i=0; i<[statResults count]; i++) {
            self.totalSteps += [[[statResults objectAtIndex:i] objectAtIndex:indexOfSteps] intValue];
            self.totalStairs += [[[statResults objectAtIndex:i] objectAtIndex:indexOfStairs] intValue];
        }
    }
    [self setUpStats];
}

-(void)setUpStats {
    double day = 86400.0;
    double week = 604800.0;
    double month = 2630000.0;
    double year = 31560000.0;
    
    double peroid = (self.endDate - self.startDate);
    NSLog(@"%@",[NSDate dateWithTimeIntervalSince1970:peroid]);
    
    double dayStepsAverage = (day/peroid)*self.totalSteps;
    double weekStepsAverage = (week/peroid)*self.totalSteps;
    double monthStepsAverage = (month/peroid)*self.totalSteps;
    double yearStepsAverage = (year/peroid)*self.totalSteps;
    
    double dayStairsAverage = (day/peroid)*self.totalStairs;
    double weekStairsAverage = (week/peroid)*self.totalStairs;
    double monthStairsAverage = (month/peroid)*self.totalStairs;
    double yearStairsAverage = (year/peroid)*self.totalStairs;
    
    switch (self.viewGoal.goalType) {
        case Steps:
            self.stepsPerDayLabel.text = [NSString stringWithFormat:@"per Day: %f",dayStepsAverage];
            self.stepsPerWeekLabel.text = [NSString stringWithFormat:@"per Week: %f",weekStepsAverage];
            self.stepsPerMonthLabel.text = [NSString stringWithFormat:@"per Month: %f",monthStepsAverage];
            self.stepsPerYearLabel.text = [NSString stringWithFormat:@"per Year: %f",yearStepsAverage];
            self.stairsTitleLabel.text = @"";
            self.stairsPerDayLabel.text = @"";
            self.stairsPerWeekLabel.text = @"";
            self.stairsPerMonthLabel.text = @"";
            self.stairsPerYearLabel.text = @"";
            break;
        case Stairs:
            self.stairsTitleLabel.text = @"";
            self.stepsPerDayLabel.text = @"";
            self.stepsPerWeekLabel.text = @"";
            self.stepsPerMonthLabel.text = @"";
            self.stepsPerYearLabel.text = @"";
            self.stairsPerDayLabel.text = [NSString stringWithFormat:@"per Day: %f",dayStairsAverage];
            self.stairsPerWeekLabel.text = [NSString stringWithFormat:@"per Week: %f",weekStairsAverage];
            self.stairsPerMonthLabel.text = [NSString stringWithFormat:@"per Month: %f",monthStairsAverage];
            self.stairsPerYearLabel.text = [NSString stringWithFormat:@"per Year: %f",yearStairsAverage];
            break;
        case Both:
            self.stepsPerDayLabel.text = [NSString stringWithFormat:@"per Day: %f",dayStepsAverage];
            self.stepsPerWeekLabel.text = [NSString stringWithFormat:@"per Week: %f",weekStepsAverage];
            self.stepsPerMonthLabel.text = [NSString stringWithFormat:@"per Month: %f",monthStepsAverage];
            self.stepsPerYearLabel.text = [NSString stringWithFormat:@"per Year: %f",yearStepsAverage];
            
            self.stairsPerDayLabel.text = [NSString stringWithFormat:@"per Day: %f",dayStairsAverage];
            self.stairsPerWeekLabel.text = [NSString stringWithFormat:@"per Week: %f",weekStairsAverage];
            self.stairsPerMonthLabel.text = [NSString stringWithFormat:@"per Month: %f",monthStairsAverage];
            self.stairsPerYearLabel.text = [NSString stringWithFormat:@"per Year: %f",yearStairsAverage];
            break;
        default:
            break;
    }
    
}

// Method to set up outlets of view to show data of the goal.
-(void)showDetails {
    // Set the title of the navigation bar.
    self.navigationItem.title = [NSString stringWithFormat:@"%@", self.viewGoal.goalName];
    
    if (self.testing.getTesting) {
        [self hideAndDisableRightNavigationItem];
    }
    else {
        [self showAndEnableRightNavigationItem];
    }
    
    // Set the title label to the goal name.
    self.viewTitle.text = [NSString stringWithFormat:@"%@", self.viewGoal.goalName];
    
    // Depending on the status of the goal set the status label and background accordingly.
    switch (self.viewGoal.goalStatus) {
        case Pending:
            self.viewStatus.text = [NSString stringWithFormat:@"Pending"];
            //self.scrollView.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((178) / 255.0) blue:((255) / 255.0) alpha:1.0];
            self.outletActiveButton.hidden = YES;
            self.outletSuspendButton.hidden = YES;
            break;
        case Active:
            self.viewStatus.text = [NSString stringWithFormat:@"Active"];
            //self.scrollView.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            self.outletActiveButton.hidden = NO;
            self.outletSuspendButton.hidden = NO;
            break;
        case Overdue:
            self.viewStatus.text = [NSString stringWithFormat:@"Overdue"];
            //self.scrollView.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((102) / 255.0) blue:((102) / 255.0) alpha:1.0];
            self.outletActiveButton.hidden = NO;
            self.outletSuspendButton.hidden = NO;
            break;
        case Suspended:
            self.viewStatus.text = [NSString stringWithFormat:@"Suspended"];
            //self.scrollView.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            [self.outletSuspendButton setTitle:@"Re-instate" forState:UIControlStateNormal];
            self.outletActiveButton.hidden = YES;
            self.outletSuspendButton.hidden = NO;
            [self hideAndDisableRightNavigationItem];
            break;
        case Abandoned:
            self.viewStatus.text = [NSString stringWithFormat:@"Abandoned"];
            //self.scrollView.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((102) / 255.0) blue:((102) / 255.0) alpha:1.0];
            self.outletActiveButton.hidden = YES;
            self.outletSuspendButton.hidden = YES;
            [self hideAndDisableRightNavigationItem];
            break;
        case Completed:
            self.viewStatus.text = [NSString stringWithFormat:@"Completed"];
            //self.scrollView.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            self.outletActiveButton.hidden = YES;
            self.outletSuspendButton.hidden = YES;
            self.activeOutletButtonTest.hidden = YES;
            [self hideAndDisableRightNavigationItem];
            break;
        default:
            break;
    }
    
    // Depending on the type of the goal set the goal type label, the progress label and the progress bar accordingly.
    switch (self.viewGoal.goalType) {
        case Steps:
            self.addStairsStepper.userInteractionEnabled = NO;
            self.viewType.text = [NSString stringWithFormat:@"Steps"];
            self.viewProgress.text = [NSString stringWithFormat:@"Steps: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            self.testTrackLabel.text = [NSString stringWithFormat:@"Steps: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps];
            [self.testTrackProgress setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            self.trackLabel.text = [NSString stringWithFormat:@"Steps: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps];
            [self.trackProgress setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            break;
        case Stairs:
            self.addStepper.userInteractionEnabled = NO;
            self.viewType.text = [NSString stringWithFormat:@"Stairs"];
            self.viewProgress.text = [NSString stringWithFormat:@"Stairs: %ld/%ld",(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            self.testTrackLabel.text = [NSString stringWithFormat:@"Stairs: %ld/%ld",(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
            [self.testTrackProgress setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            self.trackLabel.text = [NSString stringWithFormat:@"Stairs: %ld/%ld",(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
            [self.trackProgress setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            break;
        case Both:
            self.viewType.text = [NSString stringWithFormat:@"Steps and Stairs"];
            self.viewProgress.text = [NSString stringWithFormat:@"Steps: %ld/%ld  Stairs: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps,(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
            [self.viewProgressBar setProgress:(float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2)) animated:YES];
            self.testTrackLabel.text = [NSString stringWithFormat:@"Steps: %ld/%ld  Stairs: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps,(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
            [self.testTrackProgress setProgress:(float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2)) animated:YES];
            self.trackLabel.text = [NSString stringWithFormat:@"Steps: %ld/%ld  Stairs: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps,(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
            [self.trackProgress setProgress:(float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2)) animated:YES];
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
        destViewController.testing = self.testing;
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
            self.recordingStartTime = [[NSDate date] timeIntervalSince1970];
            self.recordingEndTime = [[NSDate date] timeIntervalSince1970] + self.progressSteps*self.settings.stepsTime;
            [self storeGoalStatusChangeToDB];
            [self storeGoalStatisticsToDB];
            [self updateView];
            self.stepperLabel.text = @"0";
            self.addStepper.value = 0.0;
            self.progressSteps = 0;
            [self loadFromDB];
        }
    }
    else if (self.viewGoal.goalType == Stairs) {
        if ([self.stepperStairsLabel.text intValue] > 0) {
            self.progressStairs = [self.stepperStairsLabel.text intValue];
            self.viewGoal.goalProgressStairs += self.progressStairs;
            if (self.viewGoal.goalProgressStairs > self.viewGoal.goalAmountStairs) {
                self.viewGoal.goalProgressStairs = self.viewGoal.goalAmountStairs;
            }
            self.recordingStartTime = [[NSDate date] timeIntervalSince1970];
            self.recordingEndTime = [[NSDate date] timeIntervalSince1970] + self.progressStairs*self.settings.stairsTime;
            [self storeGoalStatusChangeToDB];
            [self storeGoalStatisticsToDB];
            [self updateView];
            self.stepperStairsLabel.text = @"0";
            self.addStairsStepper.value = 0.0;
            self.progressStairs = 0;
            [self loadFromDB];
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
            self.recordingStartTime = [[NSDate date] timeIntervalSince1970];
            if (self.progressStairs > 0) {
                self.recordingEndTime = [[NSDate date] timeIntervalSince1970] + self.progressStairs*self.settings.stairsTime;
            }
            else {
                self.recordingEndTime = [[NSDate date] timeIntervalSince1970] + self.progressStairs*self.settings.stepsTime;
            }
            [self storeGoalStatusChangeToDB];
            [self storeGoalStatisticsToDB];
            [self updateView];
            self.stepperLabel.text = @"0";
            self.addStepper.value = 0.0;
            self.stepperStairsLabel.text = @"0";
            self.addStairsStepper.value = 0.0;
            self.progressSteps = 0;
            self.progressStairs = 0;
            [self loadFromDB];
        }
    }
}

- (IBAction)setActiveButtonTest:(id)sender {
    /**********************************start recording*****************************************/
    if (!self.isRecording) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now Recording" message:@"This goal is now recording." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        self.isRecording = YES;
        self.recordingStartTime = [[NSDate date] timeIntervalSince1970];
        [self storeGoalStatusChangeToDB];
        [self hideAndDisableLeftNavigationItem];
        //[self hideAndDisableRightNavigationItem];
        [self.activeOutletButtonTest setTitle:@"Stop" forState:UIControlStateNormal];
        self.autoStepSpinner.hidden = NO;
        [self.autoStepSpinner startAnimating];
        self.outletHistoryButton.hidden = YES;
        NSLog(@"Steps Time: %d",self.settings.stepsTime);
        NSLog(@"Stairs Time: %d",self.settings.stairsTime);
        [self startBackgroundThread];
    } /**********************************stop recording*****************************************/
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now not recording" message:@"This goal is now not recording." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        self.isRecording = NO;
        self.recordingEndTime = [[NSDate date] timeIntervalSince1970];
        [self storeGoalStatusChangeToDB];
        [self storeGoalStatisticsToDB];
        [self showAndEnableLeftNavigationItem];
        //[self showAndEnableRightNavigationItem];
        [self.activeOutletButtonTest setTitle:@"Start" forState:UIControlStateNormal];
        self.autoStepSpinner.hidden = YES;
        [self.autoStepSpinner stopAnimating];
        self.outletHistoryButton.hidden = NO;
        //self.scheduleButton.hidden = NO;
        //self.timeButton.hidden = NO;
        [self cancelBackgroundThread];
    }
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
        timerStep = [NSTimer timerWithTimeInterval:(double)self.settings.stepsTime
                                            target:self
                                          selector:@selector(takeStep)
                                          userInfo:nil
                                           repeats:YES ];
        [[NSRunLoop mainRunLoop] addTimer:timerStep forMode:NSRunLoopCommonModes];
    }
    if (((self.viewGoal.goalType == Stairs) || (self.viewGoal.goalType == Both)) && (self.viewGoal.goalAmountStairs != self.viewGoal.goalProgressStairs)) {
        timerStair = [NSTimer timerWithTimeInterval:(double)self.settings.stairsTime
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

-(void) updateView {
    NSLog(@"Update View");
    switch (self.viewGoal.goalType) {
        case Steps:
            if (self.viewGoal.goalAmountSteps == self.viewGoal.goalProgressSteps) {
                [self completedView];
            }
            self.viewProgress.text = [NSString stringWithFormat:@"Steps: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            if (self.testing.getTesting) {
                self.testTrackLabel.text = [NSString stringWithFormat:@"Steps: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps];
                [self.testTrackProgress setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            }
            else {
                self.trackLabel.text = [NSString stringWithFormat:@"Steps: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps];
                [self.trackProgress setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            }
            break;
        case Stairs:
            if (self.viewGoal.goalAmountStairs == self.viewGoal.goalProgressStairs) {
                [self completedView];
            }
            self.viewProgress.text = [NSString stringWithFormat:@"Stairs: %ld/%ld",(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            if (self.testing.getTesting) {
                self.testTrackLabel.text = [NSString stringWithFormat:@"Stairs: %ld/%ld",(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
                [self.testTrackProgress setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            }
            else {
                self.trackLabel.text = [NSString stringWithFormat:@"Stairs: %ld/%ld",(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
                [self.trackProgress setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            }
            break;
        case Both:
            if (((self.viewGoal.goalAmountSteps == self.viewGoal.goalProgressSteps) && (self.viewGoal.goalAmountStairs == self.viewGoal.goalProgressStairs))) {
                [self completedView];
            }
            self.viewProgress.text = [NSString stringWithFormat:@"Steps: %ld/%ld  Stairs: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps,(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
            [self.viewProgressBar setProgress:(float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2)) animated:YES];
            if (self.testing.getTesting) {
                self.testTrackLabel.text = [NSString stringWithFormat:@"Steps: %ld/%ld  Stairs: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps,(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
                [self.testTrackProgress setProgress:(float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2)) animated:YES];
            }
            else {
                self.trackLabel.text = [NSString stringWithFormat:@"Steps: %ld/%ld  Stairs: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps,(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
                [self.trackProgress setProgress:(float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2)) animated:YES];
            }
            break;
        default:
            break;
    }
    NSString *query;
    query = [NSString stringWithFormat:@"update %@ set goalStatus='%d', goalProgressSteps='%d', goalProgressStairs='%d' where goalID=%ld", self.testing.getGoalDBName, self.viewGoal.goalStatus, self.viewGoal.goalProgressSteps, self.viewGoal.goalProgressStairs, (long)self.viewGoal.goalID];
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
    self.activeOutletButtonTest.hidden = YES;
    [self.autoStepSpinner stopAnimating];
    self.autoStepSpinner.hidden = YES;
    //self.scrollView.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now completed" message:@"This goal is now completed." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
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
        //self.scrollView.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
        [self showAndEnableLeftNavigationItem];
        [self hideAndDisableRightNavigationItem];
        self.outletActiveButton.hidden = YES;
        self.outletHistoryButton.hidden = NO;
        self.stepperLabel.text = @"0";
        self.addStepper.value = 0.0;
        self.stepperStairsLabel.text = @"0";
        self.addStairsStepper.value = 0.0;
        self.outletActiveButton.hidden = YES;
        self.activeOutletButtonTest.hidden = YES;
        self.autoStepSpinner.hidden = YES;
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
            //self.scrollView.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((178) / 255.0) blue:((255) / 255.0) alpha:1.0];
        }
        else if ([[[NSDate date] earlierDate:self.viewGoal.goalCompletionDate]isEqualToDate: self.viewGoal.goalCompletionDate]) {
            self.viewGoal.goalStatus = Overdue;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now overdue" message:@"This goal is now overdue." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Overdue"];
            //self.scrollView.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((102) / 255.0) blue:((102) / 255.0) alpha:1.0];
        }
        else {
            self.viewGoal.goalStatus = Active;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now Active" message:@"This goal is now Active." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Active"];
            //self.scrollView.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            
        }
        [self storeGoalStatusChangeToDB];
        self.outletActiveButton.hidden = NO;
        self.outletHistoryButton.hidden = NO;
        self.outletActiveButton.hidden = NO;
        self.activeOutletButtonTest.hidden = NO;
        self.autoStepSpinner.hidden = NO;
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
    query = [NSString stringWithFormat:@"update %@ set statusEndDate='%f', progressSteps='%d', progressStairs='%d' where historyID=%ld", self.testing.getHistoryDBName, [[NSDate date] timeIntervalSince1970], self.progressSteps, self.progressStairs, (long)[self getHistoryRowID:self.viewGoal.goalID]];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    query = [NSString stringWithFormat:@"insert into %@ values(null, '%ld', '%d', '%f', '%f', '%d', '%d')", self.testing.getHistoryDBName, (long)self.viewGoal.goalID, self.viewGoal.goalStatus, [[NSDate date] timeIntervalSince1970], 0.0, 0, 0];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
}

-(void) storeGoalStatisticsToDB {
    NSString *query;
    
    query = [NSString stringWithFormat:@"insert into %@ values(null, %d, '%f', '%f', '%d', '%d')", self.testing.getStatisticsDBName, self.viewGoal.goalID, self.recordingStartTime, self.recordingEndTime, self.progressSteps, self.progressStairs];
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

- (IBAction)viewSelectorAction:(id)sender {
    if(self.viewSelector.selectedSegmentIndex == 0) {
        NSLog(@"Progress");
        self.datesView.hidden = NO;
        self.statisticsView.hidden = YES;
        self.trackingView.hidden = YES;
        self.testTrackingView.hidden = YES;
        [self.scrollView setContentSize:CGSizeMake(320, 568)];
        [self.scrollView setScrollEnabled:YES];
    }
    else if (self.viewSelector.selectedSegmentIndex == 1) {
        NSLog(@"Statistics");
        self.datesView.hidden = YES;
        self.statisticsView.hidden = NO;
        self.trackingView.hidden = YES;
        self.testTrackingView.hidden = YES;
        [self.scrollView setContentSize:CGSizeMake(320, 568)];
        [self.scrollView setScrollEnabled:NO];
    }
    else {
        if (self.testing.getTesting) {
            NSLog(@"Track Testing");
            self.datesView.hidden = YES;
            self.statisticsView.hidden = YES;
            self.trackingView.hidden = YES;
            self.testTrackingView.hidden = NO;
            [self.scrollView setContentSize:CGSizeMake(320, 568)];
            [self.scrollView setScrollEnabled:NO];
        }
        else {
            NSLog(@"Track");
            self.datesView.hidden = YES;
            self.statisticsView.hidden = YES;
            self.trackingView.hidden = NO;
            self.testTrackingView.hidden = YES;
            [self.scrollView setContentSize:CGSizeMake(320, 568)];
            [self.scrollView setScrollEnabled:NO];
        }
    }
}

@end
