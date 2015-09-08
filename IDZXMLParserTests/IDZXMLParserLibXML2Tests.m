//
//  IDZXMLParserLibXML2Tests.m
//  IDZXMLParser
//
//  Created by idz on 8/20/15.
//  Copyright (c) 2015 iOS Developer Zone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <IDZXMLParser/IDZXMLParser.h>
#import "IDZXMLParserCallLogger.h"
#import "IDZXMLParserTests.h"


@interface IDZXMLParserLibXML2Tests : IDZXMLParserTests

@end

@implementation IDZXMLParserLibXML2Tests

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
    id<IDZXMLParser> parser = [[IDZXMLParserLibXML2 alloc] initWithContentsOfURL:url];
    return parser;
}

- (id<IDZXMLParser>)parserForData:(NSData*)data
{
    id<IDZXMLParser> parser = [[IDZXMLParserLibXML2 alloc] initWithData:data];
    return parser;
}

- (id<IDZXMLParser>)parserForStream:(NSInputStream*)stream
{
    id<IDZXMLParser> parser = [[IDZXMLParserLibXML2 alloc] initWithStream:stream];
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



- (void)testDefinedElement
{
    const char* content =
    "<?xml version=\"1.0\" standalone=\"yes\" ?>" \
    "<!DOCTYPE blog [" \
    "  <!ELEMENT title (#PCDATA)>" \
    "  <!ELEMENT body (#PCDATA)>" \
    "  <!ELEMENT seq2 (title, body)>" \
    "  <!ELEMENT seq3 (title, body, title)>" \
    "  <!ELEMENT seq4 (title, body, title, body)>" \
    "  <!ELEMENT choice2 (title | body)>" \
    "  <!ELEMENT choice3 (title | body | title)>" \
    "  <!ELEMENT choice4 (title | body | title | body)>" \
    " ]>" \
    "<blog>" \
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
    // To passs the test all calls to parser:foundElementDeclarationWithName:model:
    // should have non-empty model strings
    XCTAssert(nonEmptyString.count == 8, @"All models strings are non-empty");
    
}

//- (void) testProbeExternal
//{
//    [super probeExteral];
//}

- (void)testProbeExternal
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths[0] stringByAppendingPathComponent:@"xmlconf"] stringByAppendingPathComponent:@"xmlconf.xml"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSAssert([fileManager fileExistsAtPath:filePath], @"Test file exists");
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
    IDZXMLParserLibXML2 *parser = [[IDZXMLParserLibXML2 alloc] initWithContentsOfURL:url];
    parser.shouldResolveExternalEntities = YES;
//    parser.externalEntityResolvingPolicy = NSXMLParserResolveExternalEntitiesNoNetwork;
    ExternalEntityDelegate *delegate = [[ExternalEntityDelegate alloc] init];
    parser.delegate = delegate;
    BOOL result = [parser parse];
    XCTAssert(result, @"Parser completed successfully (%@)", parser.parserError);
    //[delegate dump];
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
    [self remoteExternalAlways];
}

#pragma mark - External DTDs

- (void)testProbeLocalExternalDTD
{
    [self probeLocalExternalDTD];
}


@end