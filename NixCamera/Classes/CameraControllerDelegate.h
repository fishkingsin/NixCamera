//
//  CameraControllerDelegate.h
//  NixCamera
//
//  Created by James Kong on 5/2/2018.
//

#import <Foundation/Foundation.h>
@class VideoAsset;

@protocol CameraControllerDelegate <NSObject>
@optional
- (void)cameraViewControllerDidDismissed:(UIViewController *)controller;
@required
- (void)cameraViewControllerDidSelectedAlnbum:(UIViewController *)controller;
- (void)cameraViewController:(UIViewController *)controller captureStillImage:(UIImage *)image;
- (void)cameraViewController:(UIViewController *)controller captureVideoAsset:(VideoAsset *)asset;

@end
