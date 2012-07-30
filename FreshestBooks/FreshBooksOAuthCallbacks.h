//
//  FreshBooksOAuthCallbacks.h
//  FreshestBooks
//
//  Created by Fang Chen on 7/15/12.
//  Copyright (c) 2012 GoldenGloves. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FreshBooks;

@protocol FreshBooksOAuthCallbacks <NSObject>

- (void)requestFreshBooksTokenDidSucceed:(FreshBooks *)freshbooks;
- (void)requestFreshBooksTokenDidFail:(FreshBooks *)freshbooks;
- (void)authorizeFreshBooksTokenDidSucceed:(FreshBooks *)freshbooks;
- (void)authorizeFreshBooksTokenDidFail:(FreshBooks *)freshbooks;

@end