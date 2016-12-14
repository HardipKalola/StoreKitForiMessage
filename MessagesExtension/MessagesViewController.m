//
//  MessagesViewController.m
//  MessagesExtension
//
//  Created by Hardip Kalola on 12/12/16.
//  Copyright © 2016 Hardip Kalola. All rights reserved.
//

#import "MessagesViewController.h"


#define in_app_id  @"your product identifier"


@interface MessagesViewController ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
    NSArray *arrProducts;
    SKProductsRequest *purchaseProVersion;
    NSString *selectedProduct;
    NSSet *productIdentifiers;
    NSSet *invalidProductIdentifiers;
    NSString *currentIdentifier;
    NSString *productPrice;
    NSArray *products;
}
@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    Retrive In App Data Like...Product Name/Product Price/Product Detail
//    [self retrieveInAppData];
    
//    Init Once
    [self initializeOnce];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - init Once For StoreKit
-(void)initializeOnce{
    
    //StoreKit Alloc Init
    _SKObj = [[StoreKitController alloc] init];
    
    //Get Product From Plist
    arrProducts = [[NSArray alloc] init];
    arrProducts = [self getProductIdentifiers];
    
    if ([SKPaymentQueue canMakePayments])
    {
        purchaseProVersion = [[SKProductsRequest alloc] initWithProductIdentifiers:
                              [NSSet setWithObjects:[arrProducts objectAtIndex:_productIDIndex],nil]];
        purchaseProVersion.delegate = self;
        [purchaseProVersion start];
    }
}
#pragma mark - In App Purchase
-(void) retrieveInAppData {
    
    // Start the IAP Store
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    productIdentifiers =[NSSet setWithObjects:
                         in_app_id,nil];
    
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    request.delegate = self;
    [request start];
}
#pragma mark - SKProductsRequest Delegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse: (SKProductsResponse *)response {
    
    SKProduct *product;
    NSLog(@"response ...%@",response.products);
    products = response.products;
    
    invalidProductIdentifiers = (NSSet *)response.invalidProductIdentifiers;
    
    for (product in response.products)
    {
        //	product = [response.products objectAtIndex:0];
        currentIdentifier = [NSString stringWithFormat:@"%@", product.productIdentifier];
        NSLog(@"Purchase request for: %@", product.productIdentifier);
        
        // format the price for the location
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
        
        // See if the was a purchase request or a product info request
        productPrice = formattedPrice;
        NSLog(@"productPrice =%@",formattedPrice);
        NSString *formattedPriceStr = [formattedPrice substringWithRange: NSMakeRange (1, 1)];
        NSLog(@"formattedPriceStr =%@",formattedPriceStr);
        NSLog(@"product.productIdentifier =%@",product.productIdentifier);
        
        // Store the price
//        [[NSUserDefaults standardUserDefaults] setObject:formattedPrice forKey:product.productIdentifier];
    }
}

#pragma mark - get Product From Plist file
-(NSArray*)getProductIdentifiers
{
    NSString *strFilePath = [[NSBundle mainBundle] pathForResource:@"ProductIdentifiers" ofType:@"plist"];
    NSDictionary *dictPList =[NSDictionary dictionaryWithContentsOfFile:strFilePath];
    NSArray *arrIdentifiers = [dictPList objectForKey:@"ProductIdentifiers"];
    return arrIdentifiers;
}
#pragma mark - Purchase Product Clicked
- (IBAction)purchaseProduct:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [_SKObj doBuyProductWithIdentifiers:[NSSet setWithObject:in_app_id] withCompletionHandler:^(BOOL success, NSArray *PurchasedProducts, NSArray *FailedProducts)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
        if (success)
        {
            NSLog(@"Your Product Purchase Successfully.");
        }
    }];
}

#pragma mark - Conversation Handling

-(void)didBecomeActiveWithConversation:(MSConversation *)conversation {
    // Called when the extension is about to move from the inactive to active state.
    // This will happen when the extension is about to present UI.
    
    // Use this method to configure the extension and restore previously stored state.
}

-(void)willResignActiveWithConversation:(MSConversation *)conversation {
    // Called when the extension is about to move from the active to inactive state.
    // This will happen when the user dissmises the extension, changes to a different
    // conversation or quits Messages.
    
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough state information to restore your extension to its current state
    // in case it is terminated later.
}

-(void)didReceiveMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when a message arrives that was generated by another instance of this
    // extension on a remote device.
    
    // Use this method to trigger UI updates in response to the message.
}

-(void)didStartSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when the user taps the send button.
}

-(void)didCancelSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when the user deletes the message without sending it.
    
    // Use this to clean up state related to the deleted message.
}

-(void)willTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    // Called before the extension transitions to a new presentation style.
    
    // Use this method to prepare for the change in presentation style.
}

-(void)didTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    // Called after the extension transitions to a new presentation style.
    
    // Use this method to finalize any behaviors associated with the change in presentation style.
}

@end
