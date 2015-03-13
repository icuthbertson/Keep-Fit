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

@property NSInteger totalSteps;
@property NSInteger totalStairs;
@property double startDate;
@property double endDate;

@property MainTabBarViewController *mainTabBarController;

@end

@implementation StatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 568)];
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    self.mainTabBarController = (MainTabBarViewController *)self.tabBarController;
    
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
    
    NSString *query = [NSString stringWithFormat:@"select * from %@", self.mainTabBarController.testing.getMainpageStatsDBName/*, [self.mainTabBarController.testing.getTime timeIntervalSince1970]*/];
    
    NSArray *statResults;
    statResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    if ([statResults count] > 0) {
        NSInteger indexOfStartDate = [self.dbManager.arrColumnNames indexOfObject:@"startTime"];
        NSInteger indexOfSteps = [self.dbManager.arrColumnNames indexOfObject:@"steps"];
        NSInteger indexOfStairs = [self.dbManager.arrColumnNames indexOfObject:@"stairs"];
        
        self.startDate = [[[statResults objectAtIndex:0] objectAtIndex:indexOfStartDate] doubleValue];
        self.endDate = [self.mainTabBarController.testing.getTime timeIntervalSince1970];
        
        for (int i=0; i<[statResults count]; i++) {
            self.totalSteps += [[[statResults objectAtIndex:i] objectAtIndex:indexOfSteps] intValue];
            self.totalStairs += [[[statResults objectAtIndex:i] objectAtIndex:indexOfStairs] intValue];
        }
    }
    
    NSLog(@"%@",statResults);
}

-(void)setUpView {
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
    
    
    self.dayLabel.text = [NSString stringWithFormat:@"per Day: %f",dayStepsAverage];
    self.weekLabel.text = [NSString stringWithFormat:@"per Week: %f",weekStepsAverage];
    self.monthLabel.text = [NSString stringWithFormat:@"per Month: %f",monthStepsAverage];
    self.yearLabel.text = [NSString stringWithFormat:@"per Year: %f",yearStepsAverage];
    
    self.dayStairsLabel.text = [NSString stringWithFormat:@"per Day: %f",dayStairsAverage];
    self.weekStairsLabel.text = [NSString stringWithFormat:@"per Week: %f",weekStairsAverage];
    self.monthStairsLabel.text = [NSString stringWithFormat:@"per Month: %f",monthStairsAverage];
    self.yearStairsLabel.text = [NSString stringWithFormat:@"per Year: %f",yearStairsAverage];
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
