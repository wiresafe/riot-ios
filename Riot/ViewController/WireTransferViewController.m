//
//  WireTransferViewController.m
//  Riot
//
//  Created by Shahina on 27/10/17.
//  Copyright © 2017 matrix.org. All rights reserved.
//

#import "WireTransferViewController.h"

#import "AppDelegate.h"

#import "RecentsDataSource.h"
#import "PopOverController.h"


@interface WireTransferViewController ()<popOverDelegate>
{
    __weak IBOutlet UITextField *bankNameTextField;
    
    __weak IBOutlet UITextField *sendToRoomTextField;
    __weak IBOutlet UITextField *accntNumTextField;
    __weak IBOutlet UITextField *bankRoutingNoTextField;
    __weak IBOutlet UITextField *accntOwnrNameTextField;
    __weak IBOutlet UITextField *bankAddressTextField;
    
    NSString * bankname;
    NSString * accntNum;
    NSString * bankRoutingNum;
    NSString * accntOwnerName;
    NSString * bankAddress;
    NSString * sendToRoom;
    UIPopoverController *uiPopOver;
    
}


@end

@implementation WireTransferViewController


-(void)viewDidLoad{
    self.navigationController.navigationItem.title = @"Wire transfer";
    [sendToRoomTextField addTarget:self action:@selector(didclickondropdown) forControlEvents:UIControlEventTouchDown];
}
-(void)didclickondropdown{
    NSArray *dropdownArray =[NSArray arrayWithObjects: @"Linux", @"Matrix",@"Riot", @"Arch Linux",
                             nil];
    PopOverController *controller = [[PopOverController alloc]initWithNibName:@"PopOverController" bundle:nil WithArray:dropdownArray];
    controller.delegate = self;
   
    [self presentViewController:controller animated:YES completion:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [AppDelegate theDelegate].masterTabBarController.navigationItem.title = @"Wire transfer";
    [AppDelegate theDelegate].masterTabBarController.navigationController.navigationBar.tintColor = kRiotColorIndigo;
    [AppDelegate theDelegate].masterTabBarController.tabBar.tintColor = kRiotColorIndigo;
}
- (IBAction)submit:(id)sender {
    bankname = bankNameTextField.text;
    accntNum = accntNumTextField.text;
    bankRoutingNum = bankRoutingNoTextField.text;
    accntOwnerName = accntOwnrNameTextField.text;
    bankAddress = bankAddressTextField.text;
    sendToRoom = sendToRoomTextField.text;
}

-(void)cellClicked:(NSString *)text {
    sendToRoomTextField.text = text;
}

@end
