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

@property NSMutableArray *historyGoals;
@property (nonatomic, strong) DBManager *dbManager;

@property (nonatomic, strong) NSArray *arrDBResults;

@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = [NSString stringWithFormat:@"History of %@", self.viewHistoryGoal.goalName];
    
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    [self loadFromDB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadFromDB {    
    if (self.historyGoals != nil) {
        self.historyGoals = nil;
    }
    self.historyGoals = [[NSMutableArray alloc] init];
    
    // Form the query.
    NSString *query;
    query = [NSString stringWithFormat:@"select * from history where goalId='%ld'", (long)self.viewHistoryGoal.goalID];
    
    // Get the results.
    if (self.arrDBResults != nil) {
        self.arrDBResults = nil;
    }
    self.arrDBResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSInteger indexOfHistoryID = [self.dbManager.arrColumnNames indexOfObject:@"historyID"];
    NSInteger indexOfGoalID = [self.dbManager.arrColumnNames indexOfObject:@"goalID"];
    NSInteger indexOfGoalStatus = [self.dbManager.arrColumnNames indexOfObject:@"goalStatus"];
    NSInteger indexOfStatusStartDate = [self.dbManager.arrColumnNames indexOfObject:@"statusStartDate"];
    NSInteger indexOfStatusEndDate = [self.dbManager.arrColumnNames indexOfObject:@"statusEndDate"];
    NSInteger indexOfGoalProgressSteps = [self.dbManager.arrColumnNames indexOfObject:@"progressSteps"];
    NSInteger indexOfGoalProgressStairs = [self.dbManager.arrColumnNames indexOfObject:@"progressStairs"];
    NSLog(@"arrDBResults: %@", self.arrDBResults);
    
    for (int i=0; i<[self.arrDBResults count]; i++) {
        //NSLog(@"Goal Name %d: %@", i,[NSString stringWithFormat:@"%@", [[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalName]]);
        
        GoalHistory *history;
        history = [[GoalHistory alloc] init];
        history.historyID = (NSInteger)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfHistoryID] intValue];
        history.goalID = (NSInteger)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalID] intValue];
        history.goalStatus = (NSInteger)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalStatus] intValue];
        history.startDate = [NSDate dateWithTimeIntervalSince1970:[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfStatusStartDate] doubleValue]];
        history.endDate = [NSDate dateWithTimeIntervalSince1970:[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfStatusEndDate] doubleValue]];
        history.progressSteps = (long)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalProgressSteps] intValue];
        history.progressStairs = (long)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalProgressStairs] intValue];
        
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
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    
    switch (history.goalStatus) {
        case Pending:
            cell.textLabel.text = @"Pending";
            break;
        case Active:
            if ((history.progressSteps != 0) || (history.progressStairs != 0)) {
                cell.textLabel.text = [NSString stringWithFormat:@"Recording - Steps: %d Staris: %d", history.progressSteps, history.progressStairs];
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
                cell.textLabel.text = [NSString stringWithFormat:@"Recording - Steps: %d Staris: %d", history.progressSteps, history.progressStairs];
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
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    if ([[history.endDate earlierDate:history.startDate]isEqualToDate: history.endDate]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"From: %@", [formatter stringFromDate:history.startDate]];
    }
    else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"From: %@ To: %@", [formatter stringFromDate:history.startDate], [formatter stringFromDate:history.endDate]];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
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
