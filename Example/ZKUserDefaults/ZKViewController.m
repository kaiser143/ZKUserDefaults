//
//  ZKViewController.m
//  ZKUserDefaults
//
//  Created by zhangkai on 12/09/2018.
//  Copyright (c) 2018 zhangkai. All rights reserved.
//

#import "ZKViewController.h"
#import "ZKUserInfo.h"

@interface ZKViewController ()

@end

@implementation ZKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    ZKUserInfo *info = [ZKUserInfo manager];
    info.name = @"Kaiser";
    info.userId = @"12";
    info.age = 12;
    info.gender = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
