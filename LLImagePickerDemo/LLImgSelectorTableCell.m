//
//  LLImgSelectorTableCell.m
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/24.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLImgSelectorTableCell.h"

@implementation LLImgSelectorTableCell

- (id)init{
    if (self = [super init]) {
        [self setImageSelector];
    }
    return self;
}

- (void)setImageSelector{
    _imageSelector = [[IHImageSelector alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_imageSelector];
    _imageSelector.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageSelector]|" options:0 metrics:nil views:@{@"_imageSelector":_imageSelector}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageSelector]|" options:0 metrics:nil views:@{@"_imageSelector":_imageSelector}]];
}

//算高
- (CGSize)sizeThatFits:(CGSize)size{
    NSUInteger count = _imageSelector.pickerAssets.count + 1;
    NSUInteger row = count / 4 + (count % 4 == 0 ? 0 : 1);
    CGFloat itemW = IMG_SELECTOR_ITEM_WIDTH;
    CGFloat height = 15+itemW*row+13*(row-1)+15;
    return CGSizeMake(size.width, height);
}

@end
