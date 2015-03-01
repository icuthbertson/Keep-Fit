//
//  GoalListTableViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 09/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//  Base of class from https://developer.apple.com/library/ios/referencelibrary/GettingStarted/RoadMapiOS/index.html#//apple_ref/doc/uid/TP40011343-CH2-SW1
//

#import "GoalListTableViewController.h"
#import "AddGoalViewController.h"
#import "DBManager.h"
#import "ViewGoalViewController.h"
#import "KeepFitGoal.h"
#import "ListSelectionViewController.h"
#import "Testing.h"
#import "SettingsViewController.h"
#import "SettingsTabBarViewController.h"

@interface GoalListTableViewController ()

@property NSMutableArray *keepFitGoals;
@property (nonatomic, strong) DBManager *dbManager;
@property Testing *testing;

@property (nonatomic, strong) NSArray *arrDBResults;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

@implementation GoalListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Goals";
    
    if (self.keepFitGoals != nil) {
        self.keepFitGoals = nil;
    }
    self.keepFitGoals = [[NSMutableArray alloc] init];
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    self.listType = 6;
    
    self.testing = [[Testing alloc] init];
    [self.testing setTesting:NO];
    
    [self loadFromDB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

-(IBAction)unwindToList:(UIStoryboardSegue *)segue {
    AddGoalViewController *source = [segue sourceViewController];
    KeepFitGoal *goal = source.goal;
    if (goal != nil) {
        NSString *query;
        query = [NSString stringWithFormat:@"insert into %@ values(null, '%@', '%d', '%d', '%ld', '%ld', '%ld', '%ld', '%f', '%f', '%f', '%d')", self.testing.getGoalDBName, goal.goalName, goal.goalStatus, goal.goalType, (long)goal.goalAmountSteps, (long)goal.goalProgressSteps, (long)goal.goalAmountStairs, (long)goal.goalProgressStairs, [goal.goalStartDate timeIntervalSince1970], [goal.goalCompletionDate timeIntervalSince1970], [goal.goalCreationDate timeIntervalSince1970], goal.goalConversion];
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        }
        else {
            NSLog(@"Could not execute the query.");
        }
        
        [self.keepFitGoals addObject:goal];
        [self loadFromDB];
        
        KeepFitGoal *history;
        
        for (int i=0; i<[self.keepFitGoals count]; i++) {
            history = [self.keepFitGoals objectAtIndex:i];
            if ([goal.goalName isEqualToString:history.goalName]) {
                query = [NSString stringWithFormat:@"insert into %@ values(null, '%ld', '%d', '%f', '%f', '%d', '%d')", self.testing.getHistoryDBName, (long)history.goalID, history.goalStatus, [history.goalCreationDate timeIntervalSince1970], 0.0, 0, 0];
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
        
        [self.tableView reloadData];
    }
}

-(IBAction)unwindFromView:(UIStoryboardSegue *)segue {
    ViewGoalViewController *source = [segue sourceViewController];
    self.testing = source.testing;
    [self loadFromDB];
}

-(IBAction)unwindFromSettings:(UIStoryboardSegue *)segue {
    SettingsViewController *source = [segue sourceViewController];
    [self.testing setTesting:source.testing];
    [self loadFromDB];
}

-(IBAction)unwindFromListSelection:(UIStoryboardSegue *)segue {
    ListSelectionViewController *source = [segue sourceViewController];
    self.listType = source.listType;
    NSLog(@"%d",self.listType);
    [self loadFromDB];
}

#pragma mark - Database

-(void)loadFromDB {
    //get current date
    NSString *dateQuery = [NSString stringWithFormat:@"select * from testDate"];
    
    NSArray *currentDateResults;
    currentDateResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:dateQuery]];
    
    if (currentDateResults.count == 0) {
        dateQuery = [NSString stringWithFormat:@"insert into testDate values(%f)", [self.testing.getTime timeIntervalSince1970]];
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
        [self.testing setTime:[NSDate dateWithTimeIntervalSince1970:[[[currentDateResults objectAtIndex:0] objectAtIndex:indexOfCurrentDateID] doubleValue]]];
        NSLog(@"Current Time Double From DB: %f",[[[currentDateResults objectAtIndex:0] objectAtIndex:indexOfCurrentDateID] doubleValue]);
        NSLog(@"Current Time From DB: %@",self.testing.getTime);
    }
    
    //get goals
    if (self.keepFitGoals != nil) {
        self.keepFitGoals = nil;
    }
    self.keepFitGoals = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"select * from %@", self.testing.getGoalDBName];
    // Form the query.
    if (self.listType != 6) {
        query = [NSString stringWithFormat:@"select * from %@ where goalStatus='%d'", self.testing.getGoalDBName, self.listType];
    }
    
    // Get the results.
    if (self.arrDBResults != nil) {
        self.arrDBResults = nil;
    }
    self.arrDBResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSInteger indexOfGoalID = [self.dbManager.arrColumnNames indexOfObject:@"goalID"];
    NSInteger indexOfGoalName = [self.dbManager.arrColumnNames indexOfObject:@"goalName"];
    NSInteger indexOfGoalStatus = [self.dbManager.arrColumnNames indexOfObject:@"goalStatus"];
    NSInteger indexOfGoalType = [self.dbManager.arrColumnNames indexOfObject:@"goalType"];
    NSInteger indexOfGoalAmountSteps = [self.dbManager.arrColumnNames indexOfObject:@"goalAmountSteps"];
    NSInteger indexOfGoalProgressSteps = [self.dbManager.arrColumnNames indexOfObject:@"goalProgressSteps"];
    NSInteger indexOfGoalAmountStairs = [self.dbManager.arrColumnNames indexOfObject:@"goalAmountStairs"];
    NSInteger indexOfGoalProgressStairs = [self.dbManager.arrColumnNames indexOfObject:@"goalProgressStairs"];
    NSInteger indexOfGoalStartDate = [self.dbManager.arrColumnNames indexOfObject:@"goalStartDate"];
    NSInteger indexOfGoalDate = [self.dbManager.arrColumnNames indexOfObject:@"goalDate"];
    NSInteger indexOfGoalCreationDate = [self.dbManager.arrColumnNames indexOfObject:@"goalCreationDate"];
    NSInteger indexOfGoalConversion = [self.dbManager.arrColumnNames indexOfObject:@"goalConversion"];
    
    NSLog(@"arrDBResults: %@", self.arrDBResults);
    
    for (int i=0; i<[self.arrDBResults count]; i++) {
        //NSLog(@"Goal Name %d: %@", i,[NSString stringWithFormat:@"%@", [[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalName]]);
        
        KeepFitGoal *goal;
        goal = [[KeepFitGoal alloc] init];
        goal.goalID = (NSInteger)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalID] intValue];
        goal.goalName = [NSString stringWithFormat:@"%@", [[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalName]];
        goal.goalStatus = (NSInteger)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalStatus] intValue];
        goal.goalType = (NSInteger)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalType] intValue];
        goal.goalAmountSteps = (long)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalAmountSteps] intValue];
        goal.goalProgressSteps = (long)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalProgressSteps] intValue];
        goal.goalAmountStairs = (long)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalAmountStairs] intValue];
        goal.goalProgressStairs = (long)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalProgressStairs] intValue];
        goal.goalStartDate = [NSDate dateWithTimeIntervalSince1970:[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalStartDate] doubleValue]];
        goal.goalCompletionDate = [NSDate dateWithTimeIntervalSince1970:[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalDate] doubleValue]];
        goal.goalCreationDate = [NSDate dateWithTimeIntervalSince1970:[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalCreationDate] doubleValue]];
        goal.goalConversion = (NSInteger)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalConversion] intValue];
        goal.conversionTable = [[NSArray alloc]initWithObjects:@1.0,@2.5,@0.762,@0.000473485,@0.000762,nil];
        //NSLog(@"%@", goal.goalCompletionDate);
        //NSLog(@"%@", [[NSDate date] earlierDate:goal.goalCompletionDate]);
        
        if ((goal.goalStatus == Pending) && [[[self.testing getTime] earlierDate:goal.goalStartDate]isEqualToDate: goal.goalStartDate]) {
            NSLog(@"active");
            
            goal.goalStatus = Active;
            
            [self storeGoalStatusChangeToDB:goal];
        }
        if ((goal.goalStatus == Active) && [[[self.testing getTime] earlierDate:goal.goalCompletionDate]isEqualToDate: goal.goalCompletionDate]) {
            NSLog(@"overdue");
            
            goal.goalStatus = Overdue;
            
            [self storeGoalStatusChangeToDB:goal];
        }
        
        [self.keepFitGoals addObject:goal];
    }
    
    //NSLog(@"%@", self.arrDBResults);
    
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
    return [self.keepFitGoals count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    KeepFitGoal *goal = [self.keepFitGoals objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    NSString *statusText;
    switch (goal.goalStatus) {
        case Pending:
            statusText = [NSString stringWithFormat:@"Pending"];
            //cell.textLabel.textColor = [UIColor blueColor];
            //cell.detailTextLabel.textColor = [UIColor blueColor];
            cell.textLabel.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((178) / 255.0) blue:((255) / 255.0) alpha:1.0];
            cell.detailTextLabel.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((178) / 255.0) blue:((255) / 255.0) alpha:1.0];
            cell.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((178) / 255.0) blue:((255) / 255.0) alpha:1.0];
            break;
        case Active:
            statusText = [NSString stringWithFormat:@"Active"];
            //cell.textLabel.textColor = [UIColor colorWithRed:((0) / 255.0) green:((204) / 255.0) blue:((0) / 255.0) alpha:1.0];
            //cell.detailTextLabel.textColor = [UIColor colorWithRed:((0) / 255.0) green:((204) / 255.0) blue:((0) / 255.0) alpha:1.0];
            cell.textLabel.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            cell.detailTextLabel.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            cell.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            break;
        case Overdue:
            statusText = [NSString stringWithFormat:@"Overdue"];
            //cell.textLabel.textColor = [UIColor redColor];
            //cell.detailTextLabel.textColor = [UIColor redColor];
            cell.textLabel.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((102) / 255.0) blue:((102) / 255.0) alpha:1.0];
            cell.detailTextLabel.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((102) / 255.0) blue:((102) / 255.0) alpha:1.0];
            cell.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((102) / 255.0) blue:((102) / 255.0) alpha:1.0];
            break;
        case Suspended:
            statusText = [NSString stringWithFormat:@"Suspended"];
            //cell.textLabel.textColor = [UIColor colorWithRed:((255) / 255.0) green:((150) / 255.0) blue:((0) / 255.0) alpha:1.0];
            //cell.detailTextLabel.textColor = [UIColor colorWithRed:((255) / 255.0) green:((150) / 255.0) blue:((0) / 255.0) alpha:1.0];
            cell.textLabel.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            cell.detailTextLabel.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            cell.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            break;
        case Abandoned:
            statusText = [NSString stringWithFormat:@"Abandoned"];
            //cell.textLabel.textColor = [UIColor redColor];
            //cell.detailTextLabel.textColor = [UIColor redColor];
            cell.textLabel.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((102) / 255.0) blue:((102) / 255.0) alpha:1.0];
            cell.detailTextLabel.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((102) / 255.0) blue:((102) / 255.0) alpha:1.0];
            cell.backgroundColor = [UIColor colorWithRed:((255) / 255.0) green:((102) / 255.0) blue:((102) / 255.0) alpha:1.0];
            break;
        case Completed:
            statusText = [NSString stringWithFormat:@"Completed"];
            cell.textLabel.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            cell.detailTextLabel.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            cell.backgroundColor = [UIColor colorWithRed:((102) / 255.0) green:((255) / 255.0) blue:((102) / 255.0) alpha:1.0];
            break;
        default:
            break;
    }
    NSString *typeText;
    switch (goal.goalType) {
        case Steps:
            typeText = [NSString stringWithFormat:@"Steps"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Steps: %ld/%ld", (long)goal.goalProgressSteps, (long)goal.goalAmountSteps];
            break;
        case Stairs:
            typeText = [NSString stringWithFormat:@"Stairs"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Stairs: %ld/%ld", (long)goal.goalProgressStairs, (long)goal.goalAmountStairs];
            break;
        case Both:
            typeText = [NSString stringWithFormat:@"Steps and Stairs"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Steps: %ld/%ld Stairs: %ld/%ld", (long)goal.goalProgressSteps, (long)goal.goalAmountSteps, (long)goal.goalProgressStairs, (long)goal.goalAmountStairs];
            break;
        default:
            break;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", goal.goalName, statusText];
    /*if (goal.completed) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;*/
    
    /*NSInteger indexOfGoalName = [self.dbManager.arrColumnNames indexOfObject:@"goalName"];
    
    // Set the loaded data to the appropriate cell labels.
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[self.arrDBResults objectAtIndex:indexPath.row] objectAtIndex:indexOfGoalName]];*/
    
    return cell;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger objectIndex = indexPath.row;
    
    KeepFitGoal *goal;
    goal = [[KeepFitGoal alloc] init];
    
    goal = [self.keepFitGoals objectAtIndex:objectIndex];
    
    if (goal.goalStatus == Completed) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;

}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the selected record.
        NSLog(@"Abandon");
        
        //NSLog(@"index of goal: %ld", (long)indexOfGoalID);
        //NSLog(@"index of goal: %ld", (long)indexPath.row);
        NSInteger objectIndex = indexPath.row;
        
        KeepFitGoal *goal;
        goal = [[KeepFitGoal alloc] init];
        
        goal = [self.keepFitGoals objectAtIndex:objectIndex];
        
        if (goal.goalStatus == Abandoned) {
            if ([[[self.testing getTime] earlierDate:goal.goalCompletionDate]isEqualToDate: goal.goalCompletionDate]) {
                goal.goalStatus = Overdue;
            }
            else {
                goal.goalStatus = Pending;
            }
        }
        else {
            goal.goalStatus = Abandoned;
        }
        
        //NSLog(@"ID from goal: %d", [goal goalID]);
        
        // Prepare the query.
        //NSString *query = [NSString stringWithFormat:@"delete from goals where goalID=%ld", (long)[goal goalID]];
        
        [self storeGoalStatusChangeToDB:goal];
        
        // Reload the table view.
        [self loadFromDB];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger objectIndex = indexPath.row;
    
    KeepFitGoal *goal;
    goal = [[KeepFitGoal alloc] init];
    
    goal = [self.keepFitGoals objectAtIndex:objectIndex];
    
    if (goal.goalStatus == Abandoned) {
        return @"Re-instate";
    }
    return @"Abandon";
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
        destViewController.testing = self.testing;
        destViewController.keepFitGoals = self.keepFitGoals;
    }
    else if ([segue.identifier isEqualToString:@"addGoal"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        AddGoalViewController *destAddController = [[navigationController viewControllers]objectAtIndex:0];
        NSMutableArray *goalNamesForChecking = [[NSMutableArray alloc] init];
        for (int i=0; i<[self.keepFitGoals count]; i++) {
            NSString *goalNameForArray = [[NSString alloc] init];
            goalNameForArray = [[self.keepFitGoals objectAtIndex:i] goalName];
            [goalNamesForChecking addObject:goalNameForArray];
        }
        destAddController.listGoalNames = goalNamesForChecking;
        destAddController.testing = self.testing;
    }
    else if ([segue.identifier isEqualToString:@"showSettings"]) {
        SettingsTabBarViewController *tabBarController = segue.destinationViewController;
        SettingsViewController *destViewController = [[tabBarController viewControllers]objectAtIndex:1];
        destViewController.testing = [self.testing getTesting];
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

#pragma mark - History

-(int) getHistoryRowID:(int) goalID {
    NSString *query = [NSString stringWithFormat:@"select * from %@ where goalId='%d' and statusEndDate='%f'", self.testing.getHistoryDBName, goalID, 0.0];
    
    NSArray *historyResults;
    
    historyResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSInteger indexOfHistoryID = [self.dbManager.arrColumnNames indexOfObject:@"historyID"];
    
    return [[[historyResults objectAtIndex:0] objectAtIndex:indexOfHistoryID] intValue];
}

-(void) storeGoalStatusChangeToDB:(KeepFitGoal*) goal {
    NSString *query = [NSString stringWithFormat:@"update %@ set goalStatus='%d' where goalID=%ld", self.testing.getGoalDBName, goal.goalStatus,(long)goal.goalID];
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    query = [NSString stringWithFormat:@"update %@ set statusEndDate='%f' where historyID=%ld",  self.testing.getHistoryDBName, [[self.testing getTime] timeIntervalSince1970], (long)[self getHistoryRowID:goal.goalID]];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    query = [NSString stringWithFormat:@"insert into %@ values(null, '%ld', '%d', '%f', '%f', '%d', '%d')", self.testing.getHistoryDBName, (long)goal.goalID, goal.goalStatus, [[self.testing getTime] timeIntervalSince1970], 0.0, 0, 0];
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
