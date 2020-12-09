//
//  BLTRectTranslationAnimationLayer.m
//  test
//
//  Created by 尹星 on 2020/12/8.
//  Copyright © 2020 尹星. All rights reserved.
//

#import "BLTRectTranslationAnimationLayer.h"
#import <UIKit/UIKit.h>

@interface BLTRectTranslationAnimationLayer ()

@property (nonatomic, strong) CADisplayLink *displayLink;

/// 上一步动画的时间
@property (nonatomic, assign) NSTimeInterval animationBeginTime;

/// path动画开始的位置
@property (nonatomic, assign) CGRect fromRect;

/// path动画最终的位置
@property (nonatomic, assign) CGRect toRect;

/// 圆1的中心点
@property (nonatomic, assign) CGPoint center1;

/// 圆2的中心点
@property (nonatomic, assign) CGPoint center2;

/// 圆1的半径
@property (nonatomic, assign) CGFloat r1;

/// 圆2的半径
@property (nonatomic, assign) CGFloat r2;

/// control point P
@property (nonatomic, assign) CGPoint pointP;

/// control point O
@property (nonatomic, assign) CGPoint pointO;

/// 默认path的高度（静止时，path的高度）
@property (nonatomic, assign) CGFloat defaultHeight;

@end

@implementation BLTRectTranslationAnimationLayer

+ (instancetype)layer
{
    BLTRectTranslationAnimationLayer *layer = [[BLTRectTranslationAnimationLayer alloc] init];
    return layer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self p_initData];
    }
    return self;
}

#pragma mark - init
- (void)p_initData
{
    self.animationDuration = 0.3;
}
#pragma mark - ------------------------------ init End ------------------------------

#pragma mark - 公用方法
- (void)startAnimationWithFromRect:(CGRect)fromRect toRect:(CGRect)toRect
{
    NSAssert(self.oneAnimationMinWidth != 0, @"请设置 oneAnimationMinWidth");
    NSAssert(self.path, @"请设置动画开始前的 path");
    NSAssert(self.animationDuration != 0.0, @"请设置 动画执行时间");
    
    self.defaultHeight = [UIBezierPath bezierPathWithCGPath:self.path].bounds.size.height;
    
    self.fromRect = fromRect;
    self.toRect = toRect;
    // 右滑动
    if (CGRectGetMinX(self.fromRect) < CGRectGetMinX(self.toRect)) {
        self.center1 = CGPointMake(CGRectGetMinX(self.fromRect) + self.defaultHeight / 2.0, CGRectGetMidY(self.fromRect));
        self.center2 = CGPointMake(CGRectGetMaxX(self.fromRect) - self.defaultHeight / 2.0, CGRectGetMidY(self.fromRect));
    }else {  // 左滑动
        self.center1 = CGPointMake(CGRectGetMaxX(self.fromRect) - self.defaultHeight / 2.0, CGRectGetMidY(self.fromRect));
        self.center2 = CGPointMake(CGRectGetMinX(self.fromRect) + self.defaultHeight / 2.0, CGRectGetMidY(self.fromRect));
    }
    self.pointP = CGPointMake(CGRectGetMidX(self.fromRect), CGRectGetMinY(self.fromRect));
    self.pointO = CGPointMake(CGRectGetMidX(self.fromRect), CGRectGetMaxY(self.fromRect));
    self.r1 = self.r2 = self.defaultHeight / 2.0;
    
    [self startAnimation];
}
#pragma mark - ------------------------------ 公用方法 End ------------------------------

#pragma mark - CADisplayLink
- (void)startAnimation
{
    self.animationBeginTime = CACurrentMediaTime();
    self.displayLink.paused = NO;
}

- (void)stopAnimation
{
    self.displayLink.paused = YES;
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)step:(CADisplayLink *)sender
{
    // 当前时间
    NSTimeInterval this_time = CACurrentMediaTime();
    // 动画已执行时间
    NSTimeInterval animation_time = this_time - self.animationBeginTime;
    
    [self p_animationCircleCenterAndRadiusWithAnimationTime:animation_time];
    [self p_animationControlPointWithAnimationTime:animation_time];
    
    // 是否向移动
    BOOL is_move_to_right = (CGRectGetMinX(self.toRect) > CGRectGetMinX(self.fromRect));
    // 动画时间大于等于动画执行时长，结束动画
    if (animation_time >= self.animationDuration) {
        if (is_move_to_right) {
            self.r1 = self.r2 = self.defaultHeight / 2.0;
            self.center1 = CGPointMake(CGRectGetMinX(self.toRect) + self.defaultHeight / 2.0, self.center1.y);
            self.center2 = CGPointMake(CGRectGetMaxX(self.toRect) - self.defaultHeight / 2.0, self.center2.y);
        }else {
            self.r1 = self.r2 = self.defaultHeight / 2.0;
            self.center1 = CGPointMake(CGRectGetMaxX(self.toRect) - self.defaultHeight / 2.0, self.center1.y);
            self.center2 = CGPointMake(CGRectGetMinX(self.toRect) + self.defaultHeight / 2.0, self.center2.y);
        }
        self.pointP = CGPointMake(CGRectGetMidX(self.toRect), CGRectGetMinY(self.toRect));
        self.pointO = CGPointMake(CGRectGetMidX(self.toRect), CGRectGetMaxY(self.toRect));
        [self stopAnimation];
    }
    
    self.path = [self reloadBeziePath].CGPath;
}
#pragma mark - ------------------------------ CADisplayLink End ------------------------------

#pragma mark - 动画拆解
/**
 绘制path时，计算左右两个圆的中心点和半径
 在计算时，首先确定x轴变换多宽为一个变化循环（及设置的oneAnimationMinWidth），再通过framRect和toRect确定执行整个动画所需的总宽度，从而计算出一个变换循环所需的时间，然后将这一个变化循环，分成3个步骤：
 第一个1/3的时间内，r1：由 总高度1 -> 2/3总高度，r2：由 总高度1 -> 1/3总高度
 第二个1/3的时间内，r1：由 2/3总高度 -> 1/3总高度，r2：由 1/3总高度 -> 2/3总高度
 第三个1/3的时间内，r1：由 1/3总高度 ->  总高度1，r2：由 2/3总高度 -> 总高度1
 */
- (void)p_animationCircleCenterAndRadiusWithAnimationTime:(CGFloat)animation_time
{
    // 是否向移动
    BOOL is_move_to_right = (CGRectGetMinX(self.toRect) > CGRectGetMinX(self.fromRect));
    /**
     x轴，动画执行路程
     */
    // x轴，总动画执行的宽度
    CGFloat total_animation_width = fabs(CGRectGetMinX(self.toRect) - CGRectGetMinX(self.fromRect));
    // x轴，一个动画执行的宽度
    CGFloat one_animation_width = self.oneAnimationMinWidth / 3.0;
    // 动画个数
    NSInteger animation_number = (NSInteger)(total_animation_width / one_animation_width);
    
    /**
     y轴，动画执行路程
     */
    // y轴，最大变化高度（即两个圆最大的半径）
    CGFloat y_animation_height = (self.defaultHeight / 2.0);
    // y轴，1/3 个最大变化高度 （一个动画可能执行的高度是组动画高度的1/3或者2/3）
    CGFloat y_1_3_animation_height = y_animation_height / 3.0;
    // y轴，2/3 个最大变化高度
    CGFloat y_2_3_animation_height = y_animation_height / 3.0 * 2.0;

    /**
     动画执行时间
     */
    // 一个动画执行的总时间
    CGFloat one_animation_time = self.animationDuration / animation_number;
    
    /**
     动画执行速度
     */
    // x轴，一个动画执行的速度
    CGFloat velocity_x = one_animation_width / one_animation_time;
    // y轴，1/3 个组动画高度，在一个动画执行时间内的速度
    CGFloat velocity_1_3_y = y_1_3_animation_height / one_animation_time;
    // y轴，2/3 个组动画高度，在一个动画执行时间内的速度
    CGFloat velocity_2_3_y = y_2_3_animation_height / one_animation_time;
    
    // x轴，一定时间内执行的距离
    CGFloat x_animation_distance = is_move_to_right ? (animation_time * velocity_x) : -(animation_time * velocity_x);
    // x轴，开始的坐标
    CGFloat startX1 = is_move_to_right ? (CGRectGetMinX(self.fromRect) + self.defaultHeight / 2.0) : (CGRectGetMaxX(self.fromRect) - self.defaultHeight / 2.0);
    CGFloat startX2 = is_move_to_right ? (CGRectGetMaxX(self.fromRect) - self.defaultHeight / 2.0) : (CGRectGetMinX(self.fromRect) + self.defaultHeight / 2.0);
    // x轴，变化后的坐标
    self.center1 = CGPointMake(startX1 + x_animation_distance, self.center1.y);
    self.center2 = CGPointMake(startX2 + x_animation_distance, self.center2.y);
    
    // x轴，获取当前执行的第几个动画（下标从0开始）
    NSInteger animation_index = (NSInteger)(fabs(x_animation_distance) / one_animation_width);
    // y轴，每执行一个动画，将时间从0开始重新计算
    CGFloat perUnitTime = (animation_time - one_animation_time * animation_index);
    /**
     一组动画分为3个动画，
     第一个1/3的时间，r1：由 总高度1 -> 2/3总高度，r2：由 总高度1 -> 1/3总高度
     第二个1/3的时间，r1：由 2/3总高度 -> 1/3总高度，r2：由 1/3总高度 -> 2/3总高度
     第三个1/3的时间，r1：由 1/3总高度 ->  总高度1，r2：由 2/3总高度 -> 总高度1
     */
    if (animation_index % 3 == 0) {
        self.r1 = y_animation_height - velocity_1_3_y * perUnitTime;
        self.r2 = y_animation_height - velocity_2_3_y * perUnitTime;
    }else if (animation_index % 3 == 1) {
        self.r1 = y_2_3_animation_height - velocity_1_3_y * perUnitTime;
        self.r2 = y_1_3_animation_height + velocity_1_3_y * perUnitTime;
    }else {
        self.r1 = y_1_3_animation_height + velocity_2_3_y * perUnitTime;
        self.r2 = y_2_3_animation_height + velocity_1_3_y * perUnitTime;
    }
}

/**
 绘制path时，计算上面曲线和下面曲线的控制点随时间的变化
 在计算时，首先确定x轴变换多宽为一个变化循环（及设置的oneAnimationMinWidth），再通过framRect和toRect确定执行整个动画所需的总宽度，从而计算出一个变换循环所需的时间，然后将这一个变化循环，分成2个步骤：
 首先：P点和O点，x轴坐标随着时间一直变换匀速变化
  y轴：
 第一个1/2的时间，P点 + 变化高度，O点 - 变化高度，最终让P点，O点在圆中心点y轴的上下1/4半径位置
 第二个1/2的时间，P点 - 变化高度，O点 + 变化高度，最终让P点，O点在圆中心点y轴的上下1半径位置
 */
- (void)p_animationControlPointWithAnimationTime:(CGFloat)animation_time
{
    // 是否向移动
    BOOL is_move_to_right = (CGRectGetMinX(self.toRect) > CGRectGetMinX(self.fromRect));
    /**
     x轴，动画执行路程
     */
    // x轴，总动画执行的宽度
    CGFloat total_animation_width = fabs(CGRectGetMinX(self.toRect) - CGRectGetMinX(self.fromRect));
    /**
     y轴，动画执行路程
     */
    // y轴，最大变化高度（即两个圆最大的半径）
    CGFloat y_animation_height = (self.defaultHeight / 2.0);
    /**
     计算控制点动画
     */
    // x轴，控制点一个动画执行的宽度
    CGFloat control_point_animation_width = self.oneAnimationMinWidth / 2.0;
    // 控制点，y轴，最大变化高度
    CGFloat control_point_y_change_max_height = y_animation_height / 4.0 * 3.0;
    // 控制点，动画个数
    CGFloat control_point_animation_number = (NSInteger)(total_animation_width / control_point_animation_width);
    // 控制点，一个动画执行的时间
    CGFloat control_point_one_animation_time = self.animationDuration / control_point_animation_number;
    // 控制点，x轴，1/2 个组动画宽度，在一个动画执行时间内的速度
    CGFloat control_point_velocity_x = control_point_animation_width / control_point_one_animation_time;
    // 控制点，y轴，最大变化高度一个动画执行的速度
    CGFloat control_point_velocity_y = control_point_y_change_max_height / control_point_one_animation_time;
    // 控制点，x轴，一定时间内执行的距离
    CGFloat control_point_x_animation_distance = animation_time * control_point_velocity_x;
    // 控制点，x轴，获取当前执行的第几个动画（下标从0开始）
    NSInteger control_point_animation_index = (NSInteger)(fabs(control_point_x_animation_distance) / control_point_animation_width);
    // 控制点，y轴，每执行一个动画，将时间从0开始重新计算
    CGFloat control_point_per_unit_time = (animation_time - control_point_one_animation_time * control_point_animation_index);
    // 控制点，一个动画开始时，P点和O点开始的x，y坐标
    CGFloat startPX = CGRectGetMidX(self.fromRect);
    CGFloat startPY = CGRectGetMinY(self.fromRect);
    CGFloat startOY = CGRectGetMaxY(self.fromRect);
    // 控制点，x轴，变化的距离，右移时+，左移时-
    CGFloat control_point_x_change_distance = is_move_to_right ? control_point_x_animation_distance : -control_point_x_animation_distance;
    CGFloat control_point_y_change_distance = control_point_per_unit_time * control_point_velocity_y;
    /**
     一组动画分为2个动画，P点和O点，x轴坐标随着时间一直变换 （最大变化高度control_point_y_change_max_height）
     第一个1/2的时间，y轴，P点 + 变化高度，O点 - 变化高度
     第二个1/2的时间，y轴，和上一个动画正好相反
     */
    if (control_point_animation_index % 2 == 0) {
        self.pointP = CGPointMake(startPX + control_point_x_change_distance, startPY + control_point_y_change_distance);
        self.pointO = CGPointMake(self.pointP.x, startOY - control_point_y_change_distance);
    }else {
        self.pointP = CGPointMake(startPX + control_point_x_change_distance, startPY + control_point_y_change_max_height - control_point_y_change_distance);
        self.pointO = CGPointMake(self.pointP.x, startOY - control_point_y_change_max_height + control_point_y_change_distance);
    }
}
#pragma mark - ------------------------------ 动画拆解 End ------------------------------

#pragma mark - 生成path
- (UIBezierPath *)reloadBeziePath
{
    BOOL is_move_right = self.center1.x < self.center2.x;
    CGPoint pointA = CGPointMake(self.center1.x, self.center1.y + (is_move_right ? self.r1 : -self.r1));
    CGPoint pointB = CGPointMake(self.center1.x, self.center1.y - (is_move_right ? self.r1 : -self.r1));
    CGPoint pointC = CGPointMake(self.center2.x, self.center2.y - (is_move_right ? self.r2 : -self.r2));
    CGPoint pointD = CGPointMake(self.center2.x, self.center2.y + (is_move_right ? self.r2 : -self.r2));

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    [path addArcWithCenter:self.center1 radius:self.r1 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    [path addLineToPoint:pointB];
    [path addQuadCurveToPoint:pointC controlPoint:is_move_right ? self.pointP : self.pointO];
    [path addArcWithCenter:self.center2 radius:self.r2 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    [path addLineToPoint:pointD];
    [path addQuadCurveToPoint:pointA controlPoint:is_move_right ? self.pointO : self.pointP];
    
    return path;
}
#pragma mark - ------------------------------ 生成path End ------------------------------

#pragma mark - setter
- (void)setAnimationDefaultPathFrame:(CGRect)animationDefaultPathFrame
{
    _animationDefaultPathFrame = animationDefaultPathFrame;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:animationDefaultPathFrame cornerRadius:CGRectGetHeight(animationDefaultPathFrame) / 2.0];
    self.path = path.CGPath;
}
#pragma mark - ------------------------------ setter End ------------------------------

#pragma mark - 懒加载
- (CADisplayLink *)displayLink
{
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(step:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink.paused = YES;
    }
    return _displayLink;
}
#pragma mark - ------------------------------ 懒加载 End ------------------------------

@end
