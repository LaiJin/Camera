//
//  OpenCameraViewController.m
//  OpenCamera
//
//  Created by xyooyy on 13-12-4.
//  Copyright (c) 2013年 lunajin. All rights reserved.
//

#import "OpenCameraViewController.h"
//#import "VideoStreamingController.h"

@interface OpenCameraViewController (){
    
    UIImageView *imageView;
    UIImagePickerController *imagePickerController;
    
}

@end

@implementation OpenCameraViewController

- (id)init
{
    self = [super init];
    
    if (self) {
        
        imageView = [[UIImageView alloc] init];
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;

    }
    
    return self;
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self
                                                                                           action:@selector(openCamera)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                                          target:self
                                                                                          action:@selector(localPhotos)];
   
}


- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];

}


- (void)openCamera
{
    
   
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        
        imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
        
    }
    else    NSLog(@"没有相机");
    
}


- (void)localPhotos
{
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    imageView.image = image;
    [self.view addSubview:imageView];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
	
}










@end
