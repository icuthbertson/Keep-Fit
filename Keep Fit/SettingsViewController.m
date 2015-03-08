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

@property MainTabBarViewController *mainTabBarController;

@property TestSettings *settings;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mainTabBarController = (MainTabBarViewController *)self.tabBarController;
    
    // Set up the scroll view.
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 700)];
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
    
    [self loadFromDB];
    [self setUpView];
}

-(void)viewWillAppear:(BOOL)animated {
    [self setUpView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpView {
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

-(void)updateSettings {
    // Update goal in DB.
    NSString *query = [NSString stringWithFormat:@"update testSettings set stepsTime='%d', stairsTime='%d'", self.settings.stepsTime, self.settings.stairsTime];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else {
        NSLog(@"Could not execute the query.");
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
        destViewController.currentTime = [self.mainTabBarController.testing getTime];
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
    [self updateSettings];
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
