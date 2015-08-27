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

#import <libxml/SAX2.h>
#import <libxml/parser.h>

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

/**
 * NSXMLParser *should* return an error for a file that uses external entities when
 * parser.shouldResolveExternalEntities == NO
 * In this case parser:foundExternalEntityDeclarationWithName:publicID:systemID: is not called
 * Although parser:resolveExternalEntityName:systemID: is still called.
 */
- (void)testShouldNotResolveExternalEntities
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths[0] stringByAppendingPathComponent:@"xmlconf"] stringByAppendingPathComponent:@"xmlconf.xml"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSAssert([fileManager fileExistsAtPath:filePath], @"Test file exists");
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    IDZXMLParserCallLogger *delegate = [[IDZXMLParserCallLogger alloc] init];
    parser.delegate = delegate;
    parser.shouldResolveExternalEntities = NO;
    BOOL result = [parser parse];
    NSLog(@"%@", parser.parserError);
    [delegate dump];
    XCTAssert(!result, @"Expected failure with error %@", parser.parserError);
}

- (void)testShouldResolveExternalEntitiesNever
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths[0] stringByAppendingPathComponent:@"xmlconf"] stringByAppendingPathComponent:@"xmlconf.xml"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSAssert([fileManager fileExistsAtPath:filePath], @"Test file exists");
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    IDZXMLParserCallLogger *delegate = [[IDZXMLParserCallLogger alloc] init];
    parser.delegate = delegate;
    parser.shouldResolveExternalEntities = YES;
    parser.externalEntityResolvingPolicy = NSXMLParserResolveExternalEntitiesNever;
    BOOL result = [parser parse];
    NSLog(@"%@", parser.parserError);
    [delegate dump];
    XCTAssert(!result, @"Expected failure with error %@", parser.parserError);
}

- (void)testShouldResolveExternalEntitiesNoNetwork
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths[0] stringByAppendingPathComponent:@"xmlconf"] stringByAppendingPathComponent:@"xmlconf.xml"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSAssert([fileManager fileExistsAtPath:filePath], @"Test file exists");
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    IDZXMLParserCallLogger *delegate = [[IDZXMLParserCallLogger alloc] init];
    parser.delegate = delegate;
    parser.shouldResolveExternalEntities = YES;
    parser.externalEntityResolvingPolicy = NSXMLParserResolveExternalEntitiesNoNetwork;
    BOOL result = [parser parse];
    NSLog(@"%@", parser.parserError);
    [delegate dump];
    XCTAssert(!result, @"Expected failure with error %@", parser.parserError);
}

- (void)testShouldResolveExternalEntitiesSameOriginOnly
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths[0] stringByAppendingPathComponent:@"xmlconf"] stringByAppendingPathComponent:@"xmlconf.xml"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSAssert([fileManager fileExistsAtPath:filePath], @"Test file exists");
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    IDZXMLParserCallLogger *delegate = [[IDZXMLParserCallLogger alloc] init];
    parser.delegate = delegate;
    parser.shouldResolveExternalEntities = YES;
    parser.externalEntityResolvingPolicy = NSXMLParserResolveExternalEntitiesSameOriginOnly;
    BOOL result = [parser parse];
    NSLog(@"%@", parser.parserError);
    [delegate dump];
    XCTAssert(!result, @"Expected failure with error %@", parser.parserError);
}

- (void)testShouldResolveExternalEntitiesAlways
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths[0] stringByAppendingPathComponent:@"xmlconf"] stringByAppendingPathComponent:@"xmlconf.xml"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSAssert([fileManager fileExistsAtPath:filePath], @"Test file exists");
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    IDZXMLParserCallLogger *delegate = [[IDZXMLParserCallLogger alloc] init];
    parser.delegate = delegate;
    parser.shouldResolveExternalEntities = YES;
    parser.externalEntityResolvingPolicy = NSXMLParserResolveExternalEntitiesAlways;
    BOOL result = [parser parse];
    NSLog(@"%@", parser.parserError);
    [delegate dump];
    XCTAssert(!result, @"Expected failure with error %@", parser.parserError);
}


- (void)testProbeExternal
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *filePath = [[paths[0] stringByAppendingPathComponent:@"xmlconf"] stringByAppendingPathComponent:@"xmlconf.xml"];
    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSAssert([fileManager fileExistsAtPath:filePath], @"Test file exists");
//    NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"local_external" withExtension:@"xml"];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parser.shouldResolveExternalEntities = YES;
    parser.externalEntityResolvingPolicy = NSXMLParserResolveExternalEntitiesNoNetwork;
    ExternalEntityDelegate *delegate = [[ExternalEntityDelegate alloc] init];
    parser.delegate = delegate;
    BOOL result = [parser parse];
    XCTAssert(result, @"Parser completed successfully (%@)", parser.parserError);
    //[delegate dump];
}

static void SAX2StartElementNs(void *ctx,
                      const xmlChar *localname,
                      const xmlChar *prefix,
                      const xmlChar *URI,
                      int nb_namespaces,
                      const xmlChar **namespaces,
                      int nb_attributes,
                      int nb_defaulted,
                      const xmlChar **attributes)
{
    NSString *s = [[NSString alloc] initWithCString:localname encoding:NSUTF8StringEncoding];
    NSLog(@"startElement: %@", s);
}

static void SAX2Characters(void *ctx, const xmlChar *ch, int len)
{
    NSString *s = [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
    NSLog(@"character: %@", s);
}

static void SAX2EndElementNs(void *ctx,
                                const xmlChar * localname,
                                const xmlChar * prefix,
                                const xmlChar * URI )
{
    NSString *s = [[NSString alloc] initWithCString:localname encoding:NSUTF8StringEncoding];
    NSLog(@"endElement: %@", s);
    
}

static void SAX2Warning(void *ctx, const char *msg, ...) {
    char buffer[1024];
    va_list args;
    va_start(args, msg);
    vsprintf(buffer, msg, args);
    va_end(args);
    NSLog(@"WARNING: %s", buffer);
    
}


- (void)testLibXML2ExternalEntities
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths[0] stringByAppendingPathComponent:@"xmlconf"] stringByAppendingPathComponent:@"xmlconf.xml"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSAssert([fileManager fileExistsAtPath:filePath], @"Test file exists");
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    
    xmlSAXHandler sax;
    memset(&sax, 0, sizeof(sax));
    sax.characters = SAX2Characters;
    sax.startElementNs = SAX2StartElementNs;
    sax.endElementNs = SAX2EndElementNs;
    sax.warning = SAX2Warning;
    sax.initialized = XML_SAX2_MAGIC;
    xmlParserCtxtPtr context = xmlCreatePushParserCtxt(&sax, (__bridge void*)self, NULL, 0, NULL);

    int result = xmlParseChunk(context, data.bytes, (int)data.length, 1);
    NSLog(@"Parse ended with result: %d", result);
    

    
}


@end
