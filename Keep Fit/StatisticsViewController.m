//
//  StatisticsViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 08/03/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "StatisticsViewController.h"
#import "DBManager.h"
#import "ActivityHistoryTableViewController.h"
#import "MainTabBarViewController.h"
#import "PNChart.h"

@interface StatisticsViewController ()

@property (nonatomic, strong) DBManager *dbManager;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayStairsLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekStairsLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthStairsLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearStairsLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *stepsGraphView;
@property (weak, nonatomic) IBOutlet UIView *stairsGraphView;

@property NSInteger totalSteps;
@property NSInteger totalStairs;
@property double startDate;
@property double endDate;
@property NSMutableArray *stepsValues;
@property NSMutableArray *stairsValues;
@property NSMutableArray *graphTimes;

@property MainTabBarViewController *mainTabBarController;
@property NSDateFormatter *formatter;

@end

@implementation StatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 1000)];
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    self.mainTabBarController = (MainTabBarViewController *)self.tabBarController;
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"MMM dd"];
    
    [self loadFromDB];
    [self setUpView];
}

-(void)viewWillAppear:(BOOL)animated {
    [self loadFromDB];
    [self setUpView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadFromDB {
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
    
    NSString *query = [NSString stringWithFormat:@"select * from %@", self.mainTabBarController.testing.getMainpageStatsDBName/*, [self.mainTabBarController.testing.getTime timeIntervalSince1970]*/];
    
    NSArray *statResults;
    statResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    if ([statResults count] > 0) {
        NSInteger indexOfStartDate = [self.dbManager.arrColumnNames indexOfObject:@"startTime"];
        NSInteger indexOfEndDate = [self.dbManager.arrColumnNames indexOfObject:@"endTime"];
        NSInteger indexOfSteps = [self.dbManager.arrColumnNames indexOfObject:@"steps"];
        NSInteger indexOfStairs = [self.dbManager.arrColumnNames indexOfObject:@"stairs"];
        
        self.startDate = [[[statResults objectAtIndex:0] objectAtIndex:indexOfStartDate] doubleValue];
        self.endDate = [self.mainTabBarController.testing.getTime timeIntervalSince1970];
        
        [self.stepsValues addObject:[NSNumber numberWithDouble:0]];
        [self.stairsValues addObject:[NSNumber numberWithDouble:0]];
        [self.graphTimes addObject:[[statResults objectAtIndex:0] objectAtIndex:indexOfStartDate]];
        
        for (int i=0; i<[statResults count]; i++) {
            self.totalSteps += [[[statResults objectAtIndex:i] objectAtIndex:indexOfSteps] intValue];
            self.totalStairs += [[[statResults objectAtIndex:i] objectAtIndex:indexOfStairs] intValue];
            [self.stepsValues addObject:[NSNumber numberWithDouble:self.totalSteps]];
            [self.stairsValues addObject:[NSNumber numberWithDouble:self.totalStairs]];
            [self.graphTimes addObject:[NSNumber numberWithDouble:[[[statResults objectAtIndex:i] objectAtIndex:indexOfEndDate] doubleValue]]];
        }
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
        [self.graphTimes addObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]];
    }
    
    NSLog(@"%@",statResults);
}

-(void)setUpView {
    double day = 86400.0;
    double week = 604800.0;
    double month = 2630000.0;
    double year = 31560000.0;
    
    double period = (self.endDate - self.startDate);
    if (period == 0.0) {
        period = 1.0;
    }
    NSLog(@"%@",[NSDate dateWithTimeIntervalSince1970:period]);
    
    double dayStepsAverage = (day/period)*self.totalSteps;
    double weekStepsAverage = (week/period)*self.totalSteps;
    double monthStepsAverage = (month/period)*self.totalSteps;
    double yearStepsAverage = (year/period)*self.totalSteps;
    
    double dayStairsAverage = (day/period)*self.totalStairs;
    double weekStairsAverage = (week/period)*self.totalStairs;
    double monthStairsAverage = (month/period)*self.totalStairs;
    double yearStairsAverage = (year/period)*self.totalStairs;
    
    
    self.dayLabel.text = [NSString stringWithFormat:@"per Day: %.2f",dayStepsAverage];
    self.weekLabel.text = [NSString stringWithFormat:@"per Week: %.2f",weekStepsAverage];
    self.monthLabel.text = [NSString stringWithFormat:@"per Month: %.2f",monthStepsAverage];
    self.yearLabel.text = [NSString stringWithFormat:@"per Year: %.2f",yearStepsAverage];
    
    self.dayStairsLabel.text = [NSString stringWithFormat:@"per Day: %.2f",dayStairsAverage];
    self.weekStairsLabel.text = [NSString stringWithFormat:@"per Week: %.2f",weekStairsAverage];
    self.monthStairsLabel.text = [NSString stringWithFormat:@"per Month: %.2f",monthStairsAverage];
    self.yearStairsLabel.text = [NSString stringWithFormat:@"per Year: %.2f",yearStairsAverage];
    
    [self makeGraphs];
}

-(void) makeGraphs {
    //For Line Chart
    NSMutableArray *stepsStairsLabels = [[NSMutableArray alloc] init];
    
    if ([self.stepsValues count] > 6) {
        [stepsStairsLabels addObject:[NSString stringWithFormat:@"%@",[self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[self.graphTimes objectAtIndex:0] doubleValue]]]]];
        [stepsStairsLabels addObject:[NSString stringWithFormat:@""]];
        [stepsStairsLabels addObject:[NSString stringWithFormat:@""]];
        [stepsStairsLabels addObject:[NSString stringWithFormat:@""]];
        [stepsStairsLabels addObject:[NSString stringWithFormat:@""]];
        [stepsStairsLabels addObject:[NSString stringWithFormat:@"%@",[self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[self.graphTimes lastObject] doubleValue]]]]];
    }
    else {
        [stepsStairsLabels addObject:[NSString stringWithFormat:@"%@",[self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[self.graphTimes objectAtIndex:0] doubleValue]]]]];
        for (int i=0; i<([self.stepsValues count]-1); i++) {
            [stepsStairsLabels addObject:[NSString stringWithFormat:@""]];
        }
        [stepsStairsLabels addObject:[NSString stringWithFormat:@"%@",[self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[self.graphTimes lastObject] doubleValue]]]]];
    }
    
    
    //Steps Graph
    PNLineChart *stepsLineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.stepsGraphView.bounds), CGRectGetHeight(self.stepsGraphView.bounds))];
    
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
    
    
    //Stairs Graph
    PNLineChart *stairsLineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.stairsGraphView.bounds), CGRectGetHeight(self.stairsGraphView.bounds))];
    
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"activityHistory"]) {
        ActivityHistoryTableViewController *destViewController = segue.destinationViewController;
        destViewController.testing = self.mainTabBarController.testing;
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}

@end
