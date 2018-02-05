//
//  NixCameraViewController.m
//  NixCameraExample
//
//  Created by James Kong on 29/10/14.
//  Copyright (c) 2014 James Kong. All rights reserved.
//

#import "NixCameraViewController.h"
#import "ViewUtils.h"
#import "ImageViewController.h"
#import "VideoViewController.h"
#import <CircleProgressView/CircleProgressView-Swift.h>
#import "UIImage+Resources.h"
#import "CameraPreviewViewDelegate.h"
#import "CameraControllerDelegate.h"
#import "CameraPreviewViewProtocol.h"
#import "CameraPreviewView.h"
#import <Masonry/Masonry.h>
#define BUNDLE [NSBundle bundleForClass:[self class]]
@interface NixCameraViewController ()
@property (strong, nonatomic) NixCamera *camera;
@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) UILabel *hintsLabel;
@property (strong, nonatomic) CircleButtonView *snapButton;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) CameraPreviewView<CameraPreviewViewProtocol> *previewView;
@end

@implementation NixCameraViewController{
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // ----- initialize camera -------- //
    
    // create camera vc
    self.camera = [[NixCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
                                            position:NixCameraPositionRear
                                        videoEnabled:YES];
    self.camera.maximumVideoDuration = self.videoInterval;
    // attach to a view controller
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    self.camera.useDeviceOrientation = YES;
    // read: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
    // you probably will want to set this to YES, if you are going view the image outside iOS.
    self.camera.fixOrientationAfterCapture = YES;
    
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    [self.camera setOnDeviceChange:^(NixCamera *camera, AVCaptureDevice * device) {
        
        NSLog(@"Device changed.");
        
        // device changed, check if flash is available
        if([camera isFlashAvailable]) {
            weakSelf.flashButton.hidden = NO;
            
            if(camera.flash == NixCameraFlashOff) {
                weakSelf.flashButton.selected = NO;
            }
            else {
                weakSelf.flashButton.selected = YES;
            }
        }
        else {
            weakSelf.flashButton.hidden = YES;
        }
    }];
    
    [self.camera setOnError:^(NixCamera *camera, NSError *error) {
        NSLog(@"Camera error: %@", error);
        
        if([error.domain isEqualToString:NixCameraErrorDomain]) {
            if(error.code == NixCameraErrorCodeCameraPermission ||
               error.code == NixCameraErrorCodeMicrophonePermission) {
                
                if(weakSelf.errorLabel) {
                    [weakSelf.errorLabel removeFromSuperview];
                }
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.text = @"We need permission for the camera.\nPlease go to your settings.";
                label.numberOfLines = 2;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
                label.textColor = [UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                [label sizeToFit];
                label.center = CGPointMake(screenRect.size.width / 2.0f, screenRect.size.height / 2.0f);
                weakSelf.errorLabel = label;
                [weakSelf.view addSubview:weakSelf.errorLabel];
            }
        }
    }];
    [self.camera setOnRecordingTime:^(double recordedTime, double maxTime) {
        
    }];
    
    
    // ----- camera buttons -------- //
    
    [self.view addSubview:self.snapButton];
    
    // button to toggle flash
    
    [self.view addSubview:self.flashButton];
    
    if([NixCamera isFrontCameraAvailable] && [NixCamera isRearCameraAvailable]) {
        // button to toggle camera positions
        self.switchButton = [[UIButton alloc] initWithFrame:CGRectZero];
        self.switchButton.frame = CGRectMake(0, 0, 29.0f + 20.0f, 22.0f + 20.0f);
        //self.switchButton.tintColor = [UIColor whiteColor];
        [self.switchButton setImage:[UIImage imageForResourcePath:@"NixCamera.bundle/camera-switch" ofType:@"png" inBundle:BUNDLE] forState:UIControlStateNormal];
        self.switchButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        [self.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.switchButton];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = @"Hold for video (15 seconds max.), tap for photo";
    label.numberOfLines = 2;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    label.layer.cornerRadius = 10.0f;
    label.font = [UIFont systemFontOfSize:13.0f];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.center = CGPointMake(screenRect.size.width / 2.0f, screenRect.size.height / 2.0f);
    label.bottom = self.view.height - 15.0f;
    self.hintsLabel = label;
    [self.view addSubview:self.hintsLabel];
    
    [self.view addSubview:self.cancelButton];
    self.cancelButton.frame = CGRectMake(0, 0, 44, 44);
    [self onOrientationChange];
    
//    [self.snapButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view.mas_centerX);
//        make.bottom.equalTo(self.view.mas_bottom).with.offset(-50);
//    }];
//
//    [self.flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view.mas_left).with.offset(15);
//        make.centerY.equalTo(self.snapButton.mas_centerY).with.offset(-15);
//    }];
//
//    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.view.mas_right).with.offset(-15);
//        make.centerY.equalTo(self.snapButton.mas_centerY).with.offset(-15);
//    }];

    
    
    [self.view addSubview:self.previewView];
    [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(self.view.mas_height);
    }];
    //    self.snapButton.autoresizingMask = ( UIViewAutoresizingFlexibleTopMargin);
    //    self.flashButton.autoresizingMask = ( UIViewAutoresizingFlexibleTopMargin);
    //    self.switchButton.autoresizingMask = ( UIViewAutoresizingFlexibleTopMargin);
    
}

-(void) dealloc{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
 
}

/* other lifecycle methods */

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.camera.view.frame = self.view.contentBounds;
    
    self.hintsLabel.center = CGPointMake(self.view.size.width / 2.0f, self.view.size.height / 2.0f);
    self.hintsLabel.bottom = self.view.height - 15.0f;
    [self.previewView setNeedsLayout];
    
    self.snapButton.center = self.view.contentCenter;
    self.snapButton.bottom = self.view.bottom - 50.0f;
    
    self.flashButton.left = 5.0f;
    self.flashButton.y = self.snapButton.y - 15.0f;
    self.switchButton.y = self.snapButton.y - 15.0f;
    self.switchButton.right = self.view.width - 5.0f;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    
    // start the camera
    [self.camera start];
}

- (void)deviceDidRotate:(NSNotification *)notification
{
    UIDeviceOrientation currentDeviceOrientation = [[UIDevice currentDevice] orientation];
    if (currentDeviceOrientation==UIInterfaceOrientationPortrait) {

    } else if (currentDeviceOrientation==UIInterfaceOrientationLandscapeLeft) {

    } else if (currentDeviceOrientation==UIInterfaceOrientationLandscapeRight) {

    }

}

-(void) onOrientationChange {
//    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    
//    if(currentOrientation == UIDeviceOrientationPortrait || currentOrientation == UIDeviceOrientationFaceUp){
//        self.snapButton.center = self.view.contentCenter;
//        self.snapButton.bottom = self.view.bottom - 50.0f;
//        self.flashButton.left = 5.0f;
//        self.flashButton.y = self.snapButton.y - 15.0f;
//        self.switchButton.y = self.snapButton.y - 15.0f;
//        self.switchButton.right = self.view.width - 5.0f;
//
//    }else if(currentOrientation == UIDeviceOrientationLandscapeLeft){
//
//        self.snapButton.center = self.view.contentCenter;
//        self.snapButton.right = self.view.right - 50.0f;
//
//        self.flashButton.x = self.snapButton.x - 5.0f;
//        self.flashButton.bottom = self.view.bottom - 15.0f;
//
//        self.switchButton.top = self.view.top + 15.0f;
//        self.switchButton.x = self.snapButton.x - 5.0f;
//
//    }else if(currentOrientation == UIDeviceOrientationLandscapeRight){
//
//        self.snapButton.center = self.view.contentCenter;
//
//        self.snapButton.left = self.view.left + 50.0f;
//
//        self.flashButton.x = self.snapButton.x - 5.0f;
//        self.flashButton.top = self.view.top + 15.0f;
//
//        self.switchButton.bottom = self.view.bottom - 15.0f;
//        self.switchButton.x = self.snapButton.x - 5.0f;
//
//    }
}

/* camera button methods */

- (void)switchButtonPressed:(UIButton *)button
{
    [self.camera togglePosition];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (void)cancelButtonPressed:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(cameraViewControllerDidDismissed:)]) {
        [_delegate cameraViewControllerDidDismissed:self];
    }
}
- (void)flashButtonPressed:(UIButton *)button
{
    if(self.camera.flash == NixCameraFlashOff) {
        BOOL done = [self.camera updateFlashMode:NixCameraFlashOn];
        if(done) {
            self.flashButton.selected = YES;
            self.flashButton.tintColor = [UIColor yellowColor];
        }
    }
    else {
        BOOL done = [self.camera updateFlashMode:NixCameraFlashOff];
        if(done) {
            self.flashButton.selected = NO;
            self.flashButton.tintColor = [UIColor whiteColor];
        }
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait ;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait ;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait) ;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (CircleButtonView *)snapButton {
    if(_snapButton != nil) return _snapButton;
    CircleButtonView *view = [[CircleButtonView alloc] initWithFrame:CGRectMake(0, 0, 65, 65)];
    view.center = CGPointMake(self.view.center.x, UIScreen.mainScreen.bounds.size.height - 26 - self.view.frame.size.height * 0.5);
    view.delegate = self;
    view.videoInterval =  self.camera.maximumVideoDuration;
    _snapButton = view;
    return _snapButton;
}

-(UIButton*) flashButton {
    if(_flashButton != nil) return _flashButton;
    _flashButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _flashButton.frame = CGRectMake(0, 0, 16.0f + 20.0f, 24.0f + 20.0f);
    _flashButton.tintColor = [UIColor whiteColor];
    [_flashButton setImage:[UIImage imageForResourcePath:@"NixCamera.bundle/camera-flash" ofType:@"png" inBundle:BUNDLE] forState:UIControlStateNormal];
    _flashButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [_flashButton addTarget:self action:@selector(flashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return _flashButton;
}

- (NSString *) timeStamp {
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
}

#pragma mark -- CircleButtonViewDelegate

- (void)buttonView:(UIView *)button didClickTap:(UITapGestureRecognizer *)tapGes {
    __weak typeof(self) weakSelf = self;
    [self.camera capture:^(NixCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        if(!error) {
            //            ImageViewController *imageVC = [[ImageViewController alloc] initWithImage:image];
            //            [weakSelf presentViewController:imageVC animated:NO completion:nil];
            
            if (![weakSelf.previewView conformsToProtocol:@protocol(CameraPreviewViewProtocol)]) {
                
                return;
            }
            [weakSelf.previewView showMediaContentImage:image withType:Enum_StillImage];
            weakSelf.previewView.hidden = NO;
        }
        else {
            NSLog(@"An error has occured: %@", error);
        }
    } exactSeenImage:YES];
}

- (void)buttonView:(UIView *)button didLongTapBegan:(UITapGestureRecognizer *)tapGes {
    // start recording
    NSURL *outputURL = [[[self applicationDocumentsDirectory]
                         URLByAppendingPathComponent:[self timeStamp]] URLByAppendingPathExtension:@"mov"];
    __weak typeof(self) weakSelf = self;
    weakSelf.flashButton.hidden = YES;
    weakSelf.switchButton.hidden = YES;
    weakSelf.hintsLabel.hidden = YES;
    
    [self.camera startRecordingWithOutputUrl:outputURL didRecord:^(NixCamera *camera, NSURL *outputFileUrl, NSError *error, UIImage *image) {
        
        weakSelf.flashButton.hidden = NO;
        weakSelf.switchButton.hidden = NO;
        weakSelf.hintsLabel.hidden = NO;
        
        if(!error) {
            if (![weakSelf.previewView conformsToProtocol:@protocol(CameraPreviewViewProtocol)]) {
                
                return;
            }
            [weakSelf.previewView showMediaContentVideo:outputURL withType:Enum_VideoURLPath];
            weakSelf.previewView.hidden = NO;
        }else if(image){
            NSLog(@"An error has occured: %@", error);
            if (![weakSelf.previewView conformsToProtocol:@protocol(CameraPreviewViewProtocol)]) {
                
                return;
            }
            [weakSelf.previewView showMediaContentImage:image withType:Enum_StillImage];
            weakSelf.previewView.hidden = NO;
        }else{
            NSLog(@"An error has occured: %@", error);
        }
        
        
        
    }];
}

- (void)buttonView:(UIView *)button didLongTapEnded:(UITapGestureRecognizer *)tapGes {
    self.flashButton.hidden = NO;
    self.switchButton.hidden = NO;
    self.hintsLabel.hidden = NO;
    [self.camera stopRecording];
    
}

- (UIButton *)cancelButton {
    if(!_cancelButton) {
        UIImage *cancelImage = [UIImage imageForResourcePath:@"NixCamera.bundle/cancel" ofType:@"png" inBundle:BUNDLE];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tintColor = [UIColor whiteColor];
        [button setImage:cancelImage forState:UIControlStateNormal];
        button.imageView.clipsToBounds = NO;
        button.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        button.layer.shadowColor = [UIColor blackColor].CGColor;
        button.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        button.layer.shadowOpacity = 0.4f;
        button.layer.shadowRadius = 1.0f;
        button.clipsToBounds = NO;
        [button addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton = button;
    }
    
    return _cancelButton;
}
-(CameraPreviewView*)previewView{
    if(_previewView != nil) return _previewView;
    _previewView = [[CameraPreviewView<CameraPreviewViewProtocol> alloc] initWithFrame:self.view.frame];
    _previewView.hidden = YES;
    _previewView.delegate = self;
    
    return _previewView;
}

#pragma mark -- RunsCameraPreviewViewDelegate

- (void)previewDidCancel:(UIView *)preview {
    NSLog(@"preview return continue photo taking");
    [self.previewView clearContent:YES];
    self.previewView.hidden = YES;
    if (![self.previewView conformsToProtocol:@protocol(CameraPreviewViewProtocol)]) {
        NSLog(@" %@ Not implementation RunsCameraPreviewViewProtocol", self.previewView);
        return;
    }
    
    
}

- (void)preview:(UIView *)preview captureStillImage:(UIImage *)image {
    NSLog(@"Preview finished  return picture");
    if (_delegate && [_delegate respondsToSelector:@selector(cameraViewController:captureStillImage:)]) {
        [_delegate cameraViewController:self captureStillImage:image];
    }
    [self.previewView clearContent:YES];
    self.previewView.hidden = YES;
}

- (void)preview:(UIView *)preview captureVideoAsset:(VideoAsset *)asset {
    NSLog(@"Preview finished  return video");
    if (_delegate && [_delegate respondsToSelector:@selector(cameraViewController:captureVideoAsset:)]) {
        [_delegate cameraViewController:self captureVideoAsset:asset];
    }
    [self.previewView clearContent:YES];
    self.previewView.hidden = YES;
}

@end

