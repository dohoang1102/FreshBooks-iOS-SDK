//
//  OAuth_Protected.h
//  MileageAssistant
//
//  Created by Fang Chen on 6/6/12.
//  Copyright (c) 2012 GoldenGloves. All rights reserved.
//

#import "OAuth.h"

@interface OAuth ()
- (NSString *) oauth_signature_base:(NSString *)httpMethod withUrl:(NSString *)url andParams:(NSDictionary *)params;
- (NSString *) oauth_authorization_header:(NSString *)oauth_signature withParams:(NSDictionary *)params;
- (NSString *) sha1:(NSString *)str;
- (NSArray *) oauth_base_components;
@end
