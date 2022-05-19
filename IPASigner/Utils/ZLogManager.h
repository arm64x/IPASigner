//
//  ZLogManager.h
//  ABox
//
//  Created by SWING on 2022/5/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ablock)(NSString *);

@interface ZLogManager : NSObject

@property (nonatomic,copy) ablock block;


+ (instancetype)shareManager;

- (void)printLog:(char *)log;

- (void)printZipLog:(NSString *)log;


@end

NS_ASSUME_NONNULL_END
