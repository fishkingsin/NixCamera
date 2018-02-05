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
    //    [self hideLoadingActivity];
    NSLog(@"CameraPreviewView Release");
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.stillImageView];
        [self addSubview:self.backButton];
        [self addSubview:self.confirmButton];
    }
    return self;
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
    //
    self.stillImageView.hidden = YES;
    //
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
//        UIView *delegateView = [UIApplication.sharedApplication.delegate window];
//        [delegateView makeLoadingActivity:@"parpring ..."];
//        UIImage *frame = [UIImage rs_fetchVideoPreViewImageWithUrl:videoURLPath];
//        [CameraManager compressVideoWithUrl:videoURLPath completed:^(NSData * _Nullable data) {
//            [delegateView hideLoadingActivity];
//            if (!data) {
//                NSLog(@"compress failed ");;
//                return;
//            }
//            [delegateView makeToast:@"compress successed " duration:1.0 position:CSToastPositionCenter];
//            NSTimeInterval duration = player.currentItem.duration.value / player.currentItem.duration.timescale;
//            AVAsset *asset = player.currentItem.asset;
//            VideoAsset *videoAsset = [[VideoAsset alloc] initWithData:data preview:frame duration:duration asset:asset];
//            [_delegate preview:self captureVideoAsset:videoAsset];
//            //
//            [self clearContent:YES];
//        }];
    }
}

- (UIImageView *)stillImageView {
    if (stillImageView) return stillImageView;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.frame];
    imageView.hidden = YES;
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
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(self.mas_bottom);
        make.edges.equalTo(self).with.insets(padding);
        
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
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        make.edges.equalTo(self).with.insets(padding);
    }];
    return button;
}
@end

@implementation VideoAsset

- (instancetype)initWithData:(NSData *)video preview:(UIImage *)image duration:(NSTimeInterval)interval asset:(AVAsset *)playerItemAsset {
    self = [super init];
    if (self) {
        _data = video;
        _preview = image;
        _duration = interval;
        _asset = playerItemAsset;
    }
    return self;
}

@end
