//
//  VVQRCodeTool.h
//  VVQRCode
//
//  Created by wen on 2017/3/26.
//  Copyright © 2017年 cn.11wen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VVQRCodeTool : NSObject

/**
 生成普通的高清二维码

 @param data 传入要生成二维码的数据
 @param imageViewWidth 二维码的宽高（正方形）
 @return 高清二维码
 */
+ (UIImage *)generateDefautlQRCodeWithData:(NSString *)data imageViewWidth:(CGFloat)imageViewWidth;

/**
 生成带 Logo 的二维码

 @param data 传入要生成二维码的数据
 @param logoImageName logo 名
 @param logoScaleToSuperView 相对于父试图的宽高比率（0 ～ 0.5）
 @return 带 logo 的二维码
 */
+ (UIImage *)generateLogoQRCodeWithData:(NSString *)data logoImageName:(NSString *)logoImageName logoScaleToSuperView:(CGFloat)logoScaleToSuperView;

/**
 生成带颜色的二维码

 @param data 传入要生成二维码的数据
 @param backgroundColor 二维码背景颜色
 @param qrCodeColor 二维码颜色
 @return 带颜色的二维码
 */
+ (UIImage *)generateColorQRCodeWithData:(NSString *)data backgroundColor:(UIColor *)backgroundColor qrCodeColor:(UIColor *)qrCodeColor;

/**
 生成带颜色、带 logo 的二维码

 @param data 传入要生成二维码的数据
 @param logoImageName logo 名
 @param logoScaleToSuperView 相对于父试图的宽高比率（0 ～ 0.5）
 @param backgroundColor 二维码背景颜色
 @param qrCodeColor 二维码颜色
 @return 带颜色、带 logo 的二维码
 */
+ (UIImage *)generateLogoAndColorQRCodeWithData:(NSString *)data logoImageName:(NSString *)logoImageName logoScaleToSuperView:(CGFloat)logoScaleToSuperView backgroundColor:(UIColor *)backgroundColor qrCodeColor:(UIColor *)qrCodeColor;
@end
