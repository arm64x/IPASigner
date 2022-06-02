//
//  ClassDumpUtils.h
//  ABox
//
//  Created by SWING on 2022/5/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ClassDumpUtils : NSObject

+ (int)classDumpWithPath:(NSString *)path withOutput:(NSString *)outputPath;

@end

NS_ASSUME_NONNULL_END
