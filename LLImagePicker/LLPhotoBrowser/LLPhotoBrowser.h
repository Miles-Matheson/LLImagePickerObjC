//
//  LLPhotoBrowser.h
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/8.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLAlbum.h"
#import "LLPhoto.h"
#import "LLCheckManager.h"
#import "LLTailorCoverView.h"

typedef enum : NSUInteger {
    LLPhotoBrowserStyleDefault = 0,  // only have top bar
    LLPhotoBrowserStyleEditAndCheck, // have top and bottom bar with check and edit button
    LLPhotoBrowserStyleCheck,        // have top and bottom bar with check button only
} LLPhotoBrowserStyle;

@class LLAssetsPickerConfig;

@interface LLPhotoBrowser : UIViewController

/**
 Photo Browser spacial style.
 */
@property (nonatomic, assign) LLPhotoBrowserStyle style;

/**
 the image datasource will show in background scrollView
 */
@property (nonatomic, strong) NSArray <LLPhoto *> *items;

/**
 the index of current show image.
 */
@property (nonatomic, assign) NSInteger currentIndex;

/**
 the model to manager the check event.
 */
@property (nonatomic, strong) LLCheckManager *checkManager;

/**
 the handler to handle click confirm button event.
 */
@property (nonatomic, copy) void (^onClickConfirmBtn)(LLPhotoBrowser *photoBrowser);

/**
 the init method

 @param style photo browser style
 @return photo browser object
 */
- (id)initWithStyle:(LLPhotoBrowserStyle)style;

/**
 set the right button of top bar.

 @param setRightBtnCallback you can set right button attribute in this callback
 @param clickHandler the click event callback of top bar right button
 */
- (void)setTopBarRightBtn:(void(^)(LLPhotoBrowser *browser,UIButton *rightBtn))setRightBtnCallback clickHandler:(void(^)(LLPhotoBrowser *browser,UIButton *rightBtn))clickHandler;

/**
 reload dataSource of the photo browser
 */
- (void)reloadData;

@end
