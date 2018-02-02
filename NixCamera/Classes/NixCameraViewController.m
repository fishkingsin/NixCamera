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
#define BUNDLE [NSBundle bundleForClass:[self class]]
@interface NixCameraViewController ()
@property (strong, nonatomic) NixCamera *camera;
@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) UILabel *hintsLabel;
@property (strong, nonatomic) CircleButtonView *snapButton;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) UIButton *cancelButton;
@end

@implementation NixCameraViewController

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
	self.camera.maximumVideoDuration = 15;
	// attach to a view controller
	[self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
	
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
	
//    self.snapButton.autoresizingMask = ( UIViewAutoresizingFlexibleTopMargin);
//    self.flashButton.autoresizingMask = ( UIViewAutoresizingFlexibleTopMargin);
//    self.switchButton.autoresizingMask = ( UIViewAutoresizingFlexibleTopMargin);
	
}

-(void)viewDidAppear:(BOOL)animated{
	
	[[UIDevice currentDevice] setValue:
	 [NSNumber numberWithInteger: UIInterfaceOrientationPortrait    ]
								forKey:@"orientation"];
}

/* other lifecycle methods */

- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	
	self.camera.view.frame = self.view.contentBounds;
	
	self.hintsLabel.center = CGPointMake(self.view.size.width / 2.0f, self.view.size.height / 2.0f);
	self.hintsLabel.bottom = self.view.height - 15.0f;
	[self onOrientationChange];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	float rotation;
	
	if (toInterfaceOrientation==UIInterfaceOrientationPortrait) {
		rotation = 0;
	}
	else if (toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
		rotation = M_PI/2;
	} else if (toInterfaceOrientation==UIInterfaceOrientationLandscapeRight) {
		rotation = -M_PI/2;
	}
	
	
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
	if ([rootViewController isKindOfClass:[UITabBarController class]]) {
		UITabBarController* tabBarController = (UITabBarController*)rootViewController;
		return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
	} else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
		UINavigationController* navigationController = (UINavigationController*)rootViewController;
		return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
	} else if (rootViewController.presentedViewController) {
		UIViewController* presentedViewController = rootViewController.presentedViewController;
		return [self topViewControllerWithRootViewController:presentedViewController];
	} else {
		return rootViewController;
	}
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//
//    NSLog(@"willRotateToInterfaceOrientation %li %f",(long)toInterfaceOrientation, duration );
//    [self onOrientationChange];
//}
-(void) onOrientationChange {
	UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
	if(currentOrientation == UIDeviceOrientationPortrait || currentOrientation == UIDeviceOrientationFaceUp){
		self.snapButton.center = self.view.contentCenter;
		self.snapButton.bottom = self.view.bottom - 50.0f;
		self.flashButton.left = 5.0f;
		self.flashButton.y = self.snapButton.y - 15.0f;
		self.switchButton.y = self.snapButton.y - 15.0f;
		self.switchButton.right = self.view.width - 5.0f;

	}else if(currentOrientation == UIDeviceOrientationLandscapeLeft){

		self.snapButton.center = self.view.contentCenter;
		self.snapButton.right = self.view.right - 50.0f;

		self.flashButton.x = self.snapButton.x - 5.0f;
		self.flashButton.bottom = self.view.bottom - 15.0f;

		self.switchButton.top = self.view.top + 15.0f;
		self.switchButton.x = self.snapButton.x - 5.0f;

	}else if(currentOrientation == UIDeviceOrientationLandscapeRight){

		self.snapButton.center = self.view.contentCenter;

		self.snapButton.left = self.view.left + 50.0f;

		self.flashButton.x = self.snapButton.x - 5.0f;
		self.flashButton.top = self.view.top + 15.0f;

		self.switchButton.bottom = self.view.bottom - 15.0f;
		self.switchButton.x = self.snapButton.x - 5.0f;

	}
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// start the camera
	[self.camera start];
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
	[self dismissViewControllerAnimated:YES completion:NO];
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
	return !self.camera.isRecording;
}
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait;
//}
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    return UIInterfaceOrientationPortrait;
//}
//
//-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}


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
			ImageViewController *imageVC = [[ImageViewController alloc] initWithImage:image];
			[weakSelf presentViewController:imageVC animated:NO completion:nil];
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
	
//    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
//    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:currentOrientation] forKey:@"orientation"];
	
	[self.camera startRecordingWithOutputUrl:outputURL didRecord:^(NixCamera *camera, NSURL *outputFileUrl, NSError *error) {
		
		weakSelf.flashButton.hidden = NO;
		weakSelf.switchButton.hidden = NO;
		weakSelf.hintsLabel.hidden = NO;
		VideoViewController *vc = [[VideoViewController alloc] initWithVideoUrl:outputFileUrl];
		[weakSelf.navigationController pushViewController:vc animated:YES];
		
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
		
		_cancelButton = button;
	}
	
	return _cancelButton;
}

@end
