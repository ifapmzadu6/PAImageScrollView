//
//  ViewController.m
//  PAImageScrollViewExample
//
//  Created by Keisuke Karijuku on 2014/10/06.
//  Copyright (c) 2014年 Keisuke Karijuku. All rights reserved.
//

#import "ViewController.h"

#import "PAImageScrollView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PAImageScrollView *imageScrollView = [[PAImageScrollView alloc] initWithFrame:self.view.bounds];
    imageScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:imageScrollView];
    
    imageScrollView.image = [UIImage imageNamed:@"yosemite"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
