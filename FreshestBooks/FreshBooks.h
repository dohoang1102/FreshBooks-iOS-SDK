//
//  FreshBooks.h
//  FreshestBooks
//
//  Created by Fang Chen on 7/15/12.
//  Copyright (c) 2012 GoldenGloves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FreshBooksDelegate.h"
#import "FreshBooksViewController.h"

@class FreshBooksOAuth;

@interface FreshBooks : NSObject {
  FreshBooksViewController *freshVC;
}

@property (nonatomic, strong) FreshBooksOAuth *freshOAuth;
@property (nonatomic, strong) NSString *companyName;
@property (assign) id<FreshBooksDelegate>delegate;

- (id)initWithCompanyName:(NSString *)companyName;
- (void)startSession;

@end


