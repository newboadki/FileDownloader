//
//  FileDownloaderAppDelegate.h
//  FileDownloader
//
//  Created by Borja Arias Drake on 15/05/2011.
//  Copyright 2011 Unboxed Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FileDownloaderViewController;

@interface FileDownloaderAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet FileDownloaderViewController *viewController;

@end
