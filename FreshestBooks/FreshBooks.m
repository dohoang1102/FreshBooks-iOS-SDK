//
//  FreshBooks.m
//  FreshestBooks
//
//  Created by Fang Chen on 7/15/12.
//  Copyright (c) 2012 GoldenGloves. All rights reserved.
//

#import "FreshBooks.h"
#import "FreshBooksOAuth.h"
#import "OAuthConsumerCredentials.h"
/**
 todo list
 #import "FreshBooksRequestHandler"
 #import "FreshBooksXMLParser"
 */

@interface FreshBooksOAuth () <FreshBooksOAuthCallbacks>
@end

@implementation FreshBooks
@synthesize freshOAuth = _freshOAuth;
@synthesize companyName = _companyName;
@synthesize delegate;

- (id)initWithCompanyName:(NSString *)companyName {
  self = [super init];
  if (self) {
    if (!_companyName) {
      _companyName = companyName;
    }
  }
  return self;
}
- (void)startSession {
  
  if (!_freshOAuth) {
    _freshOAuth  = [[FreshBooksOAuth alloc] initWithConsumerKey:OAUTH_CONSUMER_KEY andConsumerSecret:OAUTH_CONSUMER_SECRET];
  }
  
  UIViewController *mainVC = (UIViewController *)self.delegate;
  
  if (!freshVC) {
    freshVC = [[FreshBooksViewController alloc] init];
    [freshVC setFreshOAuth:_freshOAuth];
    [freshVC setOAuthDelegate:_freshOAuth];
    [freshVC setUiDelegate:self];
  }
  
  if ([mainVC respondsToSelector:@selector(presentViewController:animated:completion:)]) {
    [mainVC presentViewController:freshVC animated:YES completion:^{
      // popup view controller is working
      
      
    }];
  }
  
}

#pragma mark -
#pragma mark - FRESHBOOKSOAUTHCALLBACKS
- (void)requestFreshBooksTokenDidSucceed:(FreshBooks *)freshbooks {
}
- (void)requestFreshBooksTokenDidFail:(FreshBooks *)freshbooks {
}
- (void)authorizeFreshBooksTokenDidSucceed:(FreshBooks *)freshbooks {
}
- (void)authorizeFreshBooksTokenDidFail:(FreshBooks *)freshbooks {
}

#pragma mark -
#pragma mark - FRESHBOOKS



@end



