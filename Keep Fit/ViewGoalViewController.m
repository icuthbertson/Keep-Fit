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
#import "PNChart.h"
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
@property (weak, nonatomic) IBOutlet UILabel *viewProgressStairs;
@property (weak, nonatomic) IBOutlet UILabel *viewPercentage;
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
@property (weak, nonatomic) IBOutlet UILabel *testTrackStairsLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *testTrackProgress;
@property (weak, nonatomic) IBOutlet UILabel *trackLabel;
@property (weak, nonatomic) IBOutlet UILabel *trackStairsLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *trackProgress;
@property UILabel *stepsPerDayLabel;
@property UILabel *stepsPerWeekLabel;
@property UILabel *stepsPerMonthLabel;
@property UILabel *stepsPerYearLabel;
@property UILabel *stairsPerDayLabel;
@property UILabel *stairsPerWeekLabel;
@property UILabel *stairsPerMonthLabel;
@property UILabel *stairsPerYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *estimatedCompletionLabel;
- (IBAction)abandonButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *abandonButton;
@property UIView *stepsEstView;
@property UIView *stepsGraphView;
@property UIView *stairsEstView;
@property UIView *stairsGraphView;
- (IBAction)socialMediaAction:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *conversionSelector;
- (IBAction)ConversionAction:(id)sender;

@property double progressSteps;
@property double progressStairs;
@property BOOL isRecording; // Holds bool to check if goal is currently recording.

@property NSInteger totalSteps;
@property NSInteger totalStairs;
@property double startDate;
@property double endDate;
@property NSMutableArray *stepsValues;
@property NSMutableArray *stairsValues;
@property NSMutableArray *graphTimes;

@property double recordingStartTime;
@property double recordingEndTime;

@property NSDate *estimatedDate;

@property NSDateFormatter *formatter;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property UIImage *image;

@property UIImagePickerController *socialImagePicker;
@property UIImage *socialImage;

@property Conversion conversion;

@property UIImage *mask;

@end

@implementation ViewGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkGoalStatus)
                                                 name:@"reloadDataView"
                                               object:nil];
    
    // Do any additional setup after loading the view.
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 800)];
    
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
    
    //Line between progress bar and social
    UIBezierPath *pathSocial = [UIBezierPath bezierPath];
    [pathSocial moveToPoint:CGPointMake(24.0, 411.0)];
    [pathSocial addLineToPoint:CGPointMake(320.0, 411.0)];
    
    CAShapeLayer *socialLine = [CAShapeLayer layer];
    socialLine.path = [pathSocial CGPath];
    socialLine.strokeColor = [[UIColor grayColor] CGColor];
    socialLine.lineWidth = 0.5;
    socialLine.fillColor = [[UIColor clearColor] CGColor];
    
    //Line between progress social and options
    UIBezierPath *pathOption = [UIBezierPath bezierPath];
    [pathOption moveToPoint:CGPointMake(24.0, 490.0)];
    [pathOption addLineToPoint:CGPointMake(320.0, 490.0)];
    
    CAShapeLayer *optionLine = [CAShapeLayer layer];
    optionLine.path = [pathOption CGPath];
    optionLine.strokeColor = [[UIColor grayColor] CGColor];
    optionLine.lineWidth = 0.5;
    optionLine.fillColor = [[UIColor clearColor] CGColor];
    
    //add lines to view
    [self.scrollView.layer addSublayer:detailsLine];
    [self.datesView.layer addSublayer:progressLine];
    [self.datesView.layer addSublayer:socialLine];
    [self.datesView.layer addSublayer:optionLine];
    
    self.conversion = self.viewGoal.goalConversion;
    
    self.estimatedDate = [[NSDate alloc] init];
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"MMM dd"];
    
    self.mask = [self imageWithColor:[UIColor blackColor] andX:0.0 andY: 0.0 andSize:CGSizeMake(90, 90)];
    
    
    // Set up the labels and other outlet with data of goal to be viewed.
    [self checkGoalStatus];
    [self loadFromDB];
    //[self showDetails];
}

- (void)viewWillAppear:(BOOL)animated {
    [self checkGoalStatus];
    [self loadFromDB];
}

-(void) checkGoalStatus {
    // check for if the start or end date has passed and update the status.
    if ((self.viewGoal.goalStatus == Pending) && [[[NSDate date] earlierDate:self.viewGoal.goalStartDate]isEqualToDate: self.viewGoal.goalStartDate]) {
        NSLog(@"active");
        
        self.viewGoal.goalStatus = Active;
        
        // Update history for the goal.
        [self storeGoalStatusChangeToDB];
    }
    if ((self.viewGoal.goalStatus == Active) && [[[NSDate date] earlierDate:self.viewGoal.goalCompletionDate]isEqualToDate: self.viewGoal.goalCompletionDate]) {
        NSLog(@"overdue");
        
        self.viewGoal.goalStatus = Overdue;
        
        // Update history for the goal.
        [self storeGoalStatusChangeToDB];
    }
    [self loadFromDB];
}

-(void)loadFromDB {
    self.testSettings = [[TestSettings alloc] init];
    NSString *query = @"select * from testSettings";
    
    NSArray *currentSettingsResults;
    currentSettingsResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSLog(@"%@",currentSettingsResults);
    
    if (currentSettingsResults.count == 0) {
        self.testSettings.stepsTime = 1;
        self.testSettings.stairsTime = 1;
        
        query = [NSString stringWithFormat:@"insert into testSettings values(%ld,%ld)", (long)self.testSettings.stepsTime, (long)self.testSettings.stairsTime];
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
        self.testSettings.stepsTime = [[[currentSettingsResults objectAtIndex:0] objectAtIndex:indexOfStepsTime] intValue];
        self.testSettings.stairsTime = [[[currentSettingsResults objectAtIndex:0] objectAtIndex:indexOfStairsTime] intValue];
        NSLog(@"Steps Time: %ld",(long)self.testSettings.stepsTime);
        NSLog(@"Stairs Time: %ld",(long)self.testSettings.stairsTime);
    }
    
    //load stats
    self.totalSteps = 0;
    self.totalStairs = 0;
    self.startDate = 1.0;
    self.endDate = 1.0;
    
    if (self.stepsValues != nil) {
        self.stepsValues = nil;
    }
    self.stepsValues = [[NSMutableArray alloc] init];
    if (self.stairsValues != nil) {
        self.stairsValues = nil;
    }
    self.stairsValues = [[NSMutableArray alloc] init];
    if (self.graphTimes != nil) {
        self.graphTimes = nil;
    }
    self.graphTimes = [[NSMutableArray alloc] init];
    
    query = [NSString stringWithFormat:@"select * from %@ where goalID='%d'", self.testing.getStatisticsDBName, /*[[NSDate date] timeIntervalSince1970],*/ self.viewGoal.goalID];
    
    NSMutableArray *totalStepsValues = [[NSMutableArray alloc] init];
    NSMutableArray *totalStairsValues = [[NSMutableArray alloc] init];
    NSMutableArray *tempDates = [[NSMutableArray alloc] init];
    
    NSArray *statResults;
    statResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    if ([statResults count] > 0) {
        NSInteger indexOfStartDate = [self.dbManager.arrColumnNames indexOfObject:@"startTime"];
        NSInteger indexOfEndDate = [self.dbManager.arrColumnNames indexOfObject:@"endTime"];
        NSInteger indexOfSteps = [self.dbManager.arrColumnNames indexOfObject:@"steps"];
        NSInteger indexOfStairs = [self.dbManager.arrColumnNames indexOfObject:@"stairs"];
        
        self.startDate = [[[statResults objectAtIndex:0] objectAtIndex:indexOfStartDate] doubleValue];
        if (self.viewGoal.goalStatus == Abandoned || self.viewGoal.goalStatus == Completed) {
            self.endDate = [[[statResults lastObject] objectAtIndex:indexOfEndDate] doubleValue];
        }
        else {
            self.endDate = [[NSDate date] timeIntervalSince1970];
        }
        
        [self.graphTimes addObject:[[statResults objectAtIndex:0] objectAtIndex:indexOfStartDate]];
        
        for (int i=0; i<[statResults count]; i++) {
            self.totalSteps += [[[statResults objectAtIndex:i] objectAtIndex:indexOfSteps] intValue];
            self.totalStairs += [[[statResults objectAtIndex:i] objectAtIndex:indexOfStairs] intValue];
            [totalStepsValues addObject:[NSNumber numberWithDouble:self.totalSteps]];
            [totalStairsValues addObject:[NSNumber numberWithDouble:self.totalStairs]];
            [tempDates addObject:[NSNumber numberWithDouble:[[[statResults objectAtIndex:i] objectAtIndex:indexOfEndDate] doubleValue]]];
        }
        int fract = floor([statResults count]/7);
        
        [self.stepsValues addObject:[NSNumber numberWithDouble:0.0]];
        [self.stairsValues addObject:[NSNumber numberWithDouble:0.0]];
        [self.graphTimes addObject:[NSNumber numberWithDouble:[[tempDates objectAtIndex:0] doubleValue]]];
        
        for (int i=1; i<=5; i++) {
            [self.stepsValues addObject:[NSNumber numberWithDouble:[[totalStepsValues objectAtIndex:(i*fract)] doubleValue]]];
            [self.stairsValues addObject:[NSNumber numberWithDouble:[[totalStairsValues
                                                                      objectAtIndex:(i*fract)] doubleValue]]];
            [self.graphTimes addObject:[NSNumber numberWithDouble:[[tempDates objectAtIndex:(i*fract)] doubleValue]]];
        }
        
        [self.stepsValues addObject:[NSNumber numberWithDouble:[[totalStepsValues lastObject] doubleValue]]];
        [self.stairsValues addObject:[NSNumber numberWithDouble:[[totalStairsValues lastObject] doubleValue]]];
        [self.graphTimes addObject:[NSNumber numberWithDouble:[[tempDates lastObject] doubleValue]]];
        
        NSLog(@"%@",self.stepsValues);
        NSLog(@"%@",self.stairsValues);
    }
    else {
        [self.stepsValues addObject:[NSNumber numberWithDouble:0]];
        [self.stepsValues addObject:[NSNumber numberWithDouble:0]];
        [self.stepsValues addObject:[NSNumber numberWithDouble:0]];
        [self.stepsValues addObject:[NSNumber numberWithDouble:0]];
        [self.stepsValues addObject:[NSNumber numberWithDouble:0]];
        [self.stepsValues addObject:[NSNumber numberWithDouble:0]];
        [self.stairsValues addObject:[NSNumber numberWithDouble:0]];
        [self.stairsValues addObject:[NSNumber numberWithDouble:0]];
        [self.stairsValues addObject:[NSNumber numberWithDouble:0]];
        [self.stairsValues addObject:[NSNumber numberWithDouble:0]];
        [self.stairsValues addObject:[NSNumber numberWithDouble:0]];
        [self.stairsValues addObject:[NSNumber numberWithDouble:0]];
        [self.graphTimes addObject:[NSNumber numberWithDouble:[self.testing.getTime timeIntervalSince1970]]];
        [self.graphTimes addObject:[NSNumber numberWithDouble:[self.testing.getTime timeIntervalSince1970]]];
        [self.graphTimes addObject:[NSNumber numberWithDouble:[self.testing.getTime timeIntervalSince1970]]];
        [self.graphTimes addObject:[NSNumber numberWithDouble:[self.testing.getTime timeIntervalSince1970]]];
        [self.graphTimes addObject:[NSNumber numberWithDouble:[self.testing.getTime timeIntervalSince1970]]];
        [self.graphTimes addObject:[NSNumber numberWithDouble:[self.testing.getTime timeIntervalSince1970]]];
        [self.graphTimes addObject:[NSNumber numberWithDouble:[self.testing.getTime timeIntervalSince1970]]];
    }
    
    NSLog(@"Stats %@",statResults);
    
    [self showDetails];
    [self setUpStats];
}

-(void)setUpStats {
    double day = 86400.0;
    double week = 604800.0;
    double month = 2630000.0;
    double year = 31560000.0;
    
    double period = (self.endDate - self.startDate);
    if (period == 0.0) {
        period = 1.0;
    }
    NSLog(@"%@",[NSDate dateWithTimeIntervalSince1970:self.startDate]);
    NSLog(@"%@",[NSDate dateWithTimeIntervalSince1970:self.endDate]);
    NSLog(@"%@",[NSDate dateWithTimeIntervalSince1970:period]);
    
    double dayStepsAverage = (day/period)*self.totalSteps;
    double weekStepsAverage = (week/period)*self.totalSteps;
    double monthStepsAverage = (month/period)*self.totalSteps;
    double yearStepsAverage = (year/period)*self.totalSteps;
    
    double dayStairsAverage = (day/period)*self.totalStairs;
    double weekStairsAverage = (week/period)*self.totalStairs;
    double monthStairsAverage = (month/period)*self.totalStairs;
    double yearStairsAverage = (year/period)*self.totalStairs;
    
    switch (self.viewGoal.goalType) {
        case Steps:
        case Pluto:
            self.stepsPerDayLabel.text = [NSString stringWithFormat:@"per Day: %.2f",dayStepsAverage];
            self.stepsPerWeekLabel.text = [NSString stringWithFormat:@"per Week: %.2f",weekStepsAverage];
            self.stepsPerMonthLabel.text = [NSString stringWithFormat:@"per Month: %.2f",monthStepsAverage];
            self.stepsPerYearLabel.text = [NSString stringWithFormat:@"per Year: %.2f",yearStepsAverage];
            self.stairsPerDayLabel.text = @"";
            self.stairsPerWeekLabel.text = @"";
            self.stairsPerMonthLabel.text = @"";
            self.stairsPerYearLabel.text = @"";
            break;
        case Stairs:
        case Everest:
        case Nevis:
            self.stepsPerDayLabel.text = @"";
            self.stepsPerWeekLabel.text = @"";
            self.stepsPerMonthLabel.text = @"";
            self.stepsPerYearLabel.text = @"";
            self.stairsPerDayLabel.text = [NSString stringWithFormat:@"per Day: %.2f",dayStairsAverage];
            self.stairsPerWeekLabel.text = [NSString stringWithFormat:@"per Week: %.2f",weekStairsAverage];
            self.stairsPerMonthLabel.text = [NSString stringWithFormat:@"per Month: %.2f",monthStairsAverage];
            self.stairsPerYearLabel.text = [NSString stringWithFormat:@"per Year: %.2f",yearStairsAverage];
            break;
        case Both:
            self.stepsPerDayLabel.text = [NSString stringWithFormat:@"per Day: %.2f",dayStepsAverage];
            self.stepsPerWeekLabel.text = [NSString stringWithFormat:@"per Week: %.2f",weekStepsAverage];
            self.stepsPerMonthLabel.text = [NSString stringWithFormat:@"per Month: %.2f",monthStepsAverage];
            self.stepsPerYearLabel.text = [NSString stringWithFormat:@"per Year: %.2f",yearStepsAverage];
            
            self.stairsPerDayLabel.text = [NSString stringWithFormat:@"per Day: %.2f",dayStairsAverage];
            self.stairsPerWeekLabel.text = [NSString stringWithFormat:@"per Week: %.2f",weekStairsAverage];
            self.stairsPerMonthLabel.text = [NSString stringWithFormat:@"per Month: %.2f",monthStairsAverage];
            self.stairsPerYearLabel.text = [NSString stringWithFormat:@"per Year: %.2f",yearStairsAverage];
            break;
        default:
            break;
    }
    
    if (dayStepsAverage == 0.0 && dayStairsAverage == 0.0) {
        self.estimatedCompletionLabel.text = @"No progress made yet";
    }
    else if (self.viewGoal.goalStatus == Abandoned) {
        self.estimatedCompletionLabel.text = @"Goal Abandoned";
    }
    else if (self.viewGoal.goalStatus == Completed) {
        self.estimatedCompletionLabel.text = @"Goal Completed";
    }
    else {
        if (dayStepsAverage == 0.0) {
            dayStepsAverage = 1.0;
        }
        if (dayStairsAverage == 0.0) {
            dayStairsAverage = 1.0;
        }
        
        double estSteps = ((self.viewGoal.goalAmountSteps - self.viewGoal.goalProgressSteps)/dayStepsAverage)*day;
        double estStairs = ((self.viewGoal.goalAmountStairs - self.viewGoal.goalProgressStairs)/dayStairsAverage)*day;
        if (estSteps > estStairs) {
            double tempEpoch = [[NSDate date] timeIntervalSince1970] + estSteps;
            self.estimatedDate = [NSDate dateWithTimeIntervalSince1970:tempEpoch];
        }
        else {
            double tempEpoch = [[NSDate date] timeIntervalSince1970] + estStairs;
            self.estimatedDate = [NSDate dateWithTimeIntervalSince1970:tempEpoch];
        }
        // Set up the date formatter to the required format.
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
        
        self.estimatedCompletionLabel.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:self.estimatedDate]];
    }
    
    [self makeGraphs];
}

-(void) makeGraphs {
    //For Line Chart
    NSMutableArray *stepsStairsLabels = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[self.stepsValues count]; i++) {
        [stepsStairsLabels addObject:[NSString stringWithFormat:@"%@",[self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[self.graphTimes objectAtIndex:i] doubleValue]]]]];
    }
    
    if (self.viewGoal.goalType == Steps || self.viewGoal.goalType == Pluto || self.viewGoal.goalType == Both) {
        //Steps Graph
        PNLineChart *stepsLineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 33, CGRectGetWidth(self.stepsGraphView.bounds), CGRectGetHeight(self.stepsGraphView.bounds))];
        stepsLineChart.showCoordinateAxis = YES;
        
        [stepsLineChart setXLabels:stepsStairsLabels];
        
        PNLineChartData *dataSteps = [PNLineChartData new];
        dataSteps.color = PNTwitterColor;
        dataSteps.itemCount = [self.stepsValues count];
        dataSteps.getData = ^(NSUInteger index) {
            CGFloat yValue = [self.stepsValues[index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        
        stepsLineChart.chartData = @[dataSteps];
        [stepsLineChart strokeChart];
        
        [self.stepsGraphView addSubview:stepsLineChart];
    }
    
    //Stairs Graph
    if (self.viewGoal.goalType == Stairs || self.viewGoal.goalType == Everest || self.viewGoal.goalType == Nevis || self.viewGoal.goalType == Both) {
        PNLineChart *stairsLineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 33, CGRectGetWidth(self.stairsGraphView.bounds), CGRectGetHeight(self.stairsGraphView.bounds))];
        stairsLineChart.showCoordinateAxis = YES;
        
        [stairsLineChart setXLabels:stepsStairsLabels];
        
        PNLineChartData *dataStairs = [PNLineChartData new];
        dataStairs.color = PNTwitterColor;
        dataStairs.itemCount = [self.stairsValues count];
        dataStairs.getData = ^(NSUInteger index) {
            CGFloat yValue = [self.stairsValues[index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        
        stairsLineChart.chartData = @[dataStairs];
        [stairsLineChart strokeChart];
        
        [self.stairsGraphView addSubview:stairsLineChart];
    }
}

// Method to set up outlets of view to show data of the goal.
-(void)showDetails {
    // Set the title of the navigation bar.
    self.navigationItem.title = [NSString stringWithFormat:@"%@", self.viewGoal.goalName];
    
    self.conversionSelector.selectedSegmentIndex = self.conversion;
    
    if (self.testing.getTesting) {
        [self hideAndDisableRightNavigationItem];
    }
    else {
        [self showAndEnableRightNavigationItem];
    }
    
    if (self.image != nil) {
        self.image = nil;
    }
    
    UIColor *tint = [[UIColor alloc] init];
    self.image = [[UIImage alloc] init];
    
    // Set the title label to the goal name.
    self.viewTitle.text = [NSString stringWithFormat:@"%@", self.viewGoal.goalName];
    
    // Depending on the status of the goal set the status label and background accordingly.
    switch (self.viewGoal.goalStatus) {
        case Pending:
            self.viewStatus.text = [NSString stringWithFormat:@"Pending"];
            tint = [UIColor colorWithRed:((102) / 255.0) green:((178) / 255.0) blue:((255) / 255.0) alpha:1.0];
            [self disableButton:self.outletActiveButton];
            [self disableButton:self.outletSuspendButton];
            [self disableStepper:self.addStepper];
            [self disableStepper:self.addStairsStepper];
            break;
        case Active:
            self.viewStatus.text = [NSString stringWithFormat:@"Active"];
            tint = [UIColor colorWithRed:((0) / 255.0) green:((152) / 255.0) blue:((0) / 255.0) alpha:1.0];
            [self enableButton:self.outletActiveButton];
            [self enableButton:self.outletSuspendButton];
            [self enableStepper:self.addStepper];
            [self enableStepper:self.addStairsStepper];
            break;
        case Overdue:
            self.viewStatus.text = [NSString stringWithFormat:@"Overdue"];
            tint = [UIColor colorWithRed:((255) / 255.0) green:((0) / 255.0) blue:((0) / 255.0) alpha:1.0];
            [self enableButton:self.outletActiveButton];
            [self enableButton:self.outletSuspendButton];
            [self enableStepper:self.addStepper];
            [self enableStepper:self.addStairsStepper];
            break;
        case Suspended:
            self.viewStatus.text = [NSString stringWithFormat:@"Suspended"];
            tint = [UIColor colorWithRed:((255) / 255.0) green:((215) / 255.0) blue:((0) / 255.0) alpha:1.0];
            [self.outletSuspendButton setTitle:@"Re-instate" forState:UIControlStateNormal];
            [self disableButton:self.outletActiveButton];
            [self enableButton:self.outletSuspendButton];
            [self disableStepper:self.addStepper];
            [self disableStepper:self.addStairsStepper];
            [self hideAndDisableRightNavigationItem];
            break;
        case Abandoned:
            self.viewStatus.text = [NSString stringWithFormat:@"Abandoned"];
            tint = [UIColor colorWithRed:((128) / 255.0) green:((128) / 255.0) blue:((128) / 255.0) alpha:1.0];
            [self disableButton:self.outletActiveButton];
            [self disableButton:self.outletSuspendButton];
            [self disableButton:self.abandonButton];
            [self disableStepper:self.addStepper];
            [self disableStepper:self.addStairsStepper];
            [self hideAndDisableRightNavigationItem];
            break;
        case Completed:
            self.viewStatus.text = [NSString stringWithFormat:@"Completed"];
            tint = [UIColor colorWithRed:((0) / 255.0) green:((0) / 255.0) blue:((0) / 255.0) alpha:1.0];
            [self disableButton:self.outletActiveButton];
            [self disableButton:self.outletSuspendButton];
            [self disableButton:self.abandonButton];
            [self disableButton:self.activeOutletButtonTest];
            [self disableStepper:self.addStepper];
            [self disableStepper:self.addStairsStepper];
            [self hideAndDisableRightNavigationItem];
            break;
        default:
            break;
    }
    
    NSString *stepsName;
    NSString *stairsName;
    NSInteger conversionIndexSteps;
    NSInteger conversionIndexStairs;
    
    NSNumberFormatter *twoDecimalPlaces = [[NSNumberFormatter alloc] init];
    [twoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
    [twoDecimalPlaces setMaximumFractionDigits:2];
    
    // Depending on the type of the goal set the goal type label, the progress label and the progress bar accordingly.
    switch (self.viewGoal.goalType) {
        case Steps:
            [self createStepsStatsView];
            [self disableStepper:self.addStairsStepper];
            self.viewType.text = [NSString stringWithFormat:@"Steps"];
            if (self.conversion == StepsStairs) {
                stepsName = @"steps";
                conversionIndexSteps = 0;
                stairsName = @"stairs";
                conversionIndexStairs = 0;
            }
            else if (self.conversion == Imperial) {
                stepsName = @"miles";
                conversionIndexSteps = 1;
                stairsName= @"feet";
                conversionIndexStairs = 3;
            }
            else if (self.conversion == Metric) {
                stepsName = @"km";
                conversionIndexSteps = 2;
                stairsName = @"meters";
                conversionIndexStairs = 4;
            }
            self.viewProgress.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.viewProgressStairs.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            self.viewPercentage.text = [NSString stringWithFormat:@"Percentage: %@%%",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)*100)]]];
            
            self.testTrackLabel.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.testTrackStairsLabel.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.testTrackProgress setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            
            self.trackLabel.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.trackStairsLabel.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.trackProgress setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            
            self.image = [UIImage imageNamed:@"Right_Filled.png"];
            break;
        case Stairs:
            [self createStairsStatsView];
            [self disableStepper:self.addStepper];
            self.viewType.text = [NSString stringWithFormat:@"Stairs"];
            if (self.conversion == StepsStairs) {
                stepsName = @"steps";
                conversionIndexSteps = 0;
                stairsName = @"stairs";
                conversionIndexStairs = 0;
            }
            else if (self.conversion == Imperial) {
                stepsName = @"miles";
                conversionIndexSteps = 1;
                stairsName= @"feet";
                conversionIndexStairs = 3;
            }
            else if (self.conversion == Metric) {
                stepsName = @"km";
                conversionIndexSteps = 2;
                stairsName = @"meters";
                conversionIndexStairs = 4;
            }
            self.viewProgress.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.viewProgressStairs.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            self.viewPercentage.text = [NSString stringWithFormat:@"Percentage: %@%%",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)*100)]]];
            
            self.testTrackLabel.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.testTrackStairsLabel.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.testTrackProgress setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            
            self.trackLabel.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.trackStairsLabel.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.trackProgress setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            
            self.image = [UIImage imageNamed:@"Up_Filled.png"];
            break;
        case Both:
            [self createBothStatsView];
            self.viewType.text = [NSString stringWithFormat:@"Steps and Stairs"];
            if (self.conversion == StepsStairs) {
                stepsName = @"steps";
                conversionIndexSteps = 0;
                stairsName = @"stairs";
                conversionIndexStairs = 0;
            }
            else if (self.conversion == Imperial) {
                stepsName = @"miles";
                conversionIndexSteps = 1;
                stairsName= @"feet";
                conversionIndexStairs = 3;
            }
            else if (self.conversion == Metric) {
                stepsName = @"km";
                conversionIndexSteps = 2;
                stairsName = @"meters";
                conversionIndexStairs = 4;
            }
            self.viewProgress.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.viewProgressStairs.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            
            [self.viewProgressBar setProgress:(float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2)) animated:YES];
            self.viewPercentage.text = [NSString stringWithFormat:@"Percentage: %@%%",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(((float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2)))*100)]]];
            
            self.testTrackLabel.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.testTrackStairsLabel.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.testTrackProgress setProgress:(float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2)) animated:YES];
            
            self.trackLabel.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.trackStairsLabel.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.trackProgress setProgress:(float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2)) animated:YES];
            
            self.image = [UIImage imageNamed:@"Up_Right.png"];
            break;
        case Everest:
            [self disableStepper:self.addStepper];
            [self createStairsStatsView];
            if (self.conversion == StepsStairs) {
                stepsName = @"steps";
                conversionIndexSteps = 0;
                stairsName = @"stairs";
                conversionIndexStairs = 0;
            }
            else if (self.conversion == Imperial) {
                stepsName = @"miles";
                conversionIndexSteps = 1;
                stairsName= @"feet";
                conversionIndexStairs = 3;
            }
            else if (self.conversion == Metric) {
                stepsName = @"km";
                conversionIndexSteps = 2;
                stairsName = @"meters";
                conversionIndexStairs = 4;
            }
            self.viewType.text = [NSString stringWithFormat:@"Climb Everest"];
            self.viewProgress.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.viewProgressStairs.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            self.viewPercentage.text = [NSString stringWithFormat:@"Percentage: %@%%",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)*100)]]];
            
            self.testTrackLabel.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.testTrackStairsLabel.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.testTrackProgress setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            
            self.trackLabel.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.trackStairsLabel.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.trackProgress setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            
            self.image = [UIImage imageNamed:@"everest.png"];
            break;
        case Nevis:
            [self disableStepper:self.addStepper];
            [self createStairsStatsView];
            if (self.conversion == StepsStairs) {
                stepsName = @"steps";
                conversionIndexSteps = 0;
                stairsName = @"stairs";
                conversionIndexStairs = 0;
            }
            else if (self.conversion == Imperial) {
                stepsName = @"miles";
                conversionIndexSteps = 1;
                stairsName= @"feet";
                conversionIndexStairs = 3;
            }
            else if (self.conversion == Metric) {
                stepsName = @"km";
                conversionIndexSteps = 2;
                stairsName = @"meters";
                conversionIndexStairs = 4;
            }
            self.viewType.text = [NSString stringWithFormat:@"Climb Ben Nevis"];
            self.viewProgress.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.viewProgressStairs.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            self.viewPercentage.text = [NSString stringWithFormat:@"Percentage: %@%%",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)*100)]]];
            
            self.testTrackLabel.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.testTrackStairsLabel.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.testTrackProgress setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            
            self.trackLabel.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.trackStairsLabel.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.trackProgress setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            
            self.image = [UIImage imageNamed:@"nevis.png"];
            break;
        case Pluto:
            [self disableStepper:self.addStairsStepper];
            [self createStepsStatsView];
            if (self.conversion == StepsStairs) {
                stepsName = @"steps";
                conversionIndexSteps = 0;
                stairsName = @"stairs";
                conversionIndexStairs = 0;
            }
            else if (self.conversion == Imperial) {
                stepsName = @"miles";
                conversionIndexSteps = 1;
                stairsName= @"feet";
                conversionIndexStairs = 3;
            }
            else if (self.conversion == Metric) {
                stepsName = @"km";
                conversionIndexSteps = 2;
                stairsName = @"meters";
                conversionIndexStairs = 4;
            }
            self.viewType.text = [NSString stringWithFormat:@"Walk Around Pluto"];
            self.viewProgress.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.viewProgressStairs.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            self.viewPercentage.text = [NSString stringWithFormat:@"Percentage: %@%%",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)*100)]]];
            
            self.testTrackLabel.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.testTrackStairsLabel.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.testTrackProgress setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            
            self.trackLabel.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.trackStairsLabel.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.trackProgress setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            
            self.image = [UIImage imageNamed:@"pluto.png"];
            break;
        default:
            break;
    }
    
    // Set up the date formatter to the required format.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd HH:mm"];
    
    double nowDate = [[NSDate date] timeIntervalSince1970];
    //double activeDate = [self.viewGoal.goalStartDate timeIntervalSince1970];
    double overdueDate = [self.viewGoal.goalCompletionDate timeIntervalSince1970];
    
    double days = (60*60*24);
    
    //double activeInDays = (activeDate-nowDate)/days;
    //double activeInDaysFloor = floor((activeDate-nowDate)/days);
    //double activeInHours = (activeInDays-activeInDaysFloor)*24;
    
    //double overdueInDays = (overdueDate-nowDate)/days;
    //double overdueInDaysFloor = floor((overdueDate-nowDate)/days);
    //double overdueInHours = (overdueInDays-overdueInDaysFloor)*24;
    
    double overdueForDays = (nowDate-overdueDate)/days;
    double overdueForDaysFloor = floor((nowDate-overdueDate)/days);
    double overdueForHours = (overdueForDays-overdueForDaysFloor)*24;
    
    // Set the date labels to their values in the required format.
    self.viewDateCreated.text = [NSString stringWithFormat:@"Date Created: %@",[formatter stringFromDate:self.viewGoal.goalCreationDate]];
    if (self.viewGoal.goalStatus == Pending) {
        self.viewDateStart.text = [NSString stringWithFormat:@"Starts on: %@",[formatter stringFromDate:self.viewGoal.goalStartDate]];
    }
    else {
        self.viewDateStart.text = [NSString stringWithFormat:@"Started on: %@",[formatter stringFromDate:self.viewGoal.goalStartDate]];
    }
    
    if (self.viewGoal.goalStatus == Completed) {
        self.viewDateCompletion.text = [NSString stringWithFormat:@"Completed on: %@",[formatter stringFromDate:self.viewGoal.goalCompletionDate]];
    }
    else if (self.viewGoal.goalStatus == Abandoned) {
        self.viewDateCompletion.text = [NSString stringWithFormat:@"Abandoned on: %@",[formatter stringFromDate:self.viewGoal.goalCompletionDate]];
    }
    else if (self.viewGoal.goalStatus == Overdue) {
        self.viewDateCompletion.text = [NSString stringWithFormat:@"Overdue for: %.f Days %.f Hours", overdueForDaysFloor,overdueForHours];
    }
    else {
        self.viewDateCompletion.text = [NSString stringWithFormat:@"Complete by: %@",[formatter stringFromDate:self.viewGoal.goalCompletionDate]];
    }
    
    
    self.stepperLabel.text = @"0";
    self.stepperStairsLabel.text = @"0";
    self.addStepper.value = 0.0;
    [self.addStepper setStepValue:1.0];
    self.addStairsStepper.value = 0.0;
    [self.addStairsStepper setStepValue:1.0];
    
    if (self.viewGoal.goalStatus == Completed) {
        if (self.image != nil) {
            self.image = nil;
        }
        self.image = [UIImage imageNamed:@"Checkmark.png"];
        tint = [UIColor colorWithRed:((0) / 255.0) green:((152) / 255.0) blue:((0) / 255.0) alpha:1.0];
    }
    
    if (self.viewGoal.goalType == Steps || self.viewGoal.goalType == Stairs || self.viewGoal.goalType == Both || self.viewGoal.goalStatus == Completed) {
        NSLog(@"tinting");
        self.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.imageView setTintColor:tint];
    }
    else if (self.viewGoal.goalType == Everest || self.viewGoal.goalType == Nevis) {
        double tempPrecent = (float)(self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs);
        [self maskMainImageWithX:0.0 andY:0.0 andWidth:90.0 andHeight:(90.0-(90*tempPrecent))];
    }
    else if (self.viewGoal.goalType == Pluto) {
        double tempPrecent = (float)(self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps);
        [self maskMainImageWithX:(90*tempPrecent) andY:0.0 andWidth:(90.0-(90*tempPrecent)) andHeight:90.0];
    }
    
    [self.imageView setImage:self.image];
    // optional:
    // [imageHolder sizeToFit];
    [self.mainDetailsView addSubview:self.imageView];
}

-(void) maskMainImageWithX:(float)x andY:(float)y andWidth:(float)width andHeight:(float)height {
    CGSize size = CGSizeMake(90, 90);
    UIGraphicsBeginImageContext(size);
    
    // Use existing opacity as is
    [self.image drawInRect:CGRectMake(0,0,size.width,size.height)];
    // Apply supplied opacity
    [self.mask drawInRect:CGRectMake(x,y,width,height) blendMode:kCGBlendModeNormal alpha:0.6];
    
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
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
            query = [NSString stringWithFormat:@"update %@ set goalName='%@', goalType='%d', goalAmountSteps='%f', goalAmountStairs='%f', goalStartDate='%f', goalDate='%f', goalConversion='%d' where goalID=%ld", self.testing.getGoalDBName, self.viewGoal.goalName, self.viewGoal.goalType, self.viewGoal.goalAmountSteps, self.viewGoal.goalAmountStairs, [self.viewGoal.goalStartDate timeIntervalSince1970], [self.viewGoal.goalCompletionDate timeIntervalSince1970], self.viewGoal.goalConversion, (long)self.viewGoal.goalID];
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
    [self checkGoalStatus];
}

-(IBAction)unwindFromHistory:(UIStoryboardSegue *)segue {
    // Reload the view.
    [self checkGoalStatus];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showEditGoal"]) {
        EditGoalViewController *destViewController = segue.destinationViewController;
        destViewController.editGoal = self.viewGoal;
        destViewController.listGoalNames = self.listGoalNames;
        destViewController.currentName = self.viewGoal.goalName;
        destViewController.settings = self.settings;
    }
    else if ([segue.identifier isEqualToString:@"showHistory"]) {
        HistoryTableViewController *destViewController = segue.destinationViewController;
        destViewController.viewHistoryGoal = self.viewGoal;
        destViewController.testing = self.testing;
    }
}

#pragma mark - Buttons

- (IBAction)setActiveButton:(id)sender {
    [self storeGoalStatusChangeToDB];
    if (self.viewGoal.goalType == Steps || self.viewGoal.goalType == Pluto) {
        if ([self.stepperLabel.text intValue] > 0) {
            self.progressSteps = [self.stepperLabel.text intValue];
            if ((self.viewGoal.goalProgressSteps + self.progressSteps) > self.viewGoal.goalAmountSteps) {
                self.progressSteps -= ((self.viewGoal.goalProgressSteps + self.progressSteps)- self.viewGoal.goalAmountSteps);
                self.viewGoal.goalProgressSteps = self.viewGoal.goalAmountSteps;
            }
            else {
                self.viewGoal.goalProgressSteps += self.progressSteps;
            }
            NSLog(@"Steps Amount: %f",self.viewGoal.goalAmountSteps);
            NSLog(@"Steps Progress: %f",self.viewGoal.goalProgressSteps);
            NSLog(@"Progress: %f",self.progressSteps);
            self.recordingStartTime = [[NSDate date] timeIntervalSince1970];
            self.recordingEndTime = [[NSDate date] timeIntervalSince1970] /*+ self.progressSteps*self.testSettings.stepsTime*/;
            [self storeGoalProgressToDB];
            [self storeGoalStatisticsToDB];
            [self updateView];
            self.stepperLabel.text = @"0";
            self.addStepper.value = 0.0;
            self.progressSteps = 0;
            [self loadFromDB];
        }
    }
    else if (self.viewGoal.goalType == Stairs || self.viewGoal.goalType == Everest || self.viewGoal.goalType == Nevis) {
        if ([self.stepperStairsLabel.text intValue] > 0) {
            self.progressStairs = [self.stepperStairsLabel.text intValue];
            NSLog(@"Stairs Amount: %f",self.viewGoal.goalAmountStairs);
            NSLog(@"Stairs Progress: %f",self.viewGoal.goalProgressStairs);
            NSLog(@"Progress Stairs: %f",self.progressStairs);
            NSLog(@"Total Progress: %f",(self.viewGoal.goalProgressStairs+self.progressStairs));
            if ((self.viewGoal.goalProgressStairs + self.progressStairs) > self.viewGoal.goalAmountStairs) {
                NSLog(@"Over");
                self.progressStairs -= ((self.viewGoal.goalProgressStairs + self.progressStairs)-self.viewGoal.goalAmountStairs);
                self.viewGoal.goalProgressStairs = self.viewGoal.goalAmountStairs;
            }
            else {
                self.viewGoal.goalProgressStairs += self.progressStairs;
            }
            self.recordingStartTime = [[NSDate date] timeIntervalSince1970];
            self.recordingEndTime = [[NSDate date] timeIntervalSince1970] /*+ self.progressStairs*self.testSettings.stairsTime*/;
            [self storeGoalProgressToDB];
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
            if ((self.viewGoal.goalProgressSteps + self.progressSteps) > self.viewGoal.goalAmountSteps) {
                self.progressSteps -= ((self.viewGoal.goalProgressSteps + self.progressSteps)- self.viewGoal.goalAmountSteps);
                self.viewGoal.goalProgressSteps = self.viewGoal.goalAmountSteps;
            }
            else {
                self.viewGoal.goalProgressSteps += self.progressSteps;
            }
            if ((self.viewGoal.goalProgressStairs + self.progressStairs) > self.viewGoal.goalAmountStairs) {
                self.progressStairs -= ((self.viewGoal.goalProgressStairs + self.progressStairs)-self.viewGoal.goalAmountStairs);
                self.viewGoal.goalProgressStairs = self.viewGoal.goalAmountStairs;
            }
            else {
                self.viewGoal.goalProgressStairs += self.progressStairs;
            }
            NSLog(@"Steps Amount: %f",self.viewGoal.goalAmountSteps);
            NSLog(@"Steps Progress: %f",self.viewGoal.goalProgressSteps);
            NSLog(@"Progress: %f",self.progressSteps);
            NSLog(@"Stairs Amount: %f",self.viewGoal.goalAmountStairs);
            NSLog(@"Stairs Progress: %f",self.viewGoal.goalProgressStairs);
            NSLog(@"Progress: %f",self.progressStairs);
            self.recordingStartTime = [[NSDate date] timeIntervalSince1970];
            if (self.progressStairs > 0) {
                self.recordingEndTime = [[NSDate date] timeIntervalSince1970] /*+ self.progressStairs*self.testSettings.stairsTime*/;
            }
            else {
                self.recordingEndTime = [[NSDate date] timeIntervalSince1970] /*+ self.progressStairs*self.testSettings.stepsTime*/;
            }
            [self storeGoalProgressToDB];
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
        [self storeGoalStatusChangeToDB];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now Recording" message:@"This goal is now recording." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        self.isRecording = YES;
        self.recordingStartTime = [[NSDate date] timeIntervalSince1970];
        [self hideAndDisableLeftNavigationItem];
        [self.activeOutletButtonTest setTitle:@"Stop" forState:UIControlStateNormal];
        self.autoStepSpinner.hidden = NO;
        [self.autoStepSpinner startAnimating];
        [self disableButton:self.outletHistoryButton];
        [self disableButton:self.abandonButton];
        [self disableSegement:self.viewSelector];
        NSLog(@"Steps Time: %ld",(long)self.testSettings.stepsTime);
        NSLog(@"Stairs Time: %ld",(long)self.testSettings.stairsTime);
        [self startBackgroundThread];
    } /**********************************stop recording*****************************************/
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now not recording" message:@"This goal is now not recording." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        self.isRecording = NO;
        [self storeGoalProgressToDB];
        [self storeGoalStatisticsToDB];
        self.progressSteps = 0;
        self.progressStairs = 0;
        [self showAndEnableLeftNavigationItem];
        [self.activeOutletButtonTest setTitle:@"Record" forState:UIControlStateNormal];
        self.autoStepSpinner.hidden = YES;
        [self.autoStepSpinner stopAnimating];
        [self enableButton:self.outletHistoryButton];
        [self enableButton:self.abandonButton];
        [self enableSegement:self.viewSelector];
        [self cancelBackgroundThread];
        [self loadFromDB];
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
    
    if (((self.viewGoal.goalType == Steps) || (self.viewGoal.goalType == Pluto) || (self.viewGoal.goalType == Both)) && (self.viewGoal.goalAmountSteps != self.viewGoal.goalProgressSteps)) {
        timerStep = [NSTimer timerWithTimeInterval:(double)self.testSettings.stepsTime
                                            target:self
                                          selector:@selector(takeStep)
                                          userInfo:nil
                                           repeats:YES ];
        [[NSRunLoop mainRunLoop] addTimer:timerStep forMode:NSRunLoopCommonModes];
    }
    if (((self.viewGoal.goalType == Stairs) || (self.viewGoal.goalType == Everest) || (self.viewGoal.goalType == Nevis) || (self.viewGoal.goalType == Both)) && (self.viewGoal.goalAmountStairs != self.viewGoal.goalProgressStairs)) {
        timerStair = [NSTimer timerWithTimeInterval:(double)self.testSettings.stairsTime
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
    self.viewGoal.goalProgressSteps++;
    self.progressSteps++;
    NSLog(@"Take Step");
    NSLog(@"Steps Amount: %f",self.viewGoal.goalAmountSteps);
    if (self.viewGoal.goalAmountSteps > self.viewGoal.goalProgressSteps) {
        NSLog(@"Steps Progress: %f",self.viewGoal.goalProgressSteps);
        [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
    }
    else {
        [timerStep invalidate];
        timerStep = nil;
        NSLog(@"Steps Progress: %f",self.viewGoal.goalProgressSteps);
        if ((self.viewGoal.goalAmountSteps <= self.viewGoal.goalProgressSteps) && (self.viewGoal.goalAmountStairs <= self.viewGoal.goalProgressStairs)) {
            NSLog(@"Stairs Progress: %f",self.viewGoal.goalProgressStairs);
            [self performSelectorOnMainThread:@selector(storeGoalProgressToDB) withObject:nil waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(storeGoalStatisticsToDB) withObject:nil waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:YES];
            [self cancelBackgroundThread];
        }
    }
}

-(void) takeStair {
    self.viewGoal.goalProgressStairs++;
    self.progressStairs++;
    NSLog(@"Take Stair");
    NSLog(@"Stairs Amount: %f",self.viewGoal.goalAmountStairs);
    if (self.viewGoal.goalAmountStairs > self.viewGoal.goalProgressStairs) {
        NSLog(@"Stairs Progress: %f",self.viewGoal.goalProgressStairs);
        [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
    }
    else {
        [timerStair invalidate];
        timerStair = nil;
        NSLog(@"Stairs Progress: %f",self.viewGoal.goalProgressStairs);
        if ((self.viewGoal.goalAmountSteps <= self.viewGoal.goalProgressSteps) && (self.viewGoal.goalAmountStairs <= self.viewGoal.goalProgressStairs)) {
            NSLog(@"Steps Progress: %f",self.viewGoal.goalProgressSteps);
            [self performSelectorOnMainThread:@selector(storeGoalProgressToDB) withObject:nil waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(storeGoalStatisticsToDB) withObject:nil waitUntilDone:YES];
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
    self.recordingEndTime = [[NSDate date] timeIntervalSince1970];
    
    NSNumberFormatter *twoDecimalPlaces = [[NSNumberFormatter alloc] init];
    [twoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
    [twoDecimalPlaces setMaximumFractionDigits:2];
    
    NSString *stepsName;
    NSString *stairsName;
    NSInteger conversionIndexSteps;
    NSInteger conversionIndexStairs;
    
    switch (self.viewGoal.goalType) {
        case Pluto:
        case Steps:
            if (self.viewGoal.goalAmountSteps <= self.viewGoal.goalProgressSteps) {
                [self completedView];
            }
            if (self.conversion == StepsStairs) {
                stepsName = @"steps";
                conversionIndexSteps = 0;
                stairsName = @"stairs";
                conversionIndexStairs = 0;
            }
            else if (self.conversion == Imperial) {
                stepsName = @"miles";
                conversionIndexSteps = 1;
                stairsName= @"feet";
                conversionIndexStairs = 3;
            }
            else if (self.conversion == Metric) {
                stepsName = @"km";
                conversionIndexSteps = 2;
                stairsName = @"meters";
                conversionIndexStairs = 4;
            }
            self.viewProgress.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            self.viewPercentage.text = [NSString stringWithFormat:@"Percentage: %@%%",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)*100)]]];
            if (self.testing.getTesting) {
                self.testTrackLabel.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
                [self.testTrackProgress setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            }
            else {
                self.trackLabel.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
                [self.trackProgress setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            }
            if (self.viewGoal.goalType == Pluto) {
                double tempPrecent = (float)(self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps);
                [self maskMainImageWithX:(90*tempPrecent) andY:0.0 andWidth:(90.0-(90*tempPrecent)) andHeight:90.0];
            }
            
            [self.imageView setImage:self.image];
            break;
        case Everest:
        case Nevis:
        case Stairs:
            if (self.viewGoal.goalAmountStairs <= self.viewGoal.goalProgressStairs) {
                [self completedView];
            }
            if (self.conversion == StepsStairs) {
                stepsName = @"steps";
                conversionIndexSteps = 0;
                stairsName = @"stairs";
                conversionIndexStairs = 0;
            }
            else if (self.conversion == Imperial) {
                stepsName = @"miles";
                conversionIndexSteps = 1;
                stairsName= @"feet";
                conversionIndexStairs = 3;
            }
            else if (self.conversion == Metric) {
                stepsName = @"km";
                conversionIndexSteps = 2;
                stairsName = @"meters";
                conversionIndexStairs = 4;
            }
            self.viewProgressStairs.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            self.viewPercentage.text = [NSString stringWithFormat:@"Percentage: %@%%",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:((float)(self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)*100)]]];
            if (self.testing.getTesting) {
                self.testTrackStairsLabel.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
                [self.testTrackProgress setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            }
            else {
                self.trackStairsLabel.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
                [self.trackProgress setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            }
            if (self.viewGoal.goalType == Everest || self.viewGoal.goalType == Nevis) {
                double tempPrecent = (float)(self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs);
                [self maskMainImageWithX:0.0 andY:0.0 andWidth:90.0 andHeight:(90.0-(90*tempPrecent))];
            }
            
            [self.imageView setImage:self.image];
            break;
        case Both:
            if (((self.viewGoal.goalAmountSteps <= self.viewGoal.goalProgressSteps) && (self.viewGoal.goalAmountStairs <= self.viewGoal.goalProgressStairs))) {
                [self completedView];
            }
            if (self.conversion == StepsStairs) {
                stepsName = @"steps";
                conversionIndexSteps = 0;
                stairsName = @"stairs";
                conversionIndexStairs = 0;
            }
            else if (self.conversion == Imperial) {
                stepsName = @"miles";
                conversionIndexSteps = 1;
                stairsName= @"feet";
                conversionIndexStairs = 3;
            }
            else if (self.conversion == Metric) {
                stepsName = @"km";
                conversionIndexSteps = 2;
                stairsName = @"meters";
                conversionIndexStairs = 4;
            }
            self.viewProgress.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
            self.viewProgressStairs.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
            [self.viewProgressBar setProgress:(float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2)) animated:YES];
            self.viewPercentage.text = [NSString stringWithFormat:@"Percentage: %@%%",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:((float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2))*100)]]];
            if (self.testing.getTesting) {
                self.testTrackLabel.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
                self.testTrackStairsLabel.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
                [self.testTrackProgress setProgress:(float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2)) animated:YES];
            }
            else {
                self.trackLabel.text = [NSString stringWithFormat:@"Walk: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])]],stepsName];
                self.trackStairsLabel.text = [NSString stringWithFormat:@"Climb: %@/%@ %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])]],stairsName];
                [self.trackProgress setProgress:(float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2)) animated:YES];
            }
            break;
        default:
            break;
    }
    
    [self setUpStats];
}

-(void) completedView {
    self.viewGoal.goalStatus = Completed;
    self.viewGoal.goalCompletionDate = [NSDate date];
    if (self.testing.getTesting) {
        [self cancelLocalNotification:[NSString stringWithFormat:@"%@startTesting",self.viewGoal.goalName] type:@"start"];
        [self cancelLocalNotification:[NSString stringWithFormat:@"%@endTesting",self.viewGoal.goalName] type:@"end"];
    }
    else {
        [self cancelLocalNotification:[NSString stringWithFormat:@"%@start",self.viewGoal.goalName] type:@"start"];
        [self cancelLocalNotification:[NSString stringWithFormat:@"%@end",self.viewGoal.goalName] type:@"end"];
    }
    self.viewStatus.text = @"Completed";
    
    if (self.viewGoal.goalAmountSteps < self.viewGoal.goalProgressSteps) {
        double stepsDiff = (self.viewGoal.goalProgressSteps-self.viewGoal.goalAmountSteps);
        self.progressSteps -= (self.progressSteps-stepsDiff);
        self.viewGoal.goalProgressSteps = self.viewGoal.goalAmountSteps;
    }
    if (self.viewGoal.goalAmountStairs < self.viewGoal.goalProgressStairs) {
        NSLog(@"here");
        double stairsDiff = (self.viewGoal.goalProgressStairs-self.viewGoal.goalAmountStairs);
        self.progressStairs = (self.progressStairs-stairsDiff);
        self.viewGoal.goalProgressStairs = self.viewGoal.goalAmountStairs;
    }
    NSLog(@"Amount Steps: %f",self.viewGoal.goalAmountSteps);
    NSLog(@"Progress Steps: %f",self.progressSteps);
    NSLog(@"Goal Progress Steps: %f",self.viewGoal.goalProgressSteps);
    NSLog(@"Amount Stairs: %f",self.viewGoal.goalAmountStairs);
    NSLog(@"Progress Stairs: %f",self.progressStairs);
    NSLog(@"Goal Progress Stairs: %f",self.viewGoal.goalProgressStairs);
    
    self.progressSteps = 0;
    self.progressStairs = 0;
    [self storeGoalStatusCompleteToDB];
    
    [self disableButton:self.outletActiveButton];
    [self disableButton:self.activeOutletButtonTest];
    [self disableButton:self.abandonButton];
    [self enableButton:self.outletHistoryButton];
    [self enableSegement:self.viewSelector];
    [self.autoStepSpinner stopAnimating];
    self.autoStepSpinner.hidden = YES;
    
    if (self.image != nil) {
        self.image = nil;
    }
    
    UIColor *tint = [[UIColor alloc] init];
    self.image = [[UIImage alloc] init];
    
    self.image = [UIImage imageNamed:@"Checkmark.png"];
    tint = [UIColor colorWithRed:((0) / 255.0) green:((152) / 255.0) blue:((0) / 255.0) alpha:1.0];
    
    if (self.viewGoal.goalType == Steps || self.viewGoal.goalType == Stairs || self.viewGoal.goalType == Both || self.viewGoal.goalStatus == Completed) {
        NSLog(@"tinting");
        self.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.imageView setTintColor:tint];
    }
    
    [self.imageView setImage:self.image];
    
    
    if (self.settings.notifications) {
        NSLog(@"Completed Notification.");
        UILocalNotification* completedNotification = [[UILocalNotification alloc] init];
        completedNotification.fireDate = [NSDate date];
        completedNotification.alertBody = [NSString stringWithFormat:@"Goal %@ is now Completed.",self.viewGoal.goalName];
        completedNotification.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:completedNotification];
    }
    else {
        NSLog(@"Completed Alert View.");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:[NSString stringWithFormat:@"Goal %@ is now Completed.",self.viewGoal.goalName]
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [self showAndEnableLeftNavigationItem];
}

- (IBAction)suspendButton:(id)sender {
    /**********************************Suspend*****************************************/
    if ((self.viewGoal.goalStatus == Pending) || (self.viewGoal.goalStatus == Active) || (self.viewGoal.goalStatus == Overdue)) {
        self.viewGoal.goalStatus = Suspended;
        if (self.testing.getTesting) {
            [self cancelLocalNotification:[NSString stringWithFormat:@"%@startTesting",self.viewGoal.goalName] type:@"start"];
            [self cancelLocalNotification:[NSString stringWithFormat:@"%@endTesting",self.viewGoal.goalName] type:@"end"];
        }
        else {
            [self cancelLocalNotification:[NSString stringWithFormat:@"%@start",self.viewGoal.goalName] type:@"start"];
            [self cancelLocalNotification:[NSString stringWithFormat:@"%@end",self.viewGoal.goalName] type:@"end"];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now suspended" message:@"This goal is now suspended." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [self storeGoalStatusChangeToDB];
        self.viewStatus.text = [NSString stringWithFormat:@"Suspended"];
        //self.scrollView.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
        [self showAndEnableLeftNavigationItem];
        [self hideAndDisableRightNavigationItem];
        [self disableButton:self.outletActiveButton];
        [self enableButton:self.outletHistoryButton];
        self.stepperLabel.text = @"0";
        self.addStepper.value = 0.0;
        self.stepperStairsLabel.text = @"0";
        self.addStairsStepper.value = 0.0;
        [self disableButton:self.outletActiveButton];
        [self disableButton:self.activeOutletButtonTest];
        self.autoStepSpinner.hidden = YES;
        [self disableStepper:self.addStepper];
        [self disableStepper:self.addStairsStepper];
        [self.outletActiveButton setTitle:@"Record" forState:UIControlStateNormal];
        [self.outletSuspendButton setTitle:@"Re-instate" forState:UIControlStateNormal];
        [self showDetails];
    }/**********************************Re-instate*****************************************/
    else if (self.viewGoal.goalStatus == Suspended) {
        if ([[[NSDate date] earlierDate:self.viewGoal.goalStartDate]isEqualToDate: [NSDate date]]) {
            self.viewGoal.goalStatus = Pending;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now pending" message:@"This goal is now pending." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            self.viewStatus.text = [NSString stringWithFormat:@"Pending"];
            //self.scrollView.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((178) / 255.0) blue:((255) / 255.0) alpha:1.0];
        }
        else if ([[[NSDate date] earlierDate:self.viewGoal.goalCompletionDate]isEqualToDate: self.viewGoal.goalCompletionDate]) {
            self.viewGoal.goalStatus = Overdue;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now overdue" message:@"This goal is now overdue." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            self.viewStatus.text = [NSString stringWithFormat:@"Overdue"];
            //self.scrollView.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((102) / 255.0) blue:((102) / 255.0) alpha:1.0];
        }
        else {
            self.viewGoal.goalStatus = Active;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Goal now Active" message:@"This goal is now Active." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Active"];
            //add the overdue notification again
            UILocalNotification* endNotification = [[UILocalNotification alloc] init];
            endNotification.fireDate = self.viewGoal.goalCompletionDate;
            endNotification.alertBody = [NSString stringWithFormat:@"Goal %@ is now Overdue.",self.viewGoal.goalName];
            endNotification.soundName = UILocalNotificationDefaultSoundName;
            endNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
            
            NSDictionary *infoDictend = [[NSDictionary alloc] init];
            if (self.testing.getTesting) {
                infoDictend = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@endTesting",self.viewGoal.goalName] forKey:[NSString stringWithFormat:@"%@endTesting",self.viewGoal.goalName]];
            }
            else {
                infoDictend = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@end",self.viewGoal.goalName] forKey:[NSString stringWithFormat:@"%@end",self.viewGoal.goalName]];
            }
            endNotification.userInfo = infoDictend;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:endNotification];
            //self.scrollView.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            
        }
        [self storeGoalStatusChangeToDB];
        [self enableButton:self.outletActiveButton];
        [self enableButton:self.outletHistoryButton];
        [self enableButton:self.outletActiveButton];
        [self enableButton:self.activeOutletButtonTest];
        self.autoStepSpinner.hidden = YES;
        [self enableStepper:self.addStepper];
        [self enableStepper:self.addStairsStepper];
        [self showAndEnableRightNavigationItem];
        [self.outletActiveButton setTitle:@"Record" forState:UIControlStateNormal];
        [self.outletSuspendButton setTitle:@"Suspend" forState:UIControlStateNormal];
        [self showDetails];
    }
}

//hide edit button
-(void) hideAndDisableRightNavigationItem {
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

//show edit button
-(void) showAndEnableRightNavigationItem {
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

//hide back button
-(void) hideAndDisableLeftNavigationItem {
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
}

//show back button
-(void) showAndEnableLeftNavigationItem {
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
}

//disable button
-(void) disableButton:(UIButton *)button {
    [button setEnabled:NO];
    button.alpha = 0.3;
}

//enable button
-(void) enableButton:(UIButton *)button {
    [button setEnabled:YES];
    button.alpha = 1.0;
}

//disable stepper
-(void) disableStepper:(UIStepper *)stepper {
    [stepper setEnabled:NO];
    stepper.alpha = 0.3;
}

//enable stepper
-(void) enableStepper:(UIStepper *)stepper {
    [stepper setEnabled:YES];
    stepper.alpha = 1.0;
}

//disable segmentated control
-(void) disableSegement:(UISegmentedControl *)segment {
    [segment setEnabled:NO];
    segment.alpha = 0.3;
}

//enable segmented control
-(void) enableSegement:(UISegmentedControl *)segment {
    [segment setEnabled:YES];
    segment.alpha = 1.0;
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

-(void) storeGoalStatusCompleteToDB {
    NSString *query = [NSString stringWithFormat:@"update %@ set goalStatus='%d', goalDate='%f' where goalID=%ld", self.testing.getGoalDBName, self.viewGoal.goalStatus,[self.viewGoal.goalCompletionDate timeIntervalSince1970],(long)self.viewGoal.goalID];
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    query = [NSString stringWithFormat:@"update %@ set goalStatus='%d', statusEndDate='%f', progressSteps='%f', progressStairs='%f' where historyID=%d", self.testing.getHistoryDBName, self.viewGoal.goalStatus,[[NSDate date] timeIntervalSince1970], self.progressSteps, self.progressStairs, [self getHistoryRowID:self.viewGoal.goalID]];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
}

-(void) storeGoalStatusChangeToDB {
    NSString *query = [NSString stringWithFormat:@"update %@ set goalStatus='%d', goalDate='%f' where goalID=%ld", self.testing.getGoalDBName, self.viewGoal.goalStatus,[self.viewGoal.goalCompletionDate timeIntervalSince1970],(long)self.viewGoal.goalID];
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    query = [NSString stringWithFormat:@"update %@ set statusEndDate='%f', progressSteps='%f', progressStairs='%f' where historyID=%d", self.testing.getHistoryDBName, [[NSDate date] timeIntervalSince1970], self.progressSteps, self.progressStairs, [self getHistoryRowID:self.viewGoal.goalID]];
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

-(void) storeGoalProgressToDB {
    NSLog(@"Goal Progress Steps: %f\n Goal  Progress Stairs: %f",self.viewGoal.goalProgressSteps, self.viewGoal.goalProgressStairs);
    NSString *query = [NSString stringWithFormat:@"update %@ set goalProgressSteps='%f', goalProgressStairs='%f' where goalID=%ld", self.testing.getGoalDBName, self.viewGoal.goalProgressSteps,self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalID];
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    NSLog(@"%f - %f",self.progressSteps, self.progressStairs);
    query = [NSString stringWithFormat:@"update %@ set statusEndDate='%f', progressSteps='%f', progressStairs='%f' where historyID=%d", self.testing.getHistoryDBName, [[NSDate date] timeIntervalSince1970], self.progressSteps, self.progressStairs, [self getHistoryRowID:self.viewGoal.goalID]];
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
    
    query = [NSString stringWithFormat:@"insert into %@ values(null, %ld, '%f', '%f', '%f', '%f')", self.testing.getStatisticsDBName, (long)self.viewGoal.goalID, self.recordingStartTime, self.recordingEndTime, self.progressSteps, self.progressStairs];
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
    if (self.addStepper.value >= 0 && self.addStepper.value < 10) {
        [self.addStepper setStepValue:1.0];
    } else if (self.addStepper.value >= 10 && self.addStepper.value < 50) {
        [self.addStepper setStepValue:5.0];
    }
    else if (self.addStepper.value >= 50 && self.addStepper.value < 250) {
        [self.addStepper setStepValue:25.0];
    }
    else if (self.addStepper.value >= 250 && self.addStepper.value < 1000) {
        [self.addStepper setStepValue:50.0];
    }
    else if (self.addStepper.value >= 1000 && self.addStepper.value < 5000) {
        [self.addStepper setStepValue:100.0];
    }
    else {
        [self.addStepper setStepValue:1000.0];
    }
    self.stepperLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}

- (IBAction)stepperStairsAction:(id)sender {
    if (self.addStairsStepper.value >= 0 && self.addStairsStepper.value < 10) {
        [self.addStairsStepper setStepValue:1.0];
    } else if (self.addStairsStepper.value >= 10 && self.addStairsStepper.value < 50) {
        [self.addStairsStepper setStepValue:5.0];
    }
    else if (self.addStairsStepper.value >= 50 && self.addStairsStepper.value < 250) {
        [self.addStairsStepper setStepValue:25.0];
    }
    else if (self.addStairsStepper.value >= 250 && self.addStairsStepper.value < 1000) {
        [self.addStairsStepper setStepValue:50.0];
    }
    else if (self.addStairsStepper.value >= 1000 && self.addStairsStepper.value < 5000) {
        [self.addStairsStepper setStepValue:100.0];
    }
    else {
        [self.addStairsStepper setStepValue:1000.0];
    }
    self.stepperStairsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}

- (IBAction)viewSelectorAction:(id)sender {
    if(self.viewSelector.selectedSegmentIndex == 0) {
        NSLog(@"Progress");
        [self loadFromDB];
        self.datesView.hidden = NO;
        self.statisticsView.hidden = YES;
        self.trackingView.hidden = YES;
        self.testTrackingView.hidden = YES;
        [self.scrollView setContentSize:CGSizeMake(320, 800)];
        [self.scrollView setScrollEnabled:YES];
    }
    else if (self.viewSelector.selectedSegmentIndex == 1) {
        NSLog(@"Statistics");
        self.datesView.hidden = YES;
        self.statisticsView.hidden = NO;
        self.trackingView.hidden = YES;
        self.testTrackingView.hidden = YES;
        if (self.viewGoal.goalType == Both) {
            [self.scrollView setContentSize:CGSizeMake(320, 1100)];
        }
        else if (self.viewGoal.goalType == Steps || self.viewGoal.goalType == Pluto) {
            [self.scrollView setContentSize:CGSizeMake(320, 650)];
        }
        else {
            [self.scrollView setContentSize:CGSizeMake(320, 650)];
        }
        [self.scrollView setScrollEnabled:YES];
        [self loadFromDB];
    }
    else {
        if (self.testing.getTesting) {
            NSLog(@"Track Testing");
            self.datesView.hidden = YES;
            self.statisticsView.hidden = YES;
            self.trackingView.hidden = YES;
            self.testTrackingView.hidden = NO;
            [self.scrollView setContentSize:CGSizeMake(320, 650)];
            [self.scrollView setScrollEnabled:YES];
        }
        else {
            NSLog(@"Track");
            self.datesView.hidden = YES;
            self.statisticsView.hidden = YES;
            self.trackingView.hidden = NO;
            self.testTrackingView.hidden = YES;
            [self.scrollView setContentSize:CGSizeMake(320, 650)];
            [self.scrollView setScrollEnabled:YES];
        }
    }
}

- (void) createStepsStatsView {
    if (self.stepsEstView != nil) {
        self.stepsEstView = nil;
        [self.stepsEstView removeFromSuperview];
    }
    if (self.stepsGraphView != nil) {
        self.stepsGraphView = nil;
        [self.stepsGraphView removeFromSuperview];
    }
    self.stepsEstView= [[UIView alloc] initWithFrame: CGRectMake(0, 41, 320, 168)];
    
    UILabel *stepsStatsEstLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 8, 288, 25)];
    [stepsStatsEstLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 20.0f]];
    stepsStatsEstLabel.text = @"Steps Estimated Average";
    [self.stepsEstView addSubview:stepsStatsEstLabel];
    
    if (self.stepsPerDayLabel != nil) {
        [self.stepsPerDayLabel removeFromSuperview];
        self.stepsPerDayLabel = nil;
    }
    self.stepsPerDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 41, 288, 21)];
    [self.stepsPerDayLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 17.0f]];
    [self.stepsEstView addSubview:self.stepsPerDayLabel];
    
    if (self.stepsPerWeekLabel != nil) {
        [self.stepsPerWeekLabel removeFromSuperview];
        self.stepsPerWeekLabel = nil;
    }
    self.stepsPerWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 70, 288, 21)];
    [self.stepsPerWeekLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 17.0f]];
    [self.stepsEstView addSubview:self.stepsPerWeekLabel];
    
    if (self.stepsPerMonthLabel != nil) {
        [self.stepsPerMonthLabel removeFromSuperview];
        self.stepsPerMonthLabel = nil;
    }
    self.stepsPerMonthLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 99, 288, 21)];
    [self.stepsPerMonthLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 17.0f]];
    [self.stepsEstView addSubview:self.stepsPerMonthLabel];
    
    if (self.stepsPerYearLabel != nil) {
        [self.stepsPerYearLabel removeFromSuperview];
        self.stepsPerYearLabel = nil;
    }
    self.stepsPerYearLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 128, 288, 21)];
    [self.stepsPerYearLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 17.0f]];
    [self.stepsEstView addSubview:self.stepsPerYearLabel];
    
    self.stepsGraphView= [[UIView alloc] initWithFrame: CGRectMake(0, 209, 320, 246)];
    
    UILabel *stepsStatsGraphLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 288, 25)];
    [stepsStatsGraphLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 20.0f]];
    stepsStatsGraphLabel.text = @"Total Steps Over Time Graph";
    [self.stepsGraphView addSubview:stepsStatsGraphLabel];
    
    [self.statisticsView addSubview:self.stepsEstView];
    [self.statisticsView addSubview:self.stepsGraphView];
}

- (void) createStairsStatsView {
    if (self.stairsEstView != nil) {
        self.stairsEstView = nil;
        [self.stairsEstView removeFromSuperview];
    }
    if (self.stairsGraphView != nil) {
        self.stairsGraphView = nil;
        [self.stairsGraphView removeFromSuperview];
    }
    self.stairsEstView= [[UIView alloc] initWithFrame: CGRectMake(0, 41, 320, 168)];
    
    UILabel *stairsStatsEstLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 8, 288, 25)];
    [stairsStatsEstLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 20.0f]];
    stairsStatsEstLabel.text = @"Stairs Estimated Average";
    [self.stairsEstView addSubview:stairsStatsEstLabel];
    
    if (self.stairsPerDayLabel != nil) {
        [self.stairsPerDayLabel removeFromSuperview];
        self.stairsPerDayLabel = nil;
    }
    self.stairsPerDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 41, 288, 21)];
    [self.stairsPerDayLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 17.0f]];
    [self.stairsEstView addSubview:self.stairsPerDayLabel];
    
    if (self.stairsPerWeekLabel != nil) {
        [self.stairsPerWeekLabel removeFromSuperview];
        self.stairsPerWeekLabel = nil;
    }
    self.stairsPerWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 70, 288, 21)];
    [self.stairsPerWeekLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 17.0f]];
    [self.stairsEstView addSubview:self.stairsPerWeekLabel];
    
    if (self.stairsPerMonthLabel != nil) {
        [self.stairsPerMonthLabel removeFromSuperview];
        self.stairsPerMonthLabel = nil;
    }
    self.stairsPerMonthLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 99, 288, 21)];
    [self.stairsPerMonthLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 17.0f]];
    [self.stairsEstView addSubview:self.stairsPerMonthLabel];
    
    if (self.stairsPerYearLabel != nil) {
        [self.stairsPerYearLabel removeFromSuperview];
        self.stairsPerYearLabel = nil;
    }
    self.stairsPerYearLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 128, 288, 21)];
    [self.stairsPerYearLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 17.0f]];
    [self.stairsEstView addSubview:self.stairsPerYearLabel];
    
    self.stairsGraphView = [[UIView alloc] initWithFrame:CGRectMake(0, 209, 320, 246)];
    
    UILabel *stairsStatsGraphLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 288, 25)];
    [stairsStatsGraphLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 20.0f]];
    stairsStatsGraphLabel.text = @"Total Stairs Over Time Graph";
    [self.stairsGraphView addSubview:stairsStatsGraphLabel];
    
    [self.statisticsView addSubview:self.stairsEstView];
    [self.statisticsView addSubview:self.stairsGraphView];
}

- (void) createBothStatsView {
    if (self.stepsEstView != nil) {
        self.stepsEstView = nil;
        [self.stepsEstView removeFromSuperview];
    }
    if (self.stepsGraphView != nil) {
        self.stepsGraphView = nil;
        [self.stepsGraphView removeFromSuperview];
    }
    self.stepsEstView= [[UIView alloc] initWithFrame: CGRectMake(0, 41, 320, 168)];
    
    UILabel *stepsStatsEstLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 8, 288, 25)];
    [stepsStatsEstLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 20.0f]];
    stepsStatsEstLabel.text = @"Steps Estimated Average";
    [self.stepsEstView addSubview:stepsStatsEstLabel];
    
    if (self.stepsPerDayLabel != nil) {
        [self.stepsPerDayLabel removeFromSuperview];
        self.stepsPerDayLabel = nil;
    }
    self.stepsPerDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 41, 288, 21)];
    [self.stepsPerDayLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 17.0f]];
    [self.stepsEstView addSubview:self.stepsPerDayLabel];
    
    if (self.stepsPerWeekLabel != nil) {
        [self.stepsPerWeekLabel removeFromSuperview];
        self.stepsPerWeekLabel = nil;
    }
    self.stepsPerWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 70, 288, 21)];
    [self.stepsPerWeekLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 17.0f]];
    [self.stepsEstView addSubview:self.stepsPerWeekLabel];
    
    if (self.stepsPerMonthLabel != nil) {
        [self.stepsPerMonthLabel removeFromSuperview];
        self.stepsPerMonthLabel = nil;
    }
    self.stepsPerMonthLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 99, 288, 21)];
    [self.stepsPerMonthLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 17.0f]];
    [self.stepsEstView addSubview:self.stepsPerMonthLabel];
    
    if (self.stepsPerYearLabel != nil) {
        [self.stepsPerYearLabel removeFromSuperview];
        self.stepsPerYearLabel = nil;
    }
    self.stepsPerYearLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 128, 288, 21)];
    [self.stepsPerYearLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 17.0f]];
    [self.stepsEstView addSubview:self.stepsPerYearLabel];
    
    self.stepsGraphView= [[UIView alloc] initWithFrame: CGRectMake(0, 209, 320, 246)];
    
    UILabel *stepsStatsGraphLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 288, 25)];
    [stepsStatsGraphLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 20.0f]];
    stepsStatsGraphLabel.text = @"Total Steps Over Time Graph";
    [self.stepsGraphView addSubview:stepsStatsGraphLabel];
    
    [self.statisticsView addSubview:self.stepsEstView];
    [self.statisticsView addSubview:self.stepsGraphView];
    
    //Stairs
    if (self.stairsEstView != nil) {
        self.stairsEstView = nil;
        [self.stairsEstView removeFromSuperview];
    }
    if (self.stairsGraphView != nil) {
        self.stairsGraphView = nil;
        [self.stairsGraphView removeFromSuperview];
    }
    self.stairsEstView = [[UIView alloc] initWithFrame:CGRectMake(0, 480, 320, 168)];
    
    UILabel *stairsStatsEstLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 8, 288, 25)];
    [stairsStatsEstLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 20.0f]];
    stairsStatsEstLabel.text = @"Stairs Estimated Average";
    [self.stairsEstView addSubview:stairsStatsEstLabel];
    
    if (self.stairsPerDayLabel != nil) {
        [self.stairsPerDayLabel removeFromSuperview];
        self.stairsPerDayLabel = nil;
    }
    self.stairsPerDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 41, 288, 21)];
    [self.stairsPerDayLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 17.0f]];
    [self.stairsEstView addSubview:self.stairsPerDayLabel];
    
    if (self.stairsPerWeekLabel != nil) {
        [self.stairsPerWeekLabel removeFromSuperview];
        self.stairsPerWeekLabel = nil;
    }
    self.stairsPerWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 70, 288, 21)];
    [self.stairsPerWeekLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 17.0f]];
    [self.stairsEstView addSubview:self.stairsPerWeekLabel];
    
    if (self.stairsPerMonthLabel != nil) {
        [self.stairsPerMonthLabel removeFromSuperview];
        self.stairsPerMonthLabel = nil;
    }
    self.stairsPerMonthLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 99, 288, 21)];
    [self.stairsPerMonthLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 17.0f]];
    [self.stairsEstView addSubview:self.stairsPerMonthLabel];
    
    if (self.stairsPerYearLabel != nil) {
        [self.stairsPerYearLabel removeFromSuperview];
        self.stairsPerYearLabel = nil;
    }
    self.stairsPerYearLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 128, 288, 21)];
    [self.stairsPerYearLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 17.0f]];
    [self.stairsEstView addSubview:self.stairsPerYearLabel];
    
    self.stairsGraphView = [[UIView alloc] initWithFrame:CGRectMake(0, 648, 320, 246)];
    
    UILabel *stairsStatsGraphLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 288, 25)];
    [stairsStatsGraphLabel setFont:[UIFont fontWithName: @".HelveticaNeueInterface-Regular" size: 20.0f]];
    stairsStatsGraphLabel.text = @"Total Stairs Over Time Graph";
    [self.stairsGraphView addSubview:stairsStatsGraphLabel];
    
    [self.statisticsView addSubview:self.stairsEstView];
    [self.statisticsView addSubview:self.stairsGraphView];
}

- (IBAction)abandonButtonAction:(id)sender {
    self.viewGoal.goalStatus = Abandoned;
    self.viewGoal.goalCompletionDate = [NSDate date];
    if (self.testing.getTesting) {
        [self cancelLocalNotification:[NSString stringWithFormat:@"%@startTesting",self.viewGoal.goalName] type:@"start"];
        [self cancelLocalNotification:[NSString stringWithFormat:@"%@endTesting",self.viewGoal.goalName] type:@"end"];
    }
    else {
        [self cancelLocalNotification:[NSString stringWithFormat:@"%@start",self.viewGoal.goalName] type:@"start"];
        [self cancelLocalNotification:[NSString stringWithFormat:@"%@end",self.viewGoal.goalName] type:@"end"];
    }
    [self storeGoalStatusChangeToDB];
    [self loadFromDB];
    [self showDetails];
}

- (void)cancelLocalNotification:(NSString*)notificationID type:(NSString*)typeString {
    //loop through all scheduled notifications and cancel the one we're looking for
    UILocalNotification *cancelThisNotification = nil;
    BOOL hasNotification = NO;
    
    for (UILocalNotification *someNotification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if([[someNotification.userInfo objectForKey:notificationID] isEqualToString:notificationID]) {
            cancelThisNotification = someNotification;
            hasNotification = YES;
            break;
        }
    }
    if (hasNotification == YES) {
        NSLog(@"%@ ",cancelThisNotification);
        [[UIApplication sharedApplication] cancelLocalNotification:cancelThisNotification];
    }
}

- (IBAction)socialMediaAction:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Take Picture?"
                                                        message:@"Would you like to take a picture to send with your post?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    [alertView setTag:99];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99) {
        if( 0 == buttonIndex ){ //no button
            self.socialImage = nil;
            [self shareToSocial];
        } else if ( 1 == buttonIndex ){ //yes button
            [self takePicture];
        }
    }
}

- (void)shareToSocial {
    NSString *baseText = [[NSString alloc] init];
    
    NSString *stepsName = [[NSString alloc] init];
    NSString *stairsName = [[NSString alloc] init];
    NSInteger conversionIndexSteps = 0;
    NSInteger conversionIndexStairs = 0;
    
    NSString *amountText = [[NSString alloc] init];
    NSString *progressText = [[NSString alloc] init];
    NSString *amountTextSteps = [[NSString alloc] init];
    NSString *progressTextSteps = [[NSString alloc] init];
    NSString *amountTextStairs = [[NSString alloc] init];
    NSString *progressTextStairs = [[NSString alloc] init];
    
    if (self.conversion == StepsStairs) {
        stepsName = @"Steps";
        conversionIndexSteps = 0;
        stairsName = @"Stairs";
        conversionIndexStairs = 0;
    }
    else if (self.conversion == Imperial) {
        stepsName = @"Miles";
        conversionIndexSteps = 1;
        stairsName= @"Feet";
        conversionIndexStairs = 3;
    }
    else if (self.conversion == Metric) {
        stepsName = @"Kilometers";
        conversionIndexSteps = 2;
        stairsName = @"Meters";
        conversionIndexStairs = 4;
    }
    
    if (self.viewGoal.goalAmountStairs == 0) { //steps
        progressText = [NSString stringWithFormat:@"%.2f/",(double)(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])];
        amountText = [NSString stringWithFormat:@"%.2f %@",(double)(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue]),stepsName];
    }
    else if (self.viewGoal.goalAmountSteps == 0) { //stairs
        progressText = [NSString stringWithFormat:@"%.2f/",(double)(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])];
        amountText = [NSString stringWithFormat:@"%.2f %@",(double)(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue]),stairsName];
    }
    else { //both
        progressTextSteps = [NSString stringWithFormat:@"%.2f/",(double)(self.viewGoal.goalProgressSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue])];
        amountTextSteps = [NSString stringWithFormat:@"%.2f %@",(double)(self.viewGoal.goalAmountSteps/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexSteps] doubleValue]),stepsName];
        progressTextStairs = [NSString stringWithFormat:@"%.2f/",(double)(self.viewGoal.goalProgressStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue])];
        amountTextStairs = [NSString stringWithFormat:@"%.2f %@",(double)(self.viewGoal.goalAmountStairs/[[self.viewGoal.conversionTable objectAtIndex:conversionIndexStairs] doubleValue]),stairsName];
    }
    
    switch (self.viewGoal.goalStatus) {
        case Pending:
            if (self.viewGoal.goalType == Both) { //both
                baseText = [NSString stringWithFormat:@"Waiting for my goal of %@ and %@ to start #KeepFit",amountTextSteps, amountTextStairs];
            }
            else { //everything else
                baseText = [NSString stringWithFormat:@"Waiting for my goal of %@ to start #KeepFit",amountText];
            }
            break;
        case Active:
            if (self.viewGoal.goalType == Both) { //both
                baseText = [NSString stringWithFormat:@"Progress towards my goal of %@%@ and %@%@ #KeepFit",progressTextSteps,amountTextSteps,progressTextStairs,amountTextStairs];
            }
            else { //everything else
                baseText = [NSString stringWithFormat:@"Progress towards my goal of %@%@ #KeepFit",progressText,amountText];
            }
            break;
        case Overdue:
            if (self.viewGoal.goalType == Both) { //both
                baseText = [NSString stringWithFormat:@"Progress towards my goal %@%@ and %@%@ #KeepFit",progressTextSteps,amountTextSteps,progressTextStairs,amountTextStairs];
            }
            else { //everything else
                baseText = [NSString stringWithFormat:@"Progress towards my goal %@%@ #KeepFit",progressText,amountText];
            }
            break;
        case Suspended:
            if (self.viewGoal.goalType == Both) { //both
                baseText = [NSString stringWithFormat:@"Going to come back to my goal of %@%@ and %@%@ #KeepFit",progressTextSteps,amountTextSteps,progressTextStairs,amountTextStairs];
            }
            else { //everything else
                baseText = [NSString stringWithFormat:@"Going to come back to my goal of %@%@ #KeepFit",progressText,amountText];
            }
            break;
        case Abandoned:
            if (self.viewGoal.goalType == Both) { //both
                baseText = [NSString stringWithFormat:@"Giving up on my goal of %@%@ and %@%@ #KeepFit",progressTextSteps,amountTextSteps,progressTextStairs,amountTextStairs];
            }
            else { //everything else
                baseText = [NSString stringWithFormat:@"Giving up on my goal of %@%@ #KeepFit",progressText,amountText];
            }
            break;
        case Completed:
            if (self.viewGoal.goalType == Both) { //both
                baseText = [NSString stringWithFormat:@"Completed my goal of %@ and %@ #KeepFit",amountTextSteps,amountTextStairs];
            }
            else { //everything else
                baseText = [NSString stringWithFormat:@"Completed my goal of %@ #KeepFit",amountText];
            }
            break;
        default:
            break;
    }
    
    NSArray *itemsToShare = @[baseText];
    if (self.socialImage != nil) {
        itemsToShare = @[baseText,self.socialImage];
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeAddToReadingList];
    if (self.socialImage != nil) {
        activityViewController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard, UIActivityTypePostToVimeo, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeMail, UIActivityTypeMessage, UIActivityTypePrint, UIActivityTypeAddToReadingList];
    }
    [self presentViewController:activityViewController animated:YES completion:nil];
    
}

- (void)takePicture {
    if (self.socialImagePicker != nil) {
        self.socialImagePicker = nil;
    }
    self.socialImagePicker = [[UIImagePickerController alloc] init];
    self.socialImagePicker.delegate = self;
    [self.socialImagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:self.socialImagePicker animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.socialImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImageWriteToSavedPhotosAlbum(self.socialImage, nil, nil, nil);
    [self shareToSocial];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.socialImage = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)ConversionAction:(id)sender {
    self.conversion = self.conversionSelector.selectedSegmentIndex;
    [self showDetails];
}

#pragma mark - Image Masking

- (UIImage *)imageWithColor:(UIColor *)color andX:(float)x andY:(float)y andSize:(CGSize)size
{
    CGRect rect = CGRectMake(x, y, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end