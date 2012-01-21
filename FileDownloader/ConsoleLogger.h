//
//  ConsoleLogger.h
//  FileDownloader
//
//  Created by Borja Arias Drake on 15/05/2011.
//

#import <Foundation/Foundation.h>

@interface ConsoleLogger : NSObject
{
}

void DebugLog(NSString* format, ...);

@end