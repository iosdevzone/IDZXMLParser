//
//  IDZXMLParser.m
//  IDZXMLParser
//
//  Created by idz on 8/13/15.
//  Copyright (c) 2015 iOS Developer Zone. All rights reserved.
//

#import "IDZXMLParserLibXML2.h"
#import <libxml/SAX2.h>
#import <libxml/parser.h>
#import <libxml/uri.h>
//#import "SwiftJPDict-Swift.h"

@interface IDZXMLParserLibXML2 ()

@property (nonatomic, readonly) xmlParserCtxtPtr context;
@property (nonatomic, assign) xmlDocPtr document;
@property (nonatomic, readonly) NSInputStream *inputStream;
@property (nonatomic, readwrite, strong) NSError* parserError;
@end

@implementation IDZXMLParserLibXML2
@synthesize inputStream = mInputStream;
@synthesize context = mContext;
@synthesize delegate = mDelegate;
@synthesize document = mDocument;
@synthesize shouldResolveExternalEntities = mShouldResolveExternalEntities;
@synthesize parserError = mParserError;

#define IDZ_BUFSIZ (16*1024)

#pragma mark - SAX2 Handlers

static IDZXMLParserLibXML2* IDZXMLParserLibXML2GetParser(void *userData) {
    return ((__bridge IDZXMLParserLibXML2 *)userData);
}

static NSString* IDZString(const xmlChar* pString) {
    return pString ? [[NSString alloc] initWithCString:(const char *)pString encoding:NSUTF8StringEncoding] : nil;
}

static NSString* IDZString2(const xmlChar* pString, NSInteger length) {
    return [[NSString alloc] initWithBytes:pString length:length encoding:NSUTF8StringEncoding];
}



int IDZSAX2IsStandalone(void *ctx) {
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    return xmlSAX2IsStandalone(parser.context);
}

int IDZSAX2HasInternalSubset(void *ctx) {
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    return IDZSAX2HasInternalSubset(parser.context);
}

int IDZSAX2HasExternalSubset(void *ctx) {
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    return IDZSAX2HasExternalSubset(parser.context);
}

void IDZSAX2InternalSubset(void *ctx, const xmlChar *name,
                      const xmlChar *ExternalID, const xmlChar *SystemID)
{
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    xmlSAX2InternalSubset(parser.context, name, ExternalID, SystemID);
}

void IDZSAX2ExternalSubset(void *ctx, const xmlChar *name,
                           const xmlChar *ExternalID, const xmlChar *SystemID)
{
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    xmlSAX2ExternalSubset(parser.context, name, ExternalID, SystemID);
}

xmlParserInputPtr IDZSAX2ResolveEntity(void *ctx, const xmlChar *publicId, const xmlChar *systemId)
{
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    return xmlSAX2ResolveEntity(ctx, publicId, systemId);
}

xmlEntityPtr IDZSAX2GetEntity(void *ctx, const xmlChar *name) {
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    return xmlSAX2GetEntity(parser.context, name);
}

xmlEntityPtr IDZSAX2GetParameterEntity(void *ctx, const xmlChar *name) {
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    return xmlSAX2GetParameterEntity(ctx, name);
}

static NSString* IDZSAX2ModelToString(xmlElementContentPtr model, int level) {
    NSMutableString *s = [[NSMutableString alloc] init];
    switch(model->type) {
        case XML_ELEMENT_CONTENT_PCDATA:
            [s appendString:@"#PCDATA"];
            break;
        case XML_ELEMENT_CONTENT_ELEMENT:
            [s appendString:IDZString(model->name)];
            break;
        case XML_ELEMENT_CONTENT_SEQ:
            NSCAssert(model->c1 && model->c2, @"Element sequence node must have two children.");
            if(model->c1 && model->c2) {
                [s appendFormat:@"%@, %@", IDZSAX2ModelToString(model->c1, level+1),
                 IDZSAX2ModelToString(model->c2, level+1)];
            }
            break;
        case XML_ELEMENT_CONTENT_OR:
            if(model->c1 && model->c2) {
                [s appendFormat:@"%@ | %@", IDZSAX2ModelToString(model->c1, level+1),
                 IDZSAX2ModelToString(model->c2, level+1)];
            }
            break;
        default:
            // This is unreachable unless a new element is added to xmlElementContentType
            NSCAssert(NO, @"Unexpected type");
    }
    if(level == 0) {
        s = [NSMutableString stringWithFormat:@"(%@)", s];
    }

    switch (model->ocur) {
        case XML_ELEMENT_CONTENT_ONCE:
            break;
        case XML_ELEMENT_CONTENT_OPT:
            [s appendString:@"?"];
            break;
        case XML_ELEMENT_CONTENT_MULT:
            [s appendString:@"*"];
            break;
        case XML_ELEMENT_CONTENT_PLUS:
            [s appendString:@"+"];
            break;
        default:
            // This is unreachable unless a new element is added to xmlElementContentOccur
            NSCAssert(NO, @"Unexpected quant");
    }
    return s;
}


void IDZSAX2ElementDecl(void *ctx, const xmlChar * name, int type,
                   xmlElementContentPtr content) {
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    NSString *elementName = IDZString(name);
    NSString *model = IDZSAX2ModelToString(content, 0);
    
    if([parser.delegate respondsToSelector:@selector(parser:foundElementDeclarationWithName:model:)]) {
        [parser.delegate parser:parser foundElementDeclarationWithName:elementName model:model];
    }
    
}

void IDZSAX2NotationDecl(void *ctx, const xmlChar *name,
                    const xmlChar *publicId, const xmlChar *systemId) {
    
}

void IDZSAX2UnparsedEntityDecl(void *ctx, const xmlChar *name,
                          const xmlChar *publicId, const xmlChar *systemId,
                          const xmlChar *notationName) {
    
}

void IDZSAX2SetDocumentLocator(void *ctx ATTRIBUTE_UNUSED, xmlSAXLocatorPtr loc ATTRIBUTE_UNUSED) {
    
}

void IDZSAX2CDataBlock(void *ctx, const xmlChar *value, int len) {
    
}

void IDZSAX2ProcessingInstruction(void *ctx, const xmlChar *target,
                             const xmlChar *data) {
    
}

void IDZParserError(void *ctx, const char *msg, ...) {
    char buffer[1024];
    va_list args;
    va_start(args, msg);
    vsprintf(buffer, msg, args);
    va_end(args);
    NSLog(@"ERROR: %s", buffer);
    
}

void IDZParserWarning(void *ctx, const char *msg, ...) {
    char buffer[1024];
    va_list args;
    va_start(args, msg);
    vsprintf(buffer, msg, args);
    va_end(args);
    NSLog(@"WARNING: %s", buffer);
    
}

#pragma mark - New SAX Handlers

void IDZSAX2AttributeDecl(void *ctx, const xmlChar *elem, const xmlChar *fullname,
                          int type, int def, const xmlChar *dflt,
                          xmlEnumerationPtr tree) {
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    NSString *elementName = IDZString(elem);
    NSString *attributeName = IDZString(fullname);
    NSString *defaultValue = IDZString(dflt);
    NSString *attributeType = nil;
    /* Possible values are:
     typedef enum {
     XML_ATTRIBUTE_CDATA = 1,
     XML_ATTRIBUTE_ID,
     XML_ATTRIBUTE_IDREF	,
     XML_ATTRIBUTE_IDREFS,
     XML_ATTRIBUTE_ENTITY,
     XML_ATTRIBUTE_ENTITIES,
     XML_ATTRIBUTE_NMTOKEN,
     XML_ATTRIBUTE_NMTOKENS,
     XML_ATTRIBUTE_ENUMERATION,
     XML_ATTRIBUTE_NOTATION
     } xmlAttributeType;
     */
    switch (type) {
        case XML_ATTRIBUTE_CDATA:
            attributeType = @"CDATA";
            break;
        default:
            NSCAssert(NO, @"Unhandled attribute type");
    }
    if([parser.delegate respondsToSelector:@selector(parser:foundAttributeDeclarationWithName:forElement:type:defaultValue:)]) {
        [parser.delegate parser:parser foundAttributeDeclarationWithName:attributeName forElement:elementName type:nil defaultValue:defaultValue];
    }
    
}

/*
 * For each attribute there are 5 entries in the attributes array.
 * [base] name
 * [base+1] prefix
 * [base+2] URI
 * [base+3] value
 * [base+4] valueend.
 * valueend - value give the length of the attribute.
 */
void
IDZSAX2StartElementNs(void *ctx,
                      const xmlChar *localname,
                      const xmlChar *prefix,
                      const xmlChar *URI,
                      int nb_namespaces,
                      const xmlChar **namespaces,
                      int nb_attributes,
                      int nb_defaulted,
                      const xmlChar **attributes)
{
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    NSString *name = IDZString(localname);
    NSMutableDictionary *attributesDict = nil;
    if(nb_attributes != 0) {
        attributesDict = [[NSMutableDictionary alloc] init];
        for(int i = 0; i < nb_attributes*5; i += 5) {
            NSString *attrName = IDZString(attributes[i]);
            NSString *attrPrefix = IDZString(attributes[i+1]);
            //NSString *attrURI = IDZString(attributes[i+2]);
            NSString *attrValue = IDZString2(attributes[i+3], attributes[i+4] - attributes[i+3]);
            NSString *attrKey = (attrPrefix.length > 0) ? [NSString stringWithFormat:@"%@:%@", attrPrefix, attrName] : attrName;
            attributesDict[attrKey] = attrValue;
        }
    }
    if([parser.delegate respondsToSelector:@selector(parser:didStartElement:namespaceURI:qualifiedName:attributes:)]) {
        [parser.delegate parser:parser didStartElement:name
                   namespaceURI:IDZString(URI)
                  qualifiedName:nil attributes:attributesDict];
    }
    
    
}

void IDZSAX2EndElementNs(void *ctx,
                         const xmlChar * localname ATTRIBUTE_UNUSED,
                         const xmlChar * prefix ATTRIBUTE_UNUSED,
                         const xmlChar * URI ATTRIBUTE_UNUSED)
{
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    if([parser.delegate respondsToSelector:@selector(parser:didEndElement:namespaceURI:qualifiedName:)])
    {
        [parser.delegate parser:parser didEndElement:IDZString(localname)
                   namespaceURI:IDZString(URI)
                  qualifiedName:nil];
    }
}
/*
 Possible values for type are     XML_INTERNAL_GENERAL_ENTITY = 1,
 XML_EXTERNAL_GENERAL_PARSED_ENTITY = 2,
 XML_EXTERNAL_GENERAL_UNPARSED_ENTITY = 3,
 XML_INTERNAL_PARAMETER_ENTITY = 4,
 XML_EXTERNAL_PARAMETER_ENTITY = 5,
 XML_INTERNAL_PREDEFINED_ENTITY = 6
 */
void IDZSAX2EntityDecl(void *ctx, const xmlChar *name, int type,
                       const xmlChar *publicId, const xmlChar *systemId, xmlChar *content) {
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    //xmlAddDocEntity(parser.document, name, type, publicId, systemId, content);
    xmlSAX2EntityDecl(parser.context, name, type, publicId, systemId, content);
    switch(type) {
        case XML_INTERNAL_GENERAL_ENTITY:
            if([parser.delegate respondsToSelector:@selector(parser:foundInternalEntityDeclarationWithName:value:)]) {
                [parser.delegate parser:parser foundInternalEntityDeclarationWithName:IDZString(name) value:IDZString(content)];
            }
            break;
        case XML_EXTERNAL_GENERAL_PARSED_ENTITY:
            if([parser.delegate respondsToSelector:@selector(parser:foundExternalEntityDeclarationWithName:publicID:systemID:)]) {
                [parser.delegate parser:parser foundExternalEntityDeclarationWithName:IDZString(name) publicID:IDZString(publicId) systemID:IDZString(systemId)];
            }
            break;
        default:
            NSCAssert(NO, @"Unhandled entity type");
    }

    // HACK: libXML2 seems to swallow the newline after entity
    if([parser.delegate respondsToSelector:@selector(parser:foundIgnorableWhitespace:)])
        [parser.delegate parser:parser foundIgnorableWhitespace:@"\n"];
}

void IDZSAX2StartDocument(void *ctx) {
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    //parser.document = xmlNewDoc(parser.context->version);
    xmlSAX2StartDocument(parser.context);
    
}

void IDZSAX2EndDocument(void *ctx) {
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    xmlSAX2EndDocument(parser.context);
}

void IDZSAX2Characters(void *ctx, const xmlChar *ch, int len) {
    NSString *characters = [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    if((parser.context->depth == 0) && [parser.delegate respondsToSelector:@selector(parser:foundCharacters:)]) {
        [parser.delegate parser:parser foundCharacters:characters];
    }
}

void IDZSAX2Reference(void *ctx, const xmlChar *name) {
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    if([parser.delegate respondsToSelector:@selector(parser:foundReference:)])
    {
        //NSLog(@"%d: Reference: %s", (int)parser.lineNumber, (const char*)name);
        [parser.delegate parser:parser foundReference:IDZString(name)];
    }
}

void IDZSAX2Comment(void *ctx, const xmlChar *value) {
    NSString *comment = [[NSString alloc] initWithCString:(const char *)value encoding:NSUTF8StringEncoding];
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    if([parser.delegate respondsToSelector:@selector(parser:foundComment:)])
        [parser.delegate parser:parser foundComment:comment];
    // HACK: libXML2 seems to swallow the newline after entity
    if([parser.delegate respondsToSelector:@selector(parser:foundIgnorableWhitespace:)])
        [parser.delegate parser:parser foundIgnorableWhitespace:@"\n"];
}

static void IDZSAX2IgnorableWhitespace(void *ctx, const xmlChar *ws, int len) {
    NSString *whitespace = [[NSString alloc] initWithBytes:ws length:len encoding:NSUTF8StringEncoding];
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    if([parser.delegate respondsToSelector:@selector(parser:foundIgnorableWhitespace:)])
        [parser.delegate parser:parser foundIgnorableWhitespace:whitespace];
}

void IDZXMLSAXHandlerInit(xmlSAXHandler *hdlr)
{
    memset(hdlr, 0, sizeof(*hdlr));
    hdlr->startElement = NULL;
    hdlr->endElement = NULL;
    hdlr->startElementNs = IDZSAX2StartElementNs;
    hdlr->endElementNs = IDZSAX2EndElementNs;
    hdlr->serror = NULL;
    hdlr->internalSubset = IDZSAX2InternalSubset;
    hdlr->externalSubset = IDZSAX2ExternalSubset;
    hdlr->isStandalone = IDZSAX2IsStandalone;
    hdlr->hasInternalSubset = IDZSAX2HasInternalSubset;
    hdlr->hasExternalSubset = IDZSAX2HasExternalSubset;
    hdlr->resolveEntity = IDZSAX2ResolveEntity;
    hdlr->getEntity = IDZSAX2GetEntity;
    hdlr->getParameterEntity = IDZSAX2GetParameterEntity;
    hdlr->entityDecl = IDZSAX2EntityDecl;
    hdlr->attributeDecl = IDZSAX2AttributeDecl;
    hdlr->elementDecl = IDZSAX2ElementDecl;
    hdlr->notationDecl = IDZSAX2NotationDecl;
    hdlr->unparsedEntityDecl = IDZSAX2UnparsedEntityDecl;
//    hdlr->setDocumentLocator = IDZSAX2SetDocumentLocator;
    hdlr->startDocument = IDZSAX2StartDocument;
    hdlr->endDocument = IDZSAX2EndDocument;
    hdlr->reference = IDZSAX2Reference;
    hdlr->characters = IDZSAX2Characters;
    hdlr->cdataBlock = IDZSAX2CDataBlock;
    hdlr->ignorableWhitespace = IDZSAX2IgnorableWhitespace;
    hdlr->processingInstruction = IDZSAX2ProcessingInstruction;
    hdlr->comment = IDZSAX2Comment;
    hdlr->warning = IDZParserWarning;
    hdlr->error = IDZParserError;
    hdlr->fatalError = IDZParserError;
    hdlr->initialized = XML_SAX2_MAGIC;
}

#define IDZ_LIBXML2_BUFSIZ (128*1024)


#pragma mark - Initializers

- (instancetype)initWithContentsOfURL:(NSURL *)url {
    // Note: -[NSInputStream initWithURL:] does not handle remote URLs
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    self = [self initWithData:data];
    mContext->input->filename = (char *)xmlCanonicPath((const xmlChar*)url.path.UTF8String);
    return  self;
}

- (instancetype)initWithStream:(NSInputStream *)stream {
    // For compatibility with NSXMLParser we delay this error until parse time
    //    NSParameterAssert(stream);
    if(self = [super init]) {
        mInputStream = stream;
        xmlKeepBlanksDefault(0);
        
        xmlSAXHandler sax;
        IDZXMLSAXHandlerInit(&sax);
        mContext = xmlCreatePushParserCtxt(&sax, (__bridge void*)self, NULL, 0, NULL);
        if(!mContext) {
            return nil;
            
        }
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

#pragma mark - Parsing

- (BOOL)parse {
    if(!self.inputStream)
    {
        self.parserError = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:nil];
        return NO;
    }
    char buffer[IDZ_LIBXML2_BUFSIZ];
    [self.inputStream open];
    if(self.inputStream.streamError)
    {
        NSLog(@"%s:%d: WARNING: Stream error", __FILE__, __LINE__);
    }
    
    // Need this here to avoid calling parserDidStartDocument if input is empty
    NSInteger nBytes = [self.inputStream read:(uint8_t*)buffer maxLength:IDZ_LIBXML2_BUFSIZ];
    if(nBytes == 0)
    {
        self.parserError = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:nil];
        return NO;
    }
    if([self.delegate respondsToSelector:@selector(parserDidStartDocument:)])
    {
        [self.delegate parserDidStartDocument:self];
    }
    int result = XML_ERR_OK;
    
    do {
        @autoreleasepool {
            result = xmlParseChunk(self.context, buffer, (int)nBytes, nBytes == 0);
            if(result != XML_ERR_OK || nBytes == 0)
                break;
            nBytes = [self.inputStream read:(uint8_t*)buffer maxLength:IDZ_LIBXML2_BUFSIZ];
            if(nBytes < 0)
            {
                result = XML_IO_UNKNOWN;
                break;
            }
        }
    } while(1);
    
    [self.inputStream close];
    if([self.delegate respondsToSelector:@selector(parserDidEndDocument:)])
    {
        [self.delegate parserDidEndDocument:self];
    }
    return (result == XML_ERR_OK);
}

#pragma mark - Properties

- (void)setDelegate:(id<IDZXMLParserDelegate>)delegate {
    mDelegate = delegate;
}

- (NSInteger)lineNumber {
    // Although the prototype of this is void* it is expecting
    // an xmlParserCtxPtr
    return xmlSAX2GetLineNumber(self.context);
}

- (void)setShouldResolveExternalEntities:(BOOL)shouldResolveExternalEntities
{
    mShouldResolveExternalEntities = shouldResolveExternalEntities;
    mContext->replaceEntities = shouldResolveExternalEntities ? YES : NO;
}

@end
