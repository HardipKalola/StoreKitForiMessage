//
//  StoreKitController.m
//
//  Created by Pradip Vanparia on 27/12/13.
//
//

#import "StoreKitController.h"
#import <StoreKit/StoreKit.h>


@interface StoreKitController () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

@implementation StoreKitController{
    SKProductsRequest * _productsRequest;
    SKCompletionHandler _completionHandler;
    SKCompletionHandler _restoreHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
    NSMutableSet * _failedProductIdentifiers;
    NSArray *arrProducts;

}

StoreKitController *Instance;

+(StoreKitController *)SharedInstance
{
    if (Instance) {
        return Instance;
    }
    Instance = [[StoreKitController alloc] init];
    return Instance;
}

-(void)doBuyProductWithIdentifiers:(NSSet *)productIdentifiers withCompletionHandler:(SKCompletionHandler)handler1
{
    _completionHandler = [handler1 copy];
    
    if ([SKPaymentQueue canMakePayments])
    {
        _productIdentifiers = productIdentifiers;
        _purchasedProductIdentifiers = [[NSMutableSet alloc] init];
        _failedProductIdentifiers = [[NSMutableSet alloc] init];
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

        SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
        request.delegate = self;
        [request start];
    }
    else
    {
        _completionHandler(NO, nil ,nil);
        _completionHandler = nil;
    }
}
- (void)requestProductsWithCompletionHandler:(SKCompletionHandler)completionHandler {
    
    NSLog(@"requestProductsWithCompletionHandler");
    // 1
    arrProducts = [[NSArray alloc] init];
//    arrProducts = [Helper getProductIdentifiers];
    
    _completionHandler = [completionHandler copy];
    _productIdentifiers = [NSSet setWithObject:arrProducts];

    // 2
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
   
    NSArray *myProduct = response.products;

    int q = (int)myProduct.count;
    if (q == 0)
    {
        _completionHandler(NO, nil ,response.invalidProductIdentifiers);
        _completionHandler = nil;
        
        return;
    }
    for (SKProduct *product in myProduct) {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil ,[_productIdentifiers allObjects]);
    _completionHandler = nil;
    
}

-(void)restoreProductWithCompletionHandler:(SKCompletionHandler)restoreHandler;
{
    _restoreHandler = [restoreHandler copy];
    _productIdentifiers = nil;
    _purchasedProductIdentifiers = [[NSMutableSet alloc] init];
    _failedProductIdentifiers = [[NSMutableSet alloc] init];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
                
            default:
                break;
        }
    }

}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    [self validateReceiptForTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    
    [self validateReceiptForTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
        NSNotification* failedNotification = [NSNotification notificationWithName: ErrorTrasactionNotification
                                                                            object: transaction.error
                                                                          userInfo: transaction.error.userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:failedNotification];
    }
    [_failedProductIdentifiers addObject:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self checkTrasactionProcess];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{

    NSNotification* failedNotification = [NSNotification notificationWithName: ErrorTrasactionNotification
                                                                       object: error
                                                                     userInfo: error.userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:failedNotification];

    if (_restoreHandler) {
        _restoreHandler (NO,nil,nil);
    }
    _restoreHandler = nil;
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    if (_restoreHandler) {
        _restoreHandler(_purchasedProductIdentifiers.count?YES:NO,[_purchasedProductIdentifiers allObjects] ,[_failedProductIdentifiers allObjects]);
    }
    _restoreHandler = nil;
}

- (void)validateReceiptForTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Successfully verified receipt!");
    [_purchasedProductIdentifiers addObject:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self checkTrasactionProcess];
    
}

-(void)checkTrasactionProcess
{
    if (_productIdentifiers)
    {
    if (_productIdentifiers.count == (_purchasedProductIdentifiers.count + _failedProductIdentifiers.count)) {
        if (_completionHandler) {
            NSLog(@"%@",_purchasedProductIdentifiers);
            if ([_purchasedProductIdentifiers count]!=0) {
//                [Flurry logEvent:[NSString stringWithFormat:@"PurchasedInApp%@",[[_purchasedProductIdentifiers allObjects] objectAtIndex:0]]];
            }
            _completionHandler(_purchasedProductIdentifiers.count?YES:NO,[_purchasedProductIdentifiers allObjects] ,[_failedProductIdentifiers allObjects]);
            _completionHandler = nil;
        }
    }
    }
}

-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}
@end
