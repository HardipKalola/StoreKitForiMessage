//
//  MessagesViewController.h
//  MessagesExtension
//
//  Created by SOTSYS113 on 12/12/16.
//  Copyright © 2016 SOTSYS113. All rights reserved.
//

#import <Messages/Messages.h>
#import <StoreKit/StoreKit.h>
#import "StoreKitController.h"
#import "MBProgressHUD.h"

@interface MessagesViewController : MSMessagesAppViewController 

{
    
}
@property (strong, nonatomic) StoreKitController *SKObj;
@property (nonatomic) NSInteger productIDIndex;

@end
