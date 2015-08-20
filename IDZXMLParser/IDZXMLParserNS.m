//
//  IDZXMLParserNS.m
//  IDZXMLParser
//
//  Created by idz on 8/13/15.
//  Copyright (c) 2015 iOS Developer Zone. All rights reserved.
//

#import "IDZXMLParserNS.h"

@interface IDZXMLParserNS () <NSXMLParserDelegate>
{
    NSXMLParser *mParser;
}

@end

@implementation IDZXMLParserNS
@synthesize delegate = mDelegate;
@dynamic shouldResolveExternalEntities;
@dynamic parserError;

- (instancetype)initWithContentsOfURL:(NSURL *)url {
    if(self = [super init]) {
        mParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        mParser.shouldResolveExternalEntities = YES;
        mParser.externalEntityResolvingPolicy = NSXMLParserResolveExternalEntitiesAlways;
        mParser.delegate = self;
    }
    return self;
}

- (BOOL)parse {
    BOOL result = [mParser parse];
    if(!result) {
        NSLog(@"Parsing failed with error: %@", mParser.parserError);
        //NSXMLParserErrorDomain
    }
    return result;
}



- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue {
    if([self.delegate respondsToSelector:@selector(parser:foundAttributeDeclarationWithName:forElement:type:defaultValue:)]) {
        [self.delegate parser:self foundAttributeDeclarationWithName:attributeName forElement:elementName type:type defaultValue:defaultValue];
    }
}

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value {
    if([self.delegate respondsToSelector:@selector(parser:foundInternalEntityDeclarationWithName:value:)]) {
        [self.delegate parser:self foundInternalEntityDeclarationWithName:name value:value];
    }
    
}

- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID {
    if([self.delegate respondsToSelector:@selector(parser:foundExternalEntityDeclarationWithName:publicID:systemID:)]) {
        [self.delegate parser:self foundExternalEntityDeclarationWithName:name publicID:publicID systemID:systemID];
    }
}

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model {
    if([self.delegate respondsToSelector:@selector(parser:foundElementDeclarationWithName:model:)]) {
        [self.delegate parser:self foundElementDeclarationWithName:elementName model:model];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if([self.delegate respondsToSelector:@selector(parser:didStartElement:namespaceURI:qualifiedName:attributes:)]) {
        NSMutableArray *attributes = [[NSMutableArray alloc] init];
        for(id key in attributeDict) {
            [attributes addObject:key];
            [attributes addObject:attributeDict[key]];
        }
        [mDelegate parser:self didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if([self.delegate respondsToSelector:@selector(parser:didEndElement:namespaceURI:qualifiedName:)]) {
        [self.delegate parser:self didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
//    NSAssert(mDelegate, @"Delegate should be non-null.");
    if([mDelegate respondsToSelector:@selector(parser:foundCharacters:)]) {
        [mDelegate parser:self foundCharacters:string];
    }
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
    if([mDelegate respondsToSelector:@selector(parser:foundIgnorableWhitespace:)]) {
        [mDelegate parser:self foundIgnorableWhitespace:whitespaceString];
    }
}
- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)string {
    //    NSAssert(mDelegate, @"Delegate should be non-null.");
    if([mDelegate respondsToSelector:@selector(parser:foundComment:)]) {
        [mDelegate parser:self foundComment:string];
    }
}

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return [name dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSInteger)lineNumber {
    return mParser.lineNumber;
}

#pragma mark - Unmapped handlers
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"%d: parserDidStartDocument", (int)self.lineNumber);
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"%d: parserDidEndDocument", (int)self.lineNumber);
    
}

- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID {
    NSLog(@"%d: foundNotationDeclarationWithName:%@", (int)self.lineNumber, name);
}

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName {
   NSLog(@"%d: foundUnparsedEntityDeclarationWithName:%@", (int)self.lineNumber, name);
}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data {
    NSLog(@"%d: foundProcessingInstructionWithTarget:%@", (int)self.lineNumber, target);
    
}

- (void)setShouldResolveExternalEntities:(BOOL)shouldResolveExternalEntities {
    mParser.shouldResolveExternalEntities = shouldResolveExternalEntities;
}

- (BOOL)shouldResolveExternalEntities {
    return  mParser.shouldResolveExternalEntities;
}

- (NSError*)parserError {
    return mParser.parserError;
}

@end
