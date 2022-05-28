//
//  AppSigner.h
//  ABox
//
//  Created by YZL-SWING on 2021/1/12.
//

#import <Foundation/Foundation.h>

@class ALTCertificate;
@class ALTProvisioningProfile;
@class ALTApplication;

NS_ASSUME_NONNULL_BEGIN

@interface AppSigner : NSObject

- (void)signAppWithAplication:(ALTApplication *)application
                  certificate:(ALTCertificate *)certificate
          provisioningProfile:(ALTProvisioningProfile *)profile
                   logHandler:(void (^)(NSString *log))logHandler
            completionHandler:(void (^)(BOOL success, NSError *_Nullable error, NSURL *_Nullable url))completionHandler;

- (int)printMachOInfoWithFileURL:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
