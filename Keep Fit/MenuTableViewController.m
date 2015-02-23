//
//  MenuTableViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 23/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "MenuTableViewController.h"
#import "SWRevealViewController.h"
#import "GoalListTableViewController.h"


@interface MenuTableViewController ()

@property NSArray *menuItems;

@end

@implementation MenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuItems = @[@"All", @"Pending", @"Active", @"Overdue", @"Suspended", @"Abandoned", @"Completed", @"Blank", @"Settings"];
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:NO];
    [self.revealViewController.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:YES];
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
    return self.menuItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //SWRevealViewController *revealController = self.revealViewController;
    
    NSInteger row = indexPath.row;
    
    //GoalListTableViewController *frontController = nil;
    //frontController = [[GoalListTableViewController alloc] init];
    
    //[revealController pushFrontViewController:frontController animated:YES];
    
    UINavigationController *navigationController = (UINavigationController *)self.revealViewController.frontViewController;
    GoalListTableViewController *destAddController = [[navigationController viewControllers]objectAtIndex:0];
    
    switch (row) {
        case 0:
            destAddController.listType = 6;
            break;
        case 1:
            destAddController.listType = 0;
            break;
        case 2:
            destAddController.listType = 1;
            break;
        case 3:
            destAddController.listType = 2;
            break;
        case 4:
            destAddController.listType = 3;
            break;
        case 5:
            destAddController.listType = 4;
            break;
        case 6:
            destAddController.listType = 5;
            break;
        case 9:
            //to settings
            break;
            
        default:
            break;
    }
    
    [destAddController loadFromDB];
    
    [self.revealViewController revealToggleAnimated:YES];
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

@end
