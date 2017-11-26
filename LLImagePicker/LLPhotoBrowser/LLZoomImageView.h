//
//  LLZoomImageView.h
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/9.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLZoomImageView : UIImageView

@property (nonatomic, copy) void(^onSingleClick)(LLZoomImageView *imageView,UITapGestureRecognizer *tap);
@property (nonatomic, copy) void(^onDoubleClick)(LLZoomImageView *imageView,UITapGestureRecognizer *tap);

@end
