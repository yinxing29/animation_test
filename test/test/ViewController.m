//
//  ViewController.m
//  test
//
//  Created by 尹星 on 2020/5/30.
//  Copyright © 2020 尹星. All rights reserved.
//

#import "ViewController.h"
#import "BLTRectTranslationAnimationLayer.h"

static CGFloat const kBtnHeight = 30.0;

@interface ViewController ()

@property (nonatomic, strong) BLTRectTranslationAnimationLayer *shapeLayer;

@property (nonatomic, strong) UIButton *selectedBtn;

@property (nonatomic, strong) UIButton *lastBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
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
    
    [self.shapeLayer startAnimationWithFromRect:self.lastBtn.frame toRect:self.selectedBtn.frame];
}

- (BLTRectTranslationAnimationLayer *)shapeLayer
{
    if (!_shapeLayer) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat btnWidth = (screenWidth - 40.0) / 4.0 - 20.0;
        _shapeLayer = [BLTRectTranslationAnimationLayer layer];
        _shapeLayer.frame = self.view.bounds;
        _shapeLayer.fillColor = [UIColor orangeColor].CGColor;
        _shapeLayer.animationDuration = 0.3;
        _shapeLayer.oneAnimationMinWidth = (CGRectGetWidth(self.selectedBtn.frame) + 20.0);
        _shapeLayer.animationDefaultPathFrame = CGRectMake(30.0, 300.0, btnWidth, 30.0);
    }
    return _shapeLayer;
}

@end
