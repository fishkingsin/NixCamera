//
//  CircleButtonView.h
//  NixCameraExample
//
//  Created by James Kong on 2/2/2018.
//  Copyright © 2018 James Kong. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CircleButtonViewDelegate <NSObject>
- (void)buttonView:(UIView *)button didClickTap:(UITapGestureRecognizer *)tapGes;
- (void)buttonView:(UIView *)button didLongTapBegan:(UITapGestureRecognizer *)tapGes;
- (void)buttonView:(UIView *)button didLongTapEnded:(UITapGestureRecognizer *)tapGes;
@end
@interface CircleButtonView : UIView
@property (nonatomic, assign) NSTimeInterval videoInterval;
@property (nonatomic, weak) id<CircleButtonViewDelegate> delegate;
@end
