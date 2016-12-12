//
//  StoreKitController.h
//
//  Created by Pradip Vanparia on 27/12/13.
//
//

#import <Foundation/Foundation.h>

typedef void (^SKCompletionHandler)(BOOL success, NSArray *PurchasedProducts ,NSArray *FailedProducts);


#define ErrorTrasactionNotification  @"TrasactionErrorNotification"

@interface StoreKitController : NSObject

+(StoreKitController *)SharedInstance;

-(void)doBuyProductWithIdentifiers:(NSSet *)productIdentifiers withCompletionHandler:(SKCompletionHandler)handler1;

- (void)requestProductsWithCompletionHandler:(SKCompletionHandler)completionHandler;

-(void)restoreProductWithCompletionHandler:(SKCompletionHandler) restoreHandler;

@end
