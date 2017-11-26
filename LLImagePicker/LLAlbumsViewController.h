//
//  LLAlbumsViewController.h
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/8.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLPhoto.h"
#import "LLPhotoBrowser.h"
#import "LLAssetsPickerConfig.h"

@interface LLAlbumsViewController : UIViewController

/**
 the user try to picking more than max number pictures callback.
 In this callback we can show a warning message.
 */
@property (nonatomic, copy) void(^pickingMoreThanMaxNum)(void);

/**
 the user cancelled the pick operation
 */
@property (nonatomic, copy) void(^didCancelPickingAssets)(LLAlbumsViewController *albumsVC);

/**
 the user finish picking assets
 */
@property (nonatomic, copy) void(^didFinishPickingAssets)(LLAlbumsViewController *albumsVC,NSArray <LLPhoto *> *assets);

@end
