//
//  IDZXMLParserExpatTests.m
//  IDZXMLParser
//
//  Created by idz on 8/19/15.
//  Copyright (c) 2015 iOS Developer Zone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <IDZXMLParser/IDZXMLParser.h>
#import "IDZXMLParserCallLogger.h"
#import "IDZXMLParserTests.h"

@interface IDZXMLParserExpatTests : IDZXMLParserTests

@end

@implementation IDZXMLParserExpatTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (id<IDZXMLParser>)parserForURL:(NSURL*)url
{
    id<IDZXMLParser> parser = [[IDZXMLParserExpat alloc] initWithContentsOfURL:url];
    return parser;
}

- (id<IDZXMLParser>)parserForData:(NSData*)data
{
    id<IDZXMLParser> parser = [[IDZXMLParserExpat alloc] initWithData:data];
    return parser;
}

- (id<IDZXMLParser>)parserForStream:(NSInputStream*)stream
{
    id<IDZXMLParser> parser = [[IDZXMLParserExpat alloc] initWithStream:stream];
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

- (void)testTrivialValidWFComment
{
    [self trivialValidWFCharacters];
}

#pragma mark - Internal Entities

/*
 * Test that if foundReference is defined in the delegate
 * that it is called with the unexpanded value of the referenced internal entity.
 */
- (void)testInternalEntityReference
{
    [self internalEntityReference];
}

- (void)testInternalEntityExpansion
{
    [self internalEntityExpansion];
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
    delegate.ignoresFoundReference = YES;
    parser.delegate = delegate;
    BOOL result = [parser parse];
    [delegate dump];
}

- (void)testDefinedElement
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
    __block NSMutableArray *emptyString = [NSMutableArray array];
    __block NSMutableArray *nonEmptyString = [NSMutableArray array];
    [delegate.invocations enumerateObjectsUsingBlock:^(IDZInvocationDetails *invocation, NSUInteger idx, BOOL *stop) {
        if(invocation.selector == @selector(parser:foundElementDeclarationWithName:model:))
        {
            NSString *model = invocation.arguments[2];
            XCTAssert([model isKindOfClass:[NSString class]]);
            if([model isEqualToString:@""])
            {
                [emptyString addObject:invocation];
            }
            else
            {
                [nonEmptyString addObject:invocation];
            }
            
        }
    }];
    // To passs the test all 3 calls to parser:foundElementDeclarationWithName:model:
    // should have non-empty model strings
    XCTAssert(nonEmptyString.count == 3, @"All models strings are non-empty");
    
}

- (void)testProbeExternal
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths[0] stringByAppendingPathComponent:@"xmlconf"] stringByAppendingPathComponent:@"xmlconf.xml"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSAssert([fileManager fileExistsAtPath:filePath], @"Test file exists");
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
    IDZXMLParserExpat *parser = [[IDZXMLParserExpat alloc] initWithContentsOfURL:url];
    //parser.shouldResolveExternalEntities = YES;
    //    parser.shouldResolveExternalEntities = YES;
    //    parser.externalEntityResolvingPolicy = NSXMLParserResolveExternalEntitiesNoNetwork;
    ExternalEntityDelegate *delegate = [[ExternalEntityDelegate alloc] init];
    parser.delegate = delegate;
    BOOL result = [parser parse];
    XCTAssert(result, @"Parser completed successfully (%@)", parser.parserError);
    //[delegate dump];
}

#pragma mark - Local External Entities

- (void)testLocalExternalNo
{
    [self localExternalNo];
}

- (void)testLocalExternalNever
{
    [self localExternalNever];
}

- (void)testLocalExternalNoNetwork
{
    [self localExternalNoNetwork];
}

- (void)testLocalExternalAlways
{
    [self localExternalAlways];
}

#pragma mark - Remote External Entities

- (void)testRemoteExternalNever
{
    [self remoteExternalNever];
}

- (void)testRemoteExternalNoNetwork
{
    [self remoteExternalNoNetwork];
}

- (void)testRemoteExternalAlways
{
    [self remoteExternalAlwaysExpat];
}

#pragma mark - External DTDs

- (void)testProbeLocalExternalDTD
{
    [self probeLocalExternalDTD];
}




@end
