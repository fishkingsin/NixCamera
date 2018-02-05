//
//  CameraPreviewViewDelegate.h
//  CircleProgressView
//
//  Created by James Kong on 5/2/2018.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class VideoAsset;
@protocol CameraPreviewViewDelegate <NSObject>
- (void)previewDidCancel:(UIView *)preview;
- (void)preview:(UIView *)preview captureStillImage:(UIImage *)image;
- (void)preview:(UIView *)preview captureVideoAsset:(VideoAsset *)asset;
@end
