//
//  IDZXMLParserCallDump.m
//  IDZXMLParser
//
//  Created by idz on 8/13/15.
//  Copyright (c) 2015 iOS Developer Zone. All rights reserved.
//

#import "IDZXMLParserCallLogger.h"

@implementation IDZXMLParserCallLogger

- (BOOL)respondsToSelector:(SEL)aSelector
{
    // libxml2's SAX2 interface does not have callbacks for these.
    if(aSelector == @selector(parser:foundXMLDeclarationWithVersion:encoding:standalone:) ||
       aSelector == @selector(parser:foundStartDoctypeDecl:systemID:publicID:hadInternalSubset:) ||
       aSelector == @selector(parserFoundEndDoctypeDecl:))
    {
        return NO;
    }
    return [super respondsToSelector:aSelector];
}
@end
