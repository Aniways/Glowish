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
                //NSLog(@"converting %@", fileName);
                count++;
                
                //validate size
                int maxSize = [[[[[[[fileName componentsSeparatedByString:@"_"] lastObject]  componentsSeparatedByString:@".png"] firstObject] componentsSeparatedByString:@"@"] firstObject] intValue];
                
                if([fileName rangeOfString:@"@2x"].location != NSNotFound){
                    maxSize = maxSize * 2;
                }
                
                if(glowish.size.width > maxSize || glowish.size.height > maxSize){
                    NSLog(@"%@ size is wrong - width: %g, height %g",fullPath,glowish.size.width, glowish.size.height);
                }
                if(glowish.size.width < maxSize  && glowish.size.height < maxSize){
                    NSLog(@"%@ size is wrong - width: %g, height %g",fullPath,glowish.size.width, glowish.size.height);
                }
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
    
    return 0;

}
