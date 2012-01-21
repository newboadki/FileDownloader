//
//  URLFileReader.m
//  DownloadFromURL
//
//  Created by Borja Arias Drake on 24/09/2010.
//  Copyright 2010 Unboxed Consulting. All rights reserved.
//

/*********************************************************************************************************
	This class attemps to download a file from a URL and stores it in file at a provided path.

	The connection gets stablished or not at initialization time (of an instance of this class).
	 - If the connection fails the instance of this class will not be created.
	The temporal file gets created or not at initialization time (of an instance of this class).
	 - If the there is an error while creating the temp. the instance of this class will not be created.
 
	This class has a delegate that implements XMLDownloadDelegateProtocol. When the download succeed or failed
	this class notifies the delegate by calling the delegate's protocol methods as pertinent.
	
*********************************************************************************************************/

#import "FileDownloader.h"


@interface FileDownloader(private)
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)newData;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
@end


@implementation FileDownloader

@synthesize fromURL;
@synthesize filePath;
@synthesize credential;
@synthesize delegate;
@synthesize fileHandler;



#pragma mark -
#pragma mark - Initialisers

- (id) initWithURL:(NSURL*)theUrl andFilePath:(NSString*)file_path andCredential:(NSURLCredential*)cred andDelegate:(id <FileDownloaderDelegateProtocol>) del
{
	/************************************************************************************/
	/* Custom initialization method.													*/
	/************************************************************************************/
	if ((self = [super init]))
	{
        [self setFilePath:file_path];
        [self setCredential:cred];
        [self setDelegate:del];
        [self setFromURL:theUrl];
	}	
	
	return self;	
}



#pragma mark -
#pragma mark - Connection Interface

- (void) start
{
	/************************************************************************************/
	/* Starts downloading the file.                                                     */
    /* If there's a connection running we won't cancel it. It will have to be cancelled */
    /* explicitally by calling cancel.                                                  */
	/************************************************************************************/		
    if(self->connection == nil)
    {
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:self.fromURL];
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
		[request release];		
        
		if (connection)
		{
			DebugLog(@"Connection created");
            
            // We will always download the data
            self->data = [[NSMutableData alloc] init];
            
            // We will write the data to a file only if filePath is not nil and make sense
            if(self.filePath)
            {
                NSFileHandle* fh = [self fileHandlerForFileAtPath:self.filePath];
                
                if(fh)
                {
                    DebugLog(@"File Handler successfully created");
                    [self setFileHandler:fh];                    
                }
                else
                {
                    DebugLog(@"File Handler couldn't be created");
                    [self cancelAndRemoveFile:NO];
                }
            }
		}
		else
		{			
			DebugLog(@"Connection couldn't be created");
            [self.delegate connectionCouldNotBeCreated];
		}		
    }
}


- (void) cancelAndRemoveFile:(BOOL)removeFile
{
	/************************************************************************************/
	/*	Cancels downloading the file.													*/
	/************************************************************************************/		
    // cancel the connection
	[self->connection cancel];
    [self->connection release];
    self->connection = nil;
    [self->data release];
    self->data = nil;
    
    if(removeFile)
    {
        // Remove the file from the system, because it might be corrupted.
        if ([[NSFileManager defaultManager] fileExistsAtPath: self.filePath])
        {
            NSError* err = nil;
            [[NSFileManager defaultManager] removeItemAtPath: self.filePath error: &err];

            if (err)
            {
                // Let the delegate know 
                // if([self.delegate respondsToSelector:@selector(handleErrorWhenRemovingFile:)])
                //   [self.delegate handleErrorWhenRemovingFile:err];
            }
        }
    }
}



#pragma mark -
#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
	/************************************************************************************/
	/*	Adds the received piece of data to the file.									*/
	/************************************************************************************/	    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if([httpResponse statusCode] != 200)
    {
        [self cancelAndRemoveFile:YES];
        [delegate connectionReceivedResponseWithErrorCode:[httpResponse statusCode]];
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)newData
{	
	/************************************************************************************/
	/*	Adds the received piece of data to the file.									*/
	/************************************************************************************/	
	[self.fileHandler writeData: newData];
    [self->data appendData:newData];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	/************************************************************************************/
	/*	There was an error, remove the file, and let listeners know.					*/
	/************************************************************************************/	    
    [self cancelAndRemoveFile:YES];
        
	// Let listeners know
    [self.delegate handleFailedDownloadWithError:error];	
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	/************************************************************************************/
	/* Download complete, let listeners know.											*/
	/************************************************************************************/		
	// Let listeners know
	[self.fileHandler closeFile];

    NSData* resultData = [[[NSData alloc] initWithData:self->data] autorelease];
    [delegate handleSuccessfullDownloadWithData:resultData];
    
    [self cancelAndRemoveFile:NO];
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	/************************************************************************************/
	/* NSURLConnection Delegate method called to authenticate the requester.			*/
	/************************************************************************************/	
	if([challenge previousFailureCount] == 0)
	{
		if([challenge proposedCredential] == nil)
		{
			[[challenge sender] useCredential:self.credential forAuthenticationChallenge:challenge];
		}	
	}
	else
	{
        [self.delegate handleAuthenticationFailed];
	}
}



#pragma mark -
#pragma mark - Helper Methods

- (NSFileHandle*)fileHandlerForFileAtPath:(NSString*)file_path
{
	/************************************************************************************/
	/* Creates a directory  if necessary at the given path, and a file within that dir. */
	/* We assume that the path is a path to a file! directory/file.extension.			*/
	/* The object that we return has already been autoreleased.                         */
	/************************************************************************************/
	NSError* err = nil;
	BOOL directory_created;
	BOOL file_created;
	NSFileHandle* fh= nil;
	
	directory_created = [[NSFileManager defaultManager] createDirectoryAtPath: [file_path stringByDeletingLastPathComponent] 
                                                  withIntermediateDirectories: YES 
                                                                   attributes: nil 
                                                                        error: &err];
    
	file_created = [[NSFileManager defaultManager] createFileAtPath: file_path contents: nil attributes: nil];        
	
	if(directory_created && file_created)
	{
		fh = [NSFileHandle fileHandleForWritingAtPath: file_path];
	}	
    
	return fh;	
}



#pragma mark -
#pragma mark - Memory Management

- (void) dealloc
{
	/************************************************************************************/
	/*	Tidy-up.																		*/
	/************************************************************************************/
	[self setFilePath: nil];
	[self setFromURL: nil];
	[self setCredential: nil];
	[self setFileHandler:nil];
    
    [self cancelAndRemoveFile:NO];

	[super dealloc];
}

@end
