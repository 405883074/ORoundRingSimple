//
//  ZPGoalBar.m
//  ORoundRingSimple
//
//  Created by WangZhipeng on 15/12/9.
//  Copyright © 2015年 WangZhipeng. All rights reserved.
//

#import "ZPGoalBar.h"

#define toRadians(x) ((x)*M_PI / 180.0)
#define toDegrees(x) ((x)*180.0 / M_PI)

#define divideNum 36

@interface ZPGoalBar ()

@property (nonatomic, strong) UIImage *bg;
@property (nonatomic, strong) UIImage *bgPressed;
@property (nonatomic, strong) UIImage *thumb;
@property (nonatomic, strong) UIImage *ridge;

@property (nonatomic, strong) ZPGoalBarPercentLayer *percentLayer;
@property (nonatomic, strong) CALayer *imageLayer;
@property (nonatomic, strong) CALayer *thumbLayer;
@property (nonatomic, strong) CALayer *ridgeLayer;

@property (nonatomic, assign) int finalPercent;
@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, assign) BOOL thumbTouch;
@property (nonatomic, assign) BOOL currentAnimating;

@property (nonatomic, assign) CGFloat lastAngle;
@property (nonatomic, assign) float maxTotal;
@property (nonatomic, assign) CGFloat totalAngle;

@property (nonatomic, assign) float lastValue;

@property (nonatomic, assign) CGRect tappableRect;
@property (nonatomic, assign) BOOL switchModes;

@end

@implementation ZPGoalBar

- (id)init {
    if ((self = [super init])) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }
    return self;
}

-(void)layoutSubviews {
    CGRect frame = self.frame;
    
    if ([_customText length] != 0) {
        [_percentLabel setText:_customText];
    } else if (_thumbLayer.hidden) {
        int percent = _percentLayer.percent * 100;
        [_percentLabel setText:[NSString stringWithFormat:@"%i%%", percent]];
    } else {
        float total = [self totalCalcuation];
        if (_allowSwitching) {
            total += _currentGoal;
        }
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        if (_allowDecimal) {
            [formatter setMinimumFractionDigits:2];
            [formatter setMaximumFractionDigits:2];
        } else {
            [formatter setMinimumFractionDigits:0];
            [formatter setMaximumFractionDigits:0];
        }
        [_percentLabel setText:[formatter stringFromNumber:[NSNumber numberWithFloat:total]]];
    }
    
    CGRect labelFrame = _percentLabel.frame;
    labelFrame.origin.x = frame.size.width / 2 - _percentLabel.frame.size.width / 2;
    labelFrame.origin.y = frame.size.height / 2 - _percentLabel.frame.size.height / 2;
    _percentLabel.frame = labelFrame;
    
    [super layoutSubviews];
}

-(void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    _bg = [UIImage imageNamed:@"circle_outline"];
    _bgPressed = [UIImage imageNamed:@"circle_outline_pressed"];
    
    _thumb = [UIImage imageNamed:@"circle_thumb"];
    _ridge = [UIImage imageNamed:@"circle_ridge"];
    
    _percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 125, 125)];
    [_percentLabel setFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:60]];
    [_percentLabel setTextColor:[UIColor colorWithRed:89/255.0 green:89/255.0 blue:89/255.0 alpha:1.0]];
    [_percentLabel setTextAlignment:UITextAlignmentCenter];
    [_percentLabel setBackgroundColor:[UIColor clearColor]];
    _percentLabel.adjustsFontSizeToFitWidth = YES;
    _percentLabel.minimumFontSize = 10;
    
    [self addSubview:_percentLabel];
    
    _thumbLayer = [CALayer layer];
    _thumbLayer.contentsScale = [UIScreen mainScreen].scale;
    _thumbLayer.contents = (id) _thumb.CGImage;
    _thumbLayer.frame = CGRectMake(self.frame.size.width / 2 - _thumb.size.width/2, 0, _thumb.size.width, _thumb.size.height);
    _thumbLayer.hidden = YES;
    
    _ridgeLayer = [CALayer layer];
    _ridgeLayer.contentsScale = [UIScreen mainScreen].scale;
    _ridgeLayer.contents = (id)_ridge.CGImage;
    _ridgeLayer.frame = CGRectMake(0, 0, _ridge.size.width, _ridge.size.height);
    
    [_thumbLayer addSublayer:_ridgeLayer];
    
    _imageLayer = [CALayer layer];
    _imageLayer.contentsScale = [UIScreen mainScreen].scale;
    _imageLayer.contents = (id) _bg.CGImage;
    _imageLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    _percentLayer = [ZPGoalBarPercentLayer layer];
    _percentLayer.contentsScale = [UIScreen mainScreen].scale;
    _percentLayer.percent = 0;
    _percentLayer.frame = self.bounds;
    _percentLayer.masksToBounds = NO;
    [_percentLayer setNeedsDisplay];
    
    [self.layer addSublayer:_percentLayer];
    [self.layer addSublayer:_imageLayer];
    [_imageLayer removeAnimationForKey:@"frame"];
    [self.layer addSublayer:_thumbLayer];
    
    _dragging = NO;
    _currentAnimating = NO;
    
    _allowTap = YES;
    _allowDragging = YES;
    
    _tappableRect = CGRectMake(50, 50, 127, 127);
}

-(float)totalCalcuation {
    float total;
    if (_totalAngle >= -(2*M_PI/180) && _totalAngle <= (2*M_PI/180)) {
        total = 0;
    } else if (_totalAngle < 0) {
        total = floorf(toDegrees(_totalAngle)/divideNum);
    } else {
        total = ceilf(toDegrees(_totalAngle)/divideNum);
    }
    
    if (_allowDecimal) {
        total = total / 4.0;
    } else {
        if (fabsf(total) > 100) {
            int remainder = fabsf(total) - 100;
            if (total < 0) {
                remainder *= -1;
            }
            total -= remainder;
            total += 25 * remainder;
        }
    }
    
    if (total != _lastValue && !_currentAnimating) {
        //        [SoundPlayer soundEffect:SEClick];
    }
    
    _lastValue = total;
    return  total;
}

#pragma mark - Custom Getters/Setters
- (void)setPercent:(int)percent animated:(BOOL)animated {
    if (animated) {
        _finalPercent = MIN(100, MAX(0, percent));
        int oldPercent = _percentLayer.percent * 100;
        
        [self performSelector:@selector(delayedDraw:) withObject:[NSNumber numberWithInt:oldPercent] afterDelay:.001];
    } else {
        CGFloat floatPercent = percent / 100.0;
        floatPercent = MIN(1, MAX(0, floatPercent));
        
        _percentLayer.percent = floatPercent;
        [self setNeedsLayout];
        [_percentLayer setNeedsDisplay];
        
//        [self moveThumbToPosition:floatPercent * (2 * M_PI) - (M_PI/2)];
    }
}

- (void)moveThumbToPosition:(CGFloat)angle {
    CGRect rect = _thumbLayer.frame;
    CGPoint center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    angle -= (M_PI/2);
    
    rect.origin.x = center.x + 75 * cosf(angle) - (rect.size.width/2);
    rect.origin.y = center.y + 75 * sinf(angle) - (rect.size.height/2);
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    _thumbLayer.frame = rect;
    
    [CATransaction commit];
}

- (void)setBarColor:(UIColor *)color {
    _percentLayer.color = color;
    [_percentLayer setNeedsDisplay];
}

@end
