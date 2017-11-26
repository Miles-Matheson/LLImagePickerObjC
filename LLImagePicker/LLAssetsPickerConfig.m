//
//  LLAssetsPickerConfig.m
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/24.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLAssetsPickerConfig.h"

@implementation LLAssetsPickerConfig


/**
 选择器配置单例

 @return 单例对象
 */
+ (LLAssetsPickerConfig *)shared{
    static LLAssetsPickerConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[LLAssetsPickerConfig alloc] init];
    });
    return config;
}

- (id)init{
    if (self = [super init]) {
        _isShowAssetControllerDirect = YES;
        _numberOfColumns = 4;
        _minimumNumberOfSelection = 1;
        _maximumNumberOfSelection = NSUIntegerMax;
    }
    return self;
}

@end
