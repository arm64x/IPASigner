// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>
#import "CDExtensions.h"

@interface CDBalanceFormatter : NSObject

- (id)initWithString:(NSString *)str;

- (void)parse:(NSString *)open index:(NSUInteger)openIndex level:(NSUInteger)level;

- (NSString *)format;

@end
