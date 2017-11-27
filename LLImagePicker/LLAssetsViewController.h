//
//  LLAssetsViewController.h
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/8.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "LLAlbum.h"
#import "LLAssetsPickerConfig.h"

#define LLImagePickerBundle [NSBundle bundleForClass:self.class]

@interface LLAssetsViewController : UIViewController

@property (nonatomic, strong) LLAlbum *album;

@property (nonatomic, copy) void(^pickingMoreThanMaxNum)(void);

@property (nonatomic, copy) void(^didFinishPickingAssets)(NSArray <LLPhoto *> *assets);

@end
