//
//  IDZXMLParserDump.m
//  IDZXMLParser
//
//  Created by idz on 8/13/15.
//  Copyright (c) 2015 iOS Developer Zone. All rights reserved.
//

#import "IDZXMLParserDump.h"

@interface IDZXMLParserDump ()
@property (nonatomic, strong) NSMutableDictionary* attributeDefaultValues;
@property (nonatomic, readonly) FILE* file;
@end

@implementation IDZXMLParserDump
@synthesize file = mFile;
@synthesize attributeDefaultValues = mAttributeDefaultValues;


- (instancetype)initWithFilePath:(NSString*)filePath {
    if(self = [super init]) {
        mFile = fopen(filePath.UTF8String, "w");
        if(!mFile)
            return nil;
        mAttributeDefaultValues = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}

- (instancetype)initWithFilePointer:(FILE*)file {
    NSParameterAssert(file);
    if(self = [super init]) {
        mFile = file;
        mAttributeDefaultValues = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    if(self.file)
        fclose(self.file);
}

- (void)parser:(id<IDZXMLParser>)parser foundXMLDeclarationWithVersion:(NSString *)version encoding:(NSString*)encoding standalone:(NSInteger)standalone {
    fprintf(self.file, "<?xml version=\"%s\" encoding=\"%s\"",
            version.UTF8String,
            encoding.UTF8String);
    if(standalone >= 0) {
        fprintf(self.file, " standalone=\"%s\"", standalone ? "yes" : "no");
    }
    fprintf(self.file, "?>");
}

- (void)parser:(id<IDZXMLParser>)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data {
    fprintf(self.file, "<?%s %s?>", target.UTF8String, data.UTF8String);
}

- (void)parser:(id<IDZXMLParser>)parser foundStartDoctypeDecl:(NSString*)name
      systemID:(NSString*)systemID publicID:(NSString*)publicID hadInternalSubset:(int)hasInternalSubset {
    fprintf(self.file, "<!DOCTYPE %s ", name.UTF8String);
    if(systemID) {
        fprintf(self.file, "SYSTEM \"%s\" ", systemID.UTF8String);
    }
    fprintf(self.file, "[");
    
}

- (void)parserFoundEndDoctypeDecl:(id<IDZXMLParser>)parser {
    fprintf(self.file, "]>");
}

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue {
    if(defaultValue) {
        self.attributeDefaultValues[attributeName] = defaultValue;
    }
    fprintf(self.file, "<!ATTLIST %s %s %s", elementName.UTF8String, attributeName.UTF8String, type.UTF8String);
    if(defaultValue) {
        fprintf(self.file, " \"%s\"", defaultValue.UTF8String);
    }
    else {
//        fprintf(self.file, " %s", isRequired ? "#REQUIRED" : "#IMPLIED");
        fprintf(self.file, " %s", "#IMPLIED");
    }
    fprintf(self.file, ">");
}


- (void)parser:(id<IDZXMLParser>)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value {
    fprintf(self.file, "<!ENTITY %s \"%s\">", name.UTF8String, value.UTF8String);
}

- (void)parser:(id<IDZXMLParser>)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID {
    fprintf(self.file, "<!ENTITY %s SYSTEM \"%s\">", name.UTF8String, systemID.UTF8String);
    
}



- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model {
    fprintf(self.file, "<!ELEMENT %s %s>", elementName.UTF8String, model.UTF8String);
    
}

//- (void)parser:(id<IDZXMLParser>)parser attlistDeclElementName:(NSString*)elementName attributeName:(NSString*)attributeName attributeType:(NSString*)attributeType defaultValue:(NSString*)defaultValue isRequired:(BOOL)isRequired {
//    NSAssert(self.attributeDefaultValues, @"Attribute default value dictionary is valid.");
//    if(defaultValue) {
//        self.attributeDefaultValues[attributeName] = defaultValue;
//    }
//    fprintf(self.file, "<!ATTLIST %s %s %s", elementName.UTF8String, attributeName.UTF8String, attributeType.UTF8String);
//    if(defaultValue) {
//        fprintf(self.file, " \"%s\"", defaultValue.UTF8String);
//    }
//    else {
//        fprintf(self.file, " %s", isRequired ? "#REQUIRED" : "#IMPLIED");
//    }
//    fprintf(self.file, ">\n");
//    
//}

- (void)parser:(id<IDZXMLParser>)parser defaultHandler:(NSString*)string {
    fprintf(self.file, "DEFAULT: %s", string.UTF8String);
}

- (void)parser:(id<IDZXMLParser>)parser foundCharacters:(NSString *)string {
    fprintf(self.file, "%s", string.UTF8String);
}

- (void)parser:(id<IDZXMLParser>)parser foundReference:(NSString *)name {
    fprintf(self.file, "&%s;", name.UTF8String);
}

- (void)parser:(id<IDZXMLParser>)parser foundComment:(NSString *)string {
    fprintf(self.file, "<!--%s-->", string.UTF8String);
}

- (void)parser:(id<IDZXMLParser>)parser foundIgnorableWhitespace:(NSString *)string {
    fprintf(self.file, "%s", string.UTF8String);
}

- (void)parser:(id<IDZXMLParser>)parser didStartElement:(NSString *)name namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSMutableString *attributeString = [[NSMutableString alloc] init];    
    for(id key in attributeDict) {
        NSString *value = attributeDict[key];
        // Suppress default attributes
        // @TODO: make this optional
        if([self.attributeDefaultValues[key] isEqualToString:value])
            continue;
        [attributeString appendFormat:@" %@=\"%@\"", key, value];
        
    }
    fprintf(self.file, "<%s%s>", name.UTF8String, attributeString.UTF8String);
}

- (void)parser:(id<IDZXMLParser>)parser didEndElement:(NSString *)name namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    fprintf(self.file, "</%s>", name.UTF8String);
}

@end


