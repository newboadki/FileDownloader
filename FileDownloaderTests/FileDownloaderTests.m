//
//  FileDownloaderTests.m
//  FileDownloaderTests
//
//  Created by Borja Arias Drake on 15/05/2011.
//  Copyright 2011 Borja Arias Drake. All rights reserved.
//

#import "FileDownloaderTests.h"
#import <objc/runtime.h>
#import "FileDownloaderDelegateProtocol.h"
#import "FileDownloaderDelegate.h"

@implementation FileDownloaderTests

- (void)setUp
{
    [super setUp];
    NSString* file_path = [NSString stringWithFormat: @"%@xml/%@", NSTemporaryDirectory(), @"file.xml"];        
    [[NSFileManager defaultManager] createFileAtPath:file_path contents:[[NSData alloc] init] attributes:nil];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    NSString* file_path = [NSString stringWithFormat: @"%@xml/%@", NSTemporaryDirectory(), @"file.xml"];        
    [[NSFileManager defaultManager] removeItemAtPath:file_path error:nil];
    
    [super tearDown];
}


- (void) testInit
{
    NSURL* url = [NSURL URLWithString:@"www.example.com"];
    NSString* path = @"xml/file.xml";
    NSURLCredential* credential = [NSURLCredential credentialWithUser:@"" password:@"" persistence:NSURLCredentialPersistenceNone];
    
    FileDownloader* fd = [[FileDownloader alloc] initWithURL: url
                                                 andFilePath: path
                                               andCredential: credential 
                                                 andDelegate: self];
    
            
    STAssertTrue([fd fromURL] == url, @"init method should set the url");
    STAssertTrue([fd filePath] == path, @"init method should set the path");
    STAssertTrue([fd credential] == credential, @"init method should set the credential");
    STAssertTrue([fd delegate] == self, @"init method should set the delegate");    
    
    [fd release];
}


/*- (void)testCancel
{
    // Problems setting the private variable connection
    NSURL* url = [NSURL URLWithString:@"www.example.com"];
    NSString* path = @"xml/file.xml";
    NSURLCredential* credential = [NSURLCredential credentialWithUser:@"" password:@"" persistence:NSURLCredentialPersistenceNone];
    
    FileDownloader* fd = [[FileDownloader alloc] initWithURL: url
                                                 andFilePath: path
                                               andCredential: credential 
                                                 andDelegate: self];
    
    NSURLConnection* connection = [[NSURLConnection alloc] init];

    object_setInstanceVariable(fd, "connection", nil);
    void** gotConnection;
    NSLog(@"----> nil? %i", object_getInstanceVariable(fd, "connection", gotConnection)==nil);

    object_setInstanceVariable(fd, "connection", connection);

    gotConnection = nil;
    NSLog(@"----> nil? %i", object_getInstanceVariable(fd, "connection", gotConnection)==nil);
    
    
    [fd release];
}*/


- (void) testConnectionDidReceiveResponseWithA_200_Response
{
    NSURL* url = [NSURL URLWithString:@"www.example.com"];
    NSString* path = @"xml/file.xml";
    NSURLCredential* credential = [NSURLCredential credentialWithUser:@"" password:@"" persistence:NSURLCredentialPersistenceNone];
    NSURLConnection* conn = [[NSURLConnection alloc] init];
    id delegateMock = [OCMockObject mockForClass:[FileDownloaderDelegate class]];

    FileDownloader*  fd = [[FileDownloader alloc] initWithURL: url
                                                 andFilePath: path
                                               andCredential: credential 
                                                 andDelegate: delegateMock];
    [fd setDelegate:delegateMock];
    int statusCodeInt = 200;
    NSValue* statusCode = [NSValue valueWithBytes:&statusCodeInt objCType:@encode(int)];
        
    id mock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[mock stub] andReturnValue:statusCode] statusCode];
    
    [fd connection:conn didReceiveResponse:mock];
    
    [mock verify];
    [delegateMock verify];
}


- (void) testConnectionDidReceiveResponseWithA_Non_200_Response
{
    NSURL* url = [NSURL URLWithString:@"www.example.com"];
    NSString* file_path = [NSString stringWithFormat: @"%@xml/%@", NSTemporaryDirectory(), @"file.xml"];    
    NSURLCredential* credential = [NSURLCredential credentialWithUser:@"" password:@"" persistence:NSURLCredentialPersistenceNone];
    NSURLConnection* conn = [[NSURLConnection alloc] init];
    NSMutableData* data = [[NSMutableData alloc] init];
    id delegateMock = [OCMockObject mockForClass:[FileDownloaderDelegate class]];
    [[delegateMock expect] connectionReceivedResponseWithErrorCode:404];
    
    FileDownloader*  fd = [[FileDownloader alloc] initWithURL: url
                                                  andFilePath: file_path
                                                andCredential: credential 
                                                  andDelegate: delegateMock];
    [fd setValue:data forKey:@"data"];
    [fd setDelegate:delegateMock];
    int statusCodeInt = 404;
    NSValue* statusCode = [NSValue valueWithBytes:&statusCodeInt objCType:@encode(int)];
    
    id mock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[mock stub] andReturnValue:statusCode] statusCode];
    
    [fd connection:conn didReceiveResponse:mock];
    
    STAssertNil([fd valueForKey:@"connection"], @"Connection should have been deleted");
    STAssertNil([fd valueForKey:@"data"], @"data should have been deleted");    
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:file_path], @"File should not exist after cancelAndRemoveFile:YES");
        
    [delegateMock verify];
    [mock verify];
    [data release];
}


- (void) testConnectionDidReceiveData
{
    NSURL* url = [NSURL URLWithString:@"www.example.com"];
    NSString* path = @"xml/file.xml";
    NSURLCredential* credential = [NSURLCredential credentialWithUser:@"" password:@"" persistence:NSURLCredentialPersistenceNone];
    NSURLConnection* conn = [[NSURLConnection alloc] init];
    char newDataBytes[5] = {'b', 'o', 'r', 'j', 'a'};
    NSData* newData = [[NSData alloc] initWithBytes:newDataBytes length:5];
    char dataBytes[1] = {'s'};
    NSMutableData* data = [[NSMutableData alloc] initWithBytes:dataBytes length:1];

    id fileHandleMock = [OCMockObject mockForClass:[NSFileHandle class]];
    
    [[fileHandleMock expect] writeData:newData];
    FileDownloader*  fd = [[FileDownloader alloc] initWithURL: url
                                                  andFilePath: path
                                                andCredential: credential 
                                                  andDelegate: self];
    [fd setValue:data forKey:@"data"];
    
    [fd setFileHandler:fileHandleMock];        
    [fd connection:conn didReceiveData:newData];
    
    NSMutableData* theData = (NSMutableData*)[fd valueForKey:@"data"];
    STAssertTrue([theData length]==6, @"connection:didReceiveData didn't append newData to the existing data. Expected %i, got %i", 6, [theData length]);
        
    [fileHandleMock verify];
    [data release];
    [newData release];
}


- (void) testConnectionDidFailWithError
{
    NSURL* url = [NSURL URLWithString:@"www.example.com"];
    NSString* file_path = [NSString stringWithFormat: @"%@xml/%@", NSTemporaryDirectory(), @"file.xml"];    
    NSURLCredential* credential = [NSURLCredential credentialWithUser:@"" password:@"" persistence:NSURLCredentialPersistenceNone];
    NSURLConnection* conn = [[NSURLConnection alloc] init];
    NSMutableData* data = [[NSMutableData alloc] init];
    id delegateMock = [OCMockObject mockForClass:[FileDownloaderDelegate class]];
    id errorMock = [OCMockObject mockForClass:[NSError class]];
    
    [[delegateMock expect] handleFailedDownloadWithError:errorMock];
    
    FileDownloader*  fd = [[FileDownloader alloc] initWithURL: url
                                                  andFilePath: file_path
                                                andCredential: credential 
                                                  andDelegate: delegateMock];
    [fd setValue:data forKey:@"data"];
    [fd setDelegate:delegateMock];

    [fd connection:conn didFailWithError:errorMock];
    
    STAssertNil([fd valueForKey:@"connection"], @"Connection should have been deleted");
    STAssertNil([fd valueForKey:@"data"], @"data should have been deleted");    
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:file_path], @"File should not exist after cancelAndRemoveFile:YES");

    
    [delegateMock verify];
}


- (void) testConnectionDidFinishLoading
{
    NSURL* url = [NSURL URLWithString:@"www.apple.com"];
    NSString* file_path = [NSString stringWithFormat: @"%@xml/%@", NSTemporaryDirectory(), @"file.xml"];    
    NSURLCredential* credential = [NSURLCredential credentialWithUser:@"" password:@"" persistence:NSURLCredentialPersistenceNone];
    NSURLConnection* conn = [[NSURLConnection alloc] init];
    char dataBytes[5] = {'b', 'o', 'r', 'j', 'a'};
    NSData* data = [[NSData alloc] initWithBytes:dataBytes length:5];
    id fileHandleMock = [OCMockObject mockForClass:[NSFileHandle class]];
    id delegateMock = [OCMockObject mockForClass:[FileDownloaderDelegate class]];

    [[delegateMock expect] handleSuccessfullDownloadWithData:data];
    [[fileHandleMock expect] closeFile];
    FileDownloader*  fd = [[FileDownloader alloc] initWithURL: url
                                                  andFilePath: file_path
                                                andCredential: credential 
                                                  andDelegate: delegateMock];
    [fd setValue:data forKey:@"data"];
    [fd setFileHandler:fileHandleMock];        
    [fd setDelegate:delegateMock];
    [fd connectionDidFinishLoading:conn];
    
    STAssertNil([fd valueForKey:@"connection"], @"Connection should have been deleted");
    STAssertNil([fd valueForKey:@"data"], @"data should have been deleted");    
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:file_path], @"File should exist after cancelAndRemoveFile:YES");

    
    [delegateMock verify];
    [fileHandleMock verify];
    [data release];
}


- (void) testConnectionReceivedAuthenticationChallengeTheFirstTimeWithProposedCredentialNil
{
    NSURL* url = [NSURL URLWithString:@"www.example.com"];
    NSString* path = @"xml/file.xml";
    id credentialMock = [OCMockObject mockForClass:[NSURLCredential class]];
    id challengeMock = [OCMockObject mockForClass:[NSURLAuthenticationChallenge class]];
    id challengeSenderMock = [OCMockObject mockForClass:[ChallengeSender class]];
    id connectionMock = [OCMockObject mockForClass:[NSURLConnection class]];
    id delegateMock = [OCMockObject mockForClass:[FileDownloaderDelegate class]];
    
    int zeroInt = 0;
    NSURLCredential* proposedCredential = nil;    
    NSValue* zeroValue = [NSValue valueWithBytes:&zeroInt objCType:@encode(int)];
    
    [[[challengeMock stub] andReturnValue:zeroValue] previousFailureCount];
    [[[challengeMock stub] andReturn:proposedCredential] proposedCredential];
    [[[challengeMock stub] andReturn:challengeSenderMock] sender];
    [[challengeSenderMock expect] useCredential:credentialMock forAuthenticationChallenge:challengeMock];
    
    FileDownloader*  fd = [[FileDownloader alloc] initWithURL: url
                                                  andFilePath: path
                                                andCredential: credentialMock 
                                                  andDelegate: delegateMock];

    [fd connection:connectionMock didReceiveAuthenticationChallenge:challengeMock];

    [credentialMock verify];
    [challengeMock verify];
    [challengeSenderMock verify];
    [challengeMock verify];
    [connectionMock verify];
    [delegateMock verify];    
}


- (void) testConnectionReceivedAuthenticationChallengeTheFirstTimeWithProposedCredentialNotNil
{
    NSURL* url = [NSURL URLWithString:@"www.example.com"];
    NSString* path = @"xml/file.xml";
    id credentialMock = [OCMockObject mockForClass:[NSURLCredential class]];
    id challengeMock = [OCMockObject mockForClass:[NSURLAuthenticationChallenge class]];
    id challengeSenderMock = [OCMockObject mockForClass:[ChallengeSender class]];
    id connectionMock = [OCMockObject mockForClass:[NSURLConnection class]];
    id delegateMock = [OCMockObject mockForClass:[FileDownloaderDelegate class]];
    
    int zeroInt = 0;
    NSURLCredential* proposedCredential = [[NSURLCredential alloc] init];    
    NSValue* zeroValue = [NSValue valueWithBytes:&zeroInt objCType:@encode(int)];
    
    [[[challengeMock stub] andReturnValue:zeroValue] previousFailureCount];
    [[[challengeMock stub] andReturn:proposedCredential] proposedCredential];
    [[[challengeMock stub] andReturn:challengeSenderMock] sender];
    // THIS IS THE TEST, THIS CALL SHOULD NOT HAPPEN[[challengeSenderMock expect] useCredential:credentialMock forAuthenticationChallenge:challengeMock];
    
    FileDownloader*  fd = [[FileDownloader alloc] initWithURL: url
                                                  andFilePath: path
                                                andCredential: credentialMock 
                                                  andDelegate: delegateMock];
    
    [fd connection:connectionMock didReceiveAuthenticationChallenge:challengeMock];
    
        
    [credentialMock verify];
    [challengeMock verify];
    [challengeSenderMock verify];
    [challengeMock verify];
    [connectionMock verify];
    [delegateMock verify];    
    [proposedCredential release];
}


- (void) testConnectionReceivedAuthenticationChallengeNotTheFirstTime
{
    NSURL* url = [NSURL URLWithString:@"www.example.com"];
    NSString* path = @"xml/file.xml";
    id credentialMock = [OCMockObject mockForClass:[NSURLCredential class]];
    id challengeMock = [OCMockObject mockForClass:[NSURLAuthenticationChallenge class]];
    id challengeSenderMock = [OCMockObject mockForClass:[ChallengeSender class]];
    id connectionMock = [OCMockObject mockForClass:[NSURLConnection class]];
    id delegateMock = [OCMockObject mockForClass:[FileDownloaderDelegate class]];
    
    int zeroInt = 1;
    NSURLCredential* proposedCredential = [[NSURLCredential alloc] init];    
    NSValue* zeroValue = [NSValue valueWithBytes:&zeroInt objCType:@encode(int)];
    
    [[[challengeMock stub] andReturnValue:zeroValue] previousFailureCount];
    [[[challengeMock stub] andReturn:proposedCredential] proposedCredential];
    [[[challengeMock stub] andReturn:challengeSenderMock] sender];
    [[delegateMock expect] handleAuthenticationFailed];
    
    FileDownloader*  fd = [[FileDownloader alloc] initWithURL: url
                                                  andFilePath: path
                                                andCredential: credentialMock 
                                                  andDelegate: delegateMock];
    
    [fd connection:connectionMock didReceiveAuthenticationChallenge:challengeMock];
    
    
    [credentialMock verify];
    [challengeMock verify];
    [challengeSenderMock verify];
    [challengeMock verify];
    [connectionMock verify];
    [delegateMock verify];    
    [proposedCredential release];
}


- (void) testCreateFileHandle
{
    NSURL* url = [NSURL URLWithString:@"www.example.com"];
    NSString* path = @"xml/file.xml";
    id credentialMock = [OCMockObject mockForClass:[NSURLCredential class]];
    id delegateMock = [OCMockObject mockForClass:[FileDownloaderDelegate class]];
            
    FileDownloader*  fd = [[FileDownloader alloc] initWithURL: url
                                                  andFilePath: path
                                                andCredential: credentialMock 
                                                  andDelegate: delegateMock];
    
    NSString* file_path = [NSString stringWithFormat: @"%@xml/%@", NSTemporaryDirectory(), @"file.xml"];    
    STAssertNotNil([fd fileHandlerForFileAtPath:file_path], @"File handle should have been created");
    
    [credentialMock verify];
    [delegateMock verify];    
}


- (void) testCancelAndRemoveFile_YES
{
    NSURL* url = [NSURL URLWithString:@"www.example.com"];
    NSString* file_path = [NSString stringWithFormat: @"%@xml/%@", NSTemporaryDirectory(), @"file.xml"];    
    id credentialMock = [OCMockObject mockForClass:[NSURLCredential class]];
    id delegateMock = [OCMockObject mockForClass:[FileDownloaderDelegate class]];
    id connectionMock = [OCMockObject niceMockForClass:[NSURLConnection class]];
    id dataMock = [OCMockObject niceMockForClass:[NSMutableData class]];
    
    FileDownloader*  fd = [[FileDownloader alloc] initWithURL: url
                                                  andFilePath: file_path
                                                andCredential: credentialMock 
                                                  andDelegate: delegateMock];
    [fd setValue:connectionMock forKey:@"connection"];
    [fd setValue:dataMock forKey:@"data"];
    NSLog(@"%i", [fd valueForKey:@"connection"]==nil);
    [fd cancelAndRemoveFile:YES];
    
    STAssertNil([fd valueForKey:@"connection"], @"Connection should have been deleted");
    STAssertNil([fd valueForKey:@"data"], @"data should have been deleted");    
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:file_path], @"File should not exist after cancelAndRemoveFile:YES");
    
    [credentialMock verify];
    [delegateMock verify];  
    [connectionMock verify];
    [dataMock verify];
}


- (void) testCancelAndRemoveFile_NO
{
    NSURL* url = [NSURL URLWithString:@"www.example.com"];
    NSString* file_path = [NSString stringWithFormat: @"%@xml/%@", NSTemporaryDirectory(), @"file.xml"];    
    id credentialMock = [OCMockObject mockForClass:[NSURLCredential class]];
    id delegateMock = [OCMockObject mockForClass:[FileDownloaderDelegate class]];
    id connectionMock = [OCMockObject niceMockForClass:[NSURLConnection class]];
    id dataMock = [OCMockObject niceMockForClass:[NSMutableData class]];
    
    FileDownloader*  fd = [[FileDownloader alloc] initWithURL: url
                                                  andFilePath: file_path
                                                andCredential: credentialMock 
                                                  andDelegate: delegateMock];
    [fd setValue:connectionMock forKey:@"connection"];
    [fd setValue:dataMock forKey:@"data"];
    NSLog(@"%i", [fd valueForKey:@"connection"]==nil);
    [fd cancelAndRemoveFile:NO];
    
    STAssertNil([fd valueForKey:@"connection"], @"Connection should have been deleted");
    STAssertNil([fd valueForKey:@"data"], @"data should have been deleted");    
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:file_path], @"File should exist after cancelAndRemoveFile:YES");
    
    [credentialMock verify];
    [delegateMock verify];  
    [connectionMock verify];
    [dataMock verify];   
}

@end

