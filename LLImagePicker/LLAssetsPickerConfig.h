//
//  LLAssetsPickerConfig.h
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/24.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLPhotoBrowser.h"
#import "LLTailorCoverView.h"

@interface LLAssetsPickerConfig : NSObject

/**
 选择器配置单例
 
 @return 单例对象
 */
+ (LLAssetsPickerConfig *)shared;

/**
 是否直接显示资源列表
 show asset controller direct or not.
 */
@property (nonatomic, assign) BOOL isShowAssetControllerDirect; // default is YES

/**
 资源列表显示列数
 the number of columns of asset collection view in asset controller.
 */
@property (nonatomic, assign) NSUInteger numberOfColumns; // //列数 default is 4

/**
 资源最小选择数，选择小于这个数不允许用户点击确定按钮
 */
@property (nonatomic, assign) NSUInteger minimumNumberOfSelection; // default is 1

/**
 资源最大选择数，选择超过这个数提示用户
 */
@property (nonatomic, assign) NSUInteger maximumNumberOfSelection; // default is NSUIntegerMax

/**
 图片浏览器的类型
 Photo Browser spacial style.
 */
@property (nonatomic, assign) LLPhotoBrowserStyle photoBrowserStyle;

/**
 裁剪视图的类型
 the type of clip view
 */
@property (nonatomic, assign) LLTailorCoverViewType clipViewType;

/**
 裁剪纵横比 , 宽高比
 the clip aspect ratio.
 */
@property (nonatomic, assign) CGFloat clipAspectRatio;


/**
 自定义图片
 */
@property (nonatomic, strong) UIImage  *backImage;
@property (nonatomic, strong) UIImage  *checkImage;
@property (nonatomic, strong) UIImage  *closeImage;
@property (nonatomic, strong) UIImage  *confirmImage;
@property (nonatomic, strong) UIImage  *iCloudDownloadImage;
@property (nonatomic, strong) UIImage  *loadFailedImage;

/**
 自定义颜色
 */
@property (nonatomic, strong) UIColor  *checkedBackgroundColor;
@property (nonatomic, strong) UIColor  *checkedTintColor;


/**
 自定义提示语
 */
@property (nonatomic,   copy) NSString *alreadyReachMaxSelectPrompt;
@property (nonatomic,   copy) NSString *alreadySelectPrompt;

@end
