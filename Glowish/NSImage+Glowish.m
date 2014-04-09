//
//  NSImage+Glowish.m
//  Glowish
//
//  Created by Elad Ben-Israel on 4/9/14.
//  Copyright (c) 2014 Aniways. All rights reserved.
//

#import "NSImage+Glowish.h"

@implementation NSImage (Glowish)


- (NSImage *)glowishImage
{
    CGFloat thinkness = 2.0f;
    CGRect originalFrame = { CGPointZero, self.size };
    CGRect targetFrame = { CGPointZero, CGSizeMake(self.size.width + thinkness * 4, self.size.height + thinkness * 4) };

    NSImage *mask = [self copy];
    [mask lockFocus];
    [[NSColor whiteColor] set];
    NSRect r = { NSZeroPoint, self.size };
    NSRectFillUsingOperation(r, NSCompositeSourceAtop);
    [mask unlockFocus];
    
    NSImage *target = [[NSImage alloc] initWithSize:targetFrame.size];

    [target lockFocus];
    
    [self drawMask:mask atPoint:CGPointMake(2*thinkness, thinkness)];
    [self drawMask:mask atPoint:CGPointMake(0, thinkness)];
    [self drawMask:mask atPoint:CGPointMake(thinkness, 2*thinkness)];
    [self drawMask:mask atPoint:CGPointMake(thinkness, 0)];
    
    CGRect imageFrame = { CGPointMake(thinkness, thinkness), self.size };
    NSImageRep *imageRep = [self bestRepresentationForRect:imageFrame context:nil hints:nil];
    NSDictionary *hints = @{ NSImageHintInterpolation: @(NSImageInterpolationHigh) };
    [imageRep drawInRect:imageFrame fromRect:originalFrame operation:NSCompositeSourceOver fraction:1.0f respectFlipped:YES hints:hints];
    
    [target unlockFocus];
    
    return target;
}

- (void)drawMask:(NSImage *)mask atPoint:(CGPoint)point
{
    CGRect f = { point, self.size };
    NSDictionary *hints = @{ NSImageHintInterpolation: @(NSImageInterpolationHigh) };
    NSImageRep *rep = [mask bestRepresentationForRect:f context:nil hints:hints];
    CGRect sourceRect = { CGPointZero, mask.size };
    [rep drawInRect:f fromRect:sourceRect operation:NSCompositeSourceOver fraction:1.0f respectFlipped:NO hints:nil];
}

- (NSImage *)imageResizedTo:(NSSize)newSize
{
    NSImage *sourceImage = self;
    
    if (![sourceImage isValid]) {
        NSLog(@"Invalid Image");
        return nil;
    }

    NSImage *resizedImage = [[NSImage alloc] initWithSize:newSize];
    [resizedImage lockFocus];
    sourceImage.size = newSize;
    [NSGraphicsContext currentContext].imageInterpolation = NSImageInterpolationHigh;
    [sourceImage drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, newSize.width, newSize.height) operation:NSCompositeCopy fraction:1.0];
    [resizedImage unlockFocus];
    return resizedImage;
}

- (BOOL)writePNGToFile:(NSString *)path outputSizeInPixels:(NSSize)outputSizePx error:(NSError*__autoreleasing*)error
{
    BOOL result = YES;
    NSImage* scalingImage = [NSImage imageWithSize:[self size] flipped:[self isFlipped] drawingHandler:^BOOL(NSRect dstRect) {
        [self drawAtPoint:NSMakePoint(0.0, 0.0) fromRect:dstRect operation:NSCompositeSourceOver fraction:1.0];
        return YES;
    }];
    NSRect proposedRect = NSMakeRect(0.0, 0.0, outputSizePx.width, outputSizePx.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGContextRef cgContext = CGBitmapContextCreate(NULL, proposedRect.size.width, proposedRect.size.height, 8, 4*proposedRect.size.width, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    NSGraphicsContext* context = [NSGraphicsContext graphicsContextWithGraphicsPort:cgContext flipped:NO];
    CGContextRelease(cgContext);
    CGImageRef cgImage = [scalingImage CGImageForProposedRect:&proposedRect context:context hints:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)(url), kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(destination, cgImage, nil);
    if(!CGImageDestinationFinalize(destination))
    {
        NSDictionary* details = @{NSLocalizedDescriptionKey:@"Error writing PNG image"};
        [details setValue:@"ran out of money" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"SSWPNGAdditionsErrorDomain" code:10 userInfo:details];
        result = NO;
    }
    CFRelease(destination);
    return result;
}

+ (NSData *)imageDataWithoutColorSyncProfile:(NSData *)data
{
    CGImageSourceRef cf_sourceImage = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    CFStringRef cf_type = CGImageSourceGetType(cf_sourceImage);
    size_t count = CGImageSourceGetCount(cf_sourceImage);
    
    NSMutableData *writeData = [[NSMutableData alloc] init];
    
    CFMutableDataRef cf_data = (__bridge CFMutableDataRef)writeData;
    CGImageDestinationRef cf_destination = CGImageDestinationCreateWithData(cf_data, cf_type, count, NULL);
    
    for(size_t i = 0; i<count; ++i) {
        CGImageRef cf_image = CGImageSourceCreateImageAtIndex(cf_sourceImage, i, NULL);
        CFDictionaryRef cf_properties = CGImageSourceCopyPropertiesAtIndex(cf_sourceImage, i, NULL);
        
        NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:cf_image];
        [rep setProperty:NSImageColorSyncProfileData withValue:nil];
        CGImageRef cf_writeImage = [rep CGImage];
        
        CGImageDestinationAddImage(cf_destination, cf_writeImage, cf_properties);
        
        CFRelease(cf_properties);
        CFRelease(cf_image);
    }
    
    CGImageDestinationFinalize(cf_destination);
    
    CFRelease(cf_destination);
    CFRelease(cf_sourceImage);
    
    return writeData;
}

@end


