//
//  Facebook.m
//  FacebookFramework
//
//  Created by Narek Barseghyan on 11/28/13.
//  Copyright (c) 2013 SocialObjects Software. All rights reserved.
//

#import "Facebook.h"
#import <WebKit/WebKit.h>
#import "FacebookURLs.h"

const NSInteger WINDOW_WIDTH = 640;
const NSInteger WINDOW_HEIGHT = 296;
NSString* const ACCESSTOKEN_KEY = @"FBAuth_accessToken";
NSString* const PERMISSIONS_KEY = @"FBAuth_grantedPerms";


@interface Facebook()

@property NSString *appID;
@property NSString *appSecret;
@property NSString *accessToken;
@property (strong) NSSet *grantedPerms;
@property (assign) id<FacebookDelegate> delegate;
@property (strong) CompletionBlock callback;

@property NSWindow *window;
@property WebView *webView;

@end

@implementation Facebook

- (id)initWithAppID:(NSString *)appID appSecret:(NSString *)appsecret delegate:(id<FacebookDelegate>)delegate
{
    self = [super init];
    if (self) {
        _appID = appID;
        _appSecret = appsecret;
        _delegate = delegate;
        _accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:ACCESSTOKEN_KEY];
        _grantedPerms = [NSSet setWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:PERMISSIONS_KEY]];
    }
    
    return self;
    
}

- (void)authenticate:(NSSet*)permissions callback:(CompletionBlock)callback
{
    self.grantedPerms = permissions;
    [[NSUserDefaults standardUserDefaults] setObject:[self.grantedPerms allObjects] forKey:PERMISSIONS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.callback = callback;
    
    NSRect windowRect = NSMakeRect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
    
    self.window = [[NSWindow alloc] initWithContentRect:windowRect
                                              styleMask:NSTitledWindowMask
                                                backing:NSBackingStoreBuffered
                                                  defer:YES];
    
    self.webView = [[WebView alloc] initWithFrame:windowRect
                                        frameName:nil
                                        groupName:nil];
    [self.webView setFrameLoadDelegate:self];
    
    NSString* authURL = nil;
    
    if(permissions.count) {
        authURL = [NSString stringWithFormat:
                   kFBAuthorizeWithScopeURL,self.appID,kFBLoginSuccessURL,
                   [[permissions allObjects] componentsJoinedByString:@","]];
    } else {
        authURL = [NSString stringWithFormat:
                   kFBAuthorizeURL,self.appID,
                   kFBLoginSuccessURL];
    }
    
    
    [self.webView setMainFrameURL:authURL];
    [self.window setContentView:self.webView];
    
}

- (void)webView:(WebView*)sender didFinishLoadForFrame:(WebFrame*)frame {
    if ([[self.webView mainFrameURL] rangeOfString:@"error="].location != NSNotFound ||
        [[self.webView mainFrameURL] rangeOfString:@"home.php"].location != NSNotFound) {
        [self closeWindow];
        
        self.callback(nil);
        return;
    }
    
    
    NSRange range = [[_webView mainFrameURL] rangeOfString:@"access_token=.+?[&$]"
                                                   options:NSRegularExpressionSearch];
    
    if (range.location != NSNotFound) {
        range.location += 13;
        range.length -= 13;
        NSDictionary *params = [self parseURLParams:_webView.mainFrameURL];
        
        self.accessToken = params.allValues[1];
        [[NSUserDefaults standardUserDefaults] setObject:self.accessToken forKey:ACCESSTOKEN_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self closeWindow];
        
        [self getLongLivedAccessTokenForToken:self.accessToken callback:^(NSDictionary *result) {
            self.accessToken = result[@"accessToken"];
            [[NSUserDefaults standardUserDefaults] setObject:self.accessToken forKey:ACCESSTOKEN_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.callback(result);
        }];
        
    } else {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(fbAuthWindowWillShow:)] && ![self.window isVisible]) {
            
            [self.window center];
            [_window makeKeyAndOrderFront:self];
            [self.delegate fbAuthWindowWillShow:self];
        }
        
    }
}

- (void)invalidate
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [[cookieStorage cookiesForURL:[NSURL URLWithString:kFBURL] ] arrayByAddingObjectsFromArray:[cookieStorage cookiesForURL: [NSURL URLWithString:kFBSecureURL]]];
    
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStorage deleteCookie: cookie];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ACCESSTOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PERMISSIONS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)closeWindow
{
    [self.window close];
    [self.webView setFrameLoadDelegate:nil];
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void)sendRequest:(NSString *)request params:(NSDictionary *)params usePostRequest:(BOOL)postRequest withCompletionBlock:(CompletionBlock)block
{
    if (_accessToken)
	{
		NSString *str;
        
        
		if (postRequest)
		{
			str = [NSString stringWithFormat: kFBGraphApiPostURL, request];
		}
		else
		{
			// Check if request already has optional parameters
			NSString *formatStr = kFBGraphApiGetURL;
			NSRange rng = [request rangeOfString:@"?"];
			if (rng.length > 0)
				formatStr = kFBGraphApiGetURLWithParams;
			str = [NSString stringWithFormat: formatStr, request, _accessToken];
		}
        
        
		NSMutableString *strPostParams = nil;
		if (params != nil)
		{
			if (postRequest)
			{
				strPostParams = [NSMutableString stringWithFormat: @"access_token=%@", _accessToken];
				for (NSString *p in [params allKeys])
					[strPostParams appendFormat: @"&%@=%@", p, [params objectForKey: p]];
			}
			else
			{
				NSMutableString *strWithParams = [NSMutableString stringWithString: str];
				for (NSString *p in [params allKeys])
					[strWithParams appendFormat: @"&%@=%@", p, [params objectForKey: p]];
				str = strWithParams;
			}
		}
        
		NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: str]];
        
		if (postRequest)
		{
			NSData *requestData = [NSData dataWithBytes: [strPostParams UTF8String] length: [strPostParams length]];
			[req setHTTPMethod: @"POST"];
			[req setHTTPBody: requestData];
			[req setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"content-type"];
		}
        
		NSURLResponse *response = nil;
		NSError *error = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest: req returningResponse: &response error: &error];
        
		NSString *resultStr = [[NSString alloc] initWithBytesNoCopy: (void*)[data bytes] length: [data length] encoding:NSASCIIStringEncoding freeWhenDone: NO];
        
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if(results[@"error"] && [results[@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            
            [self authenticate:self.grantedPerms callback:^(NSDictionary *result) {
                
                [self sendRequest:request params:params usePostRequest:postRequest withCompletionBlock:block];
            }];
            
        } else {
            
            NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
                                    resultStr, @"result",
                                    request, @"request",
                                    data, @"raw",
                                    self, @"sender",
                                    nil];
            
            // Execute completion block if available, notify delegate otherwise
            if (block != nil) {
                block(result);
            }
            
        }
        
	}
}

- (void)sendFQLRequest:(NSString *)query withCompletionBlock:(CompletionBlock)block
{
    if (_accessToken)
    {
        NSString *str = [NSString stringWithFormat: kFBGraphApiFqlURL, [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], _accessToken];
        
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: str]];
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest: req returningResponse: &response error: &error];
        
        
        NSString *resultStr = [[NSString alloc] initWithBytesNoCopy: (void*)[data bytes] length: [data length] encoding:NSASCIIStringEncoding freeWhenDone: NO];
        
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if(results[@"error"] && [results[@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            
            [self authenticate:self.grantedPerms callback:^(NSDictionary *result) {
                [self sendFQLRequest:query withCompletionBlock:block];
            }];
            
        } else {
            
            NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
                                    resultStr, @"result",
                                    query, @"request",
                                    data, @"raw",
                                    self, @"sender",
                                    nil];
            
            
            if (block != nil) {
                block(result);
            }
            
        }
        
    }
}

- (void)getLongLivedAccessTokenForToken:(NSString *)token callback:(CompletionBlock)aCallback
{
    NSString *url = [NSString stringWithFormat:kFBLongLivedAccessTokenURL,self.appID, self.appSecret, token];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: url]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest: req returningResponse: &response error: &error];
    
    NSString *resultStr = [[NSString alloc] initWithBytesNoCopy: (void*)[data bytes] length: [data length] encoding:NSASCIIStringEncoding freeWhenDone: NO];
    
    NSDictionary *params = [self parseURLParams:resultStr];
    
    aCallback(@{@"accessToken":params.allValues[1]});
}

@end
