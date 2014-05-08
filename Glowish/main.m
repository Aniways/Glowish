//
//  main.m
//  Glowish
//
//  Created by Elad Ben-Israel on 4/9/14.
//  Copyright (c) 2014 Aniways. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSImage+Glowish.h"

void recursiveGlowish(NSString *rootPath, NSFileManager *fm)
{
    NSArray *files = [fm contentsOfDirectoryAtPath:rootPath error:nil];
    if (!files) {
        rootPath = [fm currentDirectoryPath];
        files = [fm contentsOfDirectoryAtPath:rootPath error:nil];
    }
    
    
    NSLog(@"Glowing PNGs under %@...", rootPath);
    
    NSInteger count = 0;
    
    for (NSString *fileName in files) {
        NSString* fullPath = [NSString pathWithComponents:@[ rootPath, fileName ]];
        BOOL isDir;
        if([fm fileExistsAtPath:fullPath isDirectory:(&isDir)]){
            if(isDir){
                recursiveGlowish(fullPath, fm);
            }
            else{
                if ([fileName rangeOfString:@"g."].location == 0 ||
                    [fileName rangeOfString:@"."].location == 0 ||
                    [[fileName lowercaseString] rangeOfString:@".png"].length == 0) {
                    continue; // skip
                }
                
                NSData *data = [NSData dataWithContentsOfFile:fullPath];
                NSImage *image = [[NSImage alloc] initWithData:data];
                
                NSImage *glowish = [image glowishImage];
                glowish = [glowish imageResizedTo:image.size];
                
                NSString *targetPath = fullPath;
                
                [glowish writePNGToFile:targetPath outputSizeInPixels:glowish.size error:nil];
                NSLog(@"converting %@", fileName);
                count++;
            }
        }
        
    }
    
    if (count == 0) {
        NSLog(@"No PNG files under %@", rootPath);
    }
    else {
        NSLog(@"%ld files under %@", count, rootPath);
    }
}

int main(int argc, const char *argv[])
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *rootPath = argc == 1
        ? [fm currentDirectoryPath]
        : [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];

    
    recursiveGlowish(rootPath, fm);
    
    //validate sizes
    NSDictionary* directories = @{@"Android/hdpi" : @(120),
                                  @"Android/hdpi" : @(60),
                                  @"Android/mdpi" : @(80),
                                  @"Android/hdpi" : @(60),
                                  @"Android/xhdpi" : @(160),
                                  @"Android/xxhdpi" : @(240),
                                  @"iOS" : @(80)};
    
    for (NSString* directory in [directories allKeys]) {
        NSArray* imagePaths = [fm contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",rootPath, directory] error: nil];
        int maxSize = [[directories objectForKey:directory] intValue];
        for (NSString* imagePath in imagePaths) {
            NSImage* image = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@",rootPath, directory, imagePath]];
            if(image.size.width > maxSize || image.size.height > maxSize){
                NSLog(@"directory %@ image %@ size is wrong - width: %g, height %g",directory, imagePath,image.size.width, image.size.height);
            }
            if(image.size.width < maxSize  && image.size.height < maxSize){
                NSLog(@"directory %@ image %@ size is wrong - width: %g, height %g",directory, imagePath,image.size.width, image.size.height);
            }
        }
        
    }
    return 0;

}
