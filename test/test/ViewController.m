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

@property (nonatomic, assign) CGPoint pointP;

@property (nonatomic, assign) CGPoint pointO;

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
    self.pointP = CGPointMake(CGRectGetMidX(self.lastBtn.frame), CGRectGetMinY(self.lastBtn.frame));
    self.pointO = CGPointMake(CGRectGetMidX(self.lastBtn.frame), CGRectGetMaxY(self.lastBtn.frame));
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
    // y轴，最大变化高度（即两个圆最大的半径）
    CGFloat y_animation_height = (kBtnHeight / 2.0);
    // y轴，1/3 个最大变化高度 （一个动画可能执行的高度是组动画高度的1/3或者2/3）
    CGFloat y_1_3_animation_height = y_animation_height / 3.0;
    // y轴，2/3 个最大变化高度
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
    CGFloat x_animation_distance = is_move_to_right ? (animation_time * velocity_x) : -(animation_time * velocity_x);
    // x轴，开始的坐标
    CGFloat startX1 = is_move_to_right ? (CGRectGetMinX(self.lastBtn.frame) + kBtnHeight / 2.0) : (CGRectGetMaxX(self.lastBtn.frame) - kBtnHeight / 2.0);
    CGFloat startX2 = is_move_to_right ? (CGRectGetMaxX(self.lastBtn.frame) - kBtnHeight / 2.0) : (CGRectGetMinX(self.lastBtn.frame) + kBtnHeight / 2.0);
    // x轴，变化后的坐标
    self.center1 = CGPointMake(startX1 + x_animation_distance, self.center1.y);
    self.center2 = CGPointMake(startX2 + x_animation_distance, self.center2.y);
    
    /**
     计算控制点动画
     */
    // x轴，控制点一个动画执行的宽度
    CGFloat control_point_animation_width = group_animation_width / 2.0;
    // 控制点，y轴，最大变化高度
    CGFloat control_point_y_change_max_height = y_animation_height / 4.0 * 3.0;
    // 控制点，动画个数
    CGFloat control_point_animation_number = (NSInteger)(total_animation_width / control_point_animation_width);
    // 控制点，一个动画执行的时间
    CGFloat control_point_one_animation_time = self.duration / control_point_animation_number;
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
    CGFloat startPX = CGRectGetMidX(self.lastBtn.frame);
    CGFloat startPY = CGRectGetMinY(self.lastBtn.frame);
    CGFloat startOY = CGRectGetMaxY(self.lastBtn.frame);
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
        self.pointP = CGPointMake(CGRectGetMidX(self.selectedBtn.frame), CGRectGetMinY(self.selectedBtn.frame));
        self.pointO = CGPointMake(CGRectGetMidX(self.selectedBtn.frame), CGRectGetMaxY(self.selectedBtn.frame));
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
