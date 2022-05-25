//
//  patcher.m
//  iPAPatcher
//
//  Created by Brandon Plank on 10/27/20.
//

#import "patcher.h"

static NSString *const NameKey = @"CFBundleName";


void Msg(NSString *message, BOOL error){
//    NSAlert *alert = [[NSAlert alloc] init];
//    if(error){
//        [alert setMessageText:@"Error"];
//        [alert setInformativeText:message];
//        [alert addButtonWithTitle:@"Ok"];
//        [alert runModal];
//    } else {
//        [alert setMessageText:@"Notice"];
//        [alert setInformativeText:message];
//        [alert addButtonWithTitle:@"Ok"];
//        [alert runModal];
//    }
}

BOOL folderExists(NSString *folder){
    BOOL isDirectory;
    [[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:&isDirectory];
    return isDirectory;
}

int cp(NSString *file, NSString *to){
    NSTask *cp_task = [[NSTask alloc] init];
    cp_task.launchPath = CP_PATH;
    cp_task.arguments = @[@"-r", file, to];
    [cp_task launch];
    [cp_task waitUntilExit];
    return IPAPATCHER_SUCCESS;
}

int patch_binary(NSString *app_binary, NSString* dylib_path){
    NSData *originalData = [NSData dataWithContentsOfFile:app_binary];
    NSMutableData *binary = originalData.mutableCopy;
    if (!binary)
        return IPAPATCHER_FAILURE;
    struct thin_header headers[4];
    uint32_t numHeaders = 0;
    headersFromBinary(headers, binary, &numHeaders);

    if (numHeaders == 0) {
        if(DEBUG == DEBUG_ON){
            LOG("No compatible architecture found");
        }
        return IPAPATCHER_FAILURE;
    }
    
    for (uint32_t i = 0; i < numHeaders; i++) {
        struct thin_header macho = headers[i];

        NSString *lc = @"load";
        uint32_t command = LC_LOAD_DYLIB;
        if (lc)
            command = COMMAND(lc);
        if (command == -1) {
            if(DEBUG == DEBUG_ON){
                LOG("Invalid load command.");
            }
            return IPAPATCHER_FAILURE;
        }

        if (insertLoadEntryIntoBinary(dylib_path, binary, macho, command)) {
            if(DEBUG == DEBUG_ON){
                LOG("Successfully inserted a %s command for %s", LC(command), CPU(macho.header.cputype));
            }
        } else {
            if(DEBUG == DEBUG_ON){
                LOG("Failed to insert a %s command for %s", LC(command), CPU(macho.header.cputype));
            }
            return IPAPATCHER_FAILURE;
        }
    }
    if(DEBUG == DEBUG_ON){
        LOG("Writing executable to %s...", app_binary.UTF8String);
    }
    if (![binary writeToFile:app_binary atomically:NO]) {
        if(DEBUG == DEBUG_ON){
            LOG("Failed to write data. Permissions?");
        }
        return IPAPATCHER_FAILURE;
    }
    return IPAPATCHER_SUCCESS;
}

int patch_ipa(NSString *app_path, NSString *temp_path, NSMutableArray *dylib_or_deb, BOOL isDeb){
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
        
    NSDictionary *resultDictionary = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Info.plist", app_path]];
    if(DEBUG == DEBUG_ON){
        NSLog(@"Loaded .plist file at Documents Directory is: %@", [resultDictionary description]);
    }
    
    NSString *app_binary = @"";
    
    if (resultDictionary) {
        app_binary = [resultDictionary objectForKey:NameKey];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            Msg(@"Failed to plist data.", true);
        });
        return IPAPATCHER_FAILURE;
    }
    
    if(DEBUG == DEBUG_ON){
        NSLog(@"App name: %@", app_binary);
    }
    
    app_binary = [NSString stringWithFormat:@"%@/%@", app_path, app_binary];
    if(DEBUG == DEBUG_ON) {
        NSLog(@"Full app path: %@", app_binary);
    }
    
    NSArray *DylibPathFinder;
    
    if(isDeb){
        if(!fileExists([BREW_PATH UTF8String])){
            NSTask *command = [[NSTask alloc] init];
            command.launchPath = BASH_PATH;
            command.arguments = @[@"-c", @"\"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)\""];
            [command launch];
            [command waitUntilExit];
        }
        
        if(!fileExists([DPKG_PATH UTF8String])){
            NSTask *command = [[NSTask alloc] init];
            command.launchPath = BREW_PATH;
            command.arguments = @[@"install", @"dpkg"];
            [command launch];
            [command waitUntilExit];
        }
        
        if(DEBUG == DEBUG_ON){
            NSLog(@"deb path: %@", dylib_or_deb[0]);
        }
        
        NSString *deb_insatll_temp = [NSString stringWithFormat:@"%@/deb", temp_path];
        
        // Create task
        STPrivilegedTask *privilegedTask = [STPrivilegedTask new];
        [privilegedTask setLaunchPath:DPKG_PATH];
        [privilegedTask setArguments:@[@"-x", @([[[NSString stringWithFormat:@"%@", dylib_or_deb[0]] stringByReplacingOccurrencesOfString:@"\n" withString:@""] UTF8String]), @([deb_insatll_temp UTF8String])]];

        // Launch it, user is prompted for password
        OSStatus err = [privilegedTask launch];
        if (err == errAuthorizationSuccess) {
            if(DEBUG == DEBUG_ON){
                NSLog(@"Task successfully launched");
            }
        } else if (err == errAuthorizationCanceled) {
            if(DEBUG == DEBUG_ON){
                NSLog(@"User cancelled");
            }
            return IPAPATCHER_FAILURE;
        } else {
            if(DEBUG == DEBUG_ON){
                NSLog(@"Something went wrong");
            }
            return IPAPATCHER_FAILURE;
        }
        [privilegedTask waitUntilExit];
        
        /*
         NSTask *command = [[NSTask alloc] init];
         command.launchPath = DPKG_PATH;
         command.arguments = @[@"-x", @([[[NSString stringWithFormat:@"%@", dylib_or_deb[0]] stringByReplacingOccurrencesOfString:@"\n" withString:@""] UTF8String]), @([deb_insatll_temp UTF8String])];
         [command launch];
         [command waitUntilExit];
         */
        
        NSString *debcheck = [NSString stringWithFormat:@"%@/deb/Library/MobileSubstrate/DynamicLibraries", temp_path];
        if(!folderExists(debcheck)){
            dispatch_async(dispatch_get_main_queue(), ^{
                Msg(@"The tweak you entered is not in the correct format.", true);
            });
            return IPAPATCHER_FAILURE;
        }
        NSString *deb_dylibs = [NSString stringWithFormat:@"%@/deb/Library/MobileSubstrate/DynamicLibraries/", temp_path];
        NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:deb_dylibs
                                                                            error:NULL];
        NSMutableArray *debFiles = [[NSMutableArray alloc] init];
        [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *filename = (NSString *)obj;
            NSString *extension = [[filename pathExtension] lowercaseString];
            if ([extension isEqualToString:@"dylib"]) {
                [debFiles addObject:[deb_dylibs stringByAppendingPathComponent:filename]];
            }
        }];
        if(DEBUG == DEBUG_ON){
            NSLog(@".dylib: %@", debFiles);
        }
        DylibPathFinder = [debFiles copy];
        
        for(int i=0;i<DylibPathFinder.count;i++){
            printf("%s\n", [DylibPathFinder[i] UTF8String]);
            NSArray *seperated = [DylibPathFinder[i] componentsSeparatedByString:@"/"];
            dylib_or_deb[i] = [NSString stringWithFormat:@"%@/deb/Library/MobileSubstrate/DynamicLibraries/%@", temp_path, seperated.lastObject];
        }
    }

    NSString *DylibFolder = [NSString stringWithFormat:@"%@/Dylibs", app_path];
    NSString *FrameworkFolder = [NSString stringWithFormat:@"%@/Frameworks", app_path];
    
    // Create Dylibs and Frameworks dir
    ASSERT([fileManager createDirectoryAtPath:DylibFolder withIntermediateDirectories:true attributes:nil error:&error], @"Failed to create Dylibs directory for our application.", true);
    ASSERT([fileManager createDirectoryAtPath:FrameworkFolder withIntermediateDirectories:true attributes:nil error:&error], @"Failed to create Frameworks directory for our application.", true);
    // Move files into their places
    NSString *subpath1 = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"Cydia.bundle/libsubstitute.0" ofType:@"dylib"]];
    NSString *subpath2 = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"Cydia.bundle/libsubstitute" ofType:@"dylib"]];
    NSString *substrate = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"Cydia.bundle/CydiaSubstrate" ofType:@"framework"]];
    if(DEBUG == DEBUG_ON){
        printf("START====\n%s\n%s\n%s\n", [subpath1 UTF8String], [subpath2 UTF8String], [substrate UTF8String]);
    }
    //TODO: use [manager copyItemAtPath:ipa_path toPath:selected_path error:nil]; I tried it, and it just failed to copy every time.
    ASSERT(cp(subpath1, DylibFolder), @"Failed to copy over libsubstitute.0", true);
    ASSERT(cp(subpath2, DylibFolder), @"Failed to copy over libsubstitute", true);
    ASSERT(cp(substrate, FrameworkFolder), @"Failed to copy over CydiaSubstrate", true);
    
    for(int i=0;i<dylib_or_deb.count;i++){
        //TODO: use [manager copyItemAtPath:ipa_path toPath:selected_path error:nil]; I tried it, and it just failed to copy every time.
        NSString *msg = [NSString stringWithFormat:@"Failed to copy %@", dylib_or_deb[i]];
        ASSERT(cp(dylib_or_deb[i], DylibFolder), msg, true);
    }
    
    // Patch the binary to load given frameworks/dylibs
    ASSERT(patch_binary(app_binary, @"@executable_path/Dylibs/libsubstitute.dylib"), @"Failed to apply the libsubstitute patch!", true);
    ASSERT(patch_binary(app_binary, @"@executable_path/Dylibs/libsubstitute.0.dylib"), @"Failed to apply the libsubstitute.0 patch!", true);
    ASSERT(patch_binary(app_binary, @"@executable_path/Frameworks/CydiaSubstrate.framework/CydiaSubstrate"), @"Failed to apply the CydiaSubstrate patch!", true);
    
    for(int i=0;i<dylib_or_deb.count;i++){
        NSArray *dylibNameArray = [dylib_or_deb[i] componentsSeparatedByString:@"/"];
        if(DEBUG == DEBUG_ON){
            NSLog(@"array:%@", dylibNameArray);
        }
        NSString *dylibName = [NSString stringWithFormat:@"%@",dylibNameArray.lastObject];
        
        NSTask *command = [[NSTask alloc] init];
        command.launchPath = INSTALL_NAME_TOOL_PATH;
        command.arguments = @[@"-change", @"/usr/lib/libsubstrate.dylib", @"@executable_path/Frameworks/CydiaSubstrate.framework/CydiaSubstrate", @([[NSString stringWithFormat:@"%@/%@", DylibFolder, dylibName] UTF8String])];
        [command launch];
        [command waitUntilExit];
        command = [[NSTask alloc] init];
        command.launchPath = INSTALL_NAME_TOOL_PATH;
        command.arguments = @[@"-change", @"/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate", @"@executable_path/Frameworks/CydiaSubstrate.framework/CydiaSubstrate", @([[NSString stringWithFormat:@"%@/%@", DylibFolder, dylibName] UTF8String])];
        [command launch];
        [command waitUntilExit];
        NSString *load_path = [NSString stringWithFormat:@"@executable_path/Dylibs/%@", dylibName];
        NSString *msg = [NSString stringWithFormat:@"Failed to apply the %@ patch!", dylibName];
        ASSERT(patch_binary(app_binary, load_path), msg, true);
    }
    
    printf("[*] Done\n");
    return IPAPATCHER_SUCCESS;
}
