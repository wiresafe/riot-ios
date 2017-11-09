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
#import "RecentCellData.h"


@interface WireTransferViewController ()<popOverDelegate>
{   RecentsDataSource *recentsDataSource;
    __weak IBOutlet UITextField *bankNameTextField;
    __weak IBOutlet UIScrollView *scrollView;
    
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
    RecentCellData * cellDatas;
    UITextField *activeFeild;
    __weak IBOutlet UIButton *submitButton;
    
}


@end

@implementation WireTransferViewController


-(void)viewDidLoad{
    self.navigationController.navigationItem.title = @"Wire transfer";
    [sendToRoomTextField addTarget:self action:@selector(didclickondropdown) forControlEvents:UIControlEventAllEvents];
    self.recentsTableView.tag = RecentsDataSourceModeWireTransfer;
    [self addPlusButton];
    submitButton.layer.cornerRadius = 10; // this value vary as per your desire
    submitButton.clipsToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
   
}
-(void)viewDidDisappear:(BOOL)animated{
     bankNameTextField.text = @"";
    accntNumTextField.text= @"";
    bankRoutingNoTextField.text= @"";
    accntOwnrNameTextField.text= @"";
    bankAddressTextField.text= @"";
    sendToRoomTextField.text= @"";
}
-(void)dismissKeyboard{
    [self.view endEditing:YES];
    
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    if([textField isEqual:sendToRoomTextField])
//    {
//        [textField resignFirstResponder];
//    }
//    else{
    activeFeild = textField;
    [scrollView setContentOffset:CGPointMake(0,textField.center.y-60) animated:YES];
   // }
}



// called when click on the retun button.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder) {
        [scrollView setContentOffset:CGPointMake(0,textField.center.y-60) animated:YES];
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        [textField resignFirstResponder];
        return YES;
    }
    
    return NO;
}
-(void)didclickondropdown{
    NSArray * conversationArray = recentsDataSource.conversationCellDataArray;
   // NSArray *dropdownArray =[NSArray arrayWithObjects: @"Linux", @"Matrix",@"Riot", @"Arch Linux",
                          //   nil];
    PopOverController *controller = [[PopOverController alloc]initWithNibName:@"PopOverController" bundle:nil WithArray:conversationArray];
    controller.delegate = self;
   
 //   [self presentViewController:controller animated:YES completion:nil];
    
 //   MYViewController * myViewController = [[MYViewController alloc] init];
    controller.modalPresentationStyle = UIModalPresentationPopover;
    controller.popoverPresentationController.sourceView = sendToRoomTextField;
    controller.popoverPresentationController.sourceRect = CGRectMake(100, 20, 0, 0);
    [self presentViewController:controller animated:YES completion:nil];
}


-(void)viewWillAppear:(BOOL)animated{
    [AppDelegate theDelegate].masterTabBarController.navigationItem.title = @"Wire transfer";
    [AppDelegate theDelegate].masterTabBarController.navigationController.navigationBar.tintColor = kRiotColorIndigo;
    [AppDelegate theDelegate].masterTabBarController.tabBar.tintColor = kRiotColorIndigo;
    if (recentsDataSource)
    {
        // Take the lead on the shared data source.
      //  recentsDataSource.areSectionsShrinkable = NO;
        [recentsDataSource setDelegate:self andRecentsDataSourceMode:RecentsDataSourceModeWireTransfer];
    }
    
}
- (IBAction)submit:(id)sender {
    
    bankname = bankNameTextField.text;
    accntNum = accntNumTextField.text;
    bankRoutingNum = bankRoutingNoTextField.text;
    accntOwnerName = accntOwnrNameTextField.text;
    bankAddress = bankAddressTextField.text;
    sendToRoom = sendToRoomTextField.text;
    if(![bankname isEqualToString:@""] && ![accntNum isEqualToString:@""] && ![bankRoutingNum isEqualToString:@""] && ![accntOwnerName isEqualToString:@""] && ![bankAddress isEqualToString:@""] && ![sendToRoom isEqualToString:@""]){
        NSArray* message = [NSArray arrayWithObjects:bankname,accntNum,bankRoutingNum,accntOwnerName,bankAddress, nil];
        if(self.delegate){
            [self.delegate recentListViewController:self didSelectRoom:cellDatas.roomSummary.roomId inMatrixSession:cellDatas.roomSummary.room.mxSession withMessage:message];
            
        }
    }
    else{
        UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Error:"
                                                                      message:@"Please enter all the details"
                                                               preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Ok"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
        {
            /** What we write here???????? **/
            NSLog(@"you pressed Yes, please button");
            
            // call method whatever u need
        }];
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
  
}

-(void)cellClicked:(RecentCellData *)cellData {
    [activeFeild resignFirstResponder];
    [self dismissKeyboard];
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
  
    cellDatas = cellData;
    sendToRoomTextField.text = cellDatas.roomDisplayname;
}
- (void)displayList:(MXKRecentsDataSource *)listDataSource
{   [super displayList:listDataSource];
    if ([listDataSource isKindOfClass:RecentsDataSource.class])
        {
                recentsDataSource = (RecentsDataSource*)listDataSource;
        }
    self.recentsTableView.dataSource = (id)self;
    
}
- (void)scrollToNextRoomWithMissedNotifications
{
    // Check whether the recents data source is correctly configured.
    if (recentsDataSource.recentsDataSourceMode == RecentsDataSourceModeRooms)
    {
        [self scrollToTheTopTheNextRoomWithMissedNotificationsInSection:recentsDataSource.conversationSection];
    }
}
@end
