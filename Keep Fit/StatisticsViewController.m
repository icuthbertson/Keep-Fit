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
@property (weak, nonatomic) IBOutlet UILabel *totalStepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalStairsLabel;

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
    
    NSMutableArray *totalStepsValues = [[NSMutableArray alloc] init];
    NSMutableArray *totalStairsValues = [[NSMutableArray alloc] init];
    NSMutableArray *tempDates = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"select * from %@", self.mainTabBarController.testing.getMainpageStatsDBName/*, [self.mainTabBarController.testing.getTime timeIntervalSince1970]*/];
    
    NSArray *statResults;
    statResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSLog(@"%@",statResults);
    
    if ([statResults count] > 0) {
        NSInteger indexOfStartDate = [self.dbManager.arrColumnNames indexOfObject:@"startTime"];
        NSInteger indexOfEndDate = [self.dbManager.arrColumnNames indexOfObject:@"endTime"];
        NSInteger indexOfSteps = [self.dbManager.arrColumnNames indexOfObject:@"steps"];
        NSInteger indexOfStairs = [self.dbManager.arrColumnNames indexOfObject:@"stairs"];
        
        self.startDate = [[[statResults objectAtIndex:0] objectAtIndex:indexOfStartDate] doubleValue];
        self.endDate = [self.mainTabBarController.testing.getTime timeIntervalSince1970];

        //[self.graphTimes addObject:[[statResults objectAtIndex:0] objectAtIndex:indexOfStartDate]];
        
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
        [self.graphTimes addObject:[NSNumber numberWithDouble:[self.mainTabBarController.testing.getTime timeIntervalSince1970]]];
        [self.graphTimes addObject:[NSNumber numberWithDouble:[self.mainTabBarController.testing.getTime timeIntervalSince1970]]];
        [self.graphTimes addObject:[NSNumber numberWithDouble:[self.mainTabBarController.testing.getTime timeIntervalSince1970]]];
        [self.graphTimes addObject:[NSNumber numberWithDouble:[self.mainTabBarController.testing.getTime timeIntervalSince1970]]];
        [self.graphTimes addObject:[NSNumber numberWithDouble:[self.mainTabBarController.testing.getTime timeIntervalSince1970]]];
        [self.graphTimes addObject:[NSNumber numberWithDouble:[self.mainTabBarController.testing.getTime timeIntervalSince1970]]];
        [self.graphTimes addObject:[NSNumber numberWithDouble:[self.mainTabBarController.testing.getTime timeIntervalSince1970]]];
    }
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
    NSNumberFormatter *twoDecimalPlaces = [[NSNumberFormatter alloc] init];
    [twoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
    [twoDecimalPlaces setMaximumFractionDigits:2];
    
    double dayStepsAverage = (day/period)*self.totalSteps;
    double weekStepsAverage = (week/period)*self.totalSteps;
    double monthStepsAverage = (month/period)*self.totalSteps;
    double yearStepsAverage = (year/period)*self.totalSteps;
    
    double dayStairsAverage = (day/period)*self.totalStairs;
    double weekStairsAverage = (week/period)*self.totalStairs;
    double monthStairsAverage = (month/period)*self.totalStairs;
    double yearStairsAverage = (year/period)*self.totalStairs;
    
    
    self.dayLabel.text = [NSString stringWithFormat:@"per Day: %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:dayStepsAverage]]];
    self.weekLabel.text = [NSString stringWithFormat:@"per Week: %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:weekStepsAverage]]];
    self.monthLabel.text = [NSString stringWithFormat:@"per Month: %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:monthStepsAverage]]];
    self.yearLabel.text = [NSString stringWithFormat:@"per Year: %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:yearStepsAverage]]];
    self.totalStepsLabel.text = [NSString stringWithFormat:@"Total Steps: %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:self.totalSteps]]];
    
    self.dayStairsLabel.text = [NSString stringWithFormat:@"per Day: %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:dayStairsAverage]]];
    self.weekStairsLabel.text = [NSString stringWithFormat:@"per Week: %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:weekStairsAverage]]];
    self.monthStairsLabel.text = [NSString stringWithFormat:@"per Month: %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:monthStairsAverage]]];
    self.yearStairsLabel.text = [NSString stringWithFormat:@"per Year: %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:yearStairsAverage]]];
    self.totalStairsLabel.text = [NSString stringWithFormat:@"Total Stairs: %@",[twoDecimalPlaces stringFromNumber:[NSNumber numberWithDouble:self.totalStairs]]];
    
    [self makeGraphs];
}

-(void) makeGraphs {
    //For Line Chart
    NSMutableArray *stepsStairsLabels = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[self.stepsValues count]; i++) {
        [stepsStairsLabels addObject:[NSString stringWithFormat:@"%@",[self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[self.graphTimes objectAtIndex:i] doubleValue]]]]];
    }
    
    //Steps Graph
    PNLineChart *stepsLineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.stepsGraphView.bounds), CGRectGetHeight(self.stepsGraphView.bounds))];
    
    [stepsLineChart setXLabels:stepsStairsLabels];
    stepsLineChart.showCoordinateAxis = YES;
    
    PNLineChartData *dataSteps = [PNLineChartData new];
    dataSteps.color = PNTwitterColor;
    dataSteps.itemCount = [self.stepsValues count];
    dataSteps.inflexionPointStyle = PNScatterChartPointStyleCircle;
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
    stairsLineChart.showCoordinateAxis = YES;
    
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
