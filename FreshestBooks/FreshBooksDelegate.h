//
//  FreshBooksDelegate.h
//  FreshestBooks
//
//  Created by Fang Chen on 7/28/12.
//  Copyright (c) 2012 GoldenGloves. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FreshBooks;

@protocol FreshBooksDelegate <NSObject>

- (void)didAuthorizeFreshBooks;
- (void)didEpicFail;

@end
