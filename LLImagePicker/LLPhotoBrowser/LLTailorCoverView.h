//
//  LLTailorCoverView.h
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/9.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LLTailorCoverViewTypeFreeDragging = 0, /*自由拖动 , 默认模式*/
    LLTailorCoverViewTypeSpecialAspectRatio, /*固定宽高比拖动*/
} LLTailorCoverViewType;

@interface LLTailorCoverView : UIView

@property (nonatomic, assign) CGFloat aspectRatio; /*纵横比 , 宽高比*/

@property (nonatomic, assign) CGRect selfFrame; //记录self的当前frame

@property (nonatomic, copy) void (^onPanGestureDidEnd)(LLTailorCoverView *tailorView);

- (id)initWithFrame:(CGRect)frame type:(LLTailorCoverViewType)type;

- (void)showBlackCover;
- (void)dismissBlackCover;

@end

@interface LLBlackCoverView: UIView

@property (nonatomic, assign) CGRect tailorViewFrame;

@property (nonatomic, assign) CGFloat shortSegmentHW;

@end
