//
//  ClassDumpUtils.m
//  ABox
//
//  Created by SWING on 2022/5/30.
//

#import "ClassDumpUtils.h"

#import "CDClassDump.h"
#import "CDFindMethodVisitor.h"
#import "CDClassDumpVisitor.h"
#import "CDMultiFileVisitor.h"
#import "CDFile.h"
#import "CDMachOFile.h"
#import "CDFatFile.h"
#import "CDFatArch.h"
#import "CDSearchPathState.h"


@implementation ClassDumpUtils

+ (int)classDumpWithPath:(NSString *)path withOutput:(NSString *)outputPath {
    NSLog(@"classDumpWithPath:%@\noutputPath: %@",path, outputPath);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
    }
//    [[NSFileManager defaultManager] createDirectoryAtPath:outputPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    CDClassDump *classDump = [[CDClassDump alloc] init];
    NSLog(@"classDump.sdkRoot:%@",classDump.sdkRoot);
    classDump.shouldSortClasses = YES;
    classDump.shouldSortMethods = YES;
    
    CDArch targetArch = CDArchFromName(@"arm64");
    NSLog(@"chosen arch is: (%08x, %08x)", targetArch.cputype, targetArch.cpusubtype);
    classDump.targetArch = targetArch;

    NSString *executablePath = [path executablePathForFilename];
    NSLog(@"executablePath:%@",path);
    classDump.searchPathState.executablePath = [executablePath stringByDeletingLastPathComponent];
    CDFile *file = [CDFile fileWithContentsOfFile:executablePath searchPathState:classDump.searchPathState];
    if (file == nil) {
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        if ([defaultManager fileExistsAtPath:executablePath]) {
            if ([defaultManager isReadableFileAtPath:executablePath]) {
                NSLog(@"class-dump: Input file (%s) is neither a Mach-O file nor a fat archive.\n", [executablePath UTF8String]);
            } else {
                NSLog(@"class-dump: Input file (%s) is not readable (check read permissions).\n", [executablePath UTF8String]);
            }
        } else {
            NSLog(@"class-dump: Input file (%s) does not exist.\n", [executablePath UTF8String]);
        }
        return -1;
    } else {
        NSError *error;
        if (![classDump loadFile:file error:&error]) {
            NSLog(@"Error: %s\n", [[error localizedFailureReason] UTF8String]);
            return -1;
        } else {
            [classDump processObjectiveCData];
            [classDump registerTypes];
            CDMultiFileVisitor *multiFileVisitor = [[CDMultiFileVisitor alloc] init];
            multiFileVisitor.classDump = classDump;
            classDump.typeController.delegate = multiFileVisitor;
            multiFileVisitor.outputPath = outputPath;
            [classDump recursivelyVisit:multiFileVisitor];
            return 0;
        }
    }
}

@end
