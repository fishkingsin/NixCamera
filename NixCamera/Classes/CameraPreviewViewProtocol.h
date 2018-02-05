//
//  CameraPreviewViewProtocol.h
//  NixCamera
//
//  Created by James Kong on 5/2/2018.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, MediaContentType) {
    Enum_StillImage = 0,
    Enum_VideoURLPath = 1,
    Enum_Default_MediaContentType = 0,
};

@protocol CameraPreviewViewProtocol <NSObject>
@required
- (void)showMediaContentImage:(UIImage *)image withType:(MediaContentType)type;
- (void)showMediaContentVideo:(NSURL *)URLPath withType:(MediaContentType)type;
- (void)clearContent:(BOOL)needClear;
@end
