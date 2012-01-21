//
//  FileDownloaderAppDelegate.m
//  FileDownloader
//
//  Created by Borja Arias Drake on 15/05/2011.
//  Copyright 2011 Unboxed Consulting. All rights reserved.
//

#import "FileDownloaderAppDelegate.h"

@implementation FileDownloaderAppDelegate


@synthesize window=_window;

@synthesize viewController=_viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
     
    NSString* file_path = [NSString stringWithFormat: @"%@xml/%@", NSTemporaryDirectory(), @"file.xml"];    
    [[NSFileManager defaultManager] removeItemAtPath:file_path error:nil];
    NSLog(@"exists %i", [[NSFileManager defaultManager] fileExistsAtPath:file_path]);
    FileDownloader* fd = [[FileDownloader alloc] initWithURL:[NSURL URLWithString:@"http://www.apple.com"] andFilePath:nil andCredential:nil andDelegate:self];

    [fd start];
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void) handleSuccessfullDownloadWithData:(NSData*)data
{
    NSLog(@"SUCCESS! %i", [data length]);
    NSString* file_path = [NSString stringWithFormat: @"%@xml/%@", NSTemporaryDirectory(), @"file.xml"];
    NSLog(@"exists %i", [[NSFileManager defaultManager] fileExistsAtPath:file_path]);
    NSLog(@">>>>>>>>>>> %@", [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:file_path] encoding:NSUTF8StringEncoding]);
    NSLog(@"**************************** %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}


- (void) handleFailedDownloadWithError:(NSError*)error
{

}


- (void) handleAuthenticationFailed
{

}


- (void) connectionReceivedResponseWithErrorCode:(NSInteger) statusCode
{

}


- (void) connectionCouldNotBeCreated
{

}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
