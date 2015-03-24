//
//  ListSelectionViewController.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 24/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"

@interface ListSelectionViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property NSInteger listType;
@property Settings *settings;

@end
