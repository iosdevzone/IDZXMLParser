//
//  IDZXMLParserDump.h
//  IDZXMLParser
//
//  Created by idz on 8/13/15.
//  Copyright (c) 2015 iOS Developer Zone. All rights reserved.
//
#import "IDZXMLParser.h"

@interface IDZXMLParserDump : NSObject<IDZXMLParserDelegate>

- (instancetype)initWithFilePath:(NSString*)filePath;
- (instancetype)initWithFilePointer:(FILE*)file;

@end
