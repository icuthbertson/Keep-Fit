//
//  TestViewGoalViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 24/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "TestViewGoalViewController.h"
#import "TestHistoryTableViewController.h"
#import "DBManager.h"

@interface TestViewGoalViewController ()

@property DBManager *dbManager;
@property (weak, nonatomic) IBOutlet UILabel *viewTitle;
@property (weak, nonatomic) IBOutlet UILabel *viewType;
@property (weak, nonatomic) IBOutlet UILabel *viewDateCreated;
@property (weak, nonatomic) IBOutlet UILabel *viewDateCompletion;
@property (weak, nonatomic) IBOutlet UIProgressView *viewProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *viewProgress;
@property (weak, nonatomic) IBOutlet UILabel *viewDateStart;
@property (weak, nonatomic) IBOutlet UIButton *outletHistoryButton;
@property (weak, nonatomic) IBOutlet UILabel *viewStatus;

@end

@implementation TestViewGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"goalsDB.sql"];
    
    [self showDetails];
}

-(void)showDetails {
    self.navigationItem.title = [NSString stringWithFormat:@"%@", self.viewGoal.goalName];
    switch (self.viewGoal.goalStatus) {
        case Pending:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@", self.viewGoal.goalName];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Pending"];
            break;
        case Active:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@", self.viewGoal.goalName];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Active"];
            break;
        case Overdue:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@", self.viewGoal.goalName];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Overdue"];
            break;
        case Suspended:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@", self.viewGoal.goalName];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Suspended"];
            break;
        case Abandoned:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@", self.viewGoal.goalName];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Abandoned"];
            break;
        case Completed:
            self.viewTitle.text = [NSString stringWithFormat:@"Goal Name: %@", self.viewGoal.goalName];
            self.viewStatus.text = [NSString stringWithFormat:@"Goal Status: Completed"];
            break;
        default:
            break;
    }
    
    switch (self.viewGoal.goalType) {
        case Steps:
            self.viewType.text = [NSString stringWithFormat:@"Goal Type: Steps"];
            self.viewProgress.text = [NSString stringWithFormat:@"Steps: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps) animated:YES];
            break;
        case Stairs:
            self.viewType.text = [NSString stringWithFormat:@"Goal Type: Stairs"];
            self.viewProgress.text = [NSString stringWithFormat:@"Stairs: %ld/%ld",(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
            [self.viewProgressBar setProgress:(float)((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs) animated:YES];
            break;
        case Both:
            self.viewType.text = [NSString stringWithFormat:@"Goal Type: Steps and Stairs"];
            self.viewProgress.text = [NSString stringWithFormat:@"Steps: %ld/%ld  Stairs: %ld/%ld",(long)self.viewGoal.goalProgressSteps,(long)self.viewGoal.goalAmountSteps,(long)self.viewGoal.goalProgressStairs,(long)self.viewGoal.goalAmountStairs];
            [self.viewProgressBar setProgress:(float)((((float)self.viewGoal.goalProgressSteps/(float)self.viewGoal.goalAmountSteps)/2)+(((float)self.viewGoal.goalProgressStairs/(float)self.viewGoal.goalAmountStairs)/2)) animated:YES];
            break;
        default:
            break;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //uncomment to get the time only
    //[formatter setDateFormat:@"hh:mm a"];
    //[formatter setDateFormat:@"MMM dd, YYYY"];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    self.viewDateCreated.text = [NSString stringWithFormat:@"Date Created: %@",[formatter stringFromDate:self.viewGoal.goalCreationDate]];
    self.viewDateStart.text = [NSString stringWithFormat:@"Start Date: %@",[formatter stringFromDate:self.viewGoal.goalStartDate]];
    self.viewDateCompletion.text = [NSString stringWithFormat:@"Completion Date: %@",[formatter stringFromDate:self.viewGoal.goalCompletionDate]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)unwindFromChangeTime:(UIStoryboardSegue *)segue {
    
}

-(IBAction)unwindFromSchedule:(UIStoryboardSegue *)segue {
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showHistoryTest"]) {
        TestHistoryTableViewController *destViewController = segue.destinationViewController;
        destViewController.viewHistoryGoal = self.viewGoal;
    }
}

@end
