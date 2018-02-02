//
//  UINavigationController+Orientation.m
//  NixCameraExample
//
//  Created by James Kong on 2/2/2018.
//  Copyright © 2018 James Kong. All rights reserved.
//

#import "UINavigationController+Orientation.h"


@implementation UINavigationController (Orientation)
- (BOOL)shouldAutorotate{
    return [self.visibleViewController shouldAutorotate];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [self.visibleViewController supportedInterfaceOrientations];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [self.visibleViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

@end
