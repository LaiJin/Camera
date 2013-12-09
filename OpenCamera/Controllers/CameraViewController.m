//
//  CamerViewController.m
//  OpenCamera
//
//  Created by xyooyy on 13-12-7.
//  Copyright (c) 2013年 lunajin. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController (){
    
    CGFloat *centerSquareRGBAs;
	int arrayTotalCount;
	CGFloat *calculatedRGBA;
	CGPoint touchPoint;
	CVCState currentState;
	UILabel *posLabel;
    
}

@property (strong, nonatomic) AVCaptureSession *captureSession;


@end

@implementation CameraViewController

@synthesize captureSession = _captureSession;
@synthesize imageView = _imageView;
@synthesize customLayer = _customLayer;
@synthesize videoPreviewLayer = _videoPreviewLayer;


#pragma mark - Initialization
- (id)init
{
    self = [super init];
    if (self) {
        
        self.imageView = nil;
        self.videoPreviewLayer = nil;
        self.customLayer = nil;
		posLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
		posLabel.text = [NSString stringWithFormat:@"position"];
		posLabel.textColor = [UIColor blackColor];
		[self.view addSubview:posLabel];
        
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
    
	AVCaptureDevice *frontCamera = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    //    AVCaptureDevice *frontCamer = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	NSLog(@"%@",[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]);
    
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera  error:nil];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:captureInput];
    [self.captureSession addOutput:[self createCaptureVideoDataOutput]];
	[self.captureSession setSessionPreset:AVCaptureSessionPresetLow];
    [self.captureSession startRunning];
    
    //	[self setupCustomLayer];
	[self showVideoPreviewLayer];
    [self addImageVew];
    
    calculatedRGBA = calloc(8, sizeof(CGFloat));
	currentState = kStateUntouched;
    
}


#pragma mark -createCaptureVideoDataOutput
- (AVCaptureVideoDataOutput *)createCaptureVideoDataOutput
{
    
    AVCaptureVideoDataOutput *captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    dispatch_queue_t queue = dispatch_queue_create("cameraQueue", NULL);
    [captureVideoDataOutput setSampleBufferDelegate:self queue:queue];
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [captureVideoDataOutput setVideoSettings:videoSettings];
    
    return captureVideoDataOutput;
    
}


#pragma mark -setupCustomLayer
- (void)setupCustomLayer
{
    
    self.customLayer = [CALayer layer];
    self.customLayer.frame = self.view.bounds;
    self.customLayer.transform = CATransform3DRotate(CATransform3DIdentity, M_PI/2.0f, 0, 0, 1);
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


#pragma mark -addImageViewToView
- (void)addImageVew
{
    
    self.imageView = [[UIImageView alloc] init];
	float length = 320 * centerPercent;
    self.imageView.frame = CGRectMake(160 - length/2, 230 - length/2,length,length);
	self.imageView.backgroundColor = [UIColor greenColor];
	[self.view addSubview:self.imageView];
    
}

#pragma mark -calculateTargetRGBA
- (void)calculateTargetRGBA
{
    
    CGFloat redSum, greenSum, blueSum, alphaSum;
    redSum = greenSum = blueSum = alphaSum = 0;
	int count = arrayTotalCount;
	for (int i=0; i<count; i++) {
		redSum += centerSquareRGBAs[i*4 + 0];
		greenSum += centerSquareRGBAs[i*4 + 1];
		blueSum += centerSquareRGBAs[i*4 + 2];
		alphaSum += centerSquareRGBAs[i*4 + 3];
	}
	redSum /= count; greenSum /= count;  blueSum /= count;   alphaSum /= count;
	calculatedRGBA[0] = redSum * 0.9;
	calculatedRGBA[1] = greenSum * 0.9;
	calculatedRGBA[2] = blueSum * 0.9;
	calculatedRGBA[3] = alphaSum * 0.9;
	calculatedRGBA[4] = redSum * 1.1;
	calculatedRGBA[5] = greenSum * 1.1;
	calculatedRGBA[6] = blueSum * 1.1;
	calculatedRGBA[7] = alphaSum * 1.1;
	
	//free(centerSquareRGBAs);
	currentState = kStateAirControl;
    
}

- (void)moveImage
{
    
	[self.imageView setCenter:touchPoint];
    
}

- (void)convertToDogsView
{
	
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegat
- (void)captureOutput:(AVCaptureOutput *)captureOutput  didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
	
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
	
	if (currentState == kStateCalculating) {
		long squareLength = (long)((float)height * centerPercent);
		long addition = (height - squareLength)*bytesPerRow/2 + (width - squareLength)*2;
		NSLog(@"%zd,%zd,%zd,%zd",addition,squareLength,width,height);
		if (!centerSquareRGBAs) {
			arrayTotalCount = squareLength * squareLength;
			centerSquareRGBAs = calloc(arrayTotalCount*4, sizeof(CGFloat));
		}
		for (int i=0; i < squareLength; i++) {
			for (int j=0; j < squareLength; j++) {
				long cindex = i*4*squareLength + j*4;
				long baseIndex = i*bytesPerRow + j*4;
				centerSquareRGBAs[cindex + 0] = baseAddress[baseIndex + addition + 0];
				centerSquareRGBAs[cindex + 1] = baseAddress[baseIndex + addition + 1];
				centerSquareRGBAs[cindex + 2] = baseAddress[baseIndex + addition + 2];
				centerSquareRGBAs[cindex + 3] = baseAddress[baseIndex + addition + 3];
			}
		}
		[self performSelector:@selector(calculateTargetRGBA)];
	}
	
	if (currentState == kStateAirControl) {
		long count = width * height;
		CGFloat red,green,blue,alpha;
		CGFloat xpos,ypos;
		long total = 0;
		xpos = ypos = 0;
		for (long i=0; i<count; i++) {
			red =   baseAddress[i*4 + 0];
			green = baseAddress[i*4 + 1];
			blue =  baseAddress[i*4 + 2];
			alpha = baseAddress[i*4 + 3];
			
			BOOL belongTo = YES;
			if ((red - calculatedRGBA[0]) * (red - calculatedRGBA[4]) > 0) {
				belongTo = NO;
			}
			if ((green - calculatedRGBA[1]) * (green - calculatedRGBA[5]) > 0) {
				belongTo = NO;
			}
			if ((blue - calculatedRGBA[2]) * (blue - calculatedRGBA[6]) > 0) {
				belongTo = NO;
			}
            
			if (belongTo) {
				xpos+=i%width;
				ypos+=i/width;
				total++;
			}
		}
		xpos = xpos/total * 460.0/width;
		ypos = ypos/total * 320.0/height;
		
		touchPoint = CGPointMake(ypos, xpos);
		if (touchPoint.x<=320 && touchPoint.y<=460) {
			[self performSelectorOnMainThread:@selector(moveImage) withObject:nil waitUntilDone:YES];
		}
		[posLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%f,%f",xpos,ypos] waitUntilDone:YES];
	}
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
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
    
	
	if (currentState == kStateUntouched)    currentState = kStateCalculating;
	if (currentState == kStateAirControl)   currentState = kStateUntouched;
    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}


@end
