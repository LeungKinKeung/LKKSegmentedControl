//
//  LKKSegmentedControl.m
//  LKKSegmentedControl
//
//  Created by KinKeung Leung on 2016/11/8.
//  Copyright © 2016年 KinKeung Leung. All rights reserved.
//

#import "LKKSegmentedControl.h"

/********************************************************/
/********************************************************/
// 渐变Layer
@interface LKKSegmentedControlGradientLayer : CALayer
/**
 *  底部颜色，向上渐变
 */
@property (nonatomic , strong) UIColor *bottomColor;
/**
 *  默认:0
 */
@property (nonatomic , assign) CGFloat bottomOffset;

@end
@implementation LKKSegmentedControlGradientLayer

- (void)drawInContext:(CGContextRef)ctx {
    UIBezierPath *maskPath =
    [UIBezierPath bezierPathWithRoundedRect:self.bounds
                          byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                cornerRadii:CGSizeMake(15, 15)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path  = maskPath.CGPath;
    self.mask = maskLayer;
    
    UIGraphicsPushContext(ctx);
    
    CGColorSpaceRef colorSpace  = CGColorSpaceCreateDeviceRGB();
    
    CGFloat bottomLocation  = (self.bounds.size.height - self.bottomOffset) / self.bounds.size.height;
    
    CGFloat locations[] = {0,bottomLocation,1};
    
    CGFloat hue,saturation,brightness;
    
    [self.bottomColor getHue:&hue
                  saturation:&saturation
                  brightness:&brightness
                       alpha:nil];
    
    hue = hue + 0.08 < 1.0 ? hue + 0.08 : hue + 0.08 - 1.0;
    UIColor *topColor   = [UIColor colorWithHue:hue
                                     saturation:saturation
                                     brightness:brightness
                                          alpha:1.0];
    
    NSArray *colors = @[(__bridge id)topColor.CGColor,
                        (__bridge id)self.bottomColor.CGColor,
                        (__bridge id)self.bottomColor.CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint startPoint  = (CGPoint){self.bounds.size.width * 0.5, 0};
    CGPoint endPoint    = (CGPoint){self.bounds.size.width * 0.5, self.bounds.size.height};
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    
    CGGradientRelease(gradient);
    UIGraphicsPopContext();
}
@end
/********************************************************/
/********************************************************/
// 渐变Button
@interface LKKSegmentedControlButton : UIButton
/**
 *  背景底部颜色
 */
@property (nonatomic , strong) UIColor *backgroundBottomColor;
/**
 *  底部颜色偏移
 */
@property (nonatomic , assign) CGFloat bottomOffset;
/**
 *  渐变Layer
 */
@property (strong ,nonatomic) LKKSegmentedControlGradientLayer *gradientLayer;

@end

@implementation LKKSegmentedControlButton

#pragma mark 懒加载
- (LKKSegmentedControlGradientLayer *)gradientLayer
{
    if (_gradientLayer == nil)
    {
        _gradientLayer = [[LKKSegmentedControlGradientLayer alloc] init];
        [self.layer insertSublayer:self.gradientLayer atIndex:-1000];
    }
    return _gradientLayer;
}
#pragma mark 设置背景底部颜色
- (void)setBackgroundBottomColor:(UIColor *)backgroundBottomColor
{
    _backgroundBottomColor  = backgroundBottomColor;
    [self setNeedsDisplayGradienLayer];
}
#pragma mark 布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.gradientLayer.frame = self.bounds;
    [self setNeedsDisplayGradienLayer];
}
#pragma mark 刷新渐变图层
- (void)setNeedsDisplayGradienLayer
{
    self.gradientLayer.bottomColor  = self.backgroundBottomColor;
    self.gradientLayer.bottomOffset = self.bottomOffset;
    [self.gradientLayer setNeedsDisplay];
}
@end
/********************************************************/
/********************************************************/
// 分页ScrollView
@interface LKKSegmentedControlScrollView : UIScrollView

/**
 *  分页大小
 */
@property (nonatomic , assign) CGFloat pageWidth;

@end

@implementation LKKSegmentedControlScrollView

@end

/********************************************************/
/********************************************************/
// 分段控制器
@interface LKKSegmentedControl ()<UIScrollViewDelegate>

@property (strong , nonatomic) LKKSegmentedControlScrollView *backgroundScrollView;
@property (strong , nonatomic) UIView *titlesBackgroundView;
@property (strong , nonatomic) NSMutableArray <LKKSegmentedControlButton *>* buttons;
@end

@implementation LKKSegmentedControl

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialization];
}

#pragma mark 初始化
- (void)initialization
{
    // 可左右滑动的ScrollView
    self.backgroundScrollView   = [LKKSegmentedControlScrollView new];
    self.backgroundScrollView.showsHorizontalScrollIndicator  = NO;
    self.backgroundScrollView.delegate                        = self;
    [self addSubview:self.backgroundScrollView];
    
    self.titlesBackgroundView   = [UIView new];
    self.titlesBackgroundView.userInteractionEnabled    = YES;
    [self.backgroundScrollView addSubview:self.titlesBackgroundView];
    
    self.alignment              = YES;
}

#pragma mark - 设置Titles
- (void)setTitles:(NSArray<NSString *> *)titles
{
    // 如果数组内容是一样的，就不刷新
    if ([titles isEqualToArray:_titles])
    {
        return;
    }
    
    _titles = titles;
    
    // 重置
    self.selectedSegmentIndex   = 0;
    
    // 移除所有按钮
    if (self.buttons.count > 0)
    {
        for (LKKSegmentedControlButton *button in self.buttons)
        {
            [button removeFromSuperview];
        }
        [self.buttons removeAllObjects];
    }
    
    // 添加按钮
    for (NSUInteger i = 0; i < _titles.count; i ++)
    {
        LKKSegmentedControlButton *button   = [LKKSegmentedControlButton new];
        
        button.backgroundBottomColor        =
        [self colorWithMaxColorCount:_titles.count index:i];
        
        button.tag      = i;
        
        // 设置title
        NSString *title = [_titles objectAtIndex:i];
        
        [button setTitle:title
                forState:UIControlStateNormal];
        
        [button setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
        
        // 设置事件
        [button addTarget:self
                   action:@selector(buttonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        
        // 设置阴影
        button.bottomOffset             = 5.0;
        button.layer.shadowColor        = [UIColor blackColor].CGColor;
        button.layer.shadowOpacity      = 1.0;
        button.layer.shadowOffset       = CGSizeMake(0, 5);
        button.layer.shadowRadius       = 5.0;
        
        [self.titlesBackgroundView addSubview:button];
        [self.buttons addObject:button];
    }
    
    [self setSubviewsFrame];
}

#pragma mark - 选项卡按钮点击
- (void)buttonClicked:(LKKSegmentedControlButton *)sender
{
    if (self.selectedSegmentIndex == sender.tag)
    {
        return;
    }
    self.selectedSegmentIndex = sender.tag;
}

#pragma mark 设置选中的index
- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    if (_selectedSegmentIndex == selectedSegmentIndex)
    {
        return;
    }
    if (selectedSegmentIndex >= self.buttons.count)
    {
        assert(selectedSegmentIndex < self.buttons.count);
        return;
    }
    
    {
        // 取消前一个选中的按钮的阴影效果
        LKKSegmentedControlButton *previousSelectButton =
        [self.buttons objectAtIndex:_selectedSegmentIndex];
        
        previousSelectButton.layer.shadowOpacity = 0.0;
    }
    
    // 先取消前一个按钮的阴影效果再赋值
    _selectedSegmentIndex = selectedSegmentIndex;
    
    {
        // 添加阴影效果并前置
        LKKSegmentedControlButton *button  =
        [self.buttons objectAtIndex:_selectedSegmentIndex];
        
        button.layer.shadowOpacity  = 1.0;
        
        [self.titlesBackgroundView bringSubviewToFront:button];
        
        [self controlEventValueChange];
    }
}

#pragma mark 控制器值已更改
- (void)controlEventValueChange{
    
    NSSet *set  = self.allTargets;
    
    if (set.count == 0)
    {
        return;
    }
    
    NSArray *targets = set.allObjects;
    
    for (id target in targets)
    {
        NSArray *actions = [self actionsForTarget:target
                                  forControlEvent:UIControlEventValueChanged];
        if (actions.count > 0)
        {
            for (NSString *action in actions)
            {
                [self sendAction:NSSelectorFromString(action)
                              to:target
                        forEvent:[UIEvent new]];
            }
        }
    }
}

#pragma mark - 布局
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setSubviewsFrame];
}

- (void)setSubviewsFrame {
    
    CGSize superViewSize = self.bounds.size;
    
    if (superViewSize.width < 10 || superViewSize.height < 10)
    {
        return;
    }
    if (self.buttons.count == 0)
    {
        //assert(self.buttons.count > 0); // 没有设置titles
        return;
    }
    if (self.segmentWidth < 10)
    {
        self.segmentWidth = 100;
    }
    CGFloat buttonWidth     = self.segmentWidth;
    CGFloat buttonHeight    = superViewSize.height;
    
    if (buttonWidth > superViewSize.width)
    {
        assert(NO); // 建议把pageWidth设置小点
        return;
    }
    
    CGFloat maxColumn   = round(superViewSize.width / buttonWidth);
    
    // 计算出button的大小
    if (self.isAlignment)
    {
        buttonWidth     = superViewSize.width / maxColumn;
    }
    // 当要显示的Button个数小于允许显示的Button个数时，就增大buttonWidth
    if (self.buttons.count < maxColumn)
    {
        buttonWidth     = superViewSize.width / self.buttons.count;
    }
    // 设置分页宽度
    self.backgroundScrollView.pageWidth = buttonWidth;
    
    // 设置Button的frame
    for (NSUInteger i = 0; i < self.buttons.count; i++)
    {
        // 取出
        LKKSegmentedControlButton *button  = [self.buttons objectAtIndex:i];
        
        button.frame    = CGRectMake(buttonWidth * i,
                                     0,
                                     buttonWidth,
                                     buttonHeight);
        // 阴影
        if (i == self.selectedSegmentIndex)
        {
            button.layer.shadowOpacity  = 1.0;
            
            [self.titlesBackgroundView bringSubviewToFront:button];
        }else
        {
            button.layer.shadowOpacity = 0.0;
        }
    }
    
    // 设置self.itemsScrollView和self.itemsBackView的frame
    self.backgroundScrollView.frame         = self.bounds;
    self.titlesBackgroundView.frame         =
    CGRectMake(0, 0, buttonWidth * self.buttons.count, buttonHeight);
    
    self.backgroundScrollView.contentSize   = self.titlesBackgroundView.frame.size;
}

#pragma mark - UIScrollView代理

#pragma mark 停止滑动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self setOffsetWithScrollView:scrollView];
}

#pragma mark 停止拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (decelerate) {
        return;
    }
    [self setOffsetWithScrollView:scrollView];
}

#pragma mark 让ScrollView的contentOffset对齐
- (void)setOffsetWithScrollView:(UIScrollView *)scrollView{
    
    if ([scrollView isKindOfClass:[LKKSegmentedControlScrollView class]] == NO)
    {
        return;
    }
    
    if (scrollView != self.backgroundScrollView)
    {
        return;
    }
    
    LKKSegmentedControlScrollView *backgroundScrollView = (LKKSegmentedControlScrollView *)scrollView;
    
    if (backgroundScrollView.pageWidth < 1)
    {
        return;
    }
    if (scrollView.contentOffset.x <= 0)
    {
        return;
    }
    CGFloat maxOffsetX = scrollView.contentSize.width - scrollView.bounds.size.width;
    
    if (scrollView.contentOffset.x >= maxOffsetX)
    {
        return;
    }
    
    CGFloat page    = round(scrollView.contentOffset.x / backgroundScrollView.pageWidth);
    CGFloat offsetX = page * backgroundScrollView.pageWidth;
    
    [backgroundScrollView setContentOffset:CGPointMake(offsetX, backgroundScrollView.contentOffset.y) animated:YES];
}

#pragma mark 懒加载
- (NSMutableArray<LKKSegmentedControlButton *> *)buttons
{
    if (_buttons == nil) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

#pragma mark 颜色
- (UIColor *)colorWithMaxColorCount:(NSUInteger)count index:(NSUInteger)index {
    
    // Hue:1.0 ~ 0.5 / 0.2 ~ 0.0  Saturation:0.9 Brightness:0.9 Alpha:1.0
    if (count < 7.0) {
        count = 7.0;
    }
    CGFloat hueRatio = 0.7 / count;
    CGFloat hueValue = 1.0 - hueRatio * index;
    
    if (hueValue < 0.5) {
        hueValue -= 0.3;
    }
    
    return [UIColor colorWithHue:hueValue
                      saturation:0.9
                      brightness:0.9
                           alpha:1.0];
}



@end





