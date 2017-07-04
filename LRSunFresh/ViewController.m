//
//  ViewController.m
//  LRSunFresh
//
//  Created by 宇中 on 2017/7/4.
//  Copyright © 2017年 广州宇中网络科技有限公司. All rights reserved.
//

#import "ViewController.h"
#import "MGCell.h"

#define MaxHeight 100

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong)CAShapeLayer *shapeLayer;
@property(nonatomic, weak)UITableView *tableView;
@property(nonatomic, strong)CAShapeLayer *circleLayer;

@end

@implementation ViewController

- (CAShapeLayer *)shapeLayer{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:169/255.0 alpha:1].CGColor;
    }
    return _shapeLayer;
}

- (CAShapeLayer *)circleLayer{
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.fillColor = [UIColor whiteColor].CGColor;
        _circleLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, MaxHeight);
        _circleLayer.fillColor = nil;
        _circleLayer.strokeColor = [UIColor whiteColor].CGColor;
        _circleLayer.lineWidth = 2.0;
        
        CGPoint center = CGPointMake(self.view.center.x, MaxHeight*0.5);
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(self.view.center.x, 35)];
        [path addArcWithCenter:center radius:15 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
        CGFloat r1 = 17.0;
        CGFloat r2 = 22.0;
        for (int i = 0; i < 8 ; i++) {
            CGPoint pointStart = CGPointMake(center.x + sin((M_PI * 2.0 / 8 * i)) * r1, center.y - cos((M_PI * 2.0 / 8 * i)) * r1);
            CGPoint pointEnd = CGPointMake(center.x + sin((M_PI * 2.0 / 8 * i)) * r2, center.y - cos((M_PI * 2.0 / 8 * i)) * r2);
            [path moveToPoint:pointStart];
            [path addLineToPoint:pointEnd];
        }
        
        _circleLayer.path = path.CGPath;
    }
    return _circleLayer;
}

static NSString * const kCellID = @"kCellID";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    //设置内间距
    [tableView setContentInset:UIEdgeInsetsMake(MaxHeight, 0, 0, 0)];
    //设置偏移值为0
    [tableView setContentOffset:CGPointMake(0, 0)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerNib:[UINib nibWithNibName:@"MGCell" bundle:nil] forCellReuseIdentifier:kCellID];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    //显示在最底层
    [self.view.layer insertSublayer:self.shapeLayer atIndex:0];
    [self.shapeLayer addSublayer:self.circleLayer];
    
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //NSLog(@"scrollView.contentOffset.y = %f",scrollView.contentOffset.y);
    CGFloat height = -scrollView.contentOffset.y;
    UIBezierPath *path = [UIBezierPath bezierPath];
    //设置起点
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(self.view.bounds.size.width, 0)];
    if (height <= MaxHeight) {
        ///绘制矩形背景
        [path addLineToPoint:CGPointMake(self.view.bounds.size.width, MaxHeight)];
        [path addLineToPoint:CGPointMake(0, MaxHeight)];
        
        self.circleLayer.strokeEnd = height / MaxHeight;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.circleLayer.affineTransform = CGAffineTransformIdentity;
        [CATransaction commit];
    }else{
        ///绘制弧形
        [path addLineToPoint:CGPointMake(self.view.bounds.size.width, MaxHeight)];
        [path addQuadCurveToPoint:CGPointMake(0, MaxHeight) controlPoint:CGPointMake(self.view.center.x, height)];
        
        self.circleLayer.strokeEnd = 1.0;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.circleLayer.affineTransform = CGAffineTransformMakeRotation(-(M_PI / 720 * (height - 100)));
        [CATransaction commit];
    }
    [path closePath];
    self.shapeLayer.path = path.CGPath;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    NSLog(@"%s",__func__);
    if (scrollView.contentOffset.y < -100) {
        [scrollView setContentOffset:CGPointMake(0, -100) animated:YES];
    }else if(scrollView.contentOffset.y < 0) {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSLog(@"%s",__func__);
    if (scrollView.contentOffset.y < -99 &&scrollView.contentOffset.y > -101) {
        self.circleLayer.affineTransform = CGAffineTransformIdentity;
        //旋转
        self.tableView.scrollEnabled = NO;
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        anim.duration = 0.15;
        anim.toValue = @(M_PI / 4.0);
        anim.repeatCount = MAXFLOAT;
        [self.circleLayer addAnimation:anim forKey:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tableView.scrollEnabled = YES;
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
            [self.circleLayer removeAllAnimations];
        });
    }
}




#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}



@end
