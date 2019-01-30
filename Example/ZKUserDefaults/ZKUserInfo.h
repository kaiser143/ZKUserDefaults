//
//  ZKUserInfo.h
//  ZKUserDefaults_Example
//
//  Created by Kaiser on 2019/1/30.
//  Copyright © 2019 zhangkai. All rights reserved.
//

#import "ZKUserDefaults.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZKUserInfo : ZKUserDefaults

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) NSInteger gender;

@end

NS_ASSUME_NONNULL_END
