//
//  FreshBooksViewControllerOAuthDelegate.h
//  FreshestBooks
//
//  Created by Fang Chen on 7/15/12.
//  Copyright (c) 2012 GoldenGloves. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FreshBooksViewController;

@protocol FreshBooksViewControllerOAuthDelegate <NSObject>

// token request protocol 
- (void)tokenRequestDidStart:(FreshBooksViewController *)fbLogin;
- (void)tokenRequestDidSucceed:(FreshBooksViewController *)fbLogin;
- (void)tokenRequestDidFail:(FreshBooksViewController *)fbLogin;

// token authorization protocol
- (void)authorizationRequestDidStart:(FreshBooksViewController *)fbLogin;
- (void)authorizationRequestDidSucceed:(FreshBooksViewController *)fbLogin;
- (void)authorizationRequestDidFail:(FreshBooksViewController *)fbLogin;

@end
