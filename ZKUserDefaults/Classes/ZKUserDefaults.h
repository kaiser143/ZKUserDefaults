//
//  ZKUserDefaults.h
//  NN
//
//  Created by Kaiser on 2018/12/6.
//  Copyright © 2018 zhangkai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZKUserDefaults : NSObject

/*!
 *    @brief    基类，业务类通过继承后在实现属性写操作时，基类会把最新的数据通过NSUserDefauts 写入到本地
 */
+ (instancetype)manager;

- (void)removeAllItems;

@end

NS_ASSUME_NONNULL_END
