//
//  TDCanonicalJSON.m
//  TouchDB
//
//  Created by Jens Alfke on 8/15/11.
//  Copyright (c) 2011 Couchbase, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//
//  Modifications for this distribution by Cloudant, Inc., Copyright (c) 2014 Cloudant, Inc.

#import "TDCanonicalJSON.h"
#import <math.h>

@interface TDCanonicalJSON ()
- (void)encode:(id)object;
@end

@implementation TDCanonicalJSON

- (id)initWithObject:(id)object
{
    self = [super init];
    if (self) {
        _input = object;
    }
    return self;
}

@synthesize ignoreKeyPrefix = _ignoreKeyPrefix, whitelistedKeys = _whitelistedKeys;

- (void)encodeString:(NSString*)string
{
    static NSCharacterSet* kCharsToQuote;
    if (!kCharsToQuote) {
        NSMutableCharacterSet* chars =
            (id)[NSMutableCharacterSet characterSetWithRange : NSMakeRange(0, 32)];
        [chars addCharactersInString:@"\"\\"];
        kCharsToQuote = [chars copy];
    }

    [_output appendString:@"\""];
    NSRange remainder = {0, string.length};
    while (remainder.length > 0) {
        NSRange quote = [string rangeOfCharacterFromSet:kCharsToQuote options:0 range:remainder];
        if (quote.length == 0) quote.location = string.length;
        NSUInteger nChars = quote.location - remainder.location;
        [_output appendString:[string substringWithRange:NSMakeRange(remainder.location, nChars)]];
        if (quote.length > 0) {
            unichar ch = [string characterAtIndex:quote.location];
            NSString* escaped;
            switch (ch) {
                case '"':
                    escaped = @"\\\"";
                    break;
                case '\\':
                    escaped = @"\\\\";
                    break;
                case '\r':
                    escaped = @"\\r";
                    break;
                case '\n':
                    escaped = @"\\n";
                    break;
                default:
                    escaped = [NSString stringWithFormat:@"\\u%04x", ch];
                    break;
            }
            [_output appendString:escaped];
            ++nChars;
        }
        remainder.location += nChars;
        remainder.length -= nChars;
    }
    [_output appendString:@"\""];
}

- (void)encodeNumber:(NSNumber*)number
{
    const char* encoding = number.objCType;
    if (encoding[0] == 'c')
        [_output appendString:[number boolValue] ? @"true" : @"false"];
    else
        [_output appendString:[number stringValue]];
}

- (void)encodeArray:(NSArray*)array
{
    [_output appendString:@"["];
    BOOL first = YES;
    for (id item in array) {
        if (first)
            first = NO;
        else
            [_output appendString:@","];
        [self encode:item];
    }
    [_output appendString:@"]"];
}

static NSComparisonResult compareCanonStrings(id s1, id s2, void* context)
{
    return [s1 compare:s2 options:NSLiteralSearch];
    /* Alternate implementation in case NSLiteralSearch turns out to be inappropriate:
    NSUInteger len1 = [s1 length], len2 = [s2 length];
    unichar chars1[len1], chars2[len2];     //FIX: Will crash (stack overflow) on v. long strings
    [s1 getCharacters: chars1 range: NSMakeRange(0, len1)];
    [s2 getCharacters: chars2 range: NSMakeRange(0, len2)];
    NSUInteger minLen = MIN(len1, len2);
    for (NSUInteger i=0; i<minLen; i++) {
        if (chars1[i] > chars2[i])
            return 1;
        else if (chars1[i] < chars2[i])
            return -1;
    }
    // All chars match, so the longer string wins
    return (NSInteger)len1 - (NSInteger)len2;
     */
}

+ (NSArray*)orderedKeys:(NSDictionary*)dict
{
    return [[dict allKeys] sortedArrayUsingFunction:&compareCanonStrings context:NULL];
}

- (void)encodeDictionary:(NSDictionary*)dict
{
    [_output appendString:@"{"];
    BOOL first = YES;
    for (NSString* key in [[self class] orderedKeys:dict]) {
        Assert([key isKindOfClass:[NSString class]], @"Can't encode %@ as dict key in JSON",
               [key class]);
        if (_ignoreKeyPrefix && [key hasPrefix:_ignoreKeyPrefix] &&
            ![_whitelistedKeys containsObject:key])
            continue;
        if (first)
            first = NO;
        else
            [_output appendString:@","];
        [self encodeString:key];
        [_output appendString:@":"];
        [self encode:dict[key]];
    }
    [_output appendString:@"}"];
}

- (void)encode:(id)object
{
    if ([object isKindOfClass:[NSString class]]) {
        [self encodeString:object];
    } else if ([object isKindOfClass:[NSNumber class]]) {
        [self encodeNumber:object];
    } else if ([object isKindOfClass:[NSNull class]]) {
        [_output appendString:@"null"];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        [self encodeDictionary:object];
    } else if ([object isKindOfClass:[NSArray class]]) {
        [self encodeArray:object];
    } else {
        Assert(NO, @"Can't encode instances of %@ as JSON", [object class]);
    }
}

- (void)encode
{
    if (!_output) {
        _output = [[NSMutableString alloc] init];
        [self encode:_input];
    }
}

- (NSString*)canonicalString
{
    [self encode];
    return [_output copy];
}

- (NSData*)canonicalData
{
    [self encode];
    return [_output dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString*)canonicalString:(id)rootObject
{
    TDCanonicalJSON* encoder = [[self alloc] initWithObject:rootObject];
    NSString* result = encoder.canonicalString;
    return result;
}

+ (NSData*)canonicalData:(id)rootObject
{
    TDCanonicalJSON* encoder = [[self alloc] initWithObject:rootObject];
    NSData* result = encoder.canonicalData;
    return result;
}

@end
