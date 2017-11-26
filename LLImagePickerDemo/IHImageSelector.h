//
//  IHImageSelector.h
//  InstalmenHelp
//
//  Created by kevin on 2017/8/3.
//  Copyright © 2017年 XQT-zfd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLAssetsPicker.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define IMG_SELECTOR_ITEM_WIDTH ((SCREEN_WIDTH - (15*2+(4-1)*13)) / 4)

@class IHImageSelectorModel;

@interface IHImageSelector : UIView

@property (nonatomic, strong) LLAssetsPickerConfig *pickerConfig;

@property (nonatomic, strong, readonly) NSArray <IHImageSelectorModel *> *pickerAssets;

/**
 the user finish picking assets
 */
@property (nonatomic, copy) void(^didFinishPickingAssets)(IHImageSelector *imageSelector,NSArray <IHImageSelectorModel *> *assets);

/**
 通过网络图片路径数组来设置图片选择器数据源
 
 @param imageUrls 网络图片地址数组
 */
- (void)setItemsWithImageUrls:(NSArray <NSString *> *)imageUrls;

@end

@interface IHImageSelectorCell : UICollectionViewCell

@property (nonatomic, copy) void (^onClickMainImgView)(IHImageSelectorCell *cell);
@property (nonatomic, copy) void (^onClickDeleteBtn)(IHImageSelectorCell *cell,UIButton *deleteBtn);

@property (nonatomic, strong) UIImageView *mainImgView;

@property (nonatomic, strong) UIButton *deleteBtn;

@end

@class PHAsset;

typedef enum : NSUInteger {
    IHImageSelectorModelTypeAsset = 0,
    IHImageSelectorModelTypeImgPath,
} IHImageSelectorModelType; //model的类型

@interface IHImageSelectorModel : NSObject

@property (nonatomic, assign) IHImageSelectorModelType type; //model的类型

@property (nonatomic, strong) LLPhoto *llPhoto; //图片对应的LLPhoto对象

@property (nonatomic, strong) UIImage *clipImage; //用户裁剪的图片 , 优先使用

@property (nonatomic, strong) PHAsset *asset;   //图片对应的PHAsset对象,可能为nil,clipImage为空时才尝试使用此属性

@property (nonatomic, copy) NSString *imgPath;  //网络图片url , 可能为nil

/**
 通过网络图片地址初始化图片选择器模型
 
 @param imageUrl 网络图片地址
 @return 初始化后的图片选择器对象
 */
- (id)initWithImageUrl:(NSString *)imageUrl;

/**
 photo数组转model数组
 
 @param photoArray 待转换的photo数组
 @return 转换后的model数组
 */
+ (NSArray <IHImageSelectorModel *>*)modelArrayWithPhotoArray:(NSArray <LLPhoto *>*)photoArray;

/**
 model数组转photo数组
 
 @param modelArray 待转换的model数组
 @return 转换后的photo数组
 */
+ (NSArray <LLPhoto *> *)photoArrayWithModelArray:(NSArray <IHImageSelectorModel *>*)modelArray;

/**
 获取图片的二进制数据
 
 @param resultHandler 获取完成回调
 */
- (void)getImageDataWithResultHandler:(void(^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info))resultHandler;

/**
 通过model数组获取逗号拼接后的图片路径
 
 @param modelArray model数组
 @return 拼接后的图片路径
 */
+ (NSString *)imgsPathWithModelArray:(NSArray <IHImageSelectorModel *>*)modelArray;

@end
