//
//  FacebookURLs.h
//  FacebookFramework
//
//  Created by Narek Barseghyan on 11/28/13.
//  Copyright (c) 2013 SocialObjects Software. All rights reserved.
//

#define kFBAuthorizeURL @"https://graph.facebook.com/oauth/authorize?client_id=%@&redirect_uri=%@&type=user_agent&display=popup"

#define kFBAuthorizeWithScopeURL @"https://graph.facebook.com/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@&type=user_agent&display=popup"

#define kFBLoginSuccessURL @"http://www.facebook.com/connect/login_success.html"

#define kFBUIServerURL @"http://www.facebook.com/connect/uiserver.php"

#define kFBAccessToken @"access_token="
#define kFBExpiresIn   @"expires_in="
#define kFBErrorReason @"error_description="

#define kFBGraphApiGetURL @"https://graph.facebook.com/%@?access_token=%@"
#define kFBGraphApiGetURLWithParams @"https://graph.facebook.com/%@&access_token=%@"

#define kFBGraphApiPostURL @"https://graph.facebook.com/%@"

#define kFBGraphApiFqlURL @"https://api.facebook.com/method/fql.query?query=%@&access_token=%@&format=json"

#define kFBURL @"http://facebook.com"
#define kFBSecureURL @"https://facebook.com"

#define kFBPermissionsURL @"https://graph.facebook.com/me/permissions?access_token=%@"

#define kFBLongLivedAccessTokenURL @"https://graph.facebook.com/oauth/access_token?client_id=%@&client_secret=%@&grant_type=fb_exchange_token&fb_exchange_token=%@"


