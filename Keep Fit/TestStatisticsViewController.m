//
//  TestStatisticsViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 02/03/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "TestStatisticsViewController.h"
#import "DBManager.h"

@interface TestStatisticsViewController ()

@property (nonatomic, strong) DBManager *dbManager;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayStairsLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekStairsLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthStairsLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearStairsLabel;

@property NSInteger totalSteps;
@property NSInteger totalStairs;
@property double startDate;
@property double endDate;

@end

@implementation TestStatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    [self loadFromDB];
    [self SetUpView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadFromDB {
    NSDate *currentDate = [[NSDate alloc] init];
    NSString *dateQuery = @"select * from testDate";
    
    NSArray *currentDateResults;
    currentDateResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:dateQuery]];
    
    if (currentDateResults.count == 0) {
        currentDate = [NSDate date];
        
        dateQuery = [NSString stringWithFormat:@"insert into testDate values(%f)", [[NSDate date] timeIntervalSince1970]];
        // Execute the query.
        [self.dbManager executeQuery:dateQuery];
        
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        }
        else {
            NSLog(@"Could not execute the query.");
        }
    }
    else {
        NSInteger indexOfCurrentDateID = [self.dbManager.arrColumnNames indexOfObject:@"currentTime"];
        currentDate = [NSDate dateWithTimeIntervalSince1970:[[[currentDateResults objectAtIndex:0] objectAtIndex:indexOfCurrentDateID] doubleValue]];
        NSLog(@"Current Time Double From DB: %f",[[[currentDateResults objectAtIndex:0] objectAtIndex:indexOfCurrentDateID] doubleValue]);
        NSLog(@"Current Time From DB: %@",currentDate);
        
    }
    
    self.totalSteps = 0;
    self.totalStairs = 0;
    self.startDate = 1.0;
    self.endDate = 1.0;
    
    NSString *query = [NSString stringWithFormat:@"select * from testStatistics where endTime < '%f'",[currentDate timeIntervalSince1970]];
    
    NSArray *statResults;
    statResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    if ([statResults count] > 0) {
        NSInteger indexOfStartDate = [self.dbManager.arrColumnNames indexOfObject:@"startTime"];
        NSInteger indexOfSteps = [self.dbManager.arrColumnNames indexOfObject:@"steps"];
        NSInteger indexOfStairs = [self.dbManager.arrColumnNames indexOfObject:@"stairs"];
        
        self.startDate = [[[statResults objectAtIndex:0] objectAtIndex:indexOfStartDate] doubleValue];
        self.endDate = [currentDate timeIntervalSince1970];
        
        for (int i=0; i<[statResults count]; i++) {
            self.totalSteps += [[[statResults objectAtIndex:i] objectAtIndex:indexOfSteps] intValue];
            self.totalStairs += [[[statResults objectAtIndex:i] objectAtIndex:indexOfStairs] intValue];
        }
    }
}

-(void)SetUpView {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
