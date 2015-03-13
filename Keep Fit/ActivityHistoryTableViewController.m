//
//  ActivityHistoryTableViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 03/03/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "ActivityHistoryTableViewController.h"
#import "Schedule.h"
#import "DBManager.h"

@interface ActivityHistoryTableViewController ()

@property (nonatomic, strong) DBManager *dbManager;
@property NSMutableArray *activityHistory;

@end

@implementation ActivityHistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    [self loadFromDB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadFromDB {
    self.activityHistory = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"select * from %@", self.testing.getMainpageStatsDBName/*, [self.testing.getTime timeIntervalSince1970]*/];
    
    NSArray *statResults;
    statResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    if ([statResults count] > 0) {
        NSInteger indexOfStartDate = [self.dbManager.arrColumnNames indexOfObject:@"startTime"];
        NSInteger indexOfEndDate = [self.dbManager.arrColumnNames indexOfObject:@"endTime"];
        NSInteger indexOfSteps = [self.dbManager.arrColumnNames indexOfObject:@"steps"];
        NSInteger indexOfStairs = [self.dbManager.arrColumnNames indexOfObject:@"stairs"];
        for (int i=0; i<[statResults count]; i++) {
            Schedule *temp = [[Schedule alloc] init];
            
            temp.numSteps = (NSInteger)[[[statResults objectAtIndex:i] objectAtIndex:indexOfSteps ] intValue];
            temp.numStairs = (NSInteger)[[[statResults objectAtIndex:i] objectAtIndex:indexOfStairs ] intValue];
            temp.date = [NSDate dateWithTimeIntervalSince1970:[[[statResults objectAtIndex:i] objectAtIndex:indexOfStartDate] doubleValue]];
            temp.endDate = [NSDate dateWithTimeIntervalSince1970:[[[statResults objectAtIndex:i] objectAtIndex:indexOfEndDate] doubleValue]];
            
            [self.activityHistory addObject:temp];
        }
    }

}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"activityHistory" forIndexPath:indexPath];
    
    // Configure the cell...
    Schedule *activity = [self.activityHistory objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Activity - Steps: %d Staris: %d", activity.numSteps, activity.numStairs];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"From: %@ To: %@", [formatter stringFromDate:activity.date], [formatter stringFromDate:activity.endDate]];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.activityHistory count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
