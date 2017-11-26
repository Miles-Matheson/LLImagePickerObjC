//
//  LLToolbar.h
//  LLImagePickerDemo
//
//  Created by kevin on 2017/11/12.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLAssetsPickerConfig.h"

#define kTopBarHeight 64
#define kBottomBarHeight 49

typedef enum : NSUInteger {
    LLToolBarStyleDefault,  /*bar have two items*/
    LLToolBarStyleThreeItems, /*bar have three items*/
    LLToolBarStyleTitleAndRightItem, /*bar have title label and right item*/
} LLToolBarStyle;

@interface LLToolbar : UIToolbar

/**
 initilze a top bar with special style and the name of right button.
 */
- (id)initTopBarWithStyle:(LLToolBarStyle)barStyle rightImageName:(NSString *)rightImageName backBtnClickHandler:(void(^)(void))backBtnClickHandler rightBtnClickHandler:(void(^)(UIButton *rightBtn))rightBtnClickHandler;

/**
 initilze a bottom bar with special tailor button and confirm button handler.
 */
- (id)initWithBottomBarWithStyle:(LLToolBarStyle)barStyle leftBtnClickHandler:(void(^)(void))tailorBtnClickHandler confirmBtnClickHandler:(void(^)(UIButton *confirmBtn))confirmBtnClickHandler;


/**
 title label of top bar.
 */
@property (nonatomic, strong) UILabel *titleLbl;

/**
 right button of the bar.
 */
@property (nonatomic, strong) UIButton *rightBtn;


/**
 is disable show or dismiss. default is NO.
 */
@property (nonatomic, assign) BOOL isDisableShowDismiss;


/**
 show or dismiss the tool bar.
 */
- (void)showDismiss;

@end
