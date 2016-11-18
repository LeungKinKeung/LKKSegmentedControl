//
//  LKKSegmentedControl.h
//  LKKSegmentedControl
//
//  Created by KinKeung Leung on 2016/11/8.
//  Copyright © 2016年 KinKeung Leung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LKKSegmentedControl : UIControl

/**
 *  选项的Title
 */
@property (nonatomic , copy) NSArray <NSString *>* titles;

/**
 *  选中的item的index , 调用setting方法时会触发点击事件
 */
@property (nonatomic, assign) NSInteger selectedSegmentIndex;

/**
 *  分页大小，默认 100.0
 */
@property (nonatomic , assign) CGFloat segmentWidth;

/**
 *  是否对齐，默认YES
 */
@property (nonatomic , assign , getter = isAlignment) BOOL alignment;


@end










