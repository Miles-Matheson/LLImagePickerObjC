//
//  LLToolbar.m
//  LLImagePickerDemo
//
//  Created by kevin on 2017/11/12.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLToolbar.h"

@interface LLToolbar ()

@property (nonatomic, assign) BOOL isShow;

@property (nonatomic, copy) void (^onClickBackBtn)(void);
@property (nonatomic, copy) void (^onClickRightBtn)(UIButton *rightBtn);

@property (nonatomic, copy) void (^onClickLeftBtn)(void);
@property (nonatomic, copy) void (^onClickConfirmBtn)(UIButton *confirmBtn);

@end

@implementation LLToolbar

/**
 initilze a top bar with special style and the name of right button.
 */
- (id)initTopBarWithStyle:(LLToolBarStyle)barStyle rightImageName:(NSString *)rightImageName backBtnClickHandler:(void(^)(void))backBtnClickHandler rightBtnClickHandler:(void(^)(UIButton *rightBtn))rightBtnClickHandler{
    if (self = [super init]) {
        _onClickBackBtn = backBtnClickHandler;
        _onClickRightBtn = rightBtnClickHandler;
        self.barTintColor = nil;
        self.barStyle = UIBarStyleBlackTranslucent;
        LLAssetsPickerConfig *pickerConfig = [LLAssetsPickerConfig shared];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[pickerConfig.backImage?:[UIImage imageNamed:@"llimagepicker_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(clickBackBtn)];
        _titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds) - 16 - 34 - 16 - 34, 0)];
        _titleLbl.text = @" ";
        _titleLbl.textAlignment = NSTextAlignmentCenter;
        _titleLbl.textColor = [UIColor whiteColor];
        _titleLbl.font = [UIFont systemFontOfSize:18];
        UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithCustomView:_titleLbl];
        titleItem.width = CGRectGetWidth(_titleLbl.frame);
        UIBarButtonItem *checkItem = nil;
        //if (barStyle == LLToolBarStyleDefault) {
            //default style
            
        //} else {
            _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _rightBtn.frame = CGRectMake(0, 0, 34, 34);
            [_rightBtn setTitleColor:pickerConfig.checkedTintColor?:[UIColor whiteColor] forState:UIControlStateNormal];
            [_rightBtn setImage:pickerConfig.checkImage?:[UIImage imageNamed:rightImageName] forState:UIControlStateNormal];
            _rightBtn.layer.masksToBounds = YES;
            _rightBtn.layer.cornerRadius = 34 / 2.0f;
            [_rightBtn addTarget:self action:@selector(clickCheckBtn:) forControlEvents:UIControlEventTouchUpInside];
            checkItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBtn];
            checkItem.width = 34;
        //}
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceItem.width = 34;
        self.items = @[backItem,titleItem,checkItem?:spaceItem];
    }
    return self;
}

- (void)clickBackBtn{
    if (_onClickBackBtn) {
        _onClickBackBtn();
    }
}

- (void)clickCheckBtn:(UIButton *)rightBtn{
    if (_onClickRightBtn) {
        _onClickRightBtn(rightBtn);
    }
}

/**
 initilze a bottom bar with special left button and confirm button handler.
 */
- (id)initWithBottomBarWithStyle:(LLToolBarStyle)barStyle leftBtnClickHandler:(void(^)(void))leftBtnClickHandler confirmBtnClickHandler:(void(^)(UIButton *confirmBtn))confirmBtnClickHandler{
    if (self = [super init]) {
        _onClickLeftBtn = leftBtnClickHandler;
        _onClickConfirmBtn = confirmBtnClickHandler;
        self.barTintColor = nil;
        self.barStyle = UIBarStyleBlackTranslucent;
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"裁剪" style:UIBarButtonItemStylePlain target:self action:@selector(clickLeftItem)];
        leftItem.tintColor = [UIColor whiteColor];
        leftItem.width = 34;
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceItem.width = CGRectGetWidth([UIScreen mainScreen].bounds) - 15 - 44 - 15 - 44;
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(0, 0, 44, 44);
        [_rightBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _rightBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_rightBtn addTarget:self action:@selector(clickConfirmBtn:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBtn];
        if (barStyle == LLToolBarStyleThreeItems) {
            leftItem.title = @"";
            LLAssetsPickerConfig *pickerConfig = [LLAssetsPickerConfig shared];
            leftItem.image = pickerConfig.closeImage?:[UIImage imageNamed:@"llimagepicker_close"];
            [_rightBtn setTitle:nil forState:UIControlStateNormal];
            [_rightBtn setImage:pickerConfig.confirmImage?:[UIImage imageNamed:@"llimagepicker_confirm"] forState:UIControlStateNormal];
        }
        self.items = @[barStyle == LLToolBarStyleTitleAndRightItem ? spaceItem : leftItem,spaceItem,confirmItem];
    }
    return self;
}

- (void)clickConfirmBtn:(UIButton *)confirmBtn{
    if (_onClickConfirmBtn) {
        _onClickConfirmBtn(confirmBtn);
    }
}

- (void)clickLeftItem{
    if (_onClickLeftBtn) {
        _onClickLeftBtn();
    }
}

- (void)showDismiss{
    if (_isDisableShowDismiss) {
        return;
    }
    [UIView animateWithDuration:0.25f animations:^{
        self.transform = self.isShow ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, self.frame.origin.y == 0 ? -kTopBarHeight : kBottomBarHeight);
    }];
    self.isShow = !self.isShow;
}

@end
