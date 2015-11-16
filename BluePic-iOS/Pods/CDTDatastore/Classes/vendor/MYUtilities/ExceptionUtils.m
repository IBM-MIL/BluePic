//
//  ExceptionUtils.m
//  MYUtilities
//
//  Created by Jens Alfke on 1/5/08.
//  Copyright 2008 Jens Alfke. All rights reserved.
//  See BSD license at bottom of file.
//

#import "ExceptionUtils.h"

#import "Logging.h"
#import "Test.h"

#include <sys/sysctl.h>
#include <unistd.h>


#ifndef Warn
#define Warn NSLog
#endif


static void (*sExceptionReporter)(NSException*);

void MYSetExceptionReporter( void (*reporter)(NSException*) )
{
    sExceptionReporter = reporter;
}

void MYReportException( NSException *x, NSString *where, ... )
{
    va_list args;
    va_start(args,where);
    where = [[NSString alloc] initWithFormat: where arguments: args];
    va_end(args);
    Warn(@"Exception caught in %@:\n\t%@\n%@",where,x,x.my_callStack);
    if( sExceptionReporter )
        sExceptionReporter(x);
    [where release];
}


@implementation NSException (MYUtilities)


- (NSArray*) my_callStackReturnAddresses
{
    // On 10.5 or later, can get the backtrace:
    if( [self respondsToSelector: @selector(callStackReturnAddresses)] )
        return [self valueForKey: @"callStackReturnAddresses"];
    else
        return nil;
}

- (NSArray*) my_callStackReturnAddressesSkipping: (unsigned)skip limit: (unsigned)limit
{
    NSArray *addresses = [self my_callStackReturnAddresses];
    if( addresses ) {
        unsigned n = (unsigned) [addresses count];
        skip = MIN(skip,n);
        limit = MIN(limit,n-skip);
        addresses = [addresses subarrayWithRange: NSMakeRange(skip,limit)];
    }
    return addresses;
}


- (NSString*) my_callStack
{
    NSMutableString* result = [NSMutableString string];
    unsigned lines = 0;
    for (NSString* line in [self callStackSymbols]) {
        NSString* symbol = @"";
        if (line.length > 40) {
            NSRange space = [line rangeOfString: @" " options: 0 range: NSMakeRange(41, line.length - 41)];
            if (space.length > 0)
                symbol = [line substringFromIndex: NSMaxRange(space)];
        }
        // Skip  frames that are part of the exception/assertion handling itself:
        if( [symbol hasPrefix: @"-[NSAssertionHandler"] || [symbol hasPrefix: @"+[NSException"]
                || [symbol hasPrefix: @"-[NSException"] || [symbol hasPrefix: @"_AssertFailed"]
                || [symbol hasPrefix: @"__exception"] || [symbol hasPrefix: @"objc_"] )
            continue;
        if( result.length )
            [result appendString: @"\n"];
        [result appendString: @"\t"];
        [result appendString: line];
        // Don't show the "__start" frame below "main":
        if( [symbol hasPrefix: @"main "] || [symbol hasPrefix: @"start "] )
            break;
        if (++lines >= 15) {
            [result appendString: @"\n\t..."];
            break;
        }
    }
    return result;
}

@end




#ifdef NSAppKitVersionNumber10_4 // only enable this in a project that uses AppKit

@implementation MYExceptionReportingApplication


static void report( NSException *x ) {
    [NSApp reportException: x];
}

- (id) init
{
    self = [super init];
    if (self != nil) {
        MYSetExceptionReporter(&report);
    }
    return self;
}


- (void)reportException:(NSException *)x
{
    [super reportException: x];
    [self performSelector: @selector(_showExceptionAlert:) withObject: x afterDelay: 0.0];
    MYSetExceptionReporter(NULL);     // ignore further exceptions till alert is dismissed
}

- (void) _showExceptionAlert: (NSException*)x
{
    NSString *stack = [x my_callStack] ?:@"";

#pragma clang diagnostic ignored "-Wformat-security"
    NSInteger r = NSRunCriticalAlertPanel( @"Internal Error!",
                            [NSString stringWithFormat: @"Uncaught exception: %@\n%@\n\n%@\n\n"
                             "Please report this bug (you can copy & paste the text).",
                             [x name], [x reason], stack],
                            @"Continue",@"Quit",nil);
#pragma clang diagnostic pop

    if( r == NSAlertAlternateReturn )
        exit(1);
    MYSetExceptionReporter(&report);
}

@end

#endif



BOOL IsGDBAttached( void )
{
#ifdef GNUSTEP
    return NO;
#else
    // From: <http://lists.apple.com/archives/Xcode-users/2004/Feb/msg00241.html>
    int mib[4];
    size_t bufSize = 0;
    struct kinfo_proc kp;
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    
    bufSize = sizeof (kp);
    if (sysctl(mib, 4, &kp, &bufSize, NULL, 0) < 0) {
        Warn(@"Error %i calling sysctl",errno);
        return NO;
    }
    return (kp.kp_proc.p_flag & P_TRACED) != 0;
#endif
}



/*
 Copyright (c) 2008, Jens Alfke <jens@mooseyard.com>. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted
 provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions
 and the following disclaimer in the documentation and/or other materials provided with the
 distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRI-
 BUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
 THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
