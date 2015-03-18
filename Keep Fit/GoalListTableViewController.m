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
#import "SettingsViewController.h"
#import "Testing.h"
#import "MainTabBarViewController.h"
#import "TestViewGoalViewController.h"
#import "Settings.h"

@interface GoalListTableViewController ()

@property NSMutableArray *keepFitGoals; // List of keep fit goals.
@property (nonatomic, strong) DBManager *dbManager; // database manager object.

@property MainTabBarViewController *mainTabBarController;

@property (nonatomic, strong) NSArray *arrDBResults; // array to hold db select query results.
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton; // Outlet for select button.

@end

@implementation GoalListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadFromDB)
                                                 name:@"reloadData"
                                               object:nil];
    
    // set navigation title.
    self.navigationItem.title = @"Goals";
    
    // Initialise array of goals.
    if (self.keepFitGoals != nil) {
        self.keepFitGoals = nil;
    }
    self.keepFitGoals = [[NSMutableArray alloc] init];
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    // Default list to all.
    self.listType = 7;
    
    // Initialise testing object.
    self.mainTabBarController = (MainTabBarViewController *)self.tabBarController;
    self.mainTabBarController.testing = [[Testing alloc] init];
    [self.mainTabBarController.testing setTesting:NO];
    
    self.mainTabBarController.settings = [[Settings alloc] init];
    
    // load goals from db.
    [self loadFromDB];
}

-(void)viewWillAppear:(BOOL)animated {
    [self loadFromDB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

// Returing from add view.
-(IBAction)unwindToList:(UIStoryboardSegue *)segue {
    // Get the goal created in the add view.
    AddGoalViewController *source = [segue sourceViewController];
    
    self.mainTabBarController.testing = source.testing;
    
    KeepFitGoal *goal = source.goal;
    // If the goal isn't nil.
    if (goal != nil) {
        // Set up query to insert the goal data into the database.
        NSString *query;
        query = [NSString stringWithFormat:@"insert into %@ values(null, '%@', '%d', '%d', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%d')", self.mainTabBarController.testing.getGoalDBName, goal.goalName, goal.goalStatus, goal.goalType, (double)goal.goalAmountSteps, (double)goal.goalProgressSteps, (double)goal.goalAmountStairs, (double)goal.goalProgressStairs, [goal.goalStartDate timeIntervalSince1970], [goal.goalCompletionDate timeIntervalSince1970], [goal.goalCreationDate timeIntervalSince1970], goal.goalConversion];
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        }
        else {
            NSLog(@"Could not execute the query.");
        }
        // Add goal to list of goals and reload from db incase of any changes.
        [self.keepFitGoals addObject:goal];
        [self loadFromDB];
        
        // Add the first history entry for the new goal.
        KeepFitGoal *history;
        for (int i=0; i<[self.keepFitGoals count]; i++) {
            history = [self.keepFitGoals objectAtIndex:i];
            if ([goal.goalName isEqualToString:history.goalName]) {
                query = [NSString stringWithFormat:@"insert into %@ values(null, '%ld', '%d', '%f', '%f', '%d', '%d')", self.mainTabBarController.testing.getHistoryDBName, (long)history.goalID, history.goalStatus, [history.goalCreationDate timeIntervalSince1970], 0.0, 0, 0];
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
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
        
        // Schedule the notification
        if (self.mainTabBarController.settings.notifications) {
            UILocalNotification* startNotification = [[UILocalNotification alloc] init];
            startNotification.fireDate = goal.goalStartDate;
            startNotification.alertBody = [NSString stringWithFormat:@"Goal %@ is now Active.",goal.goalName];
            startNotification.soundName = UILocalNotificationDefaultSoundName;
            startNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
            
            NSDictionary *infoDictstart = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@start",goal.goalName] forKey:[NSString stringWithFormat:@"%@start",goal.goalName]];
            startNotification.userInfo = infoDictstart;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:startNotification];
            
            UILocalNotification* endNotification = [[UILocalNotification alloc] init];
            endNotification.fireDate = goal.goalCompletionDate;
            endNotification.alertBody = [NSString stringWithFormat:@"Goal %@ is now Overdue.",goal.goalName];
            endNotification.soundName = UILocalNotificationDefaultSoundName;
            endNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
            
            NSDictionary *infoDictend = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@end",goal.goalName] forKey:[NSString stringWithFormat:@"%@end",goal.goalName]];
            endNotification.userInfo = infoDictend;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:endNotification];
            
            // Request to reload table view data
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
        }
        
        // Reload table view data.
        [self.tableView reloadData];
    }
}

// Returning from view goal view.
-(IBAction)unwindFromView:(UIStoryboardSegue *)segue {
    // Update testing object from the goal view.
    ViewGoalViewController *source = [segue sourceViewController];
    self.mainTabBarController.testing = source.testing;
    // Reload db data incase of changes.
    [self loadFromDB];
}

// Returning from settings view.
-(IBAction)unwindFromSettings:(UIStoryboardSegue *)segue {
    // Update testing value.
    //SettingsViewController *source = [segue sourceViewController];
    //[self.testing setTesting:source.testing];
    [self loadFromDB];
}

// Returning from list selection view.
-(IBAction)unwindFromListSelection:(UIStoryboardSegue *)segue {
    // Update list type.
    ListSelectionViewController *source = [segue sourceViewController];
    
    if (source.listType == 8) return; //Cancel button was pressed.
    
    self.listType = source.listType;
    NSLog(@"%ld",(long)self.listType);
    // Reload db data incase of changes.
    [self loadFromDB];
}

#pragma mark - Database

// Load goals from DB.
-(void)loadFromDB {
    // get current date
    NSString *dateQuery = [NSString stringWithFormat:@"select * from testDate"];
    
    NSArray *currentDateResults;
    currentDateResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:dateQuery]];
    // If there is not a persisted date saved, save the current date.
    if (currentDateResults.count == 0) {
        dateQuery = [NSString stringWithFormat:@"insert into testDate values(%f)", [self.mainTabBarController.testing.getTime timeIntervalSince1970]];
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
        // else set the persisted date in the testing object.
        NSInteger indexOfCurrentDateID = [self.dbManager.arrColumnNames indexOfObject:@"currentTime"];
        [self.mainTabBarController.testing setTime:[NSDate dateWithTimeIntervalSince1970:[[[currentDateResults objectAtIndex:0] objectAtIndex:indexOfCurrentDateID] doubleValue]]];
        NSLog(@"Current Time Double From DB: %f",[[[currentDateResults objectAtIndex:0] objectAtIndex:indexOfCurrentDateID] doubleValue]);
        NSLog(@"Current Time From DB: %@",self.mainTabBarController.testing.getTime);
    }
    
    NSString *settingsQuery = [NSString stringWithFormat:@"select * from settings"];
    
    NSArray *settingsResults;
    settingsResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:settingsQuery]];
    // If there is not a persisted date saved, save the current date.
    if (settingsResults.count == 0) {
        settingsQuery = [NSString stringWithFormat:@"insert into settings values(%d,%d)", 0,1];
        // Execute the query.
        [self.dbManager executeQuery:settingsQuery];
        
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        }
        else {
            NSLog(@"Could not execute the query.");
        }
        self.mainTabBarController.settings.goalConversionSetting = 0;
    }
    else {
        // else set the persisted date in the testing object.
        NSInteger indexOfGoalConversion = [self.dbManager.arrColumnNames indexOfObject:@"goalConversion"];
        NSInteger indexOfNotifications = [self.dbManager.arrColumnNames indexOfObject:@"notifications"];
        self.mainTabBarController.settings.goalConversionSetting =[[[settingsResults objectAtIndex:0] objectAtIndex:indexOfGoalConversion] intValue];
        self.mainTabBarController.settings.notifications = [[[settingsResults objectAtIndex:0] objectAtIndex:indexOfNotifications] boolValue];
        NSLog(@"Goal Conversion From DB: %d",[[[settingsResults objectAtIndex:0] objectAtIndex:indexOfGoalConversion] intValue]);
    }
    
    // Re-initialise goal array.
    if (self.keepFitGoals != nil) {
        self.keepFitGoals = nil;
    }
    self.keepFitGoals = [[NSMutableArray alloc] init];
    
    NSLog(@"List Type: %ld",(long)self.listType);
    // Form the goal select query.
    NSString *query = [NSString stringWithFormat:@"select * from %@", self.mainTabBarController.testing.getGoalDBName];
    if (self.listType != 6 && self.listType != 7) { // If all the goals are not wanted to be shown.
        query = [NSString stringWithFormat:@"select * from %@ where goalStatus='%ld'", self.mainTabBarController.testing.getGoalDBName, (long)self.listType];
    }
    else if (self.listType == 7) {
        query = [NSString stringWithFormat:@"select * from %@ where goalStatus=0 or goalStatus=1 or goalStatus=2 or goalStatus=3", self.mainTabBarController.testing.getGoalDBName];
    }
    
    // Re-initialise the query results array.
    if (self.arrDBResults != nil) {
        self.arrDBResults = nil;
    }
    self.arrDBResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Set up indexes for getting column results for the rows in the database.
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
    
    // Set up the goal object with data from the rows returned by the query.
    for (int i=0; i<[self.arrDBResults count]; i++) {
        KeepFitGoal *goal;
        goal = [[KeepFitGoal alloc] init];
        goal.goalID = (NSInteger)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalID] intValue];
        goal.goalName = [NSString stringWithFormat:@"%@", [[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalName]];
        goal.goalStatus = (NSInteger)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalStatus] intValue];
        goal.goalType = (NSInteger)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalType] intValue];
        goal.goalAmountSteps = (double)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalAmountSteps] doubleValue];
        goal.goalProgressSteps = (double)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalProgressSteps] doubleValue];
        goal.goalAmountStairs = (double)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalAmountStairs] doubleValue];
        goal.goalProgressStairs = (double)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalProgressStairs] doubleValue];
        goal.goalStartDate = [NSDate dateWithTimeIntervalSince1970:[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalStartDate] doubleValue]];
        goal.goalCompletionDate = [NSDate dateWithTimeIntervalSince1970:[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalDate] doubleValue]];
        goal.goalCreationDate = [NSDate dateWithTimeIntervalSince1970:[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalCreationDate] doubleValue]];
        goal.goalConversion = (NSInteger)[[[self.arrDBResults objectAtIndex:i] objectAtIndex:indexOfGoalConversion] intValue];
        goal.conversionTable = [[NSArray alloc]initWithObjects:@1.0,@2112,@1312,@1.385,@4.545,nil];
        
        // check for if the start or end date has passed and update the status.
        if ((goal.goalStatus == Pending) && [[[NSDate date] earlierDate:goal.goalStartDate]isEqualToDate: goal.goalStartDate]) {
            NSLog(@"active");
            
            goal.goalStatus = Active;
            
            // Update history for the goal.
            [self storeGoalStatusChangeToDB:goal];
        }
        if ((goal.goalStatus == Active) && [[[NSDate date] earlierDate:goal.goalCompletionDate]isEqualToDate: goal.goalCompletionDate]) {
            NSLog(@"overdue");
            
            goal.goalStatus = Overdue;
            
            // Update history for the goal.
            [self storeGoalStatusChangeToDB:goal];
        }
        // Add the goal to the array of goals.
        [self.keepFitGoals addObject:goal];
    }
    
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
    
    // Configure the cell...
    KeepFitGoal *goal = [self.keepFitGoals objectAtIndex:indexPath.row];
    
    // Set up the font size for the cell.
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    
    // Check what the status for the goal is and change set the statusText string accordingly and set the colour for the cell.
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
    // Check the goal type and set the detailed text for the cell accordingly
    NSString *typeText;
    switch (goal.goalType) {
        case Steps:
            typeText = [NSString stringWithFormat:@"Steps"];
            if (goal.goalConversion == StepsStairs) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Steps: %ld/%ld", (long)goal.goalProgressSteps, (long)goal.goalAmountSteps];
            }
            else if (goal.goalConversion == Imperial) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Miles: %.2f/%.2f", (double)goal.goalProgressSteps/2112, (double)goal.goalAmountSteps/2112];
            }
            else if (goal.goalConversion == Metric) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Kilometers: %.2f/%.2f", (double)goal.goalProgressSteps/1312, (double)goal.goalAmountSteps/1312];
            }
            break;
        case Stairs:
            typeText = [NSString stringWithFormat:@"Stairs"];
            if (goal.goalConversion == StepsStairs) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Stairs: %ld/%ld", (long)goal.goalProgressStairs, (long)goal.goalAmountStairs];
            }
            else if (goal.goalConversion == Imperial) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Feet: %.2f/%.2f", (double)goal.goalProgressStairs/1.385, (double)goal.goalAmountStairs/1.385];
            }
            else if (goal.goalConversion == Metric) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Meters: %.2f/%.2f", (double)goal.goalProgressStairs/4.545, (double)goal.goalAmountStairs/4.545];
            }
            break;
        case Both:
            typeText = [NSString stringWithFormat:@"Steps and Stairs"];
            if (goal.goalConversion == StepsStairs) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Steps: %ld/%ld Stairs: %ld/%ld", (long)goal.goalProgressSteps, (long)goal.goalAmountSteps, (long)goal.goalProgressStairs, (long)goal.goalAmountStairs];
            }
            else if (goal.goalConversion == Imperial) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Miles: %.2f/%.2f Feet: %.2f/%.2f", (double)goal.goalProgressSteps/2112, (double)goal.goalAmountSteps/2112, (double)goal.goalProgressStairs/1.385, (double)goal.goalAmountStairs/1.385];
            }
            else if (goal.goalConversion == Metric) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Kilometers: %.2f/%.2f Meters: %.2f/%.2f", (double)goal.goalProgressSteps/1312, (double)goal.goalAmountSteps/1312, (double)goal.goalProgressStairs/4.545, (double)goal.goalAmountStairs/4.545];
            }
            break;
        default:
            break;
    }
    // Set the text label for the cell with the status text and goal name.
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", goal.goalName, statusText];

    return cell;
}

// Delegate methods always for the cell to slide left and reveal a button underneith.
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger objectIndex = indexPath.row;
    
    KeepFitGoal *goal;
    goal = [[KeepFitGoal alloc] init];
    // Get goal for the cell.
    goal = [self.keepFitGoals objectAtIndex:objectIndex];
    
    // allow sliding for any goal that is not completed.
    if (goal.goalStatus == Completed || goal.goalStatus == Abandoned) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;

}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Adandon the selected goal.
        NSLog(@"Abandon");
        
        NSInteger objectIndex = indexPath.row;
        
        KeepFitGoal *goal;
        goal = [[KeepFitGoal alloc] init];
        // Get goal for the cell.
        goal = [self.keepFitGoals objectAtIndex:objectIndex];
        
        if (goal.goalStatus == Abandoned) { // Re-instate goal.
            if ([[[NSDate date] earlierDate:goal.goalCompletionDate]isEqualToDate: goal.goalCompletionDate]) {
                goal.goalStatus = Overdue;
            }
            else {
                goal.goalStatus = Pending;
            }
        }
        else { // Abandon goal.
            goal.goalStatus = Abandoned;
        }
        
        // Update history for the goal.
        [self storeGoalStatusChangeToDB:goal];
        
        // Reload the table view.
        [self loadFromDB];
    }
}

// Set the title of the button under the cells.
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Abandon";
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // If going to the view goal view.
    if ([segue.identifier isEqualToString:@"showViewGoal"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ViewGoalViewController *destViewController = segue.destinationViewController;
        // Pass the goal to be veiewed.
        destViewController.viewGoal = [self.keepFitGoals objectAtIndex:indexPath.row];
        // Pass the list of goals.
        destViewController.keepFitGoals = self.keepFitGoals;
        // Pass the testing object.
        destViewController.testing = self.mainTabBarController.testing;
        destViewController.settings = self.mainTabBarController.settings;
        destViewController.hidesBottomBarWhenPushed = YES;
    }
    else if ([segue.identifier isEqualToString:@"addGoal"]) {
        // If going to the add view.
        UINavigationController *navigationController = segue.destinationViewController;
        AddGoalViewController *destAddController = [[navigationController viewControllers]objectAtIndex:0];
        NSMutableArray *goalNamesForChecking = [[NSMutableArray alloc] init];
        // Set up the list of goal names.
        for (int i=0; i<[self.keepFitGoals count]; i++) {
            NSString *goalNameForArray = [[NSString alloc] init];
            goalNameForArray = [[self.keepFitGoals objectAtIndex:i] goalName];
            [goalNamesForChecking addObject:goalNameForArray];
        }
        // Pass the list of goal names.
        destAddController.listGoalNames = goalNamesForChecking;
        // Pass the testing object.
        destAddController.testing = self.mainTabBarController.testing;
        destAddController.settings = self.mainTabBarController.settings;
    }
    else if ([segue.identifier isEqualToString:@"showSettings"]) {
        // If going to the settings view.
        //SettingsTabBarViewController *tabBarController = segue.destinationViewController;
        //SettingsViewController *destViewController = [[tabBarController viewControllers]objectAtIndex:1];
        //destViewController.testing = [self.testing getTesting];
    }
}

#pragma mark - History

// Get the row id of the last history entry for a goal. (check for the date being 0.0 1 Jan 1970)
-(int) getHistoryRowID:(int) goalID {
    NSString *query = [NSString stringWithFormat:@"select * from %@ where goalId='%d' and statusEndDate='%f'", self.mainTabBarController.testing.getHistoryDBName, goalID, 0.0];
    
    NSArray *historyResults;
    
    historyResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSInteger indexOfHistoryID = [self.dbManager.arrColumnNames indexOfObject:@"historyID"];
    
    return [[[historyResults objectAtIndex:0] objectAtIndex:indexOfHistoryID] intValue];
}

// store status change to db.
-(void) storeGoalStatusChangeToDB:(KeepFitGoal*) goal {
    // Update status in goals db
    NSString *query = [NSString stringWithFormat:@"update %@ set goalStatus='%d' where goalID=%ld", self.mainTabBarController.testing.getGoalDBName, goal.goalStatus,(long)goal.goalID];
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    // Add the new date to the last history entry for the goal.
    query = [NSString stringWithFormat:@"update %@ set statusEndDate='%f' where historyID=%ld",  self.mainTabBarController.testing.getHistoryDBName, [[self.mainTabBarController.testing getTime] timeIntervalSince1970], (long)[self getHistoryRowID:goal.goalID]];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    // Add new row for the history of the goal.
    query = [NSString stringWithFormat:@"insert into %@ values(null, '%ld', '%d', '%f', '%f', '%d', '%d')", self.mainTabBarController.testing.getHistoryDBName, (long)goal.goalID, goal.goalStatus, [[self.mainTabBarController.testing getTime] timeIntervalSince1970], 0.0, 0, 0];
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
