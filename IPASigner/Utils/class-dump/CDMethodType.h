// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>
#import "CDExtensions.h"

@class CDType;

@interface CDMethodType : NSObject

- (id)initWithType:(CDType *)type offset:(NSString *)offset;

@property (readonly) CDType *type;
@property (readonly) NSString *offset;

@end
