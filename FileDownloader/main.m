//
//  main.m
//  FileDownloader
//
//  Created by Borja Arias Drake on 15/05/2011.
//  Copyright 2011 Borja Arias Drake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConsoleLogger.h"
#import "FileDownloader.h"

int main(int argc, char *argv[])
{    
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];    
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
