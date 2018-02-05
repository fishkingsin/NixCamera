//
//  NixCameraViewController.h
//  NixCameraExample
//
//  Created by James Kong on 29/10/14.
//  Copyright (c) 2014 James Kong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NixCamera.h"
#import "CircleButtonView.h"
#import "CameraControllerDelegate.h"
#import "CameraPreviewViewDelegate.h"
@interface NixCameraViewController : UIViewController <CircleButtonViewDelegate, CameraPreviewViewDelegate>
@property (nonatomic, weak) id<CameraControllerDelegate> delegate;
@end
