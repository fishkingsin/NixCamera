//
//  NixViewController.m
//  NixCamera
//
//  Created by fishkingsin@gmail.com on 02/02/2018.
//  Copyright (c) 2018 fishkingsin@gmail.com. All rights reserved.
//

#import "NixViewController.h"
#import <NixCamera/NixCameraViewController.h>
@interface NixViewController ()<CameraControllerDelegate>

@end

@implementation NixViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NixCameraViewController *cameraViewController = [NixCameraViewController new];
    cameraViewController.delegate = self;
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
    
    [self presentViewController:navVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- CameraControllerDelegate

- (void)cameraViewControllerDidDismissed:(UIViewController *)controller {
    
}

- (void)cameraViewControllerDidSelectedAlnbum:(UIViewController *)controller {
    
}

- (void)cameraViewController:(UIViewController *)controller captureStillImage:(UIImage *)image {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraViewController:(UIViewController *)controller captureVideoAsset:(VideoAsset *)asset {
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end
