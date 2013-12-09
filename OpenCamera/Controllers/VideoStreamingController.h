//
//  VideoStreamingController.h
//  OpenCamera
//
//  Created by xyooyy on 13-12-5.
//  Copyright (c) 2013年 lunajin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>


@interface VideoStreamingController : UIImagePickerController<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (strong, nonatomic) CALayer *customLayer;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end
