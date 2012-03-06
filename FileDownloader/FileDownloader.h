//
//  URLFileReader.h
//  DownloadFromURL
//
//  Created by Borja Arias Drake on 24/09/2010.
//  Copyright 2010 Borja Arias Drake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileDownloaderDelegateProtocol.h"
#import "ConsoleLogger.h"

@interface FileDownloader : NSObject
{
	NSFileHandle*    fileHandler;
	NSURL*           fromURL;
	NSString*		 filePath;
	NSURLCredential* credential;	
	NSURLConnection* connection;
    NSMutableData*          data;
	id <FileDownloaderDelegateProtocol> delegate;
}

@property (retain, nonatomic) NSFileHandle*	   fileHandler;
@property (retain, nonatomic) NSURL*		   fromURL;
@property (retain, nonatomic) NSString*        filePath;
@property (retain, nonatomic) NSURLCredential* credential;
@property (assign, nonatomic) id <FileDownloaderDelegateProtocol> delegate;

- (id) initWithURL:(NSURL*)theUrl andFilePath:(NSString*)file_path andCredential:(NSURLCredential*)cred andDelegate:(id <FileDownloaderDelegateProtocol>) del;
- (void) start;
- (void) cancelAndRemoveFile:(BOOL)removeFile;
- (NSFileHandle*)fileHandlerForFileAtPath:(NSString*)file_path;

@end
