//
//  FileDownloaderDelegate.m
//  FileDownloader
//
//  Created by Borja Arias Drake on 17/05/2011.
//  Copyright 2011 Borja Arias Drake. All rights reserved.
//

#import "FileDownloaderDelegate.h"


@implementation FileDownloaderDelegate


- (void) handleSuccessfullDownloadWithData:(NSData*)data{}
- (void) handleFailedDownloadWithError:(NSError*)error{}
- (void) handleAuthenticationFailed{}
- (void) connectionReceivedResponseWithErrorCode:(NSInteger) statusCode{}
- (void) connectionCouldNotBeCreated{}

@end
