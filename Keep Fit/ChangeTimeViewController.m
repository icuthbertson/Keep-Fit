//
//  ChangeTimeViewController.m
//  Keep Fit
//
//  Created by Iain Cuthbertson on 24/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import "ChangeTimeViewController.h"

@interface ChangeTimeViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *changeTimeDatePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation ChangeTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (sender != self.saveButton) return;
    
    self.changeDate = [[NSDate alloc] init];
    self.changeDate = self.changeTimeDatePicker.date;
}


@end
