//
//  ZSXSlideCode.m
//  ZSXSlideCode
//
//  Created by yh-zsx on 2018/5/17.
//  Copyright © 2018年 yh-zsx. All rights reserved.
//

#import "ZSXSlideCode.h"
#import "ZSXSlideCodeView.h"

@implementation ZSXSlideCode

RCT_EXPORT_MODULE()

RCT_EXPORT_VIEW_PROPERTY(imageBase64, NSString)
RCT_EXPORT_VIEW_PROPERTY(buttonImageBase64, NSString)
RCT_EXPORT_VIEW_PROPERTY(minimumTrackTintColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(maximumTrackTintColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(reStart, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onResult, RCTBubblingEventBlock)

-(UIView *)view {
    return [[ZSXSlideCodeView alloc]init];
}

@end
