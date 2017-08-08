//
//  VVQRCodeTool.m
//  VVQRCode
//
//  Created by wen on 2017/3/26.
//  Copyright © 2017年 cn.11wen. All rights reserved.
//

#import "VVQRCodeTool.h"

@implementation VVQRCodeTool
// 生成普通二维码
+ (CIImage *)generateDefautlQRCodeWithData:(NSString *)data {
    // 1、创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 恢复滤镜默认属性
    [filter setDefaults];
    
    // 2、设置数据
    NSString *info = [NSString stringWithFormat:@"%@", data];
    // 将字符串转换成 Data 数据
    NSData *infoData = [info dataUsingEncoding:NSUTF8StringEncoding];
    // 通过 KVC 设置滤镜 inputMessage 数据
    [filter setValue:infoData forKey:@"inputMessage"];
    
    // 纠错级别，由小到大：L、M、Q、H
    // L级：可纠正约7%错误、M：别可纠正约15%错误、Q级：别可纠正约25%错误、H级：别可纠正约30%错误
    // 纠错级别越高，生成图片会越大，识别成功率越高
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    // 3、获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    
    return outputImage;
}

/**
 生成普通的高清二维码
 
 @param data 传入要生成二维码的数据
 @param imageViewWidth 二维码的宽高（正方形）
 @return 高清二维码
 */
+ (UIImage *)generateDefautlQRCodeWithData:(NSString *)data imageViewWidth:(CGFloat)imageViewWidth {
    // 1、生成二维码
    CIImage *outputImage = [VVQRCodeTool generateDefautlQRCodeWithData:data];
    // 2、转换为高清二维码
    return [VVQRCodeTool generateHDQRCodeWithCIImage:outputImage withSize:imageViewWidth];
}

/** 根据 CIImage 生成制定大小的 UIImage */
+ (UIImage *)generateHDQRCodeWithCIImage:(CIImage *)ciImage withSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(ciImage.extent);
    CGFloat scale = MIN(size / CGRectGetWidth(extent), size / CGRectGetHeight(extent));
    // 1、创建 bitmap（位图）
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    // 创建灰度色调空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    // 放大并绘制二维码 (上面生成的二维码很小，需要放大)
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImageRef = [context createCGImage:ciImage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    // 翻转一下图片 不然生成的QRCode就是上下颠倒的
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImageRef);
    
    // 2、保存 btimap 到图片
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImageRef);
    CGColorSpaceRelease(colorSpace);
    
    return [UIImage imageWithCGImage:scaledImageRef];
}

/**
 生成带 Logo 的二维码
 
 @param data 传入要生成二维码的数据
 @param logoImageName logo 名
 @param logoScaleToSuperView 相对于父试图的宽高比率（0 ～ 0.5）
 @return 带 logo 的二维码
 */
+ (UIImage *)generateLogoQRCodeWithData:(NSString *)data logoImageName:(NSString *)logoImageName logoScaleToSuperView:(CGFloat)logoScaleToSuperView {
    
    // 1、生成二维码
    CIImage *outputImage = [VVQRCodeTool generateDefautlQRCodeWithData:data];
    
    // 图片小于(27,27),我们需要放大
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(20, 20)];
    
    // 2、将 CIImage 类型转成 UIImage 类型
    UIImage *startImage = [UIImage imageWithCIImage:outputImage];
    
    // 3、开启绘图, 获取图形上下文 (上下文的大小, 就是二维码的大小)
    UIGraphicsBeginImageContext(startImage.size);
    // 把二维码图片画上去 (这里是以图形上下文, 左上角为(0,0)点
    [startImage drawInRect:CGRectMake(0, 0, startImage.size.width, startImage.size.height)];
    // 再把小图片画上去
    NSString *iconImageName = [NSString stringWithFormat:@"%@", logoImageName];
    UIImage *iconImage = [UIImage imageNamed:iconImageName];
    // logoScaleToSuperView 宽高比率最好不要大于 0.5 否则识别成功率会降低
    if (logoScaleToSuperView > 0.5) {
        logoScaleToSuperView = 0.5;
    } else if (logoScaleToSuperView < 0) {
        logoScaleToSuperView = 0;
    } else {
        logoScaleToSuperView = logoScaleToSuperView;
    }
    CGFloat iconImageW = startImage.size.width * logoScaleToSuperView;
    CGFloat iconImageH = startImage.size.height * logoScaleToSuperView;
    CGFloat iconImageX = (startImage.size.width - iconImageW) / 2;
    CGFloat iconImageY = (startImage.size.height - iconImageH) / 2;
    
    [iconImage drawInRect:CGRectMake(iconImageX, iconImageY, iconImageW, iconImageH)];
    
    // 4、获取当前画得的这张图片
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 5、关闭图形上下文
    UIGraphicsEndImageContext();
    
    return finalImage;
}

/**
 生成带颜色的二维码
 
 @param data 传入要生成二维码的数据
 @param backgroundColor 二维码背景颜色
 @param qrCodeColor 二维码颜色
 @return 带颜色的二维码
 */
+ (UIImage *)generateColorQRCodeWithData:(NSString *)data backgroundColor:(UIColor *)backgroundColor qrCodeColor:(UIColor *)qrCodeColor {
    // 1、生成二维码
    CIImage *outputImage = [VVQRCodeTool generateDefautlQRCodeWithData:data];
    
    // 图片小于(27,27),我们需要放大
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(9, 9)];
    
    // 2、创建彩色过滤器(彩色的用的不多)
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"];
    // 恢复滤镜默认属性
    [colorFilter setDefaults];
    
    // 3、KVC 给私有属性赋值
    [colorFilter setValue:outputImage forKey:@"inputImage"];
    
    // 4、需要使用 CIColor
    CIColor *bgColor = [CIColor colorWithCGColor:backgroundColor.CGColor];
    [colorFilter setValue:bgColor forKey:@"inputColor1"];
    CIColor *qrColor = [CIColor colorWithCGColor:qrCodeColor.CGColor];
    [colorFilter setValue:qrColor forKey:@"inputColor0"];
    
    // 5、设置输出
    CIImage *colorImage = [colorFilter outputImage];
    
    return [UIImage imageWithCIImage:colorImage];
}

/**
 生成带颜色、带 logo 的二维码
 
 @param data 传入要生成二维码的数据
 @param logoImageName logo 名
 @param logoScaleToSuperView 相对于父试图的宽高比率（0 ～ 0.5）
 @param backgroundColor 二维码背景颜色
 @param qrCodeColor 二维码颜色
 @return 带颜色、带 logo 的二维码
 */
+ (UIImage *)generateLogoAndColorQRCodeWithData:(NSString *)data logoImageName:(NSString *)logoImageName logoScaleToSuperView:(CGFloat)logoScaleToSuperView backgroundColor:(UIColor *)backgroundColor qrCodeColor:(UIColor *)qrCodeColor {
    // 1、生成二维码
    CIImage *outputImage = [VVQRCodeTool generateDefautlQRCodeWithData:data];
    
    // 图片小于(27,27),我们需要放大
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(9, 9)];
    
    // 2、创建彩色过滤器(彩色的用的不多)
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"];
    // 恢复滤镜默认属性
    [colorFilter setDefaults];
    
    // 3、KVC 给私有属性赋值
    [colorFilter setValue:outputImage forKey:@"inputImage"];
    
    // 4、需要使用 CIColor
    CIColor *bgColor = [CIColor colorWithCGColor:backgroundColor.CGColor];
    [colorFilter setValue:bgColor forKey:@"inputColor1"];
    CIColor *qrColor = [CIColor colorWithCGColor:qrCodeColor.CGColor];
    [colorFilter setValue:qrColor forKey:@"inputColor0"];
    
    // 5、设置输出
    CIImage *colorImage = [colorFilter outputImage];
    
    // 6、将 CIImage 类型转成 UIImage 类型
    UIImage *startImage = [UIImage imageWithCIImage:colorImage];
    
    // 7、开启绘图, 获取图形上下文 (上下文的大小, 就是二维码的大小)
    UIGraphicsBeginImageContext(startImage.size);
    // 把二维码图片画上去 (这里是以图形上下文, 左上角为(0,0)点
    [startImage drawInRect:CGRectMake(0, 0, startImage.size.width, startImage.size.height)];
    // 再把小图片画上去
    NSString *iconImageName = [NSString stringWithFormat:@"%@", logoImageName];
    UIImage *iconImage = [UIImage imageNamed:iconImageName];
    // logoScaleToSuperView 宽高比率最好不要大于 0.5 否则识别成功率会降低
    if (logoScaleToSuperView > 0.5) {
        logoScaleToSuperView = 0.5;
    } else if (logoScaleToSuperView < 0) {
        logoScaleToSuperView = 0;
    } else {
        logoScaleToSuperView = logoScaleToSuperView;
    }
    CGFloat iconImageW = startImage.size.width * logoScaleToSuperView;
    CGFloat iconImageH = startImage.size.height * logoScaleToSuperView;
    CGFloat iconImageX = (startImage.size.width - iconImageW) / 2;
    CGFloat iconImageY = (startImage.size.height - iconImageH) / 2;
    
    [iconImage drawInRect:CGRectMake(iconImageX, iconImageY, iconImageW, iconImageH)];
    
    // 8、获取当前画得的这张图片
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 9、关闭图形上下文
    UIGraphicsEndImageContext();

    return finalImage;
}

@end
