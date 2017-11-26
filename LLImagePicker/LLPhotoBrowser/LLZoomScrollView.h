//
//  LLZoomScrollView.h
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/9.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLPhoto.h"
#import "LLZoomImageView.h"

@interface LLZoomScrollView : UIScrollView

@property (nonatomic, strong) LLPhoto *photo;

@property (nonatomic, strong) LLZoomImageView *zoomImageView;

@property (nonatomic, copy) void (^onScrollViewWillBeginDragging)(UIScrollView *scrollView);
@property (nonatomic, copy) void (^onScrollViewDidEndDragging)(UIScrollView *scrollView);

@property (nonatomic, copy) void (^onSingleClick)(CGPoint point);

- (void)setScrollMaxMinZoomScale;

/**
 reload zoom image view's image and reset scroll max min scale.
 */
- (void)reloadData;

@end
