//
//  FreshBooksOAuthViewController.h
//  FreshestBooks
//
//  Created by Fang Chen on 7/15/12.
//  Copyright (c) 2012 GoldenGloves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FreshBooksViewControllerDelegate.h"
#import "FreshBooksViewControllerOAuthDelegate.h"

@class FreshBooksOAuth;

@interface FreshBooksViewController : UIViewController

@property (assign) id<FreshBooksViewControllerDelegate>uiDelegate;
@property (assign) id<FreshBooksViewControllerOAuthDelegate>oAuthDelegate;

@property (strong, nonatomic) FreshBooksOAuth *freshOAuth;
@property (strong, nonatomic) NSOperationQueue *queue;

@end
