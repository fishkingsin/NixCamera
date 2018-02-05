//
//  CameraPreviewView.m
//  CircleProgressView
//
//  Created by James Kong on 5/2/2018.
//

#import "CameraPreviewView.h"
#import "CameraPreviewViewProtocol.h"
#import "UIImage+Resources.h"
#import <Masonry/Masonry.h>
#import "UIImage+Configure.h"
#define BUNDLE [NSBundle bundleForClass:[self class]]
@interface CameraPreviewView ()<CameraPreviewViewProtocol>

@end
@implementation CameraPreviewView {
    MediaContentType contentType;
    UIImageView *stillImageView;
    //
    NSURL *videoURLPath;
    AVPlayer *player;
    AVPlayerLayer *playerLayer;
}

- (void)dealloc {
    NSLog(@"CameraPreviewView Release");
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blackColor]];
        [self addSubview:self.stillImageView];
        [self.stillImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
            make.width.equalTo(self.mas_width);
            make.height.equalTo(self.mas_height);
        }];
        [self addSubview:self.backButton];
        [self addSubview:self.confirmButton];
        
        
    }
    return self;
}
-(void) layoutSubviews{
    [super layoutSubviews];
    if(player){
        [playerLayer removeFromSuperlayer];
        playerLayer.frame = self.frame;
        player.externalPlaybackVideoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer:playerLayer];
        [self.layer insertSublayer:playerLayer atIndex:0];
    }
    
}
#pragma mark -- CameraPreviewViewProtocol

- (void)showMediaContentImage:(UIImage *)image withType:(MediaContentType)type {
    contentType = type;
    NSLog(@"preview picture");;
    self.stillImageView.hidden = NO;
    playerLayer.hidden = YES;
    [self.stillImageView setImage:image];
}

- (void)showMediaContentVideo:(NSURL *)URLPath withType:(MediaContentType)type {
    contentType = type;
    videoURLPath = URLPath;
    
    self.stillImageView.hidden = YES;
    player = [AVPlayer playerWithURL:URLPath];
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.frame;
    player.externalPlaybackVideoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:playerLayer];
    [self.layer insertSublayer:playerLayer atIndex:0];
    //
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onPlaybackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [player play];
    });
    
    NSLog(@"previewvideo outputURL: %@",URLPath);
}

- (void)onPlaybackFinished {
    [player seekToTime:CMTimeMake(0, 1)];
    [player play];
}

- (void)clearContent:(BOOL)needClear {
    if (!needClear) {
        return;
    }
    self.stillImageView.image = nil;
    if (player) {
        [player pause];
        player = nil;
        [playerLayer removeFromSuperlayer];
        playerLayer = nil;
    }
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)onBackToCamera {
    if (_delegate && [_delegate respondsToSelector:@selector(previewDidCancel:)]) {
        [_delegate previewDidCancel:self];
        [self clearContent:YES];
    }
}

- (void)onConfirmContent {
    if (!_delegate) {
        NSLog(@"delegate empty， can not can not reuturn select photo or video");;
        return;
    }
    if (Enum_StillImage == contentType && stillImageView.image) {
        if (![_delegate respondsToSelector:@selector(preview:captureStillImage:)]) {
            NSLog(@"delegate is not response to selector preview:captureStillImage:");
            return;
        }
        [_delegate preview:self captureStillImage:stillImageView.image];
        [self clearContent:YES];
        return;
    }
    
    if (Enum_VideoURLPath == contentType && videoURLPath) {
        if (![_delegate respondsToSelector:@selector(preview:captureVideoAsset:)]) {
            NSLog(@"delegate is not response to selector preview:captureVideoURL:");
            return;
        }
        UIImage *frame = [UIImage fetchVideoPreViewImageWithUrl:videoURLPath];
        
        NSTimeInterval duration = player.currentItem.duration.value / player.currentItem.duration.timescale;
        AVAsset *asset = player.currentItem.asset;
        VideoAsset *videoAsset = [[VideoAsset alloc] initWithData:videoURLPath preview:frame duration:duration asset:asset];
        [_delegate preview:self captureVideoAsset:videoAsset];
        [self clearContent:YES];
        
    }
}

- (UIImageView *)stillImageView {
    if (stillImageView) return stillImageView;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.frame];
    imageView.hidden = YES;
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    stillImageView = imageView;
    
    return stillImageView;
}

- (UIButton *)backButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 32, 32);
    [button setImage: [UIImage imageForResourcePath:@"NixCamera.bundle/camera_preview_back" ofType:@"png" inBundle:BUNDLE]   forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onBackToCamera) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_centerX).with.offset(-padding.right);
        make.bottom.equalTo(self.mas_bottom).with.offset(-padding.bottom);
        
    }];
    return button;
}

- (UIButton *)confirmButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 32, 32);
    [button setImage: [UIImage imageForResourcePath:@"NixCamera.bundle/camera_preview_finished" ofType:@"png" inBundle:BUNDLE] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onConfirmContent) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_centerX).with.offset(padding.left);
        make.bottom.equalTo(self.mas_bottom).with.offset(-padding.bottom);
    }];
    return button;
}
@end

@implementation VideoAsset

- (instancetype)initWithData:(NSURL *)videoURL preview:(UIImage *)image duration:(NSTimeInterval)interval asset:(AVAsset *)playerItemAsset {
    self = [super init];
    if (self) {
        _videoURL = videoURL;
        _preview = image;
        _duration = interval;
        _asset = playerItemAsset;
    }
    return self;
}

@end
