//
//  HistoryTableViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 20/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "DBManager.h"
#import "GoalHistory.h"

@interface HistoryTableViewController ()

@property NSMutableArray *historyGoals; // Array to store the history objects.
@property (nonatomic, strong) DBManager *dbManager; // Database manager object.
@property (nonatomic, strong) NSArray *arrDBResults; // Array to store select query results for the DB.

@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the navigation bar title.
    self.navigationItem.title = [NSString stringWithFormat:@"History of %@", self.viewHistoryGoal.goalName];
    
    // Initialise the database manager.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    // Load history data from the database.
    [self loadFromDB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Method to load history data from the database.
-(void)loadFromDB {
    NSLog(@"LOAD FROM DB");
    // Re-initalise the array for storing the history.
    if (self.historyGoals != nil) {
        self.historyGoals = nil;
    }
    self.historyGoals = [[NSMutableArray alloc] init];
    
    // Form the DB query.
    NSString *query;
    query = [NSString stringWithFormat:@"select * from %@ where goalId='%ld'", self.testing.getHistoryDBName, (long)self.viewHistoryGoal.goalID];
    
    // Re-initalise the array for storing the query results.
    if (self.arrDBResults != nil) {
        self.arrDBResults = nil;
    }
    self.arrDBResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Set up indexes for getting column results for the rows in the database.
    NSInteger indexOfHistoryID = [self.dbManager.arrColumnNames indexOfObject:@"historyID"];
    NSInteger indexOfGoalID = [self.dbManager.arrColumnNames indexOfObject:@"goalID"];
    NSInteger indexOfGoalStatus = [self.dbManager.arrColumnNames indexOfObject:@"goalStatus"];
    NSInteger indexOfStatusStartDate = [self.dbManager.arrColumnNames indexOfObject:@"statusStartDate"];
    NSInteger indexOfStatusEndDate = [self.dbManager.arrColumnNames indexOfObject:@"statusEndDate"];
    NSInteger indexOfGoalProgressSteps = [self.dbManager.arrColumnNames indexOfObject:@"progressSteps"];
    NSInteger indexOfGoalProgressStairs = [self.dbManager.arrColumnNames indexOfObject:@"progressStairs"];
    NSLog(@"arrDBResults: %@", self.arrDBResults);
    
    // Set up the history object with data from the rows returned by the query.
    for (int i=0; i<[self.arrDBResults count]; i++) {
        GoalHistory *history;
        history = [[GoalHistory alloc] init];
        history.historyID = (NSInteger)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfHistoryID] intValue];
        history.goalID = (NSInteger)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalID] intValue];
        history.goalStatus = (NSInteger)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalStatus] intValue];
        history.startDate = [NSDate dateWithTimeIntervalSince1970:[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfStatusStartDate] doubleValue]];
        history.endDate = [NSDate dateWithTimeIntervalSince1970:[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfStatusEndDate] doubleValue]];
        history.progressSteps = [[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalProgressSteps] intValue];
        history.progressStairs = [[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalProgressStairs] intValue];
        
        // Add object to the array of history objects.
        [self.historyGoals addObject:history];
    }
    
    NSLog(@"%@", self.arrDBResults);
    
    // Reload the table view.
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.historyGoals count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListProtoHistory" forIndexPath:indexPath];
    
    // Configure the cell...
    GoalHistory *history = [self.historyGoals objectAtIndex:indexPath.row];
    
    // Set up cell text size format.
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    
    // Set up the text and detialed text for the cell depending on the status of the goal and if any progress was made.
    switch (history.goalStatus) {
        case Pending:
            cell.textLabel.text = @"Pending";
            break;
        case Active:
            if ((history.progressSteps != 0) || (history.progressStairs != 0)) {
                if (self.viewHistoryGoal.goalConversion == StepsStairs) {
                    cell.textLabel.text = [NSString stringWithFormat:@"Recording - Steps: %d Stairs: %d", history.progressSteps, history.progressStairs];
                }
                else if (self.viewHistoryGoal.goalConversion == Imperial) {
                    cell.textLabel.text = [NSString stringWithFormat:@"Recording - Miles: %.2f Feet: %.2f", (double)(history.progressSteps/[[self.viewHistoryGoal.conversionTable objectAtIndex:1] doubleValue]), (double)(history.progressStairs/[[self.viewHistoryGoal.conversionTable objectAtIndex:3] doubleValue])];
                }
                else if (self.viewHistoryGoal.goalConversion == Metric) {
                    cell.textLabel.text = [NSString stringWithFormat:@"Recording - Kilometers: %.2f Meters: %.2f", (double)(history.progressSteps/[[self.viewHistoryGoal.conversionTable objectAtIndex:2] doubleValue]), (double)(history.progressStairs/[[self.viewHistoryGoal.conversionTable objectAtIndex:4] doubleValue])];
                }
            }
            else {
                cell.textLabel.text = [NSString stringWithFormat:@"Active"];
            }
            break;
        case Suspended:
            cell.textLabel.text = @"Suspended";
            break;
        case Overdue:
            if ((history.progressSteps != 0) || (history.progressStairs != 0)) {
                if (self.viewHistoryGoal.goalConversion == StepsStairs) {
                    cell.textLabel.text = [NSString stringWithFormat:@"Recording - Steps: %d Stairs: %d", history.progressSteps, history.progressStairs];
                }
                else if (self.viewHistoryGoal.goalConversion == Imperial) {
                    cell.textLabel.text = [NSString stringWithFormat:@"Recording - Miles: %.2f Feet: %.2f", (double)(history.progressSteps/[[self.viewHistoryGoal.conversionTable objectAtIndex:1] doubleValue]), (double)(history.progressStairs/[[self.viewHistoryGoal.conversionTable objectAtIndex:3] doubleValue])];
                }
                else if (self.viewHistoryGoal.goalConversion == Metric) {
                    cell.textLabel.text = [NSString stringWithFormat:@"Recording - Kilometers: %.2f Meters: %.2f", (double)(history.progressSteps/[[self.viewHistoryGoal.conversionTable objectAtIndex:2] doubleValue]), (double)(history.progressStairs/[[self.viewHistoryGoal.conversionTable objectAtIndex:4] doubleValue])];
                }
            }
            else {
                cell.textLabel.text = [NSString stringWithFormat:@"Overdue"];
            }
            break;
        case Abandoned:
            cell.textLabel.text = @"Abandoned";
            break;
        case Completed:
            cell.textLabel.text = [NSString stringWithFormat:@"Completed - On: %@", history.startDate];
            break;
        default:
            break;
    }
    // Set up the date formatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    if ([[history.endDate earlierDate:history.startDate]isEqualToDate: history.endDate]) {
        // If the end date is 1 Jan 1970, ie is the last history item for goal, don't display the end date.
        cell.detailTextLabel.text = [NSString stringWithFormat:@"From: %@", [formatter stringFromDate:history.startDate]];
    }
    else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"From: %@ To: %@", [formatter stringFromDate:history.startDate], [formatter stringFromDate:history.endDate]];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return the height for the cell.
    return 60.0;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
