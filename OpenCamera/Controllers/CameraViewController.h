//
//  CamerViewController.h
//  OpenCamera
//
//  Created by xyooyy on 13-12-7.
//  Copyright (c) 2013年 lunajin. All rights reserved.
//
#define centerPercent 0.2
#define squareWidth 50
#define squareHeight 50

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

typedef enum{
	kStateUntouched,
	kStateCalculating,
	kStateAirControl
}CVCState;

@interface CameraViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) CALayer *customLayer;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end
