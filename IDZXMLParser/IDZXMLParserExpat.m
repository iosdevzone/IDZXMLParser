//
//  IDZXMLParserExpat.m
//  IDZXMLParser
//
//  Created by idz on 8/13/15.
//  Copyright (c) 2015 iOS Developer Zone. All rights reserved.
//

#import "IDZXMLParserExpat.h"

#import "expat.h"

#define IDZ_EXPAT_BUFSIZ (128*1024)

@interface IDZXMLParserExpat ()
@property (nonatomic, readonly) NSInputStream *inputStream;
@property (nonatomic, readonly) XML_Parser parser;
@property (nonatomic, readwrite, strong) NSError* parserError;
@end

@implementation IDZXMLParserExpat
@synthesize parser = mParser;
@synthesize delegate = mDelegate;
@synthesize shouldResolveExternalEntities = mShouldResolveExternalEntities;
@synthesize inputStream = mInputStream;
@synthesize parserError = mParserError;

static IDZXMLParserExpat* IDZXMLParserExpatGetParser(void *userData) {
    return ((__bridge IDZXMLParserExpat *)userData);
}

static NSString* IDZExpatString(const XML_Char *s) {
    return s ? [NSString stringWithCString:s encoding:NSUTF8StringEncoding] : nil;
}

static NSString* IDZExpatString2(const XML_Char *s, int len) {
    return [[NSString alloc] initWithBytes:s length:len encoding:NSUTF8StringEncoding];
}



static void IDZParserExpatXmlDeclHandler(void           *userData,
                                    const XML_Char *version,
                                    const XML_Char *encoding,
                                    int             standalone)
{
    IDZXMLParserExpat* parser = IDZXMLParserExpatGetParser(userData);
    [parser.delegate parser:parser
        foundXMLDeclarationWithVersion:IDZExpatString(version)
                            encoding:IDZExpatString(encoding)
                 standalone:standalone];
    
}

static void IDZXMLParserExpatAttlistDecl(
                                         void            *userData,
                                         const XML_Char  *elname,
                                         const XML_Char  *attname,
                                         const XML_Char  *att_type,
                                         const XML_Char  *dflt,
                                         int              isrequired) {
    NSLog(@"%s %s %s %s %s", elname, attname, att_type, dflt, isrequired ? "YES" : "NO");
    NSString *elementName = [[NSString alloc] initWithCString:elname encoding:NSUTF8StringEncoding];
    NSString *attributeName = [[NSString alloc] initWithCString:attname encoding:NSUTF8StringEncoding];
    NSString *attributeType = [[NSString alloc] initWithCString:att_type encoding:NSUTF8StringEncoding];
    NSString *defaultValue = nil;
    if(dflt) {
        defaultValue = [[NSString alloc] initWithCString:dflt encoding:NSUTF8StringEncoding];
    }
    IDZXMLParserExpat* parser = IDZXMLParserExpatGetParser(userData);
    //    [parser.delegate parser:parser attlistDeclElementName:elementName attributeName:attributeName attributeType:attributeType defaultValue:defaultValue isRequired: isrequired ? YES : NO];
    [parser.delegate parser:parser foundAttributeDeclarationWithName:attributeName forElement:elementName type:attributeType defaultValue:defaultValue];
}

static NSString* IDZXMLModelToString(XML_Content *model, int level) {
    NSMutableString *s = [[NSMutableString alloc] init];
    switch(model->type) {
        case XML_CTYPE_SEQ:
        {
            NSCAssert(model->numchildren >= 1, @"Sequence must have at least one child.");
            [s appendString:IDZXMLModelToString(&model->children[0], level+1)];
            for(int i = 1; i < model->numchildren; ++i) {
                [s appendFormat:@", %@",IDZXMLModelToString(&model->children[i], level+1)];
            }
        }
            break;
        case XML_CTYPE_NAME:
            [s appendString:[[NSString alloc] initWithCString:model->name encoding:NSUTF8StringEncoding]];
            break;
        case XML_CTYPE_MIXED:
            
            [s appendString:@"#PCDATA"];
            
            for(int i = 0; i < model->numchildren; ++i) {
                [s appendFormat:@" | %@",IDZXMLModelToString(&model->children[i], level+1)];
            }
            break;
        default:
            NSCAssert(NO, @"Unexpected type");
    }
    if(level == 0) {
        s = [NSMutableString stringWithFormat:@"(%@)", s];
    }
    switch (model->quant) {
        case XML_CQUANT_REP:
            [s appendString:@"*"];
            break;
        case XML_CQUANT_PLUS:
            [s appendString:@"+"];
            break;
        case XML_CQUANT_OPT:
            [s appendString:@"?"];
            break;
        case XML_CQUANT_NONE:
            break;
            
        default:
            NSCAssert(NO, @"Unexpected quant");
    }
    return s;
}

static void IDZXMLParserExpatElementDecl(void *userData,
                                        const XML_Char *name,
                                        XML_Content *model) {
    NSString *nameString = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
    NSString *modelString = IDZXMLModelToString(model, 0);
    
    IDZXMLParserExpat* parser = IDZXMLParserExpatGetParser(userData);
    [parser.delegate parser:parser foundElementDeclarationWithName:nameString model:modelString];
    
}
/* 
 
 See xmlparse.c:
 
 This is called for entity declarations. The is_parameter_entity
 argument will be non-zero if the entity is a parameter entity, zero
 otherwise.
 
 For internal entities (<!ENTITY foo "bar">), value will
 be non-NULL and systemId, publicID, and notationName will be NULL.
 The value string is NOT nul-terminated; the length is provided in
 the value_length argument. Since it is legal to have zero-length
 values, do not use this argument to test for internal entities.
 
 For external entities, value will be NULL and systemId will be
 non-NULL. The publicId argument will be NULL unless a public
 identifier was provided. The notationName argument will have a
 non-NULL value only for unparsed entity declarations.
 
 Note that is_parameter_entity can't be changed to XML_Bool, since
 that would break binary compatibility.
 */
static void IDZXMLParserExpatEntityDecl(
                                               void *userData,
                                               const XML_Char *entityName,
                                               int is_parameter_entity,
                                               const XML_Char *value,
                                               int value_length,
                                               const XML_Char *base,
                                               const XML_Char *systemId,
                                               const XML_Char *publicId,
                                  const XML_Char *notationName) {
    IDZXMLParserExpat* parser = IDZXMLParserExpatGetParser(userData);
    NSString *nameString = [NSString stringWithCString:entityName encoding:NSUTF8StringEncoding];
    NSString *valueString = [[NSString alloc] initWithBytes:value length:value_length encoding:NSUTF8StringEncoding];
    if(value)
    {
        [parser.delegate parser:parser foundInternalEntityDeclarationWithName:nameString value:valueString];
    }
    else if(systemId)
    {
        NSCAssert(!publicId && !notationName, @"Unhandled entity decl type.");
        [parser.delegate parser:parser foundExternalEntityDeclarationWithName:nameString publicID:IDZExpatString(publicId) systemID:IDZExpatString(systemId)];
        
    }
    
    
    
}

static void IDZXMLParserExpatDefault(void *userData, const XML_Char* s, int len) {
    IDZXMLParserExpat* parser = IDZXMLParserExpatGetParser(userData);
    NSString *string = [[NSString alloc] initWithBytes:s length:len encoding:NSUTF8StringEncoding];
    if([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
    {
        if([parser.delegate respondsToSelector:@selector(parser:foundIgnorableWhitespace:)]) {
            [parser.delegate parser:parser foundIgnorableWhitespace:string];
        }
        return;
    }
    if([string hasPrefix:@"&"] && [string hasSuffix:@";"]) {
        if([parser.delegate respondsToSelector:@selector(parser:foundReference:)]) {
            NSString *name = [string substringWithRange:NSMakeRange(1, string.length -2)];
            [parser.delegate parser:parser foundReference:name];
        }
        return;
    }
    
    NSCAssert(parser.delegate, @"Delegate is not nil.");
    if([parser.delegate respondsToSelector:@selector(parser:defaultHandler:)]) {
        [parser.delegate parser:parser defaultHandler:string];
    }
}

static void IDZXMLParserExpatCharacterData(void *userData, const XML_Char* s, int len) {
    NSString *string = [[NSString alloc] initWithBytes:s length:len encoding:NSUTF8StringEncoding];
    IDZXMLParserExpat* parser = IDZXMLParserExpatGetParser(userData);
    NSCAssert(parser.delegate, @"Delegate is not nil.");
    [parser.delegate parser:parser foundCharacters:string];
}



void IDZXMLParserExpatStartDoctypeDecl(
                                    void *userData,
                                    const XML_Char *doctypeName,
                                    const XML_Char *sysid,
                                    const XML_Char *pubid,
                                    int has_internal_subset)
{
    NSString *name = [[NSString alloc] initWithCString:doctypeName encoding:NSUTF8StringEncoding];
    NSString *systemID = sysid ? [[NSString alloc] initWithCString:sysid encoding:NSUTF8StringEncoding] : nil;
    NSString *publicID = pubid ? [[NSString alloc] initWithCString:pubid encoding:NSUTF8StringEncoding] : nil;
    IDZXMLParserExpat* parser = IDZXMLParserExpatGetParser(userData);
    [parser.delegate parser:parser foundStartDoctypeDecl:name systemID:systemID publicID:publicID hadInternalSubset:has_internal_subset];
}

void IDZXMLParserExpatEndDoctypeDecl(void *userData)
{
    IDZXMLParserExpat* parser = IDZXMLParserExpatGetParser(userData);
    [parser.delegate parserFoundEndDoctypeDecl:parser];
}



/**
 * @note Implementing this routine disables the default behavior of passing through the 
 * enitity name 'as is'. 
 *
 * @param context The context string consists of a
 * sequence of tokens separated by formfeeds (\f); a token consisting
 * of a name specifies that the general entity of the name is open; a
 * token of the form prefix=uri specifies the namespace for a
 * particular prefix; a token of the form =uri specifies the default
 * namespace.  
 *
 * @param base The base URL of parser. In the general case this can be NULL
 * but it should never be NULL here; we should have set it up in the init.
 *
 * See: "Handling External Entity References" in http://www.xml.com/pub/a/1999/09/expat/index2.html
 * for more information.
 * The type of this handler is XML_ExternalEntityRefHandler.
 * Returns: XML_STATUS_ERROR on error
 */
int IDZXMLParserExpatExternalEntityRef(
                                             XML_Parser parser,
                                             const XML_Char *context,
                                             const XML_Char *base,
                                             const XML_Char *systemId,
                                             const XML_Char *publicId)
{
    // This should have been setup by calling XML_SetBase at startup
    NSCParameterAssert(base);
    NSURL *resolved = [NSURL URLWithString:IDZExpatString(systemId) relativeToURL:[NSURL URLWithString:IDZExpatString(base)]];

    XML_Parser child = XML_ExternalEntityParserCreate(parser, context, NULL);
    char buffer[IDZ_EXPAT_BUFSIZ];
    NSInputStream *inputStream = [[NSInputStream alloc] initWithURL:resolved];
    if(!inputStream) {
        return XML_STATUS_ERROR;
    }
    [inputStream open];
    int result = XML_STATUS_OK;
    while(1) {
        @autoreleasepool {
            NSInteger nBytes = [inputStream read:(uint8_t*)buffer maxLength:IDZ_EXPAT_BUFSIZ];
            if(nBytes < 0)
            {
                result = XML_STATUS_ERROR;
                break;
            }
            result = XML_Parse(child, (const char *)&buffer, (int)nBytes, nBytes==0);
            if(result != XML_STATUS_OK || nBytes == 0)
                break;
        }
    }
    [inputStream close];
    return result;
}



void IDZXMLParserExpatStartElement(void* userData, const XML_Char *name,
                          const XML_Char **atts) {
    NSString *string = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
   // NSMutableArray *attributes = [[NSMutableArray alloc] init];
    NSMutableDictionary *attributeDict = [[NSMutableDictionary alloc] init];
    for(const XML_Char **pAttribute = atts; *pAttribute; pAttribute++) {
        NSString *attribute = [[NSString alloc] initWithCString:*pAttribute encoding:NSUTF8StringEncoding];
        pAttribute++;
        NSCAssert(pAttribute, @"Attribute value is non-nil");
        NSString *value = [[NSString alloc] initWithCString:*pAttribute encoding:NSUTF8StringEncoding];
        attributeDict[attribute] = value;
        
        
    }
    IDZXMLParserExpat* parser = IDZXMLParserExpatGetParser(userData);
    NSCAssert(parser.delegate, @"Delegate is not nil.");
    [parser.delegate parser:parser didStartElement:string namespaceURI:nil qualifiedName:nil attributes:attributeDict];
}

static void IDZXMLParserExpatEndElement(void *userData, const XML_Char* s) {
    NSString *string = [[NSString alloc] initWithCString:s encoding:NSUTF8StringEncoding];
    IDZXMLParserExpat* parser = IDZXMLParserExpatGetParser(userData);
    NSCAssert(parser.delegate, @"Delegate is not nil.");
    [parser.delegate parser:parser didEndElement:string namespaceURI:nil qualifiedName:nil];
}

static void IDZXMLParserExpatComment(void *userData, const XML_Char* comment) {
    NSString *string = [[NSString alloc] initWithCString:comment encoding:NSUTF8StringEncoding];
    IDZXMLParserExpat* parser = IDZXMLParserExpatGetParser(userData);
    NSCAssert(parser.delegate, @"Delegate is not nil.");
    [parser.delegate parser:parser foundComment:string];
}

static void IDZXMLParserExpatProcessingInstruction(
                                                          void *userData,
                                                          const XML_Char *target,
                                                          const XML_Char *data)
{
    IDZXMLParserExpat* parser = IDZXMLParserExpatGetParser(userData);
    NSCAssert(parser.delegate, @"Delegate is not nil.");
    [parser.delegate parser:parser foundProcessingInstructionWithTarget:IDZExpatString(target) data:IDZExpatString(data)];
}

- (instancetype)initWithContentsOfURL:(NSURL *)url {
    // Note: -[NSInputStream initWithURL:] does not handle remote URLs
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    self = [self initWithData:data];
    XML_SetBase(mParser, url.absoluteString.UTF8String);
    return  self;
}

- (instancetype)initWithStream:(NSInputStream *)stream {
// For compatibility with NSXMLParser we delay this error until parse time
//    NSParameterAssert(stream);
    if(self = [super init]) {
        mInputStream = stream;
        mParser = XML_ParserCreate(NULL);
        if(!mParser) {
            return nil;
        }
        XML_SetUserData(mParser, (__bridge void*)self);
    }
    return  self;
}

- (instancetype)initWithData:(NSData *)data {
// For compatibility with NSXMLParser we delay this error until parse time
//    NSParameterAssert(data);
    NSInputStream *inputStream = data ? [[NSInputStream alloc] initWithData:data] : nil;
    self = [self initWithStream:inputStream];
    return self;
}

- (void)setDelegate:(id<IDZXMLParserDelegate>)delegate {
    mDelegate = delegate;
    if([delegate respondsToSelector:@selector(parser:defaultHandler:)] ||
       [delegate respondsToSelector:@selector(parser:foundReference:)]) {
        XML_SetDefaultHandler(self.parser, IDZXMLParserExpatDefault);
    }
    if([delegate respondsToSelector:@selector(parser:foundCharacters:)]) {
        XML_SetCharacterDataHandler(self.parser, IDZXMLParserExpatCharacterData);
    }
    if([delegate respondsToSelector:@selector(parser:didEndElement:namespaceURI:qualifiedName:)]) {
        XML_SetEndElementHandler(self.parser, IDZXMLParserExpatEndElement);
    }
    if([delegate respondsToSelector:@selector(parser:didStartElement:namespaceURI:qualifiedName:attributes:)]) {
        XML_SetStartElementHandler(self.parser, IDZXMLParserExpatStartElement);
    }
    if([delegate respondsToSelector:@selector(parser:foundAttributeDeclarationWithName:forElement:type:defaultValue:)]) {
        XML_SetAttlistDeclHandler(self.parser, IDZXMLParserExpatAttlistDecl);
    }
    
    if([delegate respondsToSelector:@selector(parser:foundComment:)]) {
        XML_SetCommentHandler(self.parser, IDZXMLParserExpatComment);
    }
    
    if([delegate respondsToSelector:@selector(parser:foundElementDeclarationWithName:model:)]) {
        XML_SetElementDeclHandler(self.parser, IDZXMLParserExpatElementDecl);
    }
    
    if([delegate respondsToSelector:@selector(parser:foundXMLDeclarationWithVersion:encoding:standalone:)]) {
        XML_SetXmlDeclHandler(self.parser, IDZParserExpatXmlDeclHandler);
    }
    
    if([delegate respondsToSelector:@selector(parser:foundStartDoctypeDecl:systemID:publicID:hadInternalSubset:)]) {
        XML_SetStartDoctypeDeclHandler(self.parser, IDZXMLParserExpatStartDoctypeDecl);
    }
    
    if([delegate respondsToSelector:@selector(parserFoundEndDoctypeDecl:)]) {
        XML_SetEndDoctypeDeclHandler(self.parser, IDZXMLParserExpatEndDoctypeDecl);
        
    }
    if([delegate respondsToSelector:@selector(parser:foundInternalEntityDeclarationWithName:value:)]) {
        XML_SetEntityDeclHandler(self.parser, IDZXMLParserExpatEntityDecl);
    }
    
    if([delegate respondsToSelector:@selector(parser:foundProcessingInstructionWithTarget:data:)]) {
        XML_SetProcessingInstructionHandler(self.parser, IDZXMLParserExpatProcessingInstruction);
    }
    
    
    
    
       
}

- (BOOL)parse {
    if(!self.inputStream)
    {
        self.parserError = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:nil];
        return NO;
    }
    char buffer[IDZ_EXPAT_BUFSIZ];
    [self.inputStream open];
    if(self.inputStream.streamError)
    {
        NSLog(@"%s:%d: WARNING: Stream error", __FILE__, __LINE__);
    }
    
    // Need this here to avoid calling parserDidStartDocument if input is empty
    NSInteger nBytes = [self.inputStream read:(uint8_t*)buffer maxLength:IDZ_EXPAT_BUFSIZ];
    if(nBytes == 0)
    {
        self.parserError = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:nil];
        return NO;
    }
    if([self.delegate respondsToSelector:@selector(parserDidStartDocument:)])
    {
        [self.delegate parserDidStartDocument:self];
    }
    int result = XML_STATUS_OK;
    
    do {
        @autoreleasepool {

            result = XML_Parse(self.parser, (const char *)&buffer, (int)nBytes, nBytes==0);
            if(result != XML_STATUS_OK || nBytes == 0)
                break;
            nBytes = [self.inputStream read:(uint8_t*)buffer maxLength:IDZ_EXPAT_BUFSIZ];
            if(nBytes < 0)
            {
                result = XML_STATUS_ERROR;
                break;
            }
        }
    } while(1);
    
    [self.inputStream close];
    if([self.delegate respondsToSelector:@selector(parserDidEndDocument:)])
    {
        [self.delegate parserDidEndDocument:self];
    }
    return (result == XML_STATUS_OK);
}

- (NSInteger)lineNumber {
    return (NSInteger)XML_GetCurrentLineNumber(self.parser);
}

- (void)setShouldResolveExternalEntities:(BOOL)shouldResolveExternalEntities {
    mShouldResolveExternalEntities = shouldResolveExternalEntities;
    XML_SetExternalEntityRefHandler(self.parser, shouldResolveExternalEntities ?IDZXMLParserExpatExternalEntityRef : NULL);
}

@end
