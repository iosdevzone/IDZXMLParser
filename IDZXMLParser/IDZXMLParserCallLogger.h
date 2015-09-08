//
//  IDZXMLParserCallDump.h
//  IDZXMLParser
//
//  Created by idz on 8/13/15.
//  Copyright (c) 2015 iOS Developer Zone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDZXMLParser.h"

#import <IDZDelegateLogger/IDZDelegateLogger.h>

@interface IDZXMLParserCallLogger : IDZDelegateLogger<IDZXMLParserDelegate>
/*
 * Makes life easier when testing entity expansion.
 * If YES logger will pretend it does not responds to @selector(parser:foundReference).
 * Default is NO.
 */
@property (nonatomic, assign) BOOL ignoresFoundReference;
@end


