//
//  SettingsViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 23/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "SettingsViewController.h"
#import "TestGoalListTableViewController.h"
#import "DBManager.h"
#import "TestSettings.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *stairsLabel;
@property (weak, nonatomic) IBOutlet UIStepper *stepsStepper;
@property (weak, nonatomic) IBOutlet UIStepper *stairsStepper;
@property (nonatomic, strong) DBManager *dbManager; // database manager object.
- (IBAction)stepsAction:(id)sender;
- (IBAction)stairsAction:(id)sender;

@property TestSettings *settings;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    [self loadFromDB];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"testingMode"]) {
        self.settings.stepsTime = [self.stepsLabel.text intValue];
        self.settings.stairsTime = [self.stairsLabel.text intValue];
        [self updateSettings];
        TestGoalListTableViewController *destViewController = segue.destinationViewController;
        // Pass the goal to be veiewed.
        destViewController.settings = self.settings;
    }
}


- (IBAction)stepsAction:(id)sender {
    self.stepsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}

- (IBAction)stairsAction:(id)sender {
    self.stairsLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:[(UIStepper *)sender value]] intValue]];
}

@end
