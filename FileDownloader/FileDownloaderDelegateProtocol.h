//
//  FileDownloaderDelegateProtocol.h
//  FileDownloader
//
//  Created by Borja Arias Drake on 15/05/2011.
//  Copyright 2011 Unboxed Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol FileDownloaderDelegateProtocol 
- (void) handleSuccessfullDownloadWithData:(NSData*)data; 
- (void) handleFailedDownloadWithError:(NSError*)error; 
- (void) handleAuthenticationFailed;
- (void) connectionReceivedResponseWithErrorCode:(NSInteger) statusCode;
- (void) connectionCouldNotBeCreated;
@end 