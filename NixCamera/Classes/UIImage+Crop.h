//
//  UIImage+Crop.h
//  NixCamera
//
//  Created by James Kong on 27/10/14.
//  Copyright (c) 2014 James Kong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(CropCategory)
- (UIImage *)crop:(CGRect)rect;
@end
