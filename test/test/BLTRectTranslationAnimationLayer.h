//
//  BLTRectTranslationAnimationLayer.h
//  test
//
//  Created by 尹星 on 2020/12/8.
//  Copyright © 2020 尹星. All rights reserved.
//

/**
 该动画layer，默认的path可以理解为左右2个圆+然后在2个圆中间填充颜色
 */

#import <QuartzCore/QuartzCore.h>

@interface BLTRectTranslationAnimationLayer : CAShapeLayer

/// 一个动画执行的最小宽度（必须）
@property (nonatomic, assign) CGFloat oneAnimationMinWidth;

/// 动画执行时间（默认0.3s）
@property (nonatomic, assign) CGFloat animationDuration;

/// 动画默认path的frame
@property (nonatomic, assign) CGRect animationDefaultPathFrame;

/// 开始动画 （需要其他值设置成功后才可调用）
/// @param fromRect 动画开始的位置
/// @param toRect 动画结束的位置
- (void)startAnimationWithFromRect:(CGRect)fromRect toRect:(CGRect)toRect;

@end
