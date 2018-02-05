//
//  CameraPreviewView.h
//  CircleProgressView
//
//  Created by James Kong on 5/2/2018.
//

#import <UIKit/UIKit.h>
#import "CameraPreviewViewDelegate.h"
@interface CameraPreviewView : UIView
@property (nonatomic, weak) id<CameraPreviewViewDelegate> delegate;
@end
@interface VideoAsset : NSObject
@property (nonatomic, readonly) NSURL *videoURL;
@property (nonatomic, readonly) UIImage *preview;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) AVAsset *asset;
- (instancetype)initWithData:(NSURL *)videoURL preview:(UIImage *)image duration:(NSTimeInterval)interval asset:(AVAsset *)playerItemAsset;
@end

