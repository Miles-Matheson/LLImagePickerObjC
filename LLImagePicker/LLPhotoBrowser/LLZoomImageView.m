//
//  LLZoomImageView.m
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/9.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLZoomImageView.h"

@implementation LLZoomImageView

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleClick:)];
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
}

- (void)singleClick:(UITapGestureRecognizer *)tap{
    if (_onSingleClick) {
        _onSingleClick(self,tap);
    }
}

- (void)doubleClick:(UITapGestureRecognizer *)tap{
    if (_onDoubleClick) {
        _onDoubleClick(self,tap);
    }
}

@end
