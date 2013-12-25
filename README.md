FacebookFramework
=============================================================

Summary
-------

FacebookFramework is a Simple and Lightweight framework for Cocoa (OS X, MacOSX) to easily access Facebook's API.

How-to-use
----------

1. 	Create your Facebook app
	* Go to your [Facebook application page](https://developers.facebook.com/apps/).
    * Select your application in the left-hand column (if you have more than one application) and select Edit App.
    * __Note:__  In section 3 you should use App ID and App Secret	    
  
2. 	Build FacebookFramework.framework
    * Open "FacebookFramework.xcodeproj" and "Build for Archiving" in the Product -> Build menu. This should build both the Debug and Release version. If it does not, check your Build Schemes in Product -> Edit Scheme… Select Build configuration Release
    * Select "FacebookFramework.framework" in the Finder. It should be in the "Release" folder; you probably don't want to embed the Debug version.
    * Drag it to your "Frameworks" folder in your Project list and add it to the appropriate target. If you want you can select "Copy items into destination group's folder"
    * In your appropriate target, under "Build Settings", select "Runpath Search Paths" in the "Linking" category, and enter "@loader_path/../Frameworks" (without the quotes). This step is essential for linking, as the Framework is built with a "@rpath" search path, which will be replaced at runtime by your application.
    * In your appropriate target, add a "Copy" build phase. For adding build phase you should select "Editor" menu of xcode and select "Add Build Phase->Add Copy Files Build Phase".  Set its destination to "Frameworks".
    * Drag "FacebookFramework.framework" to this Copy build phase to ensure it is embedded in your application.
    * Verify that you can build and run your application and there are no linker or runtime errors.

3.  Prepare to use FacebookFramework.framework
    * Import <FacebookFramework/FacebookFramework.h> where appropriate.
    * Create a new property `Facebook*` and set yourself as the delegate:
	    
4.  Request an authorization token:	
	* Just list the permissions you need in an set, or [NSSet set] if you don't require special permissions.
	
		````		
	    [self.facebook authenticate:[NSSet setWithObjects: @"read_stream", @"publish_stream", nil] callback:^(NSDictionary *result) {
    		
		}];
		````
                    
    * There is a [list of permissions](http://developers.facebook.com/docs/authentication/permissions).
    * Callback will get called with a dictionary. If `result is not nil, the authorization request was successful.
    * If FacebookFramework needs to display some UI (such as the Facebook Authentication dialog), your delegate's `fbAuthWindowWillShow:` will get called. Take this opportunity to notify the user via a Dock bounce, for instance.
    * __Note:__ the framework may put up an authorization window from Facebook. Subsequent requests are cached and/or hidden from the user as much as possible.

5.  Make API requests
    * You do not need to provide the URL or authorization token, FacebookFramework takes care of that:

		````
		[self.facebook sendRequest:@"me/friends" params:NSDictionary_params usePostRequest:POST_OR_GET withCompletionBlock:^(NSDictionary *result) {
	       NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:result[@"raw"] options:0 error:NULL];			
    	}];
	    ````

Special Thanks
--------------

* [PhFacebook](https://github.com/philippec/PhFacebook)
* [FBAuthenticator](https://github.com/jubishop/FBAuthenticator)

----
Waiting for your questions, contributions and issues :)
----
