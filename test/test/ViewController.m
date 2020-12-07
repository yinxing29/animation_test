//
//  ViewController.m
//  test
//
//  Created by 尹星 on 2020/5/30.
//  Copyright © 2020 尹星. All rights reserved.
//

#import "ViewController.h"

static CGFloat const kBtnHeight = 30.0;

@interface ViewController ()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) UIButton *selectedBtn;

@property (nonatomic, strong) UIButton *lastBtn;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSTimeInterval lastStep;

@property (nonatomic, assign) CGPoint center1;

@property (nonatomic, assign) CGPoint center2;

@property (nonatomic, assign) CGFloat r1;

@property (nonatomic, assign) CGFloat r2;

@property (nonatomic, assign) CGFloat duration;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.duration = 0.3;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat btnWidth = (screenWidth - 40.0) / 4.0 - 20.0;
    for (int i = 0; i< 4; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(30.0 + i * (btnWidth + 20.0), 300.0, btnWidth, kBtnHeight)];
        [button setTitle:[NSString stringWithFormat:@"%@ btn",@(i)] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(buttonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        if (i == 0) {
            button.selected = YES;
            self.selectedBtn = button;
        }
    }
    
    [self.view.layer insertSublayer:self.shapeLayer atIndex:0];
}

- (void)buttonPressed:(UIButton *)sender
{
    if (sender.selected) {
        return;
    }
    self.selectedBtn.selected = !self.selectedBtn.selected;
    self.lastBtn = self.selectedBtn;
    sender.selected = !sender.selected;
    self.selectedBtn = sender;
    
    // 右滑动
    if (CGRectGetMinX(self.lastBtn.frame) < CGRectGetMinX(self.selectedBtn.frame)) {
        self.center1 = CGPointMake(CGRectGetMinX(self.lastBtn.frame) + kBtnHeight / 2.0, CGRectGetMidY(self.lastBtn.frame));
        self.center2 = CGPointMake(CGRectGetMaxX(self.lastBtn.frame) - kBtnHeight / 2.0, CGRectGetMidY(self.lastBtn.frame));
    }else {  // 左滑动
        self.center1 = CGPointMake(CGRectGetMaxX(self.lastBtn.frame) - kBtnHeight / 2.0, CGRectGetMidY(self.lastBtn.frame));
        self.center2 = CGPointMake(CGRectGetMinX(self.lastBtn.frame) + kBtnHeight / 2.0, CGRectGetMidY(self.lastBtn.frame));
    }
    self.r1 = self.r2 = kBtnHeight / 2.0;
    
    
    [self startAnimation];
}

- (void)step:(CADisplayLink *)timer
{
    // 是否向移动
    BOOL is_move_to_right = (CGRectGetMinX(self.selectedBtn.frame) > CGRectGetMinX(self.lastBtn.frame));
    // 当前时间
    NSTimeInterval this_time = [[NSDate date] timeIntervalSince1970];
    // 动画已执行时间
    NSTimeInterval animation_time = this_time - self.lastStep;
    
    /**
     x轴，动画执行路程
     */
    // x轴，总动画执行的宽度
    CGFloat total_animation_width = fabs(CGRectGetMinX(self.selectedBtn.frame) - CGRectGetMinX(self.lastBtn.frame));
    // x轴，一组动画执行的宽度（该宽度内，执行一组动画，一组动画指：在这组动画中变化的节点为一个动画，所有的变化节点组成一组动画)
    CGFloat group_animation_width = (CGRectGetWidth(self.selectedBtn.frame) + 20.0);
    // x轴，一个动画执行的宽度
    CGFloat one_animation_width = group_animation_width / 3.0;
    // 动画个数
    NSInteger animation_number = (NSInteger)(total_animation_width / one_animation_width);
    
    /**
     y轴，动画执行路程
     */
    // y轴，一组动画的高度
    CGFloat y_animation_height = (kBtnHeight / 2.0);
    // y轴，1/3 个组动画高度 （一个动画可能执行的高度是组动画高度的1/3或者2/3）
    CGFloat y_1_3_animation_height = y_animation_height / 3.0;
    // y轴，2/3 个组动画高度
    CGFloat y_2_3_animation_height = y_animation_height / 3.0 * 2.0;

    /**
     动画执行时间
     */
    // 一个动画执行的总时间
    CGFloat one_animation_time = self.duration / animation_number;
    
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
    CGFloat x_animation_distanch = is_move_to_right ? (animation_time * velocity_x) : -(animation_time * velocity_x);
    // x轴，开始的坐标
    CGFloat startX1 = is_move_to_right ? (CGRectGetMinX(self.lastBtn.frame) + kBtnHeight / 2.0) : (CGRectGetMaxX(self.lastBtn.frame) - kBtnHeight / 2.0);
    CGFloat startX2 = is_move_to_right ? (CGRectGetMaxX(self.lastBtn.frame) - kBtnHeight / 2.0) : (CGRectGetMinX(self.lastBtn.frame) + kBtnHeight / 2.0);
    // x轴，变化后的坐标
    self.center1 = CGPointMake(startX1 + x_animation_distanch, self.center1.y);
    self.center2 = CGPointMake(startX2 + x_animation_distanch, self.center2.y);
    
    // x轴，获取当前执行的第几个动画（下标从0开始）
    NSInteger animation_index = (NSInteger)(fabs(x_animation_distanch) / one_animation_width);
    // 每执行一个动画，将时间从0开始重新计算
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
    
    // 动画时间大于等于动画执行时长，结束动画
    if (animation_time >= self.duration) {
        if (is_move_to_right) {
            self.r1 = self.r2 = kBtnHeight / 2.0;
            self.center1 = CGPointMake(CGRectGetMinX(self.selectedBtn.frame) + kBtnHeight / 2.0, self.center1.y);
            self.center2 = CGPointMake(CGRectGetMaxX(self.selectedBtn.frame) - kBtnHeight / 2.0, self.center2.y);
        }else {
            self.r1 = self.r2 = kBtnHeight / 2.0;
            self.center1 = CGPointMake(CGRectGetMaxX(self.selectedBtn.frame) - kBtnHeight / 2.0, self.center1.y);
            self.center2 = CGPointMake(CGRectGetMinX(self.selectedBtn.frame) + kBtnHeight / 2.0, self.center2.y);
        }
        [self stopAnimation];
    }
    
    self.shapeLayer.path = [self reloadBeziePath].CGPath;
}

- (void)startAnimation
{
    self.lastStep = [[NSDate date] timeIntervalSince1970];
    [self.timer setFireDate:[NSDate distantPast]];
}

- (void)stopAnimation
{
//    self.timer.paused = YES;
    [self.timer setFireDate:[NSDate distantFuture]];
    [self.timer invalidate];
    self.timer = nil;
}

- (UIBezierPath *)reloadBeziePath
{
    CGFloat r1 = self.r1;
    CGFloat r2 = self.r2;
    
    CGFloat x1 = self.center1.x;
    CGFloat y1 = self.center1.y;
    
    CGFloat x2 = self.center2.x;
    CGFloat y2 = self.center2.y;
    
    CGFloat distance = [self distanceWithPoint1:CGPointMake(x2, y2) point2:CGPointMake(x1, y1)];
    
    CGFloat sinDegree = (x2 - x1) / distance;
    CGFloat cosDegree = (y2 - y1) / distance;
    CGPoint pointA = CGPointMake(x1 - r1 * cosDegree, y1 + r1 * sinDegree);
    CGPoint pointB = CGPointMake(x1 + r1 * cosDegree, y1 - r1 * sinDegree);
    CGPoint pointC = CGPointMake(x2 + r2 * cosDegree, y2 - r2 * sinDegree);
    CGPoint pointD = CGPointMake(x2 - r2 * cosDegree, y2 + r2 * sinDegree);
    CGPoint pointP = CGPointMake(pointB.x + (distance / 2.0) * sinDegree, pointB.y + (distance / 2.0) * cosDegree);
    CGPoint pointO = CGPointMake(pointA.x + (distance / 2.0) * sinDegree, pointA.y + (distance / 2.0) * cosDegree);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    [path addArcWithCenter:CGPointMake(x1, y1) radius:r1 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    [path addLineToPoint:pointB];
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    [path addArcWithCenter:CGPointMake(x2, y2) radius:r2 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    [path addLineToPoint:pointD];
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
}

- (CGFloat)distanceWithPoint1:(CGPoint)point1 point2:(CGPoint)point2
{
    CGFloat offsetX = point1.x - point2.x;
    CGFloat offsetY = point1.y - point2.y;
    return sqrt(offsetX * offsetX + offsetY * offsetY);
}

- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat btnWidth = (screenWidth - 40.0) / 4.0 - 20.0;
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = self.view.bounds;
        _shapeLayer.fillColor = [UIColor orangeColor].CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(30.0, 300.0, btnWidth, 30.0) cornerRadius:15.0];
        _shapeLayer.path = path.CGPath;
    }
    return _shapeLayer;
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 60.0 target:self selector:@selector(step:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

@end
