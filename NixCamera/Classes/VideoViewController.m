//
//  TestVideoViewController.m
//  Memento
//
//  Created by James Kong on 22/05/15.
//  Copyright (c) 2015 James Kong. All rights reserved.
//

#import "VideoViewController.h"
#import "UIImage+Resources.h"
#import <Masonry/Masonry.h>
#define BUNDLE [NSBundle bundleForClass:[self class]]
@import AVFoundation;

@interface VideoViewController ()
@property (strong, nonatomic) NSURL *videoUrl;
@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerLayer *avPlayerLayer;

@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *confirmButton;
@end

@implementation VideoViewController

- (instancetype)initWithVideoUrl:(NSURL *)url {
	self = [super init];
	if(self) {
		_videoUrl = url;
	}
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	// the video player
	self.avPlayer = [AVPlayer playerWithURL:self.videoUrl];
	self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
	
	self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(playerItemDidReachEnd:)
												 name:AVPlayerItemDidPlayToEndTimeNotification
											   object:[self.avPlayer currentItem]];
	
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	
	self.avPlayerLayer.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    [self.view.layer addSublayer:self.avPlayerLayer];

    
	// cancel button
	[self.view addSubview:self.cancelButton];
	[self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
    [self.view addSubview:self.confirmButton];
    [self.confirmButton addTarget:self action:@selector(confirmButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	[self.avPlayer play];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.avPlayerLayer removeFromSuperlayer];
    self.avPlayerLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.avPlayerLayer];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
	AVPlayerItem *p = [notification object];
	[p seekToTime:kCMTimeZero];
}

- (BOOL)prefersStatusBarHidden {
	return YES;
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

- (UIButton *)confirmButton {
    if(!_confirmButton) {
        UIImage *cancelImage = [UIImage imageForResourcePath:@"NixCamera.bundle/confirm" ofType:@"png" inBundle:BUNDLE];
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
        
        _confirmButton = button;
    }
    
    return _cancelButton;
}

- (void)cancelButtonPressed:(UIButton *)button {
	NSLog(@"cancel button pressed!");
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmButtonPressed:(UIButton *)button {
    NSLog(@"confirm button pressed!");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
