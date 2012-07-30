//
//  FreshBooksViewController.m
//  FreshestBooks
//
//  Created by Fang Chen on 7/15/12.
//  Copyright (c) 2012 GoldenGloves. All rights reserved.
//

#import "FreshBooksViewController.h"
#import "FreshBooksOAuth.h"
#import "HTMLParser.h"

@interface FreshBooksViewController () <UIWebViewDelegate, FreshBooksOAuthCallbacks>
@property (strong, nonatomic) UIWebView *webView;
@property (weak, nonatomic) UIBarButtonItem *cancelButton;
@end

@implementation FreshBooksViewController
@synthesize oAuthDelegate = _oAuthDelegate;
@synthesize uiDelegate = _uiDelegate;
@synthesize freshOAuth = _freshOAuth;
@synthesize webView = _webView;
@synthesize cancelButton = _cancelButton;
@synthesize queue = _queue;

#pragma mark -
#pragma mark - boilerplate
- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  self.freshOAuth.delegate = self;    
  // create an ordered nsoperation queue for handling the oauth dance
  if (!self.queue) {
    self.queue = [[NSOperationQueue alloc] init];
  }
  // first we'll need an unauthorized token from freshbook's server
  if (!self.freshOAuth.oauth_token_authorized) {
    [self requestTokenWithCallback:@"oob"];
  } else {
    [self.uiDelegate oAuthLoginPopupDidAuthorize:self];
  }
}
- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  [self setOAuthDelegate:nil];
  [self setUiDelegate:nil];
  [self setCancelButton:nil];
  [self.webView setDelegate:nil];
  [self setWebView:nil];
  [self setQueue:nil];
}

#pragma mark -
#pragma mark - web view delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  NSLog(@"web view should start load with request = %@", request);
  return YES;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  NSLog(@"webView delegate error = %@",error);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];   
  /* since freshbooks isn't redirecting to our oob callback url, we are unable to intercept any obvious oauth_verifer key the response, which is why we're using this as a temp solution; parse the webview's html */
  NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"]; NSLog(@"logging html document body... %@",html);
  NSError *error = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
  HTMLNode *bodyNode = [parser body];
  HTMLNode *boxMainNode = [bodyNode findChildOfClass:@"box-main"];
  HTMLNode *boxBottomNode = [boxMainNode findChildOfClass:@"binding-content cut-bottom"];
  for (HTMLNode *node in boxBottomNode.children) {
    if ([[node getAttributeNamed:@"class"] isEqualToString:@"verifier"]) {
      HTMLNode *verifierNode = [boxBottomNode findChildOfClass:@"verifier"];
      NSLog(@"We've got our verifier key = %@", verifierNode.contents);
      [self handleOAuthVerifier:verifierNode.contents];
    }
  }
}



#pragma mark - 
#pragma mark - the oauth dance
#pragma mark - 0: Token Request Cancelled (dismiss popup) 
- (IBAction)cancelTokenRequest:(UIBarButtonItem *)sender {
  /* popup delegate */
  [self.queue cancelAllOperations];
  [self.uiDelegate oAuthLoginPopupDidCancel:self];
}
#pragma mark - 1: Requesting Unauthorized Tokens
- (void)requestTokenWithCallback:(NSString *)callbackUrl {
  /* uiDelegate */
  [self.oAuthDelegate tokenRequestDidStart:self];
  /* add to queue synchronousRequestFreshBooksTokenWithCallbackUrl:callbackUrl */
  NSInvocationOperation *operation = [[NSInvocationOperation alloc]
                                      initWithTarget:self.freshOAuth
                                      selector:@selector(synchronousRequestFreshBooksTokenWithCallbackUrl:)
                                      object:callbackUrl];
  [self.queue addOperation:operation];
}
#pragma mark - 1-B: Token Request Callback (OAuthFreshBooksCallbacks delegate methods)
- (void)requestFreshBooksTokenDidSucceed:(FreshBooks *)freshbooks {
  /* begin authorization sequence */
  if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(authorizeFreshBooksToken:)
                           withObject:freshbooks
                        waitUntilDone:YES];
	} else {
    [self authorizeFreshBooksToken:freshbooks];
  }
}
- (void)requestFreshBooksTokenDidFail:(FreshBooks *)freshbooks {
  /* uiDelegate */
  [self.oAuthDelegate tokenRequestDidFail:self];
}
#pragma mark - 2: Token Authorization
- (void)authorizeFreshBooksToken:(FreshBooks *)freshbooks {
  /* uiDelegate */
  [self.oAuthDelegate tokenRequestDidSucceed:self];
  /* url for authorization request */
  NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?oauth_callback=oob&oauth_token=%@",_freshOAuth.fbUserAuthorizationURL, _freshOAuth.oauth_token]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:myURL];
  [request setHTTPMethod:@"GET"];
  /* create and set our web view for token authorization */
  if (!self.webView) {
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
  }
  /* load request */
	[self.webView loadRequest:request];
}
#pragma mark - 2-B: Handle OAuth Verifier & Step 3: Perform Token Exchange (in FreshBooks)
- (void)handleOAuthVerifier:(NSString *)oauth_verifier {
  /* uiDelegate */
	[self.oAuthDelegate authorizationRequestDidStart:self];
  /* add selector to queue synchronousAuthorizeFreshBooksTokenWithVerifier:oauth_verifier */
	NSInvocationOperation *operation = [[NSInvocationOperation alloc]
                                      initWithTarget:self.freshOAuth
                                      selector:@selector(synchronousAuthorizeFreshBooksTokenWithVerifier:)
                                      object:oauth_verifier];
	[self.queue addOperation:operation];
}
#pragma mark - 3-B: Token Authorization Callback (OAuthFreshBooksCallback delegate methods)
- (void)authorizeFreshBooksTokenDidSucceed:(FreshBooks *)freshbooks {
  [self authorizationComplete];
  /* uiDelegate */
  if ([self.uiDelegate respondsToSelector:@selector(authorizationRequestDidSucceed:)]) {
    [self.oAuthDelegate authorizationRequestDidSucceed:self];
  }
}
- (void)authorizeFreshBooksTokenDidFail:(FreshBooks *)freshbooks {
  /* uiDelegate */
  if ([self.oAuthDelegate respondsToSelector:@selector(authorizationRequestDidFail:)]) {
    [self.oAuthDelegate authorizationRequestDidFail:self];
  }
}
#pragma mark - 4: Token Authorization Completed (dismiss popup)
- (void)authorizationComplete {
  /* popup delegate */
  if ([self.uiDelegate respondsToSelector:@selector(oAuthLoginPopupDidAuthorize:)]) {
    [self.uiDelegate oAuthLoginPopupDidAuthorize:self];
  }
}


@end