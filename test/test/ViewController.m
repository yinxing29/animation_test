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

@property (nonatomic, assign) BOOL startAdd;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.duration = 0.25;
    
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
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
//    animation.duration = 0.25;
////    animation.fromValue = @(CGRectGetMidX(self.lastBtn.frame));
////    animation.toValue = [self reloadBeziePath];
//    //使视图保留到最新状态
//    animation.removedOnCompletion = NO;
//    animation.fillMode = kCAFillModeForwards;
//    self.shapeLayer.path = [self reloadBeziePath].CGPath;
//    [self.shapeLayer addAnimation:animation forKey:nil];
//    self.shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.selectedBtn.frame cornerRadius:15.0].CGPath;
}

- (void)step:(CADisplayLink *)timer
{
    BOOL isMoveToRight = (CGRectGetMinX(self.selectedBtn.frame) > CGRectGetMinX(self.lastBtn.frame));
    
    NSTimeInterval thisStep = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval stepDuration = thisStep - self.lastStep;

    CGFloat changeTotalWidth = (CGRectGetWidth(self.selectedBtn.frame) + 20.0) / 2.0;
    CGFloat r = (kBtnHeight / 2.0);
    CGFloat changeTotalHeight1 = r / 3.0;
    CGFloat changeTotalHeight2 = r / 3.0 * 2.0;
    
    CGFloat scale = changeTotalWidth / (self.duration / 2.0);
    CGFloat scale1 = changeTotalHeight1 / (self.duration / 2.0);
    CGFloat scale2 = changeTotalHeight2 / (self.duration / 2.0);
    
    CGFloat changeDistance1 = isMoveToRight ? (stepDuration * scale) : -(stepDuration * scale);
    CGFloat startX1 = isMoveToRight ? (CGRectGetMinX(self.lastBtn.frame) + kBtnHeight / 2.0) : (CGRectGetMaxX(self.lastBtn.frame) - kBtnHeight / 2.0);
    CGFloat startX2 = isMoveToRight ? (CGRectGetMaxX(self.lastBtn.frame) - kBtnHeight / 2.0) : (CGRectGetMinX(self.lastBtn.frame) + kBtnHeight / 2.0);
    self.center1 = CGPointMake(startX1 + changeDistance1, self.center1.y);
    self.center2 = CGPointMake(startX2 + changeDistance1, self.center2.y);
    
    NSLog(@" --- === %@ === ---",@(changeDistance1));
    
    BOOL isMoveHalf = NO;
    if (fabs(changeDistance1) >= changeTotalWidth) {
        isMoveHalf = YES;
    }
        
    if (!isMoveHalf) {
        self.r1 = r - scale1 * stepDuration;

        self.r2 = r - scale2 * stepDuration;
    }else {
        if (self.r1 > changeTotalHeight1 && !self.startAdd) {
            self.r1 = changeTotalHeight2 - scale1 * (stepDuration - self.duration / 2.0);
        }else {
            self.startAdd = YES;
            self.r1 = changeTotalHeight1 + scale2 * (stepDuration - self.duration / 2.0);
        }

        self.r2 = changeTotalHeight1 + scale2 * (stepDuration - self.duration / 2.0);
    }
    
//    if (self.r1 > changeTotalHeight2 && !isMoveHalf) {
//        self.r1 = self.r1 - changeTotalHeight1 * scale;
//    }else if (self.r1 > changeTotalHeight1 && isMoveHalf) {
//        self.r1 = self.r1 - changeTotalHeight1 * scale;
//    }else if (isMoveHalf) {
//        self.r1 = self.r1 + changeTotalHeight2 * scale;
//    }
//
//    if (self.r2 > changeTotalHeight1 && !isMoveHalf) {
//        self.r2 = self.r2 - changeTotalHeight2 * scale;
//    }else if (self.r2 < changeTotalHeight1 && isMoveHalf) {
//        self.r2 = self.r2 + changeTotalHeight2 * scale;
//    }
        
    if (stepDuration >= self.duration) {
        if (isMoveToRight) {
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
//    if (isMoveToRight && stepDuration >= self.duration) {
//
//        [self stopAnimation];
//    }else if (!isMoveToRight && self.center2.x < CGRectGetMinX(self.selectedBtn.frame) + kBtnHeight / 2.0) {
//
//        [self stopAnimation];
//    }
    
    self.shapeLayer.path = [self reloadBeziePath].CGPath;
}

- (void)startAnimation
{
    self.lastStep = [[NSDate date] timeIntervalSince1970];
    [self.timer setFireDate:[NSDate distantPast]];
//    self.lastStep = CACurrentMediaTime();
//    self.timer.paused = NO;
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
//        [_timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

@end
