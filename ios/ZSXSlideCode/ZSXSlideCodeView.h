//
//  ZSXSlideCodeView.h
//  ZSXSlideCode
//
//  Created by yh-zsx on 2018/5/17.
//  Copyright © 2018年 yh-zsx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>

@interface ZSXSlideCodeView : UIView

@property(nonatomic,copy)NSString *imageBase64;
@property(nonatomic,copy)NSString *buttonImageBase64;
@property(nonatomic,copy)NSString *minimumTrackTintColor;
@property(nonatomic,copy)NSString *maximumTrackTintColor;
@property(nonatomic,assign)BOOL reStart;
/**
 消息回调 将检测过程的状态消息回调给RN
 */
@property (nonatomic, copy) RCTBubblingEventBlock onResult;

@end
