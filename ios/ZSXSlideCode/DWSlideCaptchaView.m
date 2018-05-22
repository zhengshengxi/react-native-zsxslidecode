//
//  DWSlideCaptchaView.m
//  code
//
//  Created by Wicky on 2017/4/12.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWSlideCaptchaView.h"
#import "UIImage+DWImageUtils.h"
#import "UIBezierPath+DWPathUtils.h"
#import "DWMacro.h"

#define SafeConfiguration if (!self.configurating) return;

@interface DWSlideCaptchaView ()<CAAnimationDelegate>

///滑块尺寸
@property (nonatomic ,assign) CGSize thumbSize;

///目标验证点
@property (nonatomic ,assign) CGPoint targetPoint;

///有效验证范围
@property (nonatomic ,assign) CGSize validSize;

///是否需要重新设置验证点
@property (nonatomic ,assign) BOOL resetTargetPoint;

///当前点
@property (nonatomic ,assign) CGPoint currentPoint;

@end

@implementation DWSlideCaptchaView
@synthesize thumbSize = _thumbSize;
@synthesize thumbShape = _thumbShape;
@synthesize tolerance = _tolerance;
@synthesize positionLayer = _positionLayer;
@synthesize thumbLayer = _thumbLayer;
-(instancetype)initWithFrame:(CGRect)frame {
//    NSAssert((frame.size.width >= 100 && frame.size.height >= 40), @"To get a better experience,you may set the width more than 100 and height more than 50.");
    if (self = [super initWithFrame:frame]) {
        _useRandomValue = YES;
        _targetValue = DWSlideCaptchaUndefineValue;
        _thumbCenterY = DWSlideCaptchaUndefineValue;
        _tolerance = DWSlideCaptchaUndefineValue;
        _thumbSize = puzzlePath().bounds.size;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame bgImage:(UIImage *)bgImage {
    if (self = [self initWithFrame:frame]) {
        [self beginConfiguration];
        self.bgImage = bgImage;
        [self commitConfiguration];
    }
    return self;
}

-(void)beginConfiguration {
    _configurating = YES;
    self.resetTargetPoint = YES;
}

-(void)commitConfiguration {
    if (!self.configurating) {
        return;
    }
    _configurating = NO;
    self.layer.contents = (id)self.bgImage.CGImage;
    [self handlePositionLayer];
    [self handleThumbLayer];
//    [self hideThumbWithAnimated:NO];
    self.positionImgV.hidden = NO;
}

-(void)reset {
    _successed = NO;
    [self beginConfiguration];
    [self commitConfiguration];
}

-(void)indentifyWithAnimated:(BOOL)animated result:(void(^)(BOOL success))result {
    BOOL isSuccess = fabs(self.targetPoint.x - self.currentPoint.x) < self.tolerance;
    isSuccess &= fabs(self.targetPoint.y - self.currentPoint.y) < self.tolerance;
    _successed = isSuccess;
    _indentified = YES;
    if (isSuccess) {
        if (animated) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(dw_CaptchaView:animationWillStartWithSuccess:)]) {///动画开始回调
                [self.delegate dw_CaptchaView:self animationWillStartWithSuccess:YES];
            }
            if (!self.successAnimation) {///未指定动画使用默认动画
                [self.layer addAnimation:defaultSuccessAnimaiton(self) forKey:@"successAnimation"];
                [self hideThumbWithAnimated:NO];
                DWLayerTransactionWithAnimation(NO, ^(){
                    self.positionLayer.opacity = 0;
                    self.positionImgV.hidden = YES;
                });
            } else {///使用指定动画
                [self.thumbLayer addAnimation:self.successAnimation forKey:@"successAnimation"];
            }
        }
        if (result) result(YES);
    } else {
        if (animated) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(dw_CaptchaView:animationWillStartWithSuccess:)]) {///动画开始回调
                [self.delegate dw_CaptchaView:self animationWillStartWithSuccess:YES];
            }
            if (!self.failAnimation) {///未指定动画则使用默认动画
                [self.thumbLayer addAnimation:defaultFailAnimation(self) forKey:@"failAnimation"];
            } else {///使用指定动画
                [self.thumbLayer addAnimation:self.failAnimation forKey:@"failAnimation"];
            }
        }
        if (result) result(NO);
    }
}

-(void)moveToPoint:(CGPoint)point animated:(BOOL)animated {
    if (self.successed) {
        return;
    }
    _indentified = NO;
    point = fixPointWithLimit(point, self.validSize, self.thumbSize);
    self.currentPoint = point;
    if (self.thumbLayer.opacity != 1) {
        [self showThumbWithAnimated:YES];
    }
    DWLayerTransactionWithAnimation(animated, ^(){
        self.thumbLayer.position = transformLocation2Center(point, self.thumbSize);
    });
}

-(void)setValue:(CGFloat)value animated:(BOOL)animated {
    CGFloat x = value * self.validSize.width + self.thumbSize.width / 2;
    CGFloat y = self.targetPoint.y + self.thumbSize.height / 2;
    [self moveToPoint:CGPointMake(x, y) animated:animated];
}

-(void)showThumbWithAnimated:(BOOL)animated {
    DWLayerTransactionWithAnimation(animated,^(){
        self.thumbLayer.opacity = 1;
    });
}

-(void)hideThumbWithAnimated:(BOOL)animated {
    DWLayerTransactionWithAnimation(animated, ^(){
        self.thumbLayer.opacity = 0;
//        self.thumbLayer.opacity = 1;//滑块改为始终显示
    });
}

#pragma mark --- tool Method ---
-(void)handleThumbLayer {
    UIImage * thumbImage = [self.bgImage dw_SubImageWithRect:self.positionLayer.frame];
    thumbImage = [thumbImage dw_ClipImageWithPath:self.thumbShape mode:(DWContentModeScaleToFill)];
    self.thumbLayer.contents = (id)thumbImage.CGImage;
    self.thumbLayer.frame = self.positionLayer.frame;
    //阴影
    self.thumbLayer.shadowColor = [UIColor blackColor].CGColor;
    self.thumbLayer.shadowOffset = CGSizeMake(0, 0);
    self.thumbLayer.shadowOpacity = 1.0f;
    self.thumbLayer.shadowRadius = 3;
    
    [self setValue:0 animated:NO];
    if (!self.thumbLayer.superlayer) {
        [self.layer addSublayer:self.thumbLayer];
    }
}

-(void)handlePositionLayer {
    UIBezierPath * path = [self.thumbShape copy];
    self.positionLayer.fillColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:0.6f].CGColor;
    self.positionLayer.path = path.CGPath;
    self.positionLayer.lineJoin = kCALineJoinRound;
//    self.positionLayer.lineWidth = 2;
//    self.positionLayer.strokeColor = [UIColor colorWithWhite:0 alpha:0.5f].CGColor;
    
    self.positionLayer.shadowColor = [UIColor blackColor].CGColor;
    self.positionLayer.shadowOffset = CGSizeMake(0, 0);
    self.positionLayer.shadowRadius = 2;
    self.positionLayer.shadowOpacity = 0.9;
    
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGPathRef roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.positionLayer.frame cornerRadius:0.0f].CGPath;
//    CGContextAddPath(context, roundedRect);
//
//    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0,0), 7.0f, [UIColor colorWithWhite:0 alpha:1].CGColor);
//    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0 alpha:1].CGColor);
//    CGContextStrokePath(context);
    
    
    self.positionLayer.frame = CGRectMake(self.targetPoint.x, self.targetPoint.y, (int)path.bounds.size.width, (int)path.bounds.size.height);
    if (!self.positionLayer.superlayer) {
//        [self.layer addSublayer:self.positionLayer];
    }
    
    self.positionImgV.frame = self.positionLayer.frame;
    NSData *shadowImageData = [[NSData alloc]initWithBase64EncodedString:kImage_Shadow options:NSDataBase64DecodingIgnoreUnknownCharacters];
    self.positionImgV.image = [UIImage imageWithData:shadowImageData];
    [self insertSubview:self.positionImgV atIndex:0];
    
    
    /*
     CGRect rect1 = _cap.captchaView.positionLayer.bounds;
     CGSize radii = CGSizeMake(0, 0);
     UIRectCorner corners = UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft;
     //create path
     UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect1 byRoundingCorners:corners cornerRadii:radii];
     //create shape layer
     CAShapeLayer *shapeLayer = [CAShapeLayer layer];
     shapeLayer.strokeColor = [UIColor redColor].CGColor;
     shapeLayer.fillColor = [UIColor clearColor].CGColor;
     shapeLayer.lineWidth = 2;
     shapeLayer.lineJoin = kCALineJoinRound;
     shapeLayer.lineCap = kCALineCapRound;
     shapeLayer.path = path.CGPath;
     shapeLayer.lineDashPattern = @[@3, @5];//画虚线
     [_cap.captchaView.positionLayer addSublayer:shapeLayer];
     */
}

#pragma mark --- animation delegate ---
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.isSuccessed) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(dw_CaptchaView:animationCompletionWithSuccess:)]) {
            [self.delegate dw_CaptchaView:self animationCompletionWithSuccess:YES];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(dw_CaptchaView:animationCompletionWithSuccess:)]) {
            [self.delegate dw_CaptchaView:self animationCompletionWithSuccess:NO];
        }
    }
}

#pragma mark --- 内联方法 ---
///默认滑块形状
static inline UIBezierPath * puzzlePath (){
    UIBezierPath * path = [UIBezierPath bezierPathWithPathMaker:^(DWPathMaker *maker) {
        maker.MoveTo(0, 8).
        AddLineTo(12, 8).AddArcWithPoint(12, 8, 20, 8, 5, YES, YES).AddLineTo(32, 8).
        AddLineTo(32, 20).AddArcWithPoint(32, 20, 32, 28, 5, YES, YES).AddLineTo(32, 40).
        AddLineTo(20, 40).AddArcWithPoint(20, 40, 12, 40, 5, NO, YES).AddLineTo(0, 40).
        AddLineTo(0, 28).AddArcWithPoint(0, 28, 0, 20, 5, NO, YES).ClosePath();
    }];
    return path;
}

///指定尺寸内的随机点
static inline CGPoint randomPointInSize(CGSize size) {
    CGPoint point = CGPointZero;
    point.x = randomValueInLength((int)size.width);
    point.y = randomValueInLength((int)size.height);
    return point;
}

///指定范围内的随机值
static inline int randomValueInLength(int length) {
    return arc4random() % ((int)(length + 1));
}

///修正centerY值合适的值
static inline CGFloat fixCenterYWithSize(CGSize thumbSize,CGSize validSize,CGFloat centerY) {
    CGFloat y = centerY - thumbSize.height / 2;
    return fixValueWithLimit(y, validSize.height);
}

///将值修正至指定范围
static inline CGFloat fixValueWithLimit(CGFloat value,CGFloat limitLength) {
    return value < 0 ? 0 : (value > limitLength ? limitLength : value);
}

///将点修正值有效范围内
static inline CGPoint fixPointWithLimit(CGPoint point,CGSize validSize,CGSize thumbSize) {
    CGFloat x = point.x - thumbSize.width / 2;
    CGFloat y = point.y - thumbSize.height / 2;
    return CGPointMake(fixValueWithLimit(x, validSize.width), fixValueWithLimit(y, validSize.height));
}

///将验证位置转换为layer中心点
static inline CGPoint transformLocation2Center(CGPoint origin,CGSize thumbSize) {
    return CGPointMake(origin.x + thumbSize.width / 2, origin.y + thumbSize.height / 2);
}

///Point转value
static inline NSValue * valueOfPoint(CGPoint point) {
    return [NSValue valueWithCGPoint:point];
}

///默认成功动画
static inline CAAnimation * defaultSuccessAnimaiton(id<CAAnimationDelegate> delegate) {
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.2;
    animation.autoreverses = YES;
    animation.fromValue = @1;
    animation.toValue = @0;
    animation.removedOnCompletion = YES;
    animation.delegate = delegate;
    return animation;
}

///默认失败动画
static inline CAAnimation * defaultFailAnimation(id<CAAnimationDelegate> delegate) {
    DWSlideCaptchaView * captcha = (DWSlideCaptchaView *)delegate;
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGFloat a = 3;
    CGPoint Cp = captcha.thumbLayer.position;
    CGPoint Lp = CGPointMake(Cp.x - a, Cp.y);
    CGPoint Rp = CGPointMake(Cp.x + a, Cp.y);
    animation.values = @[valueOfPoint(Cp),valueOfPoint(Lp),valueOfPoint(Rp),valueOfPoint(Cp)];
    animation.repeatCount = 2;
    animation.removedOnCompletion = YES;
    animation.duration = 0.2;
    animation.delegate = captcha;
    return animation;
}

#pragma mark --- setter/getter ---
-(CAShapeLayer *)positionLayer {
    if (!_positionLayer) {
        _positionLayer = [CAShapeLayer layer];
    }
    return _positionLayer;
}

-(CAShapeLayer *)thumbLayer {
    if (!_thumbLayer) {
        _thumbLayer = [CAShapeLayer layer];
    }
    return _thumbLayer;
}

-(UIImageView *)positionImgV {
    if (!_positionImgV) {
        _positionImgV = [UIImageView new];
    }
    return _positionImgV;
}

-(void)setThumbShape:(UIBezierPath *)thumbShape {
    SafeConfiguration
    CGSize size = thumbShape.bounds.size;
    if (!(size.width >= 40 && size.height >= 40)) {
        NSAssert(NO, @"To get a better experience,the width and height of thumbShape both should be more than 40.");
        return;
    }
    
    _thumbShape = thumbShape;
    _thumbSize = size;
}

-(UIBezierPath *)thumbShape {
    if (!_thumbShape) {
        return puzzlePath();
    }
    return _thumbShape;
}

-(void)setTargetValue:(CGFloat)targetValue {
    SafeConfiguration
    _targetValue = fixValueWithLimit(targetValue, 1);
}

-(void)setThumbCenterY:(CGFloat)thumbCenterY {
    SafeConfiguration
    _thumbCenterY = thumbCenterY;
}

-(void)setUseRandomValue:(BOOL)useRandomValue {
    SafeConfiguration
    _useRandomValue = useRandomValue;
}

-(void)setTolerance:(CGFloat)tolerance {
    SafeConfiguration
    _tolerance = tolerance;
}

-(CGFloat)tolerance {
    if (_tolerance < 0) {
        return 3;
    }
    return _tolerance;
}

-(void)setSuccessAnimation:(CAAnimation *)successAnimation {
    SafeConfiguration
    _successAnimation = successAnimation;
    _successAnimation.delegate = self;
}

-(void)setFailAnimation:(CAAnimation *)failAnimation {
    SafeConfiguration
    _failAnimation = failAnimation;
    _failAnimation.delegate = self;
}

-(void)setBgImage:(UIImage *)bgImage {
    SafeConfiguration
    if (bgImage) {
        _bgImage = [bgImage dw_RescaleImageToSize:self.frame.size];
    } else {
        _bgImage = nil;
    }
}

-(void)setThumbSize:(CGSize)thumbSize {
    SafeConfiguration
    if (!CGSizeEqualToSize(_thumbSize, thumbSize)) {
        _thumbSize = thumbSize;
    }
}

-(CGPoint)targetPoint {
    if (!self.resetTargetPoint) {
        return _targetPoint;
    }
    self.resetTargetPoint = NO;
    if (self.useRandomValue) {
        _targetPoint = randomPointInSize(self.validSize);
        return _targetPoint;
    }
    CGFloat x = (self.targetValue != DWSlideCaptchaUndefineValue) ? self.targetValue : randomValueInLength((int)self.validSize.width);
    CGFloat y = (self.thumbCenterY != DWSlideCaptchaUndefineValue) ? fixCenterYWithSize(self.thumbSize, self.validSize, self.thumbCenterY) : randomValueInLength((int)self.validSize.height);
    _targetPoint = CGPointMake(x, y);
    return _targetPoint;
}

-(CGSize)validSize {
    return CGSizeMake(self.bounds.size.width - self.thumbSize.width, self.bounds.size.height - self.thumbSize.height);
}

@end

@implementation DWDefaultSlideCaptchaView

-(instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image slider:(UISlider *)slider {
    if (self = [super initWithFrame:frame]) {
        if (!slider) {
            slider = [[UISlider alloc] initWithFrame:CGRectMake(0, frame.size.height - 32, frame.size.width, 32)];
        }
        _slider = slider;
        _captchaView = [[DWSlideCaptchaView alloc] initWithFrame:CGRectMakeWithPointAndSize(CGPointZero, CGSizeMake(frame.size.width, frame.size.height - slider.frame.size.height - 12)) bgImage:image];
        _captchaView.delegate = self;
        [self addSubview:_slider];
        [self addSubview:_captchaView];
        
        ///为了获取slider结束拖动使用KVO
        [self addObserver:self forKeyPath:@"slider.tracking" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
        
        ///为了改变验证视图的时使用通知观察slider的数值
        [self.slider addTarget:self action:@selector(sliderValueChange) forControlEvents:(UIControlEventValueChanged)];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"slider.tracking"]) {
        if ([change[@"new"] integerValue] == 0 && [change[@"old"] integerValue] == 1) {///silder结束拖动，开始验证
            if (!self.captchaView.isSuccessed) {
                [self.captchaView indentifyWithAnimated:YES result:^(BOOL success) {
                    if (self.indentifyCompletion) {
                        self.indentifyCompletion(success);
                    }
                }];
            }
        } else if ([change[@"new"] integerValue] == 0 && [change[@"old"] integerValue] == 0) {///slider归位
            if (self.slider.value) {
                self.slider.value = 0;
            }
        }
    }
}

-(void)sliderValueChange {
    if (!self.captchaView.isIndentified) {
        [self.captchaView setValue:self.slider.value animated:NO];
    }
}

-(void)dw_CaptchaView:(DWSlideCaptchaView *)captchaView animationCompletionWithSuccess:(BOOL)success {
    if (!success) {
        [self.captchaView setValue:0 animated:YES];
//        [self.captchaView hideThumbWithAnimated:YES];
    }
}

-(void)dealloc {
    [self removeObserver:self forKeyPath:@"slider.tracking"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // 判断前缀
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    //R、G、B
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

@end
