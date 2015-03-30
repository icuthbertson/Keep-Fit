//
//  SettingsViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 23/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "SettingsViewController.h"
#import "DBManager.h"
#import "TestSettings.h"
#import "MainTabBarViewController.h"
#import "ScheduleViewController.h"
#import "Schedule.h"
#import "ChangeTimeViewController.h"
#import "Settings.h"
#import "KeepFitGoal.h"
#import <QuartzCore/QuartzCore.h>

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *stairsLabel;
@property (weak, nonatomic) IBOutlet UIStepper *stepsStepper;
@property (weak, nonatomic) IBOutlet UIStepper *stairsStepper;
@property (nonatomic, strong) DBManager *dbManager; // database manager object.
- (IBAction)stepsAction:(id)sender;
- (IBAction)stairsAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *scheduleView;
@property (weak, nonatomic) IBOutlet UIView *generalView;
@property (weak, nonatomic) IBOutlet UIView *testingView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISwitch *testingSwitch;
- (IBAction)testingSwtichAction:(id)sender;
- (IBAction)saveTestingSettings:(id)sender;
- (IBAction)goalConversionAction:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *goalConversionSelector;
- (IBAction)saveGeneralSettings:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *notificationsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *pendingSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *activeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *overdueSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *suspendedSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *abandonedSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *completedSwitch;


@property MainTabBarViewController *mainTabBarController;

@property TestSettings *settings;

@property BOOL oldNotif;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mainTabBarController = (MainTabBarViewController *)self.tabBarController;
    
    // Set up the scroll view.
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 1000)];
    [self.scrollView setBackgroundColor:[UIColor lightGrayColor]];
    
    self.generalView.layer.cornerRadius = 5;
    self.generalView.layer.masksToBounds = YES;
    
    self.testingView.layer.cornerRadius = 5;
    self.testingView.layer.masksToBounds = YES;
    
    self.scheduleView.layer.cornerRadius = 5;
    self.scheduleView.layer.masksToBounds = YES;
    [self.scheduleView setFrame:CGRectMake(self.scheduleView.frame.origin.x, self.scheduleView.frame.origin.y, self.scheduleView.frame.size.width, 0.0)];
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    self.oldNotif = self.mainTabBarController.settings.notifications;
    
    [self loadFromDB];
    [self setUpView];
}

-(void)viewWillAppear:(BOOL)animated {
    self.oldNotif = self.mainTabBarController.settings.notifications;
    [self setUpView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpView {
    self.goalConversionSelector.selectedSegmentIndex = self.mainTabBarController.settings.goalConversionSetting;
    
    self.stepsLabel.text = [NSString stringWithFormat:@"%d",self.settings.stepsTime];
    self.stairsLabel.text = [NSString stringWithFormat:@"%d",self.settings.stairsTime];
    self.stepsStepper.value = self.settings.stepsTime;
    self.stairsStepper.value = self.settings.stairsTime;
    
    [self.testingSwitch setOn:[self.mainTabBarController.testing getTesting]];
    
    if ([self.mainTabBarController.testing getTesting]) {
        [UIView animateWithDuration:.1f animations:^{
            [self.scheduleView setFrame:CGRectMake(self.scheduleView.frame.origin.x, self.scheduleView.frame.origin.y, self.scheduleView.frame.size.width, 125.0)];
        }];
    }
    else {
        [UIView animateWithDuration:.1f animations:^{
            [self.scheduleView setFrame:CGRectMake(self.scheduleView.frame.origin.x, self.scheduleView.frame.origin.y, self.scheduleView.frame.size.width, 0.0)];
        }];
    }
    
    [self.notificationsSwitch setOn:self.mainTabBarController.settings.notifications];
    
    [self.pendingSwitch setOn:self.mainTabBarController.settings.pending];
    [self.activeSwitch setOn:self.mainTabBarController.settings.active];
    [self.overdueSwitch setOn:self.mainTabBarController.settings.overdue];
    [self.suspendedSwitch setOn:self.mainTabBarController.settings.suspended];
    [self.abandonedSwitch setOn:self.mainTabBarController.settings.abandoned];
    [self.completedSwitch setOn:self.mainTabBarController.settings.completed];
}

-(void)loadFromDB {
    self.settings = [[TestSettings alloc] init];
    NSString *query = @"select * from testSettings";
    
    NSArray *currentSettingsResults;
    currentSettingsResults = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSLog(@"%@",currentSettingsResults);
    
    if (currentSettingsResults.count == 0) {
        self.settings.stepsTime = 1;
        self.settings.stairsTime = 1;
        
        query = [NSString stringWithFormat:@"insert into testSettings values(%d,%d)", self.settings.stepsTime, self.settings.stairsTime];
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        }
        else {
            NSLog(@"Could not execute the query.");
        }
    }
    else {
        NSInteger indexOfStepsTime = [self.dbManager.arrColumnNames indexOfObject:@"stepsTime"];
        NSInteger indexOfStairsTime = [self.dbManager.arrColumnNames indexOfObject:@"stairsTime"];
        self.settings.stepsTime = [[[currentSettingsResults objectAtIndex:0] objectAtIndex:indexOfStepsTime] intValue];
        self.settings.stairsTime = [[[currentSettingsResults objectAtIndex:0] objectAtIndex:indexOfStairsTime] intValue];
        NSLog(@"Steps Time: %d",self.settings.stepsTime);
        NSLog(@"Stairs Time: %d",self.settings.stairsTime);
    }
}

-(void)updateTestSettings {
    // Update goal in DB.
    NSString *query = [NSString stringWithFormat:@"update testSettings set stepsTime='%d', stairsTime='%d'", self.settings.stepsTime, self.settings.stairsTime];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:[NSString stringWithFormat:@"Testing Settings Saved."]
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        NSLog(@"Could not execute the query.");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:[NSString stringWithFormat:@"An Error occured. General Settings not saved"]
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(IBAction)unwindFromScheduleActivityTest:(UIStoryboardSegue *)segue {
    ScheduleViewController *source = [segue sourceViewController];
    
    if (source.schedule == nil) return;
    
    [self storeGoalStatisticsToDB:source.schedule];
}

-(IBAction)unwindFromChangeTimeActivityTest:(UIStoryboardSegue *)segue {
    ChangeTimeViewController *source = [segue sourceViewController];
    // Update the persisted time in the database.
    
    if (source.changeDate == nil) return;
    
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
    if ([segue.identifier isEqualToString:@"changeTimeActivity"]) {
        ChangeTimeViewController *destViewController = segue.destinationViewController;
        destViewController.currentTime = [self.mainTabBarController.testing getTime];
        destViewController.hidesBottomBarWhenPushed = YES;
    }
    else if ([segue.identifier isEqualToString:@"scheduleActivity"]) {
        ScheduleViewController *destViewController = segue.destinationViewController;
        destViewController.testing = self.mainTabBarController.testing;
        destViewController.scheduleGoal = NO;
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}


- (IBAction)stepsAction:(id)sender {
    self.stepsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}

- (IBAction)stairsAction:(id)sender {
    self.stairsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}

- (IBAction)testingSwtichAction:(id)sender {
    [self.mainTabBarController.testing setTesting:[self.testingSwitch isOn]];
    [self setUpView];
}

- (IBAction)saveTestingSettings:(id)sender {
    self.settings.stepsTime = [self.stepsLabel.text intValue];
    self.settings.stairsTime = [self.stairsLabel.text intValue];
    [self updateTestSettings];
}

- (IBAction)goalConversionAction:(id)sender {
    
}

- (IBAction)saveGeneralSettings:(id)sender {
    // Update goal in DB.
    NSString *query = [NSString stringWithFormat:@"update settings set goalConversion='%d', notifications='%d', pending='%d', active='%d', overdue='%d', suspended='%d', abandoned='%d', completed='%d'", self.goalConversionSelector.selectedSegmentIndex, self.notificationsSwitch.isOn,  self.pendingSwitch.isOn, self.activeSwitch.isOn, self.overdueSwitch.isOn, self.suspendedSwitch.isOn, self.abandonedSwitch.isOn, self.completedSwitch.isOn];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        if (!self.notificationsSwitch.isOn) { //cancel notifications
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        }
        else if (self.notificationsSwitch.isOn && !self.oldNotif) { //reinitalise notifications if notifications were off and are now on.
            
            NSString *goals = [NSString stringWithFormat:@"select * from %@",self.mainTabBarController.testing.getGoalDBName];
            NSArray *goalsForNotifs;
            goalsForNotifs = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:goals]];
            
            NSInteger indexOfGoalName = [self.dbManager.arrColumnNames indexOfObject:@"goalName"];
            NSInteger indexOfGoalStatus = [self.dbManager.arrColumnNames indexOfObject:@"goalStatus"];
            NSInteger indexOfGoalStartDate = [self.dbManager.arrColumnNames indexOfObject:@"goalStartDate"];
            NSInteger indexOfGoalDate = [self.dbManager.arrColumnNames indexOfObject:@"goalDate"];
            
            for (int i=0; i<[goalsForNotifs count]; i++) {
                NSString *goalName = [NSString stringWithFormat:@"%@", [[goalsForNotifs objectAtIndex:i] objectAtIndex:indexOfGoalName]];
                GoalStatus status = (NSInteger)[[[goalsForNotifs objectAtIndex:i] objectAtIndex:indexOfGoalStatus] intValue];
                NSDate *goalStartDate = [NSDate dateWithTimeIntervalSince1970:[[[goalsForNotifs objectAtIndex:i] objectAtIndex:indexOfGoalStartDate] doubleValue]];
                NSDate *goalCompletionDate = [NSDate dateWithTimeIntervalSince1970:[[[goalsForNotifs objectAtIndex:i] objectAtIndex:indexOfGoalDate] doubleValue]];

                
                if (status == Pending) {
                    UILocalNotification* startNotification = [[UILocalNotification alloc] init];
                    startNotification.fireDate = goalStartDate;
                    startNotification.alertBody = [NSString stringWithFormat:@"Goal %@ is now Active.",goalName];
                    startNotification.soundName = UILocalNotificationDefaultSoundName;
                    startNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
                    
                    NSDictionary *infoDictstart = [[NSDictionary alloc] init];
                    if (self.mainTabBarController.testing.getTesting) {
                        infoDictstart = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@startTesting",goalName] forKey:[NSString stringWithFormat:@"%@startTesting",goalName]];
                    }
                    else {
                        infoDictstart = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@start",goalName] forKey:[NSString stringWithFormat:@"%@start",goalName]];
                    }
                    startNotification.userInfo = infoDictstart;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:startNotification];
                    
                    UILocalNotification* endNotification = [[UILocalNotification alloc] init];
                    endNotification.fireDate = goalCompletionDate;
                    endNotification.alertBody = [NSString stringWithFormat:@"Goal %@ is now Overdue.",goalName];
                    endNotification.soundName = UILocalNotificationDefaultSoundName;
                    endNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
                    
                    NSDictionary *infoDictend = [[NSDictionary alloc] init];
                    if (self.mainTabBarController.testing.getTesting) {
                        infoDictend = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@endTesting",goalName] forKey:[NSString stringWithFormat:@"%@endTesting",goalName]];
                    }
                    else {
                        infoDictend = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@end",goalName] forKey:[NSString stringWithFormat:@"%@end",goalName]];
                    }
                    endNotification.userInfo = infoDictend;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:endNotification];
                }
                if (status == Active) {
                    UILocalNotification* endNotification = [[UILocalNotification alloc] init];
                    endNotification.fireDate = goalCompletionDate;
                    endNotification.alertBody = [NSString stringWithFormat:@"Goal %@ is now Overdue.",goalName];
                    endNotification.soundName = UILocalNotificationDefaultSoundName;
                    endNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
                    
                    NSDictionary *infoDictend = [[NSDictionary alloc] init];
                    if (self.mainTabBarController.testing.getTesting) {
                        infoDictend = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@endTesting",goalName] forKey:[NSString stringWithFormat:@"%@endTesting",goalName]];
                    }
                    else {
                        infoDictend = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@end",goalName] forKey:[NSString stringWithFormat:@"%@end",goalName]];
                    }
                    endNotification.userInfo = infoDictend;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:endNotification];
                }
            }
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
            message:[NSString stringWithFormat:@"General Settings Saved."]
            delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        NSLog(@"Could not execute the query.");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:[NSString stringWithFormat:@"An Error occured. General Settings not saved"]
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    self.oldNotif = self.notificationsSwitch.isOn;
}

-(void) storeGoalStatisticsToDB:(Schedule*) schedule {
    NSString *query;
    
    NSLog(@"Schedule Start Date: %@",schedule.date);
    NSLog(@"Schedule End Date: %@",schedule.endDate);
    NSLog(@"Schedule Steps: %d",schedule.numSteps);
    NSLog(@"Schedule Stairs: %d",schedule.numStairs);
    
    query = [NSString stringWithFormat:@"insert into activities values(null, '%f', '%f', '%d', '%d')", [schedule.date timeIntervalSince1970], [schedule.endDate timeIntervalSince1970], schedule.numSteps, schedule.numStairs];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
    
    NSString *dateQuery = [NSString stringWithFormat:@"update testDate set currentTime='%f'",[schedule.endDate timeIntervalSince1970]];
    
    // Execute the query.
    [self.dbManager executeQuery:dateQuery];
    [self.mainTabBarController.testing setTime:schedule.endDate];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
    }
}

@end
