//
//  ConsoleLogger.m
//  FileDownloader
//
//  Created by Borja Arias Drake on 15/05/2011.

#import "ConsoleLogger.h"
#import <stdarg.h>


@implementation ConsoleLogger



void DebugLog(NSString* format, ...)
{
    /***********************************************************************************************/
    /* The content of this C function gets only compiled if DEBUG is defined. DEBUG is in the      */
    /* buildings settings project file under PREPROCESSOR MACROS                                   */
	/***********************************************************************************************/    
    #ifdef DEBUG
        // get the argument list
        va_list argumentList;
        va_start(argumentList, format);
    
        // pass it verbatim to a suitable method provided by NSString
        NSString* string = [[NSString alloc] initWithFormat:format arguments:argumentList];
        NSLog(@"%@", string);
    
        // clean up
        va_end(argumentList);
    #endif
}

@end