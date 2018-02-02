//
//  CircleButtonView.m
//  NixCameraExample
//
//  Created by James Kong on 2/2/2018.
//  Copyright © 2018  James Kong. All rights reserved.
//

#import "CircleButtonView.h"
#import <CircleProgressView/CircleProgressView-Swift.h>
#import "UIImage+Resources.h"
#define CIRCLE_RATE (2)
#define BUNDLE [NSBundle bundleForClass:[self class]]
@interface CircleButtonView () <UIGestureRecognizerDelegate>

@end
@implementation CircleButtonView{
    BOOL isVideoCapture;
    BOOL isEffectiveVideo;
	UIImageView *topImageView;
	UIImageView *bottomImageView;
	CGSize topImageViewOriginSize;
	CGSize bottomImageViewOriginSize;
    CircleProgressView *circleProgressView;
	dispatch_source_t longTapQueueTimer;
}
- (void)dealloc {
	[self stop];
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {

		[self addSubview:self.bottomImageView];
		[self addSubview:self.circleProgressView];
		[self addSubview:self.topImageView];
		[self addGestureRecognizer:self.clickTap];
		[self addGestureRecognizer:self.longTap];
	}
	return self;
}

- (void)setVideoInterval:(NSTimeInterval)videoInterval {
	_videoInterval = videoInterval > 0 ? videoInterval : 10;
}

- (void)start {
	circleProgressView.hidden = NO;
	if (!isVideoCapture)  return;
	dispatch_resume(self.longTapQueueTimer);
}

- (void)stop {

	isVideoCapture = NO;
	if (longTapQueueTimer) {
		dispatch_source_cancel(longTapQueueTimer);
	}
	[circleProgressView setProgress:0.0];
	circleProgressView.hidden = YES;
}

- (void)resume {

	[self stop];
	[self restoreFrame];
}

- (void)expandAnimation {

	__block CGFloat bottomRate = CIRCLE_RATE;//self.frame.size.width / bottomImageView.frame.size.width;
	[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
		bottomImageView.transform = CGAffineTransformMakeScale(bottomRate, bottomRate);
		bottomImageView.center = self.thisCenter;
		//
		topImageView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        topImageView.image = [UIImage imageForResourcePath:@"NixCamera.bundle/camera_action_top_recording" ofType:@"png" inBundle:BUNDLE];
		topImageView.center = self.thisCenter;
	} completion:^(BOOL finished) {
		[self start];
	}];
}

- (void)restoreFrame {

	[UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
		bottomImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
		bottomImageView.frame = CGRectMake(0, 0, bottomImageViewOriginSize.width, bottomImageViewOriginSize.height);
		bottomImageView.center = self.thisCenter;
		//
		topImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
		topImageView.frame = CGRectMake(0, 0, topImageViewOriginSize.width, topImageViewOriginSize.height);
		topImageView.center = self.thisCenter;
        
	} completion:^(BOOL finished) {
        topImageView.image = [UIImage imageForResourcePath:@"NixCamera.bundle/camera_action_top" ofType:@"png" inBundle:BUNDLE];
	}];
}
#pragma mark -- tap event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[self resume];
}

- (void)onClickTap:(UITapGestureRecognizer *)tapGes {


	if (isVideoCapture) {

		return;
	}
	if (_delegate && [_delegate respondsToSelector:@selector(buttonView:didClickTap:)]) {
		[_delegate buttonView:self didClickTap:tapGes];
	}
	[self stop];
}

- (void)onLongTap:(UITapGestureRecognizer *)tapGes {
	UIGestureRecognizerState state = tapGes.state;
	if (UIGestureRecognizerStateChanged == state) {
		//
		return;
	}

	if (!_delegate) {

		return;
	}

	if (UIGestureRecognizerStateBegan == state) {

		isVideoCapture = YES;
		isEffectiveVideo = NO;
		[self expandAnimation];
		if ([_delegate respondsToSelector:@selector(buttonView:didLongTapBegan:)]) {
			[_delegate buttonView:self didLongTapBegan:tapGes];
		}
		return;
	}

	if (UIGestureRecognizerStateEnded == state) {

		isVideoCapture = NO;
		if (!isEffectiveVideo && [_delegate respondsToSelector:@selector(buttonView:didClickTap:)]) {

			[_delegate buttonView:self didClickTap:tapGes];
			[self resume];
			return;
		}

		if ([_delegate respondsToSelector:@selector(buttonView:didLongTapEnded:)]) {
			[_delegate buttonView:self didLongTapEnded:tapGes];
		}
	}
	[self resume];

}

#pragma mark -- UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return NO;
}

- (void)captureVideoOver {
	isVideoCapture = NO;
	if (!isEffectiveVideo && [_delegate respondsToSelector:@selector(buttonView:didClickTap:)]) {
		[self resume];
		return;
	}
	if ([_delegate respondsToSelector:@selector(buttonView:didLongTapEnded:)]) {
		UITapGestureRecognizer *tap = (UITapGestureRecognizer *)self.longTap;
		[_delegate buttonView:self didLongTapEnded:tap];
	}
	[self resume];
}

#pragma mark -- init UI and componet

- (UITapGestureRecognizer *)clickTap {
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickTap:)];
	tap.delegate = self;
	return tap;
}

- (UILongPressGestureRecognizer *)longTap {
	UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongTap:)];
	tap.minimumPressDuration = 0.1;
	tap.delegate = self;
	return tap;
}

- (UIImageView *)topImageView {
	if (topImageView) return topImageView;
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
	imageView.image = [UIImage imageForResourcePath:@"NixCamera.bundle/camera_action_top" ofType:@"png" inBundle:BUNDLE];
	imageView.userInteractionEnabled = NO;
	imageView.center = self.thisCenter;
	topImageView = imageView;
	topImageViewOriginSize = imageView.frame.size;
	return topImageView;
}

- (UIImageView *)bottomImageView {
	if (bottomImageView) return bottomImageView;
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	imageView.image = [UIImage imageForResourcePath:@"NixCamera.bundle/camera_action_bottom" ofType:@"png" inBundle:BUNDLE];
	imageView.userInteractionEnabled = NO;
	imageView.center = self.thisCenter;
	bottomImageView = imageView;
	bottomImageViewOriginSize = bottomImageView.frame.size;
	return bottomImageView;
}

- (CircleProgressView *)circleProgressView {
	if (circleProgressView) return circleProgressView;
	CircleProgressView *progressView = [[CircleProgressView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width*CIRCLE_RATE, self.frame.size.height*CIRCLE_RATE)];
	
    
    [progressView setProgress:0];
    [progressView setTrackBorderWidth:10];
    [progressView setTrackBackgroundColor:[UIColor clearColor]];
    [progressView setTrackFillColor:[UIColor redColor]];
    [progressView setBackgroundColor:[UIColor clearColor]];
    [progressView setCenterFillColor:[UIColor clearColor]];
    
	progressView.center = self.thisCenter;
	progressView.progress =0;
	progressView.hidden = YES;
	circleProgressView = progressView;
	return circleProgressView;
}

static int count = 0;
- (dispatch_source_t)longTapQueueTimer {
	//    dispatch_queue_t queue = dispatch_queue_create("com.RunsCircleButtonView.timer", DISPATCH_QUEUE_CONCURRENT);
	__weak typeof(self) weakSelf = self;
	dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
	dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0);
	uint64_t interval = 0.01 * NSEC_PER_SEC;
	dispatch_source_set_timer(timer, start, interval, 0);
	dispatch_source_set_event_handler(timer, ^{
		if (count > (_videoInterval*100)) {
			[circleProgressView setProgress:1.0];
			[weakSelf captureVideoOver];

			return;
		}
		count += 1;
		CGFloat rate = (CGFloat)count/(_videoInterval*100);
		[circleProgressView setProgress:rate];
		isEffectiveVideo = count >= 10;
		//
	});
	dispatch_source_set_cancel_handler(timer, ^{
		count = 0;
	});
	longTapQueueTimer = timer;
	return longTapQueueTimer;
}

- (CGPoint)thisCenter {
	return CGPointMake(self.frame.size.width * 0.5, self.frame.size.height *0.5);
}

@end
