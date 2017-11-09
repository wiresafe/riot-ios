//
//  PopOverController.h
//  PopOverDemo
//
//  Created by Rajeesh R Kartha on 09/09/15.
//  Copyright (c) 2015 Rapidvalue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecentCellData.h"
@protocol popOverDelegate <NSObject>
- (void)cellClicked:(RecentCellData*)cellData;
@end
@interface PopOverController : UIViewController <UIPopoverPresentationControllerDelegate>
@property(weak,nonatomic) IBOutlet id <popOverDelegate> delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithArray:(NSArray *)listDict;

@end
