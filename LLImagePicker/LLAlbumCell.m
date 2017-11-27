//
//  LLAlbumCell.m
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/8.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLAlbumCell.h"

@interface LLAlbumCell ()

@property (nonatomic, strong) UIView *imgBgView;
@property (nonatomic, strong) NSArray <UIImageView *> *imgViews;

@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UILabel *contentLbl;

@property (nonatomic, strong) PHImageRequestOptions *options;

@end

@implementation LLAlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _options = [PHImageRequestOptions new];
        _options.synchronous = YES; // 同步获得图片, 只会返回1张图片
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    _imgBgView = [UIView new];
    [self.contentView addSubview:_imgBgView];
    
    _titleLbl = [UILabel new];
    [self.contentView addSubview:_titleLbl];
    
    _contentLbl = [UILabel new];
    [self.contentView addSubview:_contentLbl];
    _contentLbl.font = [UIFont systemFontOfSize:13];
    
    NSMutableArray *imgViews = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        UIImageView *imgView = [UIImageView new];
        [_imgBgView addSubview:imgView];
        [imgViews addObject:imgView];
    }
    _imgViews = imgViews;
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints{
    [super updateConstraints];
    _imgBgView.translatesAutoresizingMaskIntoConstraints  = NO;
    _titleLbl.translatesAutoresizingMaskIntoConstraints   = NO;
    _contentLbl.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(_imgBgView,_titleLbl,_contentLbl);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_imgBgView(69)]-15-[_titleLbl]-15-|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_imgBgView]-15-[_contentLbl]-15-|" options:0 metrics:nil views:views]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_imgBgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:72]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_imgBgView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_imgBgView.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLbl attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_imgBgView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_contentLbl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_imgBgView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_titleLbl(_contentLbl)]-0-[_contentLbl]" options:0 metrics:nil views:views]];
    
    int count = (int)_imgViews.count;
    int tops[] = {0,1,3};
    for (int i = 0; i < count; i++) {
        _imgViews[i].translatesAutoresizingMaskIntoConstraints = NO;
        views = @{@"imgView":_imgViews[i]};
        [_imgBgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%d-[imgView]-%d-|",count-i,count-i] options:0 metrics:nil views:views]];
        [_imgBgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%d-[imgView]-0-|",tops[i]] options:0 metrics:nil views:views]];
    }
}

- (void)setAlbum:(LLAlbum *)album{
    if (_album != album) {
        _titleLbl.text = album.title;
        _contentLbl.text = [NSString stringWithFormat:@"%ld",(unsigned long)album.fetchResult.count];
        for (int i = 0; i < album.fetchResult.count; i++) {
            if (i >= 3) {
                break;
            }
            [[PHImageManager defaultManager] requestImageForAsset:album.fetchResult[i] targetSize:_imgViews[i].bounds.size contentMode:PHImageContentModeDefault options:_options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                _imgViews[i].image = result;
            }];
        }
    }
}

@end
