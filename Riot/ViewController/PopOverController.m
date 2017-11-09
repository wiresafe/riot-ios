//
//  PopOverController.m
//  PopOverDemo
//
//  Created by Rajeesh R Kartha on 09/09/15.
//  Copyright (c) 2015 Rapidvalue. All rights reserved.
//

#import "PopOverController.h"


@interface PopOverController ()
{
    NSArray *contentArray;
}
@end

@implementation PopOverController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone; //You have to specify this particular value in order to make it work on iPhone.
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithArray:(NSArray *)listArray
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nil])) {
       contentArray = listArray;
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.popoverPresentationController.delegate = self;
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [contentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    RecentCellData *cellData = contentArray[indexPath.row];
    
    cell.textLabel.text = cellData.roomDisplayname;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellClicked:)]) {
        [self.delegate cellClicked:contentArray[indexPath.row]];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}
@end
