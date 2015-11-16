//
//  TDAuthorizer.h
//  TouchDB
//
//  Created by Jens Alfke on 5/21/12.
//  Copyright (c) 2012 Couchbase, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Protocol for adding authorization to HTTP requests. */
@protocol TDAuthorizer <NSObject>

/** Should generate and return an authorization string for the given request.
    The string, if non-nil, will be set as the value of the "Authorization:" HTTP header. */
- (NSString*)authorizeURLRequest:(NSMutableURLRequest*)request forRealm:(NSString*)realm;

- (NSString*)authorizeHTTPMessage:(CFHTTPMessageRef)message forRealm:(NSString*)realm;

@optional

- (NSString*)loginPathForSite:(NSURL*)site;
- (NSDictionary*)loginParametersForSite:(NSURL*)site;

@end

/** Simple implementation of TDAuthorizer that does HTTP Basic Auth. */
@interface TDBasicAuthorizer : NSObject <TDAuthorizer> {
   @private
    NSURLCredential* _credential;
}

/** Initialize given a credential object that contains a username and password. */
- (id)initWithCredential:(NSURLCredential*)credential;

/** Initialize given a URL alone -- will use a baked-in username/password in the URL,
    or look up a credential from the keychain. */
- (id)initWithURL:(NSURL*)url;

@end

/** Implementation of TDAuthorizer that supports MAC authorization as used in OAuth 2. */
@interface TDMACAuthorizer : NSObject <TDAuthorizer> {
   @private
    NSString* _key, *_identifier;
    NSDate* _issueTime;
    NSData* (*_hmacFunction)(NSData*, NSData*);
}

/** Initialize given MAC credentials */
- (id)initWithKey:(NSString*)key
       identifier:(NSString*)identifier
        algorithm:(NSString*)algorithm
        issueTime:(NSDate*)issueTime;

@end
