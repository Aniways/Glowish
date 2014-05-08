//
//  main.m
//  Glowish
//
//  Created by Elad Ben-Israel on 4/9/14.
//  Copyright (c) 2014 Aniways. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSImage+Glowish.h"

int main(int argc, const char *argv[])
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *rootPath = argc == 1
        ? [fm currentDirectoryPath]
        : [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];

    NSArray *files = [fm contentsOfDirectoryAtPath:rootPath error:nil];
    if (!files) {
        rootPath = [fm currentDirectoryPath];
        files = [fm contentsOfDirectoryAtPath:rootPath error:nil];
    }

    NSLog(@"Glowing PNGs under %@...", rootPath);

    NSInteger count = 0;
    
    for (NSString *fileName in files) {

        if ([fileName rangeOfString:@"g."].location == 0 ||
            [fileName rangeOfString:@"."].location == 0 ||
            [[fileName lowercaseString] rangeOfString:@".png"].length == 0) {
            continue; // skip
        }
        
        NSString *filePath = [NSString pathWithComponents:@[ rootPath, fileName ]];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSImage *image = [[NSImage alloc] initWithData:data];
  
        NSImage *glowish = [image glowishImage];
        glowish = [glowish imageResizedTo:image.size];
        
        NSString *targetPath = filePath;

        [glowish writePNGToFile:targetPath outputSizeInPixels:glowish.size error:nil];
        NSLog(@"converting %@", fileName);
        count++;
    }
    
    if (count == 0) {
        NSLog(@"No PNG files under %@", rootPath);
    }
    else {
        NSLog(@"%ld files under %@", count, rootPath);
    }
}
