//
//  ViewController.m
//  YQRCodeCreate
//
//  Created by 闫明 on 2017/8/8.
//  Copyright © 2017年 Linktrust. All rights reserved.
//

#define IsSTU

#ifdef IsSTU//学生端
#define LXHTMLPATH @""
#define LOGO @"student"
#else
#define LXHTMLPATH @""
#define LOGO @"teacher"
#endif

#import "ViewController.h"

#import "VVQRCodeTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self qrCode];
}

- (void)qrCode {
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    [self.view addSubview:imageV];
    
    imageV.image = [VVQRCodeTool generateLogoQRCodeWithData:LXHTMLPATH logoImageName:LOGO logoScaleToSuperView:0.3];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
