//
//  NSXMLParserTests.m
//  IDZXMLParser
//
//  Created by idz on 8/19/15.
//  Copyright (c) 2015 iOS Developer Zone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "IDZXMLParserTests.h"
#import "IDZXMLParserCallLogger.h"

//@interface IDZXMLParserCallLogger (NSXMLParserDelegate)<NSXMLParserDelegate>
//@end
//@implementation IDZXMLParserCallLogger (NSXMLParserDelegate)
//@end

@interface NSXMLParser (IDZXMLParserConformance)<IDZXMLParser>
@end
@implementation NSXMLParser (IDZXMLParserConformance)
@end

@interface NSXMLParserTests : IDZXMLParserTests
@end

@implementation NSXMLParserTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Required overrides

- (id<IDZXMLParser>)parserForURL:(NSURL*)url
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    return parser;
}

- (id<IDZXMLParser>)parserForData:(NSData*)data
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    return parser;
}

- (id<IDZXMLParser>)parserForStream:(NSInputStream*)stream
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithStream:stream];
    return parser;
}

#pragma mark - Test nil arguments to init

- (void)testNilURL
{
    [self nilURL];
}

- (void)testNilData
{
    [self nilData];
}

- (void)testNilStream
{
    [self nilStream];
}

#pragma mark - Test extant, empty input

- (void)testEmptyURL
{
    [self emptyURL];
}

- (void)testEmptyData
{
    [self emptyData];
}

- (void)testEmptyStream
{
    [self emptyStream];
}

#pragma mark - Test for URL issues (non-existent, non-local, etc.)

- (void)testRemoteMissingURL
{
    [self remoteMissingURL];
}


- (void)testRemoteURL
{
    [self remoteURL];
}

- (void)testTrivialValidWF
{
    [self trivialValidWF];
}

- (void)testTrivialValidWFCharacters
{
    [self trivialValidWFCharacters];
}

- (void)trivialValidWFComment
{
    [self trivialValidWFCharacters];

}

- (void)testDefinedEntity
{
    const char* content = IDZXML(
                                 <?xml version="1.0" standalone="yes" ?>
                                 <!DOCTYPE foo [<!ENTITY bar "Johnnie Fox's">]>
                                 <foo>
                                 Entity expansion test begin &bar; end.
                                 </foo>);
    id<IDZXMLParser> parser = [self parserForCString:content];
    IDZXMLParserCallLogger *delegate = [[IDZXMLParserCallLogger alloc] init];
    parser.delegate = delegate;
    BOOL result = [parser parse];
    [delegate dump];
}

- (void)testElementDeclarationModel
{
    const char* content =
    "<?xml version=\"1.0\" standalone=\"yes\" ?>" \
    "<!DOCTYPE blog [" \
    "  <!ELEMENT title (#PCDATA)>" \
    "  <!ELEMENT body (#PCDATA)>" \
    "  <!ELEMENT post (title, body)>]>" \
    "<blog>" \
    "<post><title>Title</title><body>Lorem ipsum, etc.</body></post>" \
    "</blog>";
    id<IDZXMLParser> parser = [self parserForCString:content];
    IDZXMLParserCallLogger *delegate = [[IDZXMLParserCallLogger alloc] init];
    parser.delegate = delegate;
    BOOL result = [parser parse];
    [delegate dump];
    
}


@end
