//
//  LLCheckManager.m
//  LLImagePickerDemo
//
//  Created by kevin on 2017/11/12.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLCheckManager.h"
#import "UIView+LLAnimation.h"
#import "UIView+LLToast.h"
#import "LLAssetsPickerConfig.h"

@interface LLCheckManager ()

@end

@implementation LLCheckManager

- (id)init{
    if (self = [super init]) {
        _checkedPhotos = [NSMutableDictionary dictionary];
    }
    return self;
}

/**
 the handle of response check button clicked.
 invoke the method on check on check button clicked.
 the method update checkedPhotos dictionary and check button status
 */
- (void)clickCheckBtn:(UIButton *)checkBtn currentIndex:(NSUInteger)currentIndex photo:(LLPhoto *)photo{
    NSNumber *indexNumber = @(currentIndex);
    LLPhoto *checkPhoto = _checkedPhotos[indexNumber];
    if (checkPhoto) {
        //already checked state
        [_checkedPhotos removeObjectForKey:indexNumber];
        //checkedPhotos's key subtract 1 from _currentIndex+1
        NSUInteger startIndex = checkPhoto.checkIndex;
        for (NSNumber *photoIndex in _checkedPhotos) {
            if (_checkedPhotos[photoIndex].checkIndex >= startIndex) {
                _checkedPhotos[photoIndex].checkIndex -= 1;
            }
        }
        [self updateCheckBtnStatus:checkBtn isChecked:NO checkIndex:0 animated:YES];
    } else {
        //unchecked state
        // check is already select max number picture
        LLAssetsPickerConfig *pickerConfig = [LLAssetsPickerConfig shared];
        if (_checkedPhotos.count >= pickerConfig.maximumNumberOfSelection) {
            //already select max number. show alert to warn the user
            if (_pickingMoreThanMaxNum) {
                _pickingMoreThanMaxNum();
            } else {
                [[UIApplication sharedApplication].keyWindow show:[NSString stringWithFormat:[LLAssetsPickerConfig shared].alreadyReachMaxSelectPrompt?:@"您最多可选择%lu张",(unsigned long)pickerConfig.maximumNumberOfSelection]];
            }
            return;
        }
        NSUInteger checkIndex = _checkedPhotos.count;
        photo.checkIndex = checkIndex;
        photo.photoIndex = currentIndex;
        [_checkedPhotos setObject:photo forKey:indexNumber];
        [self updateCheckBtnStatus:checkBtn isChecked:YES checkIndex:checkIndex animated:YES];
    }
}

/**
 initilize the check button status
 */
- (void)initCheckBtnStatus:(UIButton *)checkBtn currentIndex:(NSUInteger)currentIndex{
    LLPhoto *photo = _checkedPhotos[@(currentIndex)];
    if (photo) {
        //already checked state
        [self updateCheckBtnStatus:checkBtn isChecked:YES checkIndex:photo.checkIndex animated:NO];
    } else {
        //unchecked state
        [self updateCheckBtnStatus:checkBtn isChecked:NO checkIndex:0 animated:NO];
    }
}

/**
 update the check button status
 */
- (void)updateCheckBtnStatus:(UIButton *)checkBtn isChecked:(BOOL)isChecked checkIndex:(NSUInteger)checkIndex animated:(BOOL)animated{
    LLAssetsPickerConfig *pickerConfig = [LLAssetsPickerConfig shared];
    if (isChecked) {
        checkBtn.selected = YES;
        checkBtn.backgroundColor = pickerConfig.checkedBackgroundColor?:[UIColor greenColor];
        [checkBtn setTitle:[NSString stringWithFormat:@"%ld",checkIndex+1] forState:UIControlStateNormal];
        [checkBtn setImage:[UIImage new] forState:UIControlStateNormal];
        if (animated) {
            [checkBtn showSpringBackAnimationView];
        }
    } else {
        checkBtn.selected = NO;
        checkBtn.backgroundColor = nil;
        [checkBtn setTitle:nil forState:UIControlStateNormal];
        [checkBtn setImage:[pickerConfig.checkImage?:[UIImage imageNamed:@"llimagepicker_check"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    }
}

@end
