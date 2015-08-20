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
//#import "SwiftJPDict-Swift.h"

@interface IDZXMLParserLibXML2 ()

@property (nonatomic, readonly) xmlParserCtxtPtr context;
@property (nonatomic, assign) xmlDocPtr document;
@property (nonatomic, readonly) FILE*      file;
@end

@implementation IDZXMLParserLibXML2
@synthesize file = mFile;
@synthesize context = mContext;
@synthesize delegate = mDelegate;
@synthesize document = mDocument;
@synthesize shouldResolveExternalEntities = mShouldResolveExternalEntities;


/*
 XMLPUBFUN xmlParserCtxtPtr XMLCALL
 xmlCreatePushParserCtxt(xmlSAXHandlerPtr sax,
 void *user_data,
 const char *chunk,
 int size,
 const char *filename);
 XMLPUBFUN int XMLCALL
 xmlParseChunk		(xmlParserCtxtPtr ctxt,
 const char *chunk,
 int size,
 int terminate);
 */

#define IDZ_BUFSIZ (16*1024)

//typedef struct IDZXMlParserContextTag {
//    void *delegate;
//    xmlDocPtr document;
//    xmlParserCtxtPtr context;
//} IDZXMLParserContext;

//xmlEntitiesTablePtr pEntities = NULL;
//
//static void
//print_element_names(xmlNode * a_node)
//{
//    xmlNode *cur_node = NULL;
//    
//    for (cur_node = a_node; cur_node; cur_node = cur_node->next) {
//        if (cur_node->type == XML_ELEMENT_NODE) {
//            if(strcmp((const char *)cur_node->name, "pos") == 0) {
//                if(cur_node->children) {
//                    printf("node type: Element, name: %s content: %s child_type:%d child_name:%s child_context:%s\n",
//                           cur_node->name,
//                           cur_node->content,
//                           cur_node->children->type,
//                           cur_node->children->name,
//                           cur_node->children->content);
//                }
//                else {
//                    printf("node type: Element, name: %s content: %s\n",
//                           cur_node->name,
//                           cur_node->content);
//                }
//            }
//        }
//        
//        print_element_names(cur_node->children);
//    }
//}
//
//void startDocument(void *ctxt) {
//    NSLog(@"startDocument");
//    
//}
//
//void endDocument(void *ctxt) {
//    NSLog(@"endDocument");
//}
//void startElement(void *ctx, const xmlChar *fullname, const xmlChar **atts) {
//    NSLog(@"startElement");
//    
//}
//
//void endElement(void *ctx, const xmlChar *name) {
//    NSLog(@"endElement");
//    
//}
//
//void entityDecl(void *ctx, const xmlChar *name, int type, const xmlChar *publicId, const xmlChar *systemId, xmlChar *content)
//{
//    NSLog(@"entityDecl %s %d %s %s %s",
//          name, type, publicId, systemId, content);
//    if(!pEntities) {
//        pEntities = xmlCreateEntitiesTable();
//    }
//    IDZXMLParserContext *pContext = (IDZXMLParserContext *)ctx;
//    xmlParserCtxt *pCtxt = pContext->context;
//    xmlAddDocEntity(pContext->document, name, type, publicId, systemId, content);
//    
//    
//    
//}
//
//xmlEntityPtr getEntity(void *ctx,
//                       const xmlChar *name) {
//    IDZXMLParserContext *pContext = (IDZXMLParserContext *)ctx;
//    xmlParserCtxt *pCtxt = pContext->context;
//    return xmlGetDocEntity(pContext->document, name);
//    
//}
//
//
//
//
//
//void error (void *ctx,
//            const char *msg, ...) {
//    char buffer[1024];
//    va_list args;
//    va_start(args, msg);
//    vsprintf(buffer, msg, args);
//    va_end(args);
//    NSLog(@"ERROR: %s", buffer);
//}

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
    return 0;
}

int IDZSAX2HasInternalSubset(void *ctx) {
    return 0;
}

/* 
 * The SAX2 implementation of this in libxml2 creates a nested 
 * parser and calls it to parse the external file.
 */
int IDZSAX2HasExternalSubset(void *ctx) {
    return 0;
}

void IDZSAX2InternalSubset(void *ctx, const xmlChar *name,
                      const xmlChar *ExternalID, const xmlChar *SystemID) {
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    xmlCreateIntSubset(parser.document, name, ExternalID, SystemID);
    
}

void IDZSAX2ExternalSubset(void *ctx, const xmlChar *name,
                           const xmlChar *ExternalID, const xmlChar *SystemID)
{
//    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    NSLog(@"IDZSAX2ExternalSubset %s external=%s system=%s",
          name, ExternalID, SystemID);
}

xmlParserInputPtr IDZSAX2ResolveEntity(void *ctx, const xmlChar *publicId, const xmlChar *systemId) {
    return NULL;
}

xmlEntityPtr IDZSAX2GetEntity(void *ctx, const xmlChar *name) {
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    xmlEntityPtr pEntity = xmlGetDocEntity(parser.document, name);
    return pEntity ? pEntity : xmlGetPredefinedEntity(name);
}

xmlEntityPtr IDZSAX2GetParameterEntity(void *ctx, const xmlChar *name) {
    return NULL;
}





void IDZSAX2ElementDecl(void *ctx, const xmlChar * name, int type,
                   xmlElementContentPtr content) {
    
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
    xmlAddDocEntity(parser.document, name, type, publicId, systemId, content);
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
    parser.document = xmlNewDoc(parser.context->version);
    
}

void IDZSAX2EndDocument(void *ctx) {
    
}

void IDZSAX2Characters(void *ctx, const xmlChar *ch, int len) {
    NSString *characters = [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
    IDZXMLParserLibXML2 *parser = IDZXMLParserLibXML2GetParser(ctx);
    /*
     * If the delegate has defined a foundReference method then we want to suppress 
     * enitity expansion and call this. 
     * I could not find a way to suppress entity expansion in libxml2. It seems like
     * it always performs it (i.e. it recursivelu calls charaters then reference).
     *
     * When it is performing entity expansion the depth of the context always (seems) to 
     * be greater than 0. This leads to the slightly ugly code below.
     */
    if([parser.delegate respondsToSelector:@selector(parser:foundCharacters:)] &&
       (parser.context->depth == 0 || ![parser.delegate respondsToSelector:@selector(parser:foundReference:)])) {
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


- (instancetype)initWithContentsOfURL:(NSURL *)url {
    if(self = [super init]) {
        mFile = fopen(url.fileSystemRepresentation, "r");
        if(!mFile) {
            return nil;
        }
        
//        xmlSubstituteEntitiesDefault(1);
        xmlKeepBlanksDefault(0);
        
        xmlSAXHandler sax;
        IDZXMLSAXHandlerInit(&sax);
        
        NSString *fileName = url.path.lastPathComponent;
        mContext = xmlCreatePushParserCtxt(&sax, (__bridge void*)self, NULL, 0, fileName.UTF8String);
        if(!mContext) {
            return nil;
        }
        
        
        
        
    }
    return  self;
}

- (void)setDelegate:(id<IDZXMLParserDelegate>)delegate {
    mDelegate = delegate;
}

- (BOOL)parse {
    char buffer[IDZ_LIBXML2_BUFSIZ];
    while(1) {
        @autoreleasepool {
            size_t nBytes = (int)fread(buffer, 1, IDZ_LIBXML2_BUFSIZ,  self.file);
            // Return is one of http://www.xmlsoft.org/html/libxml-xmlerror.html#xmlParserErrors
            int result = xmlParseChunk(self.context, buffer, (int)nBytes, nBytes == 0);
            if(result != XML_ERR_OK)
            {
                NSLog(@"Parse error (Code: %d)", result);
                return NO;
            }
            if(nBytes == 0) {
                NSLog(@"Parsing complete normally");
                break;
            }
        }
    }
    return YES;
}

- (NSInteger)lineNumber {
    // Although the prototype of this is void* it is expecting
    // an xmlParserCtxPtr
    return xmlSAX2GetLineNumber(self.context);
}

@end
