//
//  UIImage+Crop.m
//  NixCamera
//
//  Created by James Kong on 27/10/14.
//  Copyright (c) 2014 James Kong. All rights reserved.
//

#import "UIImage+Crop.h"

@implementation UIImage(CropCategory)
- (UIImage *)crop:(CGRect)rect {

    rect = CGRectMake(rect.origin.x * self.scale,
                      rect.origin.y * self.scale,
                      rect.size.width * self.scale,
                      rect.size.height * self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}
@end
