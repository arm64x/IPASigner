//
//  AppSigner.h
//  ABox
//
//  Created by YZL-SWING on 2021/1/12.
//

#import <Foundation/Foundation.h>
#import <SSZipArchive/SSZipArchive.h>

@class ALTCertificate;
@class ALTProvisioningProfile;
@class ALTApplication;

NS_ASSUME_NONNULL_BEGIN

@interface AppSigner : NSObject

- (void)unzipAppBundleAtURL:(NSURL *)ipaURL
         outputDirectoryURL:(NSURL *)outputDirectoryURL
            progressHandler:(void (^_Nullable)(NSString *entry, unz_file_info zipInfo, long entryNumber, long total))progressHandler
          completionHandler:(void (^)(BOOL success, ALTApplication *_Nullable application, NSError *_Nullable error))completionHandler;


- (void)signAppWithAplication:(ALTApplication *)application
                  certificate:(ALTCertificate *)certificate
          provisioningProfile:(ALTProvisioningProfile *)profile
                   logHandler:(void (^)(NSString *log))logHandler
            completionHandler:(void (^)(BOOL success, NSError *_Nullable error, NSURL *_Nullable url))completionHandler;

@end

NS_ASSUME_NONNULL_END
