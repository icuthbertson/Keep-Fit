//
//  TestGoalListTableViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 24/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "TestGoalListTableViewController.h"
#import "KeepFitGoal.h"
#import "TestAddGoalViewController.h"
#import "TestViewGoalViewController.h"
#import "DBManager.h"

@interface TestGoalListTableViewController ()

@property NSMutableArray *keepFitGoals;
@property NSDate *currentDate;
@property (nonatomic, strong) DBManager *dbManager;

@property (nonatomic, strong) NSArray *arrDBResults;

@end

@implementation TestGoalListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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

#pragma mark - Segues

-(IBAction)unwindToListTest:(UIStoryboardSegue *)segue {
    TestAddGoalViewController *source = [segue sourceViewController];
    KeepFitGoal *goal = source.goal;
    if (goal != nil) {
        NSString *query;
        query = [NSString stringWithFormat:@"insert into testGoals values(null, '%@', '%d', '%d', '%ld', '%ld', '%ld', '%ld', '%f', '%f', '%f', '%d')", goal.goalName, goal.goalStatus, goal.goalType, (long)goal.goalAmountSteps, (long)goal.goalProgressSteps, (long)goal.goalAmountStairs, (long)goal.goalProgressStairs, [goal.goalStartDate timeIntervalSince1970], [goal.goalCompletionDate timeIntervalSince1970], [goal.goalCreationDate timeIntervalSince1970], goal.goalConversion];
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
                query = [NSString stringWithFormat:@"insert into testHistory values(null, '%ld', '%d', '%f', '%f', '%d', '%d')", (long)history.goalID, history.goalStatus, [history.goalCreationDate timeIntervalSince1970], 0.0, 0, 0];
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

-(IBAction)unwindFromViewTest:(UIStoryboardSegue *)segue {
    [self loadFromDB];
}

#pragma mark - Database

-(void)loadFromDB {
    //get current date
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
    
    //get goals
    if (self.keepFitGoals != nil) {
        self.keepFitGoals = nil;
    }
    self.keepFitGoals = [[NSMutableArray alloc] init];
    
    // Form the query.
     NSString *query = @"select * from testGoals";
    
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
        
        if ((goal.goalStatus == Pending) && [[self.currentDate earlierDate:goal.goalStartDate]isEqualToDate: goal.goalStartDate]) {
            NSLog(@"active");
            
            goal.goalStatus = Active;
            
            [self storeGoalStatusChangeToDB:goal];
        }
        if ((goal.goalStatus == Active) && [[self.currentDate earlierDate:goal.goalCompletionDate]isEqualToDate: goal.goalCompletionDate]) {
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"protoCellTesting" forIndexPath:indexPath];
    KeepFitGoal *goal = [self.keepFitGoals objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    NSString *statusText;
    switch (goal.goalStatus) {
        case Pending:
            statusText = [NSString stringWithFormat:@"Pending"];
            break;
        case Active:
            statusText = [NSString stringWithFormat:@"Active"];
            break;
        case Overdue:
            statusText = [NSString stringWithFormat:@"Overdue"];
            break;
        case Suspended:
            statusText = [NSString stringWithFormat:@"Suspended"];
            break;
        case Abandoned:
            statusText = [NSString stringWithFormat:@"Abandoned"];
            break;
        case Completed:
            statusText = [NSString stringWithFormat:@"Completed"];
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showViewGoalTest"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TestViewGoalViewController *destViewController = segue.destinationViewController;
        destViewController.viewGoal = [self.keepFitGoals objectAtIndex:indexPath.row];
        destViewController.currentDate = self.currentDate;
        destViewController.keepFitGoals = self.keepFitGoals;
        destViewController.settings = self.settings;
    }
    else if ([segue.identifier isEqualToString:@"addGoalTest"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        TestAddGoalViewController *destAddController = [[navigationController viewControllers]objectAtIndex:0];
        NSMutableArray *goalNamesForChecking = [[NSMutableArray alloc] init];
        for (int i=0; i<[self.keepFitGoals count]; i++) {
            NSString *goalNameForArray = [[NSString alloc] init];
            goalNameForArray = [[self.keepFitGoals objectAtIndex:i] goalName];
            [goalNamesForChecking addObject:goalNameForArray];
        }
        destAddController.listGoalNames = goalNamesForChecking;
        destAddController.currentDate = self.currentDate;
    }
}

#pragma mark - History

-(int) getHistoryRowID:(int) goalID {
    NSString *query = [NSString stringWithFormat:@"select * from testHistory where goalId='%d' and statusEndDate='%f'", goalID, 0.0];
    
    NSArray *historyResults;
    
    historyResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSInteger indexOfHistoryID = [self.dbManager.arrColumnNames indexOfObject:@"historyID"];
    
    return [[[historyResults objectAtIndex:0] objectAtIndex:indexOfHistoryID] intValue];
}

-(void) storeGoalStatusChangeToDB:(KeepFitGoal*) goal {
    NSString *query = [NSString stringWithFormat:@"update testGoals set goalStatus='%d' where goalID=%ld", goal.goalStatus,(long)goal.goalID];
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    query = [NSString stringWithFormat:@"update testHistory set statusEndDate='%f' where historyID=%ld", [[NSDate date] timeIntervalSince1970], (long)[self getHistoryRowID:goal.goalID]];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    query = [NSString stringWithFormat:@"insert into testHistory values(null, '%ld', '%d', '%f', '%f', '%d', '%d')", (long)goal.goalID, goal.goalStatus, [[NSDate date] timeIntervalSince1970], 0.0, 0, 0];
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
