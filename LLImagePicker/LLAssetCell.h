//
//  LLAssetCell.h
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/8.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "LLPhoto.h"
#import "LLAssetsPickerConfig.h"

@interface LLAssetCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mainImgView;
@property (weak, nonatomic) IBOutlet UIButton *checkedBtn;

@property (nonatomic, copy) void(^onClickCheckBtn)(UIButton *checkBtn);

- (void)setPhoto:(LLPhoto *)photo itemSize:(CGSize)itemSize;

@property (nonatomic, strong) LLPhoto *photo;

@end
