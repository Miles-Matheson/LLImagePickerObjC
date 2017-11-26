//
//  LLCheckManager.h
//  LLImagePickerDemo
//
//  Created by kevin on 2017/11/12.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "LLPhoto.h"

@interface LLCheckManager : NSObject

@property (nonatomic, strong) NSMutableDictionary <NSNumber *,LLPhoto *> *checkedPhotos;

@property (nonatomic, copy) void(^pickingMoreThanMaxNum)(void);

/**
 the handle of response check button clicked.
 invoke the method on check on check button clicked.
 the method update checkedPhotos dictionary and check button status.
 */
- (void)clickCheckBtn:(UIButton *)checkBtn currentIndex:(NSUInteger)currentIndex photo:(LLPhoto *)photo;

/**
 initilize the check button status.
 */
- (void)initCheckBtnStatus:(UIButton *)checkBtn currentIndex:(NSUInteger)currentIndex;

@end
