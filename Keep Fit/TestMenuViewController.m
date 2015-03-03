//
//  TestMenuViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 02/03/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "TestMenuViewController.h"
#import "TestGoalListTableViewController.h"
#import "ChangeTimeViewController.h"
#import "Schedule.h"
#import "ScheduleViewController.h"
#import "DBManager.h"

@interface TestMenuViewController ()

@property (nonatomic, strong) DBManager *dbManager;
@property NSDate *currentDate;

@end

@implementation TestMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    [self loadFromDB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadFromDB {
    self.currentDate = [[NSDate alloc] init];
    NSString *dateQuery = @"select * from testDate";
    
    NSArray *currentDateResults;
    currentDateResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:dateQuery]];
    
    if (currentDateResults.count == 0) {
        self.currentDate = [NSDate date];
        
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
        self.currentDate = [NSDate dateWithTimeIntervalSince1970:[[[currentDateResults objectAtIndex:0] objectAtIndex:indexOfCurrentDateID] doubleValue]];
        NSLog(@"Current Time Double From DB: %f",[[[currentDateResults objectAtIndex:0] objectAtIndex:indexOfCurrentDateID] doubleValue]);
        NSLog(@"Current Time From DB: %@",self.currentDate);
        
    }
    
}

-(IBAction)unwindFromScheduleActivityTest:(UIStoryboardSegue *)segue {
    ScheduleViewController *source = [segue sourceViewController];
    [self storeGoalStatisticsToDB:source.schedule];
}

-(IBAction)unwindFromChangeTimeActivityTest:(UIStoryboardSegue *)segue {
    ChangeTimeViewController *source = [segue sourceViewController];
    // Update the persisted time in the database.
    NSString *dateQuery = [NSString stringWithFormat:@"update testDate set currentTime='%f'",[source.changeDate timeIntervalSince1970]];
    
    // Execute the query.
    [self.dbManager executeQuery:dateQuery];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"testingMode"]) {
        TestGoalListTableViewController *destViewController = segue.destinationViewController;
        // Pass the goal to be veiewed.
        destViewController.settings = self.settings;
    }
    else if ([segue.identifier isEqualToString:@"changeTimeActivity"]) {
        ChangeTimeViewController *destViewController = segue.destinationViewController;
        destViewController.currentTime = self.currentDate;
    }
    else if ([segue.identifier isEqualToString:@"scheduleActivity"]) {
        ScheduleViewController *destViewController = segue.destinationViewController;
        destViewController.currentTime = self.currentDate;
        destViewController.scheduleGoal = NO;
    }
}

-(void) storeGoalStatisticsToDB:(Schedule*) schedule {
    NSString *query;
    
    query = [NSString stringWithFormat:@"insert into testStatistics values(null, '%f', '%f', '%d', '%d')", [schedule.date timeIntervalSince1970], [schedule.endDate timeIntervalSince1970], schedule.numSteps, schedule.numStairs];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
}


@end
