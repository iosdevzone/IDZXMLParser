//
//  IDZXMLParserTests.h
//  IDZXMLParser
//
//  Created by idz on 8/19/15.
//  Copyright (c) 2015 iOS Developer Zone. All rights reserved.
//

#import <IDZXMLParser/IDZXMLParser.h>
#import "IDZDelegateLogger.h"

/**
 * Delegate to test delegated external entity resolution.
 */
@interface ExternalEntityDelegate : NSObject<IDZXMLParserDelegate>
@end

extern BOOL verbose;
/**
 * Macros to stringify inplace XML.
 */
#define IDZXML(_X) #_X

/*
 * Shorthand for various selectors
 */
#define IDZStartDocument @selector(parserDidStartDocument:)
#define IDZEndDocument @selector(parserDidEndDocument:)

#define IDZStartElement @selector(parser:didStartElement:namespaceURI:qualifiedName:attributes:)
#define IDZEndElement @selector(parser:didEndElement:namespaceURI:qualifiedName:)


@interface IDZDelegateLogger (IDZXMLParserTestsAdditions)
- (void)expectSelector:(SEL)selector atIndex:(NSInteger)index;
- (void)dumpToStdFile:(FILE*)f;
- (void)dump;
@end
/*
 * Base class holding tests for all parser implmentations.
 */
@interface IDZXMLParserTests : XCTestCase

/*
 * Subclasses must override all parser* methods.
 */
- (id<IDZXMLParser>)parserForData:(NSData*)data;
- (id<IDZXMLParser>)parserForURL:(NSURL*)url;
- (id<IDZXMLParser>)parserForStream:(NSInputStream*)stream;
/**
 * Convenience function for handling stringified inline XML
 */
- (id<IDZXMLParser>)parserForCString:(const char *)content;

- (void)assertInvocations:(NSArray*)invocations match:(SEL)firstSelector, ... NS_REQUIRES_NIL_TERMINATION;
/*
 *  Test bodies 
 */
- (void)nilURL;
- (void)nilData;
- (void)nilStream;
- (void)emptyURL;
- (void)emptyData;
- (void)emptyStream;
- (void)remoteURL;
- (void)remoteMissingURL;

- (void)trivialValidWF;
- (void)trivialValidWFCharacters;
- (void)trivialValidWFComment;

- (void)internalEntityReference;
- (void)internalEntityExpansion;

- (void)localExternalNo;

- (void)localExternalNever;
- (void)localExternalNoNetwork;
- (void)localExternalAlways;


- (void)remoteExternalNever;
- (void)remoteExternalNoNetwork;
- (void)remoteExternalAlways;

- (void)remoteExternalAlwaysExpat;

// Local External DTDs
- (void)probeLocalExternalDTD;

@end



