//
//  FreshBooksOAuth.m
//  FreshestBooks
//
//  Created by Fang Chen on 7/15/12.
//  Copyright (c) 2012 GoldenGloves. All rights reserved.
//

#import "FreshBooksOAuth.h"
#import "NSString+URLEncoding.h"
#import "OAPlaintextSignatureProvider.h"
#import "OAuth_Protected.h"

@interface FreshBooksOAuth () <NSURLConnectionDataDelegate>
@end

@implementation FreshBooksOAuth
@synthesize fbCompanyName = _fbCompanyName;
@synthesize fbRequestTokenURL = _fbRequestTokenURL;
@synthesize fbAccessTokenURL = _fbAccessTokenURL;
@synthesize fbUserAuthorizationURL = _fbUserAuthorizationURL;
@synthesize delegate = _delegate;

- (NSString *)oauthHeaderForHTTPRequest {
  return [self oAuthHeaderForMethod:nil andUrl:nil andParams:nil];    
}
- (void)setFbCompanyName:(NSString *)fbCompanyName {
  if (_fbCompanyName != fbCompanyName) {
    _fbCompanyName = fbCompanyName;
    _fbRequestTokenURL = [NSString stringWithFormat:@"https://%@.freshbooks.com/oauth/oauth_request.php",_fbCompanyName];
    _fbUserAuthorizationURL = [NSString stringWithFormat:@"https://%@.freshbooks.com/oauth/oauth_authorize.php",_fbCompanyName];
    _fbAccessTokenURL = [NSString stringWithFormat:@"https://%@.freshbooks.com/oauth/oauth_access.php",_fbCompanyName];
  }
}

/**
 * Initialize an OAuth context object with a given consumer key and secret. These are immutable as you
 * always work in the context of one app.
 */
- (id)initWithConsumerKey:(NSString *)aConsumerKey andConsumerSecret:(NSString *)aConsumerSecret {
	if ((self = [super init])) {
		oauth_consumer_key = [aConsumerKey copy];
		oauth_consumer_secret = [aConsumerSecret copy];
    //		oauth_signature_method = @"HMAC-SHA1";
    oauth_signature_method = @"PLAINTEXT";
		oauth_version = @"1.0";
		self.oauth_token = @"";
		self.oauth_token_secret = @"";
		srandom(time(NULL)); // seed the random number generator, used for generating nonces
		self.oauth_token_authorized = NO;
    
    self.save_prefix = @"PlainOAuth";
	}
	
	return self;
}

//- (id)initWithConsumerKey:(NSString *)aConsumerKey andConsumerSecret:(NSString *)aConsumerSecret {
//    self = [super initWithConsumerKey:aConsumerKey andConsumerSecret:aConsumerSecret];
//    if (self) {
//        [self loadTokens];
//    }
//    return self;
//}

#pragma mark - Token Request 
/**
 * Convenience method for PIN-based flow. Start a token request with out-of-band URL.
 */
//- (void)synchronousRequestFreshBooksToken {
//    [self synchronousRequestFreshBooksTokenWithCallbackUrl:@"oob"];
//}

/**
 * Given a request URL, request an unauthorized OAuth token from that URL. This starts
 * the process of getting permission from user. This is done synchronously. If you want
 * threading, do your own.
 *
 * This is the request/response specified in OAuth Core 1.0A section 6.1.
 */
- (void)synchronousRequestFreshBooksTokenWithCallbackUrl:(NSString *)callbackUrl {
  
  NSString *url = self.fbRequestTokenURL;
	
  // Invalidate the previous request token, whether it was authorized or not.
	self.oauth_token_authorized = NO; // We are invalidating whatever token we had before.
	self.oauth_token = @"";
	self.oauth_token_secret = @"";    
  
  // Guard against someone forgetting to set the callback. Pretend that we have out-of-band request
  NSString *_callbackUrl = callbackUrl;
  if (!callbackUrl) {
    _callbackUrl = @"oob";
  }
  
  // Calculate Header
  NSDictionary *params = [NSDictionary dictionaryWithObject:_callbackUrl forKey:@"oauth_callback"];
	NSString *oauth_header = [self oAuthHeaderForMethod:@"POST" andUrl:url andParams:params];
	
  // Synchronously perform the HTTP request.
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f]; 
	[request setHTTPMethod:@"POST"];
  [request addValue:oauth_header forHTTPHeaderField:@"Authorization"];    
  
  // reading the response
  NSHTTPURLResponse *response;
  NSError *error = nil;
  NSString *responseString = [[NSString alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] encoding:NSUTF8StringEncoding];    
  
  // response handlers
	if ([response statusCode] != 200) {
		if ([self.delegate respondsToSelector:@selector(requestFreshBooksTokenDidFail:)]) {
			[self.delegate requestFreshBooksTokenDidFail:self];
		}
	} else {
		NSArray *responseBodyComponents = [responseString componentsSeparatedByString:@"&"];
		// For a successful response, break the response down into pieces and set the properties
		// with KVC. If there's a response for which there is no local property or ivar, this
		// may end up with setValue:forUndefinedKey:.
		for (NSString *component in responseBodyComponents) {
			NSArray *subComponents = [component componentsSeparatedByString:@"="];
			[self setValue:[subComponents objectAtIndex:1] forKey:[subComponents objectAtIndex:0]];			
		}
		if ([self.delegate respondsToSelector:@selector(requestFreshBooksTokenDidSucceed:)]) {
			[self.delegate requestFreshBooksTokenDidSucceed:self];
		}
	}
}
- (NSString *) oAuthHeaderForMethod:(NSString *)method
                             andUrl:(NSString *)url
                          andParams:(NSDictionary *)params
                     andTokenSecret:(NSString *)token_secret {
  
	OAPlaintextSignatureProvider *sigProvider = [[OAPlaintextSignatureProvider alloc] init];
	
	// If there were any params, URLencode them. Also URLencode their keys.
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithCapacity:[params count]];
	if (params) {
		for (NSString *key in [params allKeys]) {
			[_params setObject:[[params objectForKey:key] encodedURLParameterString] forKey: [key encodedURLParameterString]];
		}
	}
  
	// Given a signature base and secret key, calculate the signature.
	NSString *oauth_signature = [sigProvider
                               signClearText:[self oauth_signature_base:method
                                                                withUrl:url
                                                              andParams:_params]
                               withSecret:[NSString stringWithFormat:@"%@&%@", oauth_consumer_secret, token_secret]];
  
	// Return the authorization header using the signature and parameters (if any).
	return [super oauth_authorization_header:oauth_signature withParams:_params];
}

#pragma mark - Token Authorization w/ Verifier

/**
 * By this point, we have a token, and we have a verifier such as PIN from the user. We combine
 * these together and exchange the unauthorized token for a new, authorized one.
 *
 * This is the request/response specified in OAuth Core 1.0A section 6.3.
 */
- (void)synchronousAuthorizeFreshBooksTokenWithVerifier:(NSString *)oauth_verifier {
  
  NSString *url = self.fbAccessTokenURL;
  
	// We manually specify the token as a param, because it has not yet been authorized
	// and the automatic state checking wouldn't include it in signature construction or header,
	// since oauth_token_authorized is still NO by this point.
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                          oauth_token, @"oauth_token",
                          oauth_verifier, @"oauth_verifier",
                          nil];
  
	NSString *oauth_header = [self oAuthHeaderForMethod:@"POST" andUrl:url andParams:params andTokenSecret:oauth_token_secret];
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f]; 
	[request setHTTPMethod:@"POST"];
  [request addValue:oauth_header forHTTPHeaderField:@"Authorization"];
  
  NSHTTPURLResponse *response;
  NSError *error = nil;
  
  NSString *responseString = [[NSString alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] encoding:NSUTF8StringEncoding];    
	
	if ([response statusCode] != 200) {
    
    NSLog(@"HTTP return code for token authorization error: %d, message: %@, string: %@", [response statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]], responseString);
    NSLog(@"OAuth header was: %@", oauth_header);
    
		if ([self.delegate respondsToSelector:@selector(authorizeFreshBooksTokenDidFail:)]) {
			[_delegate authorizeFreshBooksTokenDidFail:self];
		}
	} else {
		NSArray *responseBodyComponents = [responseString componentsSeparatedByString:@"&"];
		for (NSString *component in responseBodyComponents) {
			// Twitter as of January 2010 returns oauth_token, oauth_token_secret, user_id and screen_name.
			// We support all these.
			NSArray *subComponents = [component componentsSeparatedByString:@"="];
			[self setValue:[subComponents objectAtIndex:1] forKey:[subComponents objectAtIndex:0]];			
		}
		
		self.oauth_token_authorized = YES;
		if ([self.delegate respondsToSelector:@selector(authorizeFreshBooksTokenDidSucceed:)]) {
			[_delegate authorizeFreshBooksTokenDidSucceed:self];
		}
    [self saveTokens];
	}
}


#pragma mark - Save / Load Token 
- (void)saveTokens {
  [super save];
  
  NSMutableDictionary *dictionaryToSave = [[NSMutableDictionary alloc] init];
  [dictionaryToSave setObject:self.fbCompanyName forKey:@"fbCompanyName"];
  //    [dictionaryToSave setObject:self.fbRequestTokenURL forKey:@"fbRequestTokenURL"];
  //    [dictionaryToSave setObject:self.fbUserAuthorizationURL forKey:@"fbUserAuthorizationURL"];
  //    [dictionaryToSave setObject:self.fbAccessTokenURL forKey:@"fbAccessTokenURL"];
  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setObject:dictionaryToSave forKey:@"FreshBooksDefaults"];
}
- (void)loadTokens {
  [super load];
  
  NSDictionary *loadedDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"FreshBooksDefaults"];
  self.fbCompanyName = [loadedDictionary objectForKey:@"fbCompanyName"];
  //    self.fbRequestTokenURL = [loadedDictionary objectForKey:@"fbRequestTokenURL"];
  //    self.fbUserAuthorizationURL = [loadedDictionary objectForKey:@"fbUserAuthorizationURL"];
  //    self.fbAccessTokenURL = [loadedDictionary objectForKey:@"fbAccessTokenURL"];
  
  NSLog(@"test self.fbAccessTokenURL = %@",self.fbAccessTokenURL);
}

@end