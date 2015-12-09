//
//  ViewController.m
//  ORoundRingSimple
//
//  Created by WangZhipeng on 15/12/9.
//  Copyright © 2015年 WangZhipeng. All rights reserved.
//

#import "ViewController.h"
#import "ZPGoalBar.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet ZPGoalBar *firstGoalBar;
@property (weak, nonatomic) IBOutlet ZPGoalBar *secondGoalBar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [_firstGoalBar setPercent:25 animated:NO];
    
    [_secondGoalBar setPercent:50 animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
