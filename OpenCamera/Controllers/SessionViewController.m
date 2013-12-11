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


#pragma mark - 
#pragma mark Prvate Methods

#pragma mark -setupCaptureSession
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
        [self.captureSesstion beginConfiguration];
        [self.captureSesstion addInput:captureDeviceInput];
        [self.captureSesstion addOutput:[self createCaptureVideoDataOutput]];
        [self.captureSesstion setSessionPreset:AVCaptureSessionPresetPhoto];
        [self.captureSesstion commitConfiguration];
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
    [previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    [self.view.layer addSublayer: previewLayer];
    
}


#pragma mark -getImageFromSampleBuffer Method
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    
    //为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer =CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0); // 锁定pixel buffer的基地址
    
    //從 CVImageBufferRef 取得影像的細部資訊
    //得到pixel buffer的基地址，,并转化为uint_8类型，basaAddress是取得的一帧原始数据
    uint8_t *baseAddress = (uint8_t *) CVPixelBufferGetBaseAddress(imageBuffer);
    
//    NSLog(@"%u, %u, %u, %u, %u", baseAddress[0], baseAddress[1], baseAddress[2], baseAddress[3], baseAddress[4]);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);   // 得到pixel buffer的行字节数
    size_t width = CVPixelBufferGetWidth(imageBuffer);// 得到pixel buffer的宽和高
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t size = CVPixelBufferGetDataSize(imageBuffer);
    
    NSLog(@"%zu, %zu, %zu, %zu", width, height, bytesPerRow, size);
    
    /*  
     int bufferSize = bytesPerRow * height;
     uint8_t *tempAddress = malloc(bufferSize);
//     uint8_t *tempAddress = calloc(bufferSize);
     memcpy(tempAddress, baseAddress, bytesPerRow * height);
     baseAddress = tempAddress;
    */
    
    /*
     NSUInteger bytesPerPixel = 4;
     int byteIndex = bytesPerRow * bytesPerPixel;
     char red = baseAddress[byteIndex];
     char green = baseAddress[byteIndex + 1];
     char blue = baseAddress[byteIndex + 2];
     char alpha = baseAddress[byteIndex + 3];
     NSLog(@"%hhd, %hhd, %hhd, %hhd", red, green, blue, alpha);
    */
    
    
    /*转换RGB十六进制字符串转换成的UIColor
     CGFloat red   = ((baseColor1 & 0xFF0000) >> 16) / 255.0f;
     CGFloat green = ((baseColor1 & 0x00FF00) >>  8) / 255.0f;
     CGFloat blue  =  (baseColor1 & 0x0000FF) / 255.0f;
     */
    
    /* 
     */
    //利用取得影像細部資訊格式化 CGContextRef
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();// 创建一个依赖于设备的RGB颜色空间
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    
    /*
     * CGBitmapContextCreate(void *data, size_t width, size_t height, size_t bitsPerComponent, size_t bytesPerRow, CGColorSpaceRef space, CGBitmapInfo bitmapInfo)
     * 函数参数的意思：data                 指向要渲染的绘制内存的地址。这个内存块的大小至少是（bytesPerRow*height）个字节
     *              width                bitmap的宽度,单位为像素
     *              height               bitmap的高度,单位为像素
     *              bitsPerComponent     内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8.
     *              bytesPerRow          bitmap的每一行在内存所占的比特数 就是 每行有多少个像素
     *              colorspace           bitmap上下文使用的颜色空间。    
     *              bitmapInfo           指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串。
     * 当你调用这个函数的时候，Quartz创建一个位图绘制环境，也就是位图上下文。当你向上下文中绘制信息时，Quartz把你要绘制的信息作为位图数据绘制到指定的内存块。
     * 一个新的位图上下文的像素格式由三个参数决定：每个组件的位数，颜色空间，alpha选项。alpha值决定了绘制像素的透明性。
     */

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


#pragma mark -getRGBASFromImage method 获取静态的图片 或者是已经拍摄好的图片的 RGBAs 
- (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)xx andY:(int)yy count:(int)count
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    int byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel; //xx yy 是图像的坐标信息
    for (int ii = 0 ; ii < count ; ++ii)
    {
        CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
        CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
        byteIndex += 4;
        
        UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [result addObject:acolor];
    }
    
    free(rawData);
    
    return result;
}


#pragma mark -processImage 获取静态的图片 或者是已经拍摄好的图片的RGB的平均值
- (void) processImage:(UIImage*) image
{
    
    int redTotal = 0;   int greenTotal = 0;    int blueTotal = 0;
    CGSize imageSize = image.size;
    int bytesPerPixel = 4;
    
    NSData *imageData = (__bridge NSData*)CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    
    unsigned char *imageBytes = (UInt8 *)[imageData bytes];
    
    for (int j=0; j<imageSize.height; j++) {
        
        for(int i=0; i<imageSize.width; i += bytesPerPixel){
            
            //Bytes in BGRA order
            blueTotal  += imageBytes[i];
            greenTotal += imageBytes[i+1];
            redTotal   += imageBytes[i+2];
            //skip alpha
        }
    }
    
    int numPixels = imageSize.height * imageSize.width;
    
    int redAverage   = redTotal   / numPixels;
    int greenAverage = greenTotal / numPixels;
    int blueAverage  = blueTotal  / numPixels;
    
    NSLog(@"Red: %d, Green: %d, Blue: %d", redAverage, greenAverage, blueAverage);
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate Methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    NSLog(@"%@", image);
    
}


@end
