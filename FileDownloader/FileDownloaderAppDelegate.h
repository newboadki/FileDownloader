//
//  FileDownloaderAppDelegate.h
//  FileDownloader
//
//  Created by Borja Arias Drake on 15/05/2011.
//  Copyright 2011 Borja Arias Drake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileDownloaderViewController.h"
#import "FileDownloader.h"
#import "FileDownloaderDelegateProtocol.h"


@class FileDownloaderViewController;

@interface FileDownloaderAppDelegate : NSObject <UIApplicationDelegate, FileDownloaderDelegateProtocol>
{

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FileDownloaderViewController *viewController;
@property (nonatomic, retain) FileDownloader* fileDownloader;
@end
