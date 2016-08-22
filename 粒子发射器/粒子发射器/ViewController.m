//
//  ViewController.m
//  粒子发射器
//
//  Created by 刘松 on 16/8/2.
//  Copyright © 2016年 liusong. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property(nonatomic, strong) CAEmitterLayer *emitterLayer;

@end

@implementation ViewController

static CGFloat PI = M_PI;
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
      self.emitterLayer;
//  [self animateInView:self.view];
//  [NSTimer scheduledTimerWithTimeInterval:0.3
//                                   target:self
//                                 selector:@selector(click)
//                                 userInfo:nil
//                                  repeats:YES];
}

- (void)click {
  [self animateInView:self.view];
}
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self animateInView:self.view];
}
- (void)animateInView:(UIView *)view {
  UIImageView *imageView = [[UIImageView alloc] init];
  imageView.frame = CGRectMake(100, 400, 30, 30);
  int nameI = arc4random() % 4 + 1;
  imageView.image =
      [UIImage imageNamed:[NSString stringWithFormat:@"good%d_30x30", nameI]];
  [view addSubview:imageView];

  // Pre-Animation setup
  imageView.transform = CGAffineTransformMakeScale(0, 0);
  imageView.alpha = 0;

  //在底部 由无到有 又小变大的弹性动画
  [UIView animateWithDuration:0.5
                        delay:0.0
       usingSpringWithDamping:0.6
        initialSpringVelocity:0.8
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     imageView.transform = CGAffineTransformIdentity;
                     //                       imageView.transform =
                     //                       CGAffineTransformScale(imageView.transform,
                     //                       4, 4);
                     imageView.alpha = 0.9;
                   }
                   completion:NULL];

  NSInteger i = arc4random_uniform(2);
  NSInteger rotationDirection = 1 - (2 * i); // -1 OR 1
  NSInteger rotationFraction = arc4random_uniform(10);

  NSTimeInterval totalAnimationDuration = 3;
  //放大后向左或向右旋转一定角度动画
  [UIView
      animateWithDuration:totalAnimationDuration
               animations:^{
                 imageView.transform = CGAffineTransformMakeRotation(
                     rotationDirection * PI / (16 + rotationFraction * 0.2));
               }
               completion:NULL];

  // S型动画

  CGFloat heartSize = CGRectGetWidth(imageView.bounds);
  CGFloat heartCenterX = imageView.center.x;
  CGFloat viewHeight = CGRectGetHeight(view.bounds);

  UIBezierPath *heartTravelPath = [UIBezierPath bezierPath];
  [heartTravelPath moveToPoint:imageView.center];

  // 随机结束点
  CGPoint endPoint = CGPointMake(
      heartCenterX + (rotationDirection)*arc4random_uniform(2 * heartSize),
      viewHeight / 6.0 + arc4random_uniform(viewHeight / 4.0));

  NSInteger j = arc4random_uniform(2);
  NSInteger travelDirection = 1 - (2 * j); // -1 OR 1

  //绘制S型曲线 随机点
  CGFloat xDelta =
      (heartSize / 2.0 + arc4random_uniform(2 * heartSize)) * travelDirection;
  CGFloat yDelta =
      MAX(endPoint.y, MAX(arc4random_uniform(8 * heartSize), heartSize));

  //控制点1 控制点2
  CGPoint controlPoint1 = CGPointMake(heartCenterX + xDelta, yDelta);
  CGPoint controlPoint2 = CGPointMake(heartCenterX - xDelta, yDelta);
  //    CGPoint controlPoint1 =
  //    CGPointMake(heartCenterX + xDelta, viewHeight - yDelta);
  //    CGPoint controlPoint2 = CGPointMake(heartCenterX - 2 * xDelta, yDelta);

  [heartTravelPath addCurveToPoint:endPoint
                     controlPoint1:controlPoint1
                     controlPoint2:controlPoint2];

  CAKeyframeAnimation *keyFrameAnimation =
      [CAKeyframeAnimation animationWithKeyPath:@"position"];
  keyFrameAnimation.path = heartTravelPath.CGPath;
  keyFrameAnimation.timingFunction =
      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
  keyFrameAnimation.duration = totalAnimationDuration + endPoint.y / viewHeight;
  [imageView.layer addAnimation:keyFrameAnimation forKey:@"positionOnPath"];

  // 动画消失
  [UIView animateWithDuration:totalAnimationDuration
      animations:^{
        imageView.alpha = 0.0;
      }
      completion:^(BOOL finished) {
        [imageView removeFromSuperview];
      }];
  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
      });
}

- (CAEmitterLayer *)emitterLayer {
  if (!_emitterLayer) {
    CAEmitterLayer *emitterLayer = [CAEmitterLayer layer];
    // 发射器在xy平面的中心位置
    emitterLayer.emitterPosition = CGPointMake(
        self.view.frame.size.width - 50, self.view.frame.size.height - 50);
    // 发射器的尺寸大小
    emitterLayer.emitterSize = CGSizeMake(20, 20);
    // 渲染模式
    emitterLayer.renderMode = kCAEmitterLayerUnordered;
    // 开启三维效果
    _emitterLayer.preservesDepth = YES;
    NSMutableArray *array = [NSMutableArray array];
    // 创建粒子
    for (int i = 0; i < 10; i++) {
      // 发射单元
      CAEmitterCell *stepCell = [CAEmitterCell emitterCell];
      // 粒子的创建速率，默认为1/s
      stepCell.birthRate = 1;
      // 粒子存活时间
      stepCell.lifetime = arc4random_uniform(4) + 1;
      // 粒子的生存时间容差
      stepCell.lifetimeRange = 1.5;
      // 颜色
      // fire.color=[[UIColor colorWithRed:0.8 green:0.4 blue:0.2
      // alpha:0.1]CGColor];
      UIImage *image =
          [UIImage imageNamed:[NSString stringWithFormat:@"good%d_30x30", i]];
      // 粒子显示的内容
      stepCell.contents = (id)[image CGImage];
      // 粒子的名字
      //            [fire setName:@"step%d", i];
      // 粒子的运动速度
      stepCell.velocity = arc4random_uniform(100) + 100;
      // 粒子速度的容差
      stepCell.velocityRange = 80;
      // 粒子在xy平面的发射角度
      stepCell.emissionLongitude = M_PI + M_PI_2;
      ;
      // 粒子发射角度的容差
      stepCell.emissionRange = M_PI_2 / 6;
      // 缩放比例
      stepCell.scale = 0.3;
      [array addObject:stepCell];
    }

    emitterLayer.emitterCells = array;
    emitterLayer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:emitterLayer];
    _emitterLayer = emitterLayer;
  }
  return _emitterLayer;
}

@end
