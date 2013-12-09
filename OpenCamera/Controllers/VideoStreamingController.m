//
//  VideoStreamingController.m
//  OpenCamera
//
//  Created by xyooyy on 13-12-5.
//  Copyright (c) 2013年 lunajin. All rights reserved.
//
#import "VideoStreamingController.h"

@interface VideoStreamingController ()


@property (strong, nonatomic) AVCaptureSession *captureSession;


@end

@implementation VideoStreamingController


@synthesize captureSession = _captureSession;
@synthesize customLayer = _customLayer;
@synthesize videoPreviewLayer = _videoPreviewLayer;


#pragma mark - Initialization
- (id)init
{
    self = [super init];
    if (self) {
        
        self.videoPreviewLayer = nil;
        self.customLayer = nil;
        
    }
    return self;
    
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self setupCustomLayer];
    
}


#pragma mark - Private Methods

#pragma mark -setupCaptureSession 
- (void)setupCaptureSession
{
    
	AVCaptureDevice *rearCamera = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    AVCaptureDevice *frontCamer = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	NSLog(@"%@",[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]);
    
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:rearCamera  error:nil];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:captureInput];
    [self.captureSession addOutput:[self createCaptureVideoDataOutput]];
	[self.captureSession setSessionPreset:AVCaptureSessionPresetLow];
    [self.captureSession startRunning];
    
//	[self setupCustomLayer];
	[self showVideoPreviewLayer];
    
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


#pragma mark -setupCustomLayer
- (void)setupCustomLayer
{
    
    self.customLayer = [CALayer layer];
    self.customLayer.frame = self.view.bounds;
    self.customLayer.transform = CATransform3DRotate(
    CATransform3DIdentity, M_PI/2.0f, 0, 0, 1);
    self.customLayer.contentsGravity = kCAGravityResizeAspectFill;
    [self.view.layer addSublayer:self.customLayer];
    
}


#pragma mark -showVideoPreviewLayerToView
- (void)showVideoPreviewLayer
{
    
    self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession: self.captureSession];
    self.videoPreviewLayer.frame = CGRectMake(0, 0, 320, 480);
    self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer: self.videoPreviewLayer];
    
}


#pragma mark -getImageFromSampleBuffer Method
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
        
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    // Release the Quartz image
    CGImageRelease(quartzImage);
    return (image);
    
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate Methods
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    NSLog(@"%@", image);
    
}

#pragma mark - TouchDealing
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}


@end
