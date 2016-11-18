//
//  ViewController.m
//  LKKSegmentedControl
//
//  Created by KinKeung Leung on 2016/11/8.
//  Copyright © 2016年 KinKeung Leung. All rights reserved.
//

#import "ViewController.h"
#import "LKKSegmentedControl.h"

@interface ViewController ()

@property (nonatomic , strong ) LKKSegmentedControl *control;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.control        = [LKKSegmentedControl new];
    self.control.titles = @[@"1",@"2",@"3",@"4"];
    
    [self.control addTarget:self
                     action:@selector(changed:)
           forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.control];
}

#pragma mark 值更改时
- (void)changed:(LKKSegmentedControl *)sender
{
    NSLog(@"select index:%ld",sender.selectedSegmentIndex);
}

#pragma mark 布局
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.control.frame = CGRectMake(0, 20, self.view.bounds.size.width,40);
}




@end
