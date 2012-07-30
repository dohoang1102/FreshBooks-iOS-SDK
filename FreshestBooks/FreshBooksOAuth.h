//
//  FreshBooksOAuth.h
//  FreshestBooks
//
//  Created by Fang Chen on 7/15/12.
//  Copyright (c) 2012 GoldenGloves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuth.h"
#import "FreshBooksOAuthCallbacks.h"

@interface FreshBooksOAuth : OAuth

@property (assign) id<FreshBooksOAuthCallbacks>delegate;

/**
 * company subdomain
 */
@property (strong, nonatomic) NSString *fbCompanyName;
@property (strong, nonatomic) NSString *fbRequestTokenURL;
@property (strong, nonatomic) NSString *fbUserAuthorizationURL;
@property (strong, nonatomic) NSString *fbAccessTokenURL;

/**
 * oauth header for http requests
 */
- (NSString *)oauthHeaderForHTTPRequest;

@end