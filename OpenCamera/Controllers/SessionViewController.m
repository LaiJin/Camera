//
//  SessionViewController.m
//  OpenCamera
//
//  Created by xyooyy on 13-12-6.
//  Copyright (c) 2013年 lunajin. All rights reserved.
//

#import "SessionViewController.h"

@interface SessionViewController ()


@property (strong, nonatomic) AVCaptureSession *captureSesstion;


@end


@implementation SessionViewController
@synthesize captureSesstion = _captureSesstion;

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self setupCaptureSession];
    
}


- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


#pragma mark - Prvate Methods

- (void)setupCaptureSession
{
    
    NSError *error = nil;
    AVCaptureDevice *rearCamera = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSLog(@"%@", [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]);
    
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:rearCamera error:&error];
    
    if (!error){
        
        self.captureSesstion = [[AVCaptureSession alloc] init];
        [self.captureSesstion addInput:captureDeviceInput];
        [self.captureSesstion addOutput:[self createCaptureVideoDataOutput]];
        [self.captureSesstion setSessionPreset:AVCaptureSessionPresetPhoto];
        [self.captureSesstion startRunning];
        [self showVideoPreviewLayer];
        
    }
    else NSLog(@"not input");
    
//    if(![self.captureSesstion isRunning])   [self.captureSesstion startRunning];

}


#pragma mark -createCaptureVideoDataOutput

- (AVCaptureVideoDataOutput *)createCaptureVideoDataOutput
{
    
    AVCaptureVideoDataOutput *captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]
                                                              forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
    [captureVideoDataOutput setVideoSettings:videoSettings];
    //    dispatch_queue_t queue = dispatch_queue_create("cameraQueue", NULL);
    //    [captureVideoDataOutput setSampleBufferDelegate:self queue:queue];
    [captureVideoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [captureVideoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    AVCaptureConnection *captureConnection = [captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    [captureConnection setVideoMaxFrameDuration:CMTimeMake(1, 20)];
    [captureConnection setVideoMinFrameDuration:CMTimeMake(1, 10)];
    
    return captureVideoDataOutput;
    
}


#pragma mark -showAVCaptureVideoPreviewLayer

-(void)showVideoPreviewLayer
{
    
    AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession: self.captureSesstion];
    previewLayer.frame = self.view.bounds; //视频显示到的UIView
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //    [previewLayer setOrientation:AVCaptureVideoOrientationLandscapeRight];
    [self.view.layer addSublayer: previewLayer];
    
}


#pragma mark -getImageFromSampleBuffer Method

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    
    //制作 CVImageBufferRef
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    //從 CVImageBufferRef 取得影像的細部資訊
    uint8_t *baseAddress;
    size_t width, height, bytesPerRow;
    baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    width = CVPixelBufferGetWidth(imageBuffer);
    height = CVPixelBufferGetHeight(imageBuffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    //利用取得影像細部資訊格式化 CGContextRef
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    //通过 CGImageRef 將 CGContextRef 转化成 UIImage
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    CGImageRelease(quartzImage);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    return image;
    
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate Methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    NSLog(@"%@", image);
    
}





@end
