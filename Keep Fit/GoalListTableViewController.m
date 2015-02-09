//
//  GoalListTableViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 09/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "GoalListTableViewController.h"
#import "KeepFitGoal.h"
#import "AddGoalViewController.h"

@interface GoalListTableViewController ()

@property NSMutableArray *keepFitGoals;

@end

@implementation GoalListTableViewController

-(void)loadInitialData {
    KeepFitGoal *goal1 = [[KeepFitGoal alloc] init];
    goal1.goalName = @"Goal1";
    [self.keepFitGoals addObject:goal1];
    KeepFitGoal *goal2 = [[KeepFitGoal alloc] init];
    goal2.goalName = @"Goal2";
    [self.keepFitGoals addObject:goal2];
    KeepFitGoal *goal3 = [[KeepFitGoal alloc] init];
    goal3.goalName = @"Goal3";
    [self.keepFitGoals addObject:goal3];
}

-(IBAction)unwindToList:(UIStoryboardSegue *)segue {
    AddGoalViewController *source = [segue sourceViewController];
    KeepFitGoal *goal = source.goal;
    if (goal != nil) {
        [self.keepFitGoals addObject:goal];
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.keepFitGoals = [[NSMutableArray alloc] init];
    [self loadInitialData];
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
    cell.textLabel.text = goal.goalName;
    if (goal.completed) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
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

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    KeepFitGoal *tappedItem = [self.keepFitGoals objectAtIndex:indexPath.row];
    tappedItem.completed = !tappedItem.completed;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
