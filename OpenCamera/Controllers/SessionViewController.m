//
//  SessionViewController.m
//  OpenCamera
//
//  Created by xyooyy on 13-12-6.
//  Copyright (c) 2013年 lunajin. All rights reserved.
//

#import "SessionViewController.h"


#define MASKA   0xff000000
#define MASKR   0x00ff0000
#define MASKG   0x0000ff00
#define MASKB   0x000000ff

#define COLOR32_WHITE   0xffffffff
#define COLOR32_BLACK   0xff000000

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
    NSLog(@"%@",captureDeviceInput);
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
    NSLog(@"%@", captureConnection);
    [captureConnection setVideoMaxFrameDuration:CMTimeMake(1, 20)];
    [captureConnection setVideoMinFrameDuration:CMTimeMake(1, 10)];
    
    NSLog(@"%@", captureVideoDataOutput);
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
    
    //为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0); // 锁定pixel buffer的基地址
    
    //從 CVImageBufferRef 取得影像的細部資訊
    //得到pixel buffer的基地址，,并转化为UInt8类型，basaAddress是取得的一帧原始数据
    uint8_t *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    double i = 0;
    while (*baseAddress++) {
        NSLog(@"%u", *baseAddress++);
        i++;
    }
    NSLog(@"%f", i);
//    NSLog(@"%u, %u, %u, %u, %u", baseAddress[0], baseAddress[1], baseAddress[2], baseAddress[3], baseAddress[4]);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);   // 得到pixel buffer的行字节数
    size_t width = CVPixelBufferGetWidth(imageBuffer);// 得到pixel buffer的宽和高
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    NSLog(@"%zu, %zu, %zu", width, height, bytesPerRow);
    size_t size = CVPixelBufferGetDataSize(imageBuffer);
    NSLog(@"%zu", size);
    
    uint8_t pixelRed = baseAddress[0];
    uint8_t pixelGreen =baseAddress[1];
    uint8_t pixelBlue = baseAddress[2];
    uint8_t pixelAlpha = baseAddress[3];
    NSLog(@"%hhu, %hhu, %hhu, %hhu", pixelRed, pixelGreen, pixelBlue, pixelAlpha);
    
    //利用取得影像細部資訊格式化 CGContextRef
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();// 创建一个依赖于设备的RGB颜色空间
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    
    //通过 CGImageRef 將 CGContextRef 转化成 UIImage
    CGImageRef imageRef= CGBitmapContextCreateImage(context);// 根据这个位图context中的像素数据创建一个Quartz image对象
    UIImage *image = [UIImage imageWithCGImage:imageRef];
//    NSLog(@"%f, %f", image.size.width, image.size.height);
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);  // 解锁pixel buffer
    return (image);
    
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate Methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
//    NSLog(@"%@", image);
    
}





@end
