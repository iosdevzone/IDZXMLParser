//
//  IDZXMLParserProtocols.h
//  IDZXMLParser
//
//  Created by idz on 8/19/15.
//  Copyright (c) 2015 iOS Developer Zone. All rights reserved.
//

@protocol IDZXMLParserDelegate;

@protocol IDZXMLParser <NSObject>

- (instancetype)initWithContentsOfURL:(NSURL*)url;
- (instancetype)initWithData:(NSData*)data;
- (instancetype)initWithStream:(NSInputStream*)stream;
- (BOOL)parse;

@property (nonatomic, weak) id<IDZXMLParserDelegate> delegate;
@property (nonatomic, readonly) NSInteger lineNumber;
@property (nonatomic, assign) BOOL shouldResolveExternalEntities;
@property (nonatomic, readonly) NSError* parserError;

@end

@protocol IDZXMLParserDelegate  <NSObject>

@optional
// Unsupportable by NSXMLParser
- (void)parser:(id<IDZXMLParser>)parser foundXMLDeclarationWithVersion:(NSString *)version encoding:(NSString*)encoding standalone:(NSInteger)standalone;

- (void)parser:(id<IDZXMLParser>)parser foundStartDoctypeDecl:(NSString*)name
      systemID:(NSString*)systemID publicID:(NSString*)publicID hadInternalSubset:(int)hasInternalSubset;

- (void)parserFoundEndDoctypeDecl:(id<IDZXMLParser>)parser;

- (void)parser:(id<IDZXMLParser>)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data;

// New
- (void)parserDidStartDocument:(id<IDZXMLParser>)parser;
- (void)parserDidEndDocument:(id<IDZXMLParser>)parser;

- (void)parser:(id<IDZXMLParser>)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue;

- (void)parser:(id<IDZXMLParser>)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value;
- (void)parser:(id<IDZXMLParser>)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID;

- (void)parser:(id<IDZXMLParser>)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model;

- (void)parser:(id<IDZXMLParser>)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(id<IDZXMLParser>)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

- (void)parser:(id<IDZXMLParser>)parser foundCharacters:(NSString *)string;
- (void)parser:(id<IDZXMLParser>)parser foundReference:(NSString *)name;

- (void)parser:(id<IDZXMLParser>)parser foundIgnorableWhitespace:(NSString *)whitespaceString;

- (void)parser:(id<IDZXMLParser>)parser foundComment:(NSString *)comment;
//Old

@optional
- (void)parser:(id<IDZXMLParser>)parser defaultHandler:(NSString*)string;





//- (void)parser:(id<IDZXMLParser>)parser attlistDeclElementName:(NSString*)elementName attributeName:(NSString*)attributeName attributeType:(NSString*)attributeType defaultValue:(NSString*)defaultValue isRequired:(BOOL)isRequired;
@end
