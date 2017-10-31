//
//  WireTransferViewController.h
//  Riot
//
//  Created by Shahina on 27/10/17.
//  Copyright © 2017 matrix.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecentsViewController.h"

@interface WireTransferViewController :RecentsViewController<UITextFieldDelegate>

- (void)scrollToNextRoomWithMissedNotifications;
@end
