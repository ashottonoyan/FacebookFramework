//
//  Facebook.h
//  FacebookFramework
//
//  Created by Narek Barseghyan on 11/28/13.
//  Copyright (c) 2013 SocialObjects Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)(NSDictionary *result);

@protocol FacebookDelegate <NSObject>
@optional

- (void)fbAuthWindowWillShow:(id)sender;

@end

@interface Facebook : NSObject

- (id)initWithAppID:(NSString *)appID appSecret:(NSString*)appSecret delegate:(id<FacebookDelegate>)delegate;

- (void)authenticate:(NSSet*)permissions callback:(CompletionBlock)callback;

- (void)invalidate;


- (void) sendRequest: (NSString*) request params: (NSDictionary*) params usePostRequest: (BOOL) postRequest withCompletionBlock:(CompletionBlock) block;

- (void) sendFQLRequest: (NSString*) query withCompletionBlock:(CompletionBlock) block;


@end

