//
//  LLAlbumCell.m
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/8.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLAlbumCell.h"

@interface LLAlbumCell ()

@property (nonatomic, strong) PHImageRequestOptions *options;

@end

@implementation LLAlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _options = [PHImageRequestOptions new];
    _options.synchronous = YES; // 同步获得图片, 只会返回1张图片
}

- (void)setAlbum:(LLAlbum *)album{
    if (_album != album) {
        _titleLbl.text = album.title;
        _contentLbl.text = [NSString stringWithFormat:@"%ld",album.fetchResult.count];
        NSArray <UIImageView *> *imgViews = @[_topImgView,_centerImgView,_btmImgView];
        for (int i = 0; i < album.fetchResult.count; i++) {
            if (i >= 3) {
                break;
            }
            [[PHImageManager defaultManager] requestImageForAsset:album.fetchResult[i] targetSize:imgViews[i].bounds.size contentMode:PHImageContentModeDefault options:_options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                imgViews[i].image = result;
            }];
        }
    }
}

@end
