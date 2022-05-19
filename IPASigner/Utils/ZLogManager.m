//
//  ZLogManager.m
//  ABox
//
//  Created by SWING on 2022/5/12.
//

#import "ZLogManager.h"

@interface ZLogManager()

@end

static ZLogManager *manager = nil;
@implementation ZLogManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}

- (void)printLog:(char *)log {
    NSString *logString = [NSString stringWithUTF8String:log];
    NSLog(@"ZLogManager printLog: %@",logString);
    if (self.block) {
        self.block(logString);
    }
}

- (void)printZipLog:(NSString *)log {
    NSString *logString = [NSString stringWithFormat:@">>> %@",log];
    NSLog(@"ZLogManager printZipLog: %@",logString);
    if (self.block) {
        self.block(logString);
    }
}

@end
