//
//  ZSXSlideCodeView.m
//  ZSXSlideCode
//
//  Created by yh-zsx on 2018/5/17.
//  Copyright © 2018年 yh-zsx. All rights reserved.
//

#import "ZSXSlideCodeView.h"
#import "DWSlideCaptchaView.h"
#import "UIImage+DWImageUtils.h"
#import "DWMacro.h"

@implementation ZSXSlideCodeView {
    DWDefaultSlideCaptchaView * _cap;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (!_imageBase64.length) {
        _imageBase64 = kImage_image;
    }
    UIImage *decodedImage = nil;
    if (_imageBase64.length) {
        NSData *decodedImageData = [[NSData alloc]initWithBase64EncodedString:_imageBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
        decodedImage = [UIImage imageWithData:decodedImageData];
    }
    _cap = [[DWDefaultSlideCaptchaView alloc] initWithFrame:rect image:decodedImage slider:nil];
    __weak typeof(self) selfWeak = self;
    _cap.indentifyCompletion = ^(BOOL success) {
        //回调验证结果
        !selfWeak.onResult?:selfWeak.onResult(@{@"result":@(success)});
    };
    [self addSubview:_cap];
    
    if (!_minimumTrackTintColor.length) {
        _minimumTrackTintColor = [NSString stringWithFormat:@"#E7E7E7"];
    }
    if (!_maximumTrackTintColor) {
        _maximumTrackTintColor = [NSString stringWithFormat:@"#E7E7E7"];
    }
    if (!_buttonImageBase64) {
        _buttonImageBase64 = kImage_Group;
    }
    _cap.slider.minimumTrackTintColor = [_cap colorWithHexString:_minimumTrackTintColor];
    _cap.slider.maximumTrackTintColor = [_cap colorWithHexString:_maximumTrackTintColor];
    //按钮图片
    NSData *decodedImageData = [[NSData alloc]initWithBase64EncodedString:kImage_Group options:NSDataBase64DecodingIgnoreUnknownCharacters];
    [_cap.slider setThumbImage:[UIImage imageWithData:decodedImageData] forState:0];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
