//
//  GoalListTableViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 09/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "GoalListTableViewController.h"
#import "AddGoalViewController.h"
#import "DBManager.h"
#import "ViewGoalViewController.h"
#import "KeepFitGoal.h"

@interface GoalListTableViewController ()

@property NSMutableArray *keepFitGoals;
@property (nonatomic, strong) DBManager *dbManager;

@property (nonatomic, strong) NSArray *arrDBResults;

@end

@implementation GoalListTableViewController

-(IBAction)unwindToList:(UIStoryboardSegue *)segue {
    AddGoalViewController *source = [segue sourceViewController];
    KeepFitGoal *goal = source.goal;
    if (goal != nil) {
        NSString *query;
        query = [NSString stringWithFormat:@"insert into goals values(null, '%@')", goal.goalName];
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        }
        else {
            NSLog(@"Could not execute the query.");
        }
        
        [self.keepFitGoals addObject:goal];
        [self.tableView reloadData];
    }
}

-(IBAction)unwindFromView:(UIStoryboardSegue *)segue {
    [self.tableView reloadData];
}

-(void)loadFromDB {
    /*// Form the query.
    NSString *query = @"select * from goals";
    
    // Get the results.
    if (self.keepFitGoals != nil) {
        self.keepFitGoals = nil;
    }
    NSMutableArray *data = [[NSMutableArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSInteger indexOfGoalName = [self.dbManager.arrColumnNames indexOfObject:@"goalName"];
    
    for (int i=0; i<[data count]; i++) {
        KeepFitGoal *goal;
        goal.goalName = [NSString stringWithFormat:@"%@", [[data objectAtIndex:i] objectAtIndex:indexOfGoalName]];
        goal.completed = NO;
        [self.keepFitGoals addObject:goal];
    }
    
    // Reload the table view.
    [self.tableView reloadData];*/
    
    if (self.keepFitGoals != nil) {
        self.keepFitGoals = nil;
    }
    self.keepFitGoals = [[NSMutableArray alloc] init];
    
    // Form the query.
    NSString *query = @"select * from goals";
    
    // Get the results.
    if (self.arrDBResults != nil) {
        self.arrDBResults = nil;
    }
    self.arrDBResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSInteger indexOfGoalID = [self.dbManager.arrColumnNames indexOfObject:@"goalID"];
    NSInteger indexOfGoalName = [self.dbManager.arrColumnNames indexOfObject:@"goalName"];
    
    //NSLog(@"arrDBResults: %@", self.arrDBResults);
    
    for (int i=0; i<[self.arrDBResults count]; i++) {
        //NSLog(@"Goal Name %d: %@", i,[NSString stringWithFormat:@"%@", [[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalName]]);
        
        KeepFitGoal *goal;
        goal = [[KeepFitGoal alloc] init];
        goal.goalID = (NSInteger)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalID] intValue];
        goal.goalName = [NSString stringWithFormat:@"%@", [[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalName]];
        goal.completed = NO;
        [self.keepFitGoals addObject:goal];
    }
    
    //NSLog(@"%@", self.arrDBResults);
    
    // Reload the table view.
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Goals";
    
    if (self.keepFitGoals != nil) {
        self.keepFitGoals = nil;
    }
    self.keepFitGoals = [[NSMutableArray alloc] init];
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    [self loadFromDB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.keepFitGoals count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    KeepFitGoal *goal = [self.keepFitGoals objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.text = goal.goalName;
    if (goal.completed) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
    
    /*NSInteger indexOfGoalName = [self.dbManager.arrColumnNames indexOfObject:@"goalName"];
    
    // Set the loaded data to the appropriate cell labels.
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[self.arrDBResults objectAtIndex:indexPath.row] objectAtIndex:indexOfGoalName]];
    
    return cell;*/
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the selected record.
        
        //NSLog(@"index of goal: %ld", (long)indexOfGoalID);
        //NSLog(@"index of goal: %ld", (long)indexPath.row);
        NSInteger objectIndex = indexPath.row;
        
        KeepFitGoal *goal;
        goal = [[KeepFitGoal alloc] init];
        
        goal = [self.keepFitGoals objectAtIndex:objectIndex];
        
        //NSLog(@"ID from goal: %d", [goal goalID]);
        
        // Prepare the query.
        NSString *query = [NSString stringWithFormat:@"delete from goals where goalID=%d", [goal goalID]];
        
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        }
        else {
            NSLog(@"Could not execute the query.");
        }
        
        // Reload the table view.
        [self loadFromDB];
    }
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showViewGoal"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ViewGoalViewController *destViewController = segue.destinationViewController;
        destViewController.viewGoal = [self.keepFitGoals objectAtIndex:indexPath.row];
    }
}

/*
#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    KeepFitGoal *tappedItem = [self.keepFitGoals objectAtIndex:indexPath.row];
    tappedItem.completed = !tappedItem.completed;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}*/

@end
