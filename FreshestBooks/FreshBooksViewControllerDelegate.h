//
//  FreshBooksViewControllerDelegate.h
//  FreshestBooks
//
//  Created by Fang Chen on 7/15/12.
//  Copyright (c) 2012 GoldenGloves. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FreshBooksViewControllerDelegate <NSObject>

- (void)oAuthLoginPopupDidCancel:(UIViewController *)popup;
- (void)oAuthLoginPopupDidAuthorize:(UIViewController *)popup;

@end