//
//  ListSelectionViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 24/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "ListSelectionViewController.h"

@interface ListSelectionViewController ()

@property NSArray *menuItems;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation ListSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.menuItems = @[@"Default", @"All", @"Pending", @"Active", @"Overdue", @"Suspended", @"Abandoned", @"Completed"];
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
    
    if ([CellIdentifier isEqualToString:@"Default"]) {
        NSString *defaultListQuery = [[NSString alloc] init];
        int count = 0;
        if (self.settings.pending) {
            if (count == 0) {
                defaultListQuery = [NSString stringWithFormat:@"Pending"];
            }
            else {
                defaultListQuery = [NSString stringWithFormat:@"%@, Pending",defaultListQuery];
            }
            count++;
        }
        if (self.settings.active) {
            if (count == 0) {
                defaultListQuery = [NSString stringWithFormat:@"Active"];
            }
            else {
                defaultListQuery = [NSString stringWithFormat:@"%@, Active",defaultListQuery];
            }
            count++;
        }
        if (self.settings.overdue) {
            if (count == 0) {
                defaultListQuery = [NSString stringWithFormat:@"Overdue"];
            }
            else {
                defaultListQuery = [NSString stringWithFormat:@"%@, Overdue",defaultListQuery];
            }
            count++;
        }
        if (self.settings.suspended) {
            if (count == 0) {
                defaultListQuery = [NSString stringWithFormat:@"Suspened"];
            }
            else {
                defaultListQuery = [NSString stringWithFormat:@"%@, Suspended",defaultListQuery];
            }
            count++;
        }
        if (self.settings.abandoned) {
            if (count == 0) {
                defaultListQuery = [NSString stringWithFormat:@"Abandoned"];
            }
            else {
                defaultListQuery = [NSString stringWithFormat:@"%@, Abandoned",defaultListQuery];
            }
            count++;
        }
        if (self.settings.completed) {
            if (count == 0) {
                defaultListQuery = [NSString stringWithFormat:@"Completed"];
            }
            else {
                defaultListQuery = [NSString stringWithFormat:@"%@, Completed",defaultListQuery];
            }
            count++;
        }
        if (count == 0) {
            defaultListQuery = [NSString stringWithFormat:@"Nothing"];
        }
        else if (count == 6)
        {
            defaultListQuery = [NSString stringWithFormat:@"Everything"];
        }
        cell.detailTextLabel.text = defaultListQuery;
    }
    
    return cell;
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}*/


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
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSInteger row = indexPath.row;
    
    if (sender == self.cancelButton) {
        self.listType = 8; //default for cancel.
        return;
    }
    
    switch (row) {
        case 0: //Pending, Active, Overdue
            NSLog(@"Pending, Active, Overdue, Suspended");
            self.listType = 7;
            break;
        case 1: //All
            NSLog(@"Selection All");
            self.listType = 6;
            break;
        case 2: //Pending
            NSLog(@"Selection Pending");
            self.listType = 0;
            break;
        case 3: //Active
            NSLog(@"Selection Active");
            self.listType = 1;
            break;
        case 4: //Overdue
            NSLog(@"Selection Overdue");
            self.listType = 2;
            break;
        case 5: //Suspended
            NSLog(@"Selection Suspended");
            self.listType = 3;
            break;
        case 6: //Abandoned
            NSLog(@"Selection Abandoned");
            self.listType = 4;
            break;
        case 7: //Completed
            NSLog(@"Selection Completed");
            self.listType = 5;
            break;
        default: //Should never reach
            NSLog(@"Selection Should Never Reach");
            self.listType = 6;
            break;
    }
}


@end
