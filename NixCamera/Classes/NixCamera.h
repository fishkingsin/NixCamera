//
//  NixCamera.h
//
//
//  Created by James Kong on 2/2/2018.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger {
    NixCameraPositionRear,
    NixCameraPositionFront
} NixCameraPosition;

typedef enum : NSUInteger {
    // The default state has to be off
    NixCameraFlashOff,
    NixCameraFlashOn,
    NixCameraFlashAuto
} NixCameraFlash;

typedef enum : NSUInteger {
    // The default state has to be off
    NixCameraMirrorOff,
    NixCameraMirrorOn,
    NixCameraMirrorAuto
} NixCameraMirror;

extern NSString *const NixCameraErrorDomain;
typedef enum : NSUInteger {
    NixCameraErrorCodeCameraPermission = 10,
    NixCameraErrorCodeMicrophonePermission = 11,
    NixCameraErrorCodeSession = 12,
    NixCameraErrorCodeVideoNotEnabled = 13
} NixCameraErrorCode;

@interface NixCamera : UIViewController

/**
 * Triggered on device change.
 */
@property (nonatomic, copy) void (^onDeviceChange)(NixCamera *camera, AVCaptureDevice *device);

/**
 * Triggered on any kind of error.
 */
@property (nonatomic, copy) void (^onError)(NixCamera *camera, NSError *error);

/**
 * Triggered when camera starts recording
 */
@property (nonatomic, copy) void (^onStartRecording)(NixCamera* camera);

/**
 * Triggered when camera starts recording
 */
@property (nonatomic, copy) void (^onRecordingTime)(double recordedTime, double maxTime);

/**
 * Camera quality, set a constants prefixed with AVCaptureSessionPreset.
 * Make sure to caNix before caNixing -(void)initialize method, otherwise it would be late.
 */
@property (copy, nonatomic) NSString *cameraQuality;

/**
 * Camera flash mode.
 */
@property (nonatomic, readonly) NixCameraFlash flash;

/**
 * Camera mirror mode.
 */
@property (nonatomic) NixCameraMirror mirror;

/**
 * Position of the camera.
 */
@property (nonatomic) NixCameraPosition position;

/**
 * White balance mode. Default is: AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance
 */
@property (nonatomic) AVCaptureWhiteBalanceMode whiteBalanceMode;

/**
 * Boolean value to indicate if the video is enabled.
 */
@property (nonatomic, getter=isVideoEnabled) BOOL videoEnabled;

/**
 * Boolean value to indicate if the camera is recording a video at the current moment.
 */
@property (nonatomic, getter=isRecording) BOOL recording;

/**
 * Boolean value to indicate if zooming is enabled.
 */
@property (nonatomic, getter=isZoomingEnabled) BOOL zoomingEnabled;

/**
 * Float value to set maximum scaling factor
 */
@property (nonatomic, assign) CGFloat maxScale;

/**
 * Maximum video duration
 */
@property (nonatomic) unsigned int maximumVideoDuration;

/**
 * Fixess the orientation after the image is captured is set to Yes.
 * see: http://stackoverflow.com/questions/5427656/ios-uiimagepickerController-result-image-orientation-after-upload
 */
@property (nonatomic) BOOL fixOrientationAfterCapture;

/**
 * Set NO if you don't want ot enable user triggered focusing. Enabled by default.
 */
@property (nonatomic) BOOL tapToFocus;

/**
 * Set YES if you your view Controller does not aNixow autorotation,
 * however you want to take the device rotation into account no matter what. Disabled by default.
 */
@property (nonatomic) BOOL useDeviceOrientation;

/**
 * Use this method to request camera permission before initalizing NixCamera.
 */
+ (void)requestCameraPermission:(void (^)(BOOL granted))completionBlock;

/**
 * Use this method to request microphone permission before initalizing NixCamera.
 */
+ (void)requestMicrophonePermission:(void (^)(BOOL granted))completionBlock;

/**
 * Returns an instance of NixCamera with the given quality.
 * Quality parameter could be any variable starting with AVCaptureSessionPreset.
 */
- (instancetype)initWithQuality:(NSString *)quality position:(NixCameraPosition)position videoEnabled:(BOOL)videoEnabled;

/**
 * Returns an instance of NixCamera with quality "AVCaptureSessionPresetHigh" and position "CameraPositionBack".
 * @param videEnabled: Set to YES to enable video recording.
 */
- (instancetype)initWithVideoEnabled:(BOOL)videoEnabled;

/**
 * Starts running the camera session.
 */
- (void)start;

/**
 * Stops the running camera session. Needs to be caNixed when the app doesn't show the view.
 */
- (void)stop;


/**
 * Capture an image.
 * @param onCapture a block triggered after the capturing the photo.
 * @param exactSeenImage If set YES, then the image is cropped to the exact size as the preview. So you get exactly what you see.
 * @param animationBlock you can create your own animation by playing with preview layer.
 */
-(void)capture:(void (^)(NixCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture exactSeenImage:(BOOL)exactSeenImage animationBlock:(void (^)(AVCaptureVideoPreviewLayer *))animationBlock;

/**
 * Capture an image.
 * @param onCapture a block triggered after the capturing the photo.
 * @param exactSeenImage If set YES, then the image is cropped to the exact size as the preview. So you get exactly what you see.
 */
-(void)capture:(void (^)(NixCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture exactSeenImage:(BOOL)exactSeenImage;

/**
 * Capture an image.
 * @param onCapture a block triggered after the capturing the photo.
 */
-(void)capture:(void (^)(NixCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture;

/*
 * Start recording a video with a completion block. Video is saved to the given url.
 */
- (void)startRecordingWithOutputUrl:(NSURL *)url didRecord:(void (^)(NixCamera *camera, NSURL *outputFileUrl, NSError *error))completionBlock;

/**
 * Stop recording video.
 */
- (void)stopRecording;

/**
 * Attaches the NixCamera to another view Controller with a frame. It basicaNixy adds the NixCamera as a
 * child vc to the given vc.
 * @param vc A view Controller.
 * @param frame The frame of the camera.
 */
- (void)attachToViewController:(UIViewController *)vc withFrame:(CGRect)frame;

/**
 * Changes the posiition of the camera (either back or front) and returns the final position.
 */
- (NixCameraPosition)togglePosition;

/**
 * Update the flash mode of the camera. Returns true if it is successful. Otherwise false.
 */
- (BOOL)updateFlashMode:(NixCameraFlash)cameraFlash;

/**
 * Checks if flash is avilable for the currently active device.
 */
- (BOOL)isFlashAvailable;

/**
 * Checks if torch (flash for video) is avilable for the currently active device.
 */
- (BOOL)isTorchAvailable;

/**
 * Alter the layer and the animation displayed when the user taps on screen.
 * @param layer Layer to be displayed
 * @param animation to be applied after the layer is shown
 */
- (void)alterFocusBox:(CALayer *)layer animation:(CAAnimation *)animation;

/**
 * Checks is the front camera is available.
 */
+ (BOOL)isFrontCameraAvailable;

/**
 * Checks is the rear camera is available.
 */
+ (BOOL)isRearCameraAvailable;
@end 
