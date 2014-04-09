//
//  NSImage+Glowish.h
//  Glowish
//
//  Created by Elad Ben-Israel on 4/9/14.
//  Copyright (c) 2014 Aniways. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Glowish)

- (NSImage *)glowishImage;
- (NSImage *)imageResizedTo:(NSSize)newSize;
- (BOOL)writePNGToFile:(NSString *)path outputSizeInPixels:(NSSize)outputSizePx error:(NSError*__autoreleasing*)error;

@end
