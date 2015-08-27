//
//  IDZXMLParserTests.m
//  IDZXMLParserTests
//
//  Created by idz on 8/13/15.
//  Copyright (c) 2015 iOS Developer Zone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <IDZXMLParser/IDZXMLParser.h>
#import "DCTar.h"
#import "NVHTarGzip.h"

#import "IDZXMLParserCallLogger.h"
#import "IDZXMLParserTests.h"

BOOL verbose = YES;

@implementation ExternalEntityDelegate

//- (BOOL)respondsToSelector:(SEL)aSelector
//{
//    NSLog(@"respondsToSelector: %@", NSStringFromSelector(aSelector));
//    return [super respondsToSelector:aSelector];
//}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    NSLog(@"startElement: %@", elementName);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSLog(@"endElement: %@", elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"foundCharacter: %@", string);
}

- (void)parser:(NSXMLParser *)parser foundReference:(NSString *)string
{
    NSLog(@"foundReference: %@", string);
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"parseErrorOccurred:%@", parseError);
}

//- (NSData*)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID
//{
//    NSString *fizzbuzz = @"fizzbuzz";
//    return [fizzbuzz dataUsingEncoding:NSUTF8StringEncoding];
//}

@end

@implementation IDZDelegateLogger (IDZXMLParserTestsAdditions)

//- (void)forwardInvocation:(NSInvocation *)anInvocation
//{
//    NSLog(@"Forwarding %@", NSStringFromSelector(anInvocation.selector));
//    [super forwardInvocation:anInvocation];
//}

- (SEL)selectorAtIndex:(NSInteger)index
{
    return ((IDZInvocationDetails*)self.invocations[index]).selector;
}

- (IDZInvocationDetails*)invocationAtIndex:(NSInteger)index
{
    return self.invocations[index];
}

- (void)dumpToStdFile:(FILE*)f
{
    [self.invocations enumerateObjectsUsingBlock:^(IDZInvocationDetails *invocation, NSUInteger idx, BOOL *stop) {
        fprintf(f, "%s\n", invocation.description.UTF8String);
    }];
}

- (void)dump
{
    [self dumpToStdFile:stderr];
}
@end

@implementation IDZXMLParserTests

+ (void)initialize {
    
    NSString *tarfile = [[NSBundle bundleForClass:[self class]] pathForResource:@"xmlts20130923.tar" ofType:@"gz"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dataPath = tarfile;
    NSString* toPath = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSCAssert([fileManager fileExistsAtPath:dataPath], @"Input file exists.");

    NSError *error = nil;
    BOOL ok = [[NVHTarGzip sharedInstance] unTarGzipFileAtPath:dataPath toPath:toPath error:&error];
    NSCAssert(ok && (error == nil), @"Untarred test files successfully. %@", error);

}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Parser creation (must override)

- (id<IDZXMLParser>)parserForData:(NSData*)data
{
    NSAssert(NO, @"Subclasses must implement this.");
    return nil;
}

- (id<IDZXMLParser>)parserForURL:(NSURL*)url
{
    NSAssert(NO, @"Subclasses must implement this.");
    return nil;
}

- (id<IDZXMLParser>)parserForStream:(NSInputStream*)stream
{
    NSAssert(NO, @"Subclasses must implement this.");
    return nil;
}

#pragma mark - Convenience parser creation
- (id<IDZXMLParser>)parserForCString:(const char *)content
{
    NSData *data = content ? [NSData dataWithBytes:content length:strlen(content)] : nil;
    return [self parserForData:data];
}

#pragma mark - Common Pass/Fail Criteria
- (void)expectFailureWithParser:(id<IDZXMLParser>)parser error:(NSError*)errorDetails
{
    BOOL result = [parser parse];
    NSError *error = parser.parserError;
    XCTAssert(!result && error, @"Parser should fail with error.");
    if(error && verbose) {
        NSLog(@"result=%@ error=%@", result ? @"YES" : @"NO", parser.parserError);
    }
}

- (void)expectSuccessWithParser:(id<IDZXMLParser>)parser
{
    BOOL result = [parser parse];
    NSError *error = parser.parserError;
    XCTAssert(result && !error, @"Parser should succeed with no error.");
    if(error && verbose) {
        NSLog(@"result=%@ error=%@", result ? @"YES" : @"NO", parser.parserError);
    }
}



#pragma mark - Nil input tests
- (void)nilURL
{
    id<IDZXMLParser> parser = [self parserForURL:nil];
    [self expectFailureWithParser:parser error:nil];
}

- (void)nilData
{
    id<IDZXMLParser> parser = [self parserForData:nil];
    [self expectFailureWithParser:parser error:nil];
}

- (void)nilStream
{
    id<IDZXMLParser> parser = [self parserForStream:nil];
    [self expectFailureWithParser:parser error:nil];
}

#pragma mark - Empty input tests

- (void)emptyURL
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"empty" withExtension:@"xml"];
    NSAssert(url, @"Missing test input file.");
    id<IDZXMLParser> parser = [self parserForURL:nil];
    [self expectFailureWithParser:parser error:nil];
}

- (void)emptyData
{
    NSData *data = [NSData data];
    XCTAssertNotNil(data);
    id<IDZXMLParser> parser = [self parserForData:data];
    [self expectFailureWithParser:parser error:nil];
}

- (void)emptyStream
{
    NSInputStream *inputStream = [[NSInputStream alloc] initWithData:[NSData data]];
    XCTAssert(inputStream != nil);
    id<IDZXMLParser> parser = [self parserForStream:inputStream];
    [self expectFailureWithParser:parser error:nil];
}

- (void)remoteMissingURL
{
    NSUUID *uuid = [NSUUID UUID];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.iosdeveloperzone.com/%@.xml", uuid.UUIDString]];
    NSAssert(url, @"Missing test input file.");
    id<IDZXMLParser> parser = [self parserForURL:url];
    [self expectFailureWithParser:parser error:nil];
}

- (void)remoteURL
{
    NSURL *url = [NSURL URLWithString:@"http://www.w3schools.com/xml/note.xml"];
    NSAssert(url, @"Missing test input file.");
    id<IDZXMLParser> parser = [self parserForURL:url];
    [self expectSuccessWithParser:parser];
}



- (void)assertInvocations:(NSArray*)invocations match:(SEL)firstSelector, ...
{
    va_list args;
    va_start(args, firstSelector);
    SEL selector = firstSelector;
    NSInteger idx = 0;
    while(selector)
    {
        NSArray* arguments = va_arg(args, NSArray*);
        IDZInvocationDetails *invocation = invocations[idx++];
        XCTAssertEqual(selector, invocation.selector);
        
        
        
        XCTAssertEqualObjects(NSStringFromSelector(selector), NSStringFromSelector(invocation.selector), @"Expected %@ Got %@",
                              
                              NSStringFromSelector(selector),
                              NSStringFromSelector(invocation.selector));
        
        //XCTAssert(invocation.selector == selector);
        if(arguments && arguments.count > 0) {
            XCTAssert(arguments.count <= invocation.arguments.count);
            [arguments enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL *stop) {
                XCTAssert([obj isEqual:invocation.arguments[idx]]);
            }];
        }
        selector = va_arg(args, SEL);
    }
    va_end(args);
}

- (void)trivialValidWF
{
    const char* content = IDZXML(
                                    <doc></doc>
                                    );
    id<IDZXMLParser> parser = [self parserForCString:content];
    IDZXMLParserCallLogger *delegate = [[IDZXMLParserCallLogger alloc] init];
    parser.delegate = delegate;
    BOOL result = [parser parse];
    
    NSError *error = parser.parserError;
    XCTAssert(delegate.invocations.count == 4, @"Parser should have invoked delegate this many times.");
    [self assertInvocations:delegate.invocations match:
        IDZStartDocument, @[ parser ],
        IDZStartElement, @[ parser, @"doc" ],
        IDZEndElement, @[ parser, @"doc" ],
        IDZEndDocument, @[ parser ],
     nil];
    
    XCTAssert(result && !error, @"Parser should complete succesfully withour error");
    XCTAssert(result, @"Parser should complete succesfully withour error");
}

- (void)trivialValidWFCharacters
{
    
    const char* content = IDZXML(
                                 <doc>This is some text.</doc>
                                 );
    id<IDZXMLParser> parser = [self parserForCString:content];
    IDZXMLParserCallLogger *delegate = [[IDZXMLParserCallLogger alloc] init];
    parser.delegate = delegate;
    BOOL result = [parser parse];
    
    NSError *error = parser.parserError;
    XCTAssert(delegate.invocations.count == 5, @"Parser should have invoked delegate this many times.");
    [self assertInvocations:delegate.invocations match:
     IDZStartDocument, @[ parser ],
     IDZStartElement, @[ parser, @"doc" ],
     @selector(parser:foundCharacters:), @[ parser, @"This is some text."],
     IDZEndElement, @[ parser, @"doc" ],
     IDZEndDocument, @[ parser ],
     nil];
    
    XCTAssert(result && !error, @"Parser should complete succesfully without error");
    XCTAssert(result, @"Parser should complete succesfully withour error");
}

#pragma mark - External Entities
/**
 * Tests that a simple local entity can be expanded by the parser.
 * This requires that shouldResolveExternalEntities be YES.
 */
- (void)localExternal
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"local_external" withExtension:@"xml"];
    NSAssert(url, @"Missing test input file.");
    id<IDZXMLParser> parser = [self parserForURL:url];
    IDZXMLParserCallLogger *delegate = [[IDZXMLParserCallLogger alloc] init];
    //ExternalEntityDelegate *delegate = [[ExternalEntityDelegate alloc] init];
    parser.delegate = delegate;
    parser.shouldResolveExternalEntities = YES;
    BOOL result = [parser parse];
    [delegate dump];
    NSError *error = parser.parserError;
    [self assertInvocations:delegate.invocations match:
     IDZStartDocument, @[ parser ],
     @selector(parser:foundExternalEntityDeclarationWithName:publicID:systemID:), @[],
     @selector(parser:foundIgnorableWhitespace:), @[],
     IDZStartElement, @[ parser, @"book" ],
     @selector(parser:foundCharacters:), @[ parser, @"iOS Developer Zone"],
     IDZEndElement, @[ parser, @"book" ],
     IDZEndDocument, @[ parser ],
     nil];
    XCTAssert(result && !error, @"Parser should complete succesfully without error");
}


@end


