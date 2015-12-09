//
//  ZPGoalBar.h
//  ORoundRingSimple
//
//  Created by WangZhipeng on 15/12/9.
//  Copyright © 2015年 WangZhipeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZPGoalBarPercentLayer.h"

@protocol ZPGoalBarDelegate <NSObject>

-(void)newValue:(NSNumber *)number fromControl:(id)control;
-(void)valueCommitted:(NSNumber *)number fromControl:(id)control;

@end

@interface ZPGoalBar : UIControl

@property (nonatomic, assign) BOOL allowDragging;
@property (nonatomic, assign) BOOL allowTap;
@property (nonatomic, assign) BOOL allowSwitching;
@property (nonatomic, assign) BOOL allowDecimal;
@property (nonatomic, assign) int currentGoal;
@property (nonatomic, weak) id<ZPGoalBarDelegate> delegate;
@property (nonatomic, strong) UILabel *percentLabel;
@property (nonatomic, strong) NSString *customText;

- (void)setPercent:(int)percent animated:(BOOL)animated;
- (void)setBarColor:(UIColor *)color;
- (void)setThumbEnabled:(BOOL)enabled;
- (BOOL)thumbEnabled;
- (void)moveThumbToPosition:(CGFloat)angle;
- (float)bailOutAnimation;
- (BOOL)thumbHitTest:(CGPoint)point;
- (void)displayChartMode;

@end
