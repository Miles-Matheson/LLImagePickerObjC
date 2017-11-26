//
//  LLTailorCoverView.m
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/9.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLTailorCoverView.h"
#import "LLToolbar.h"

typedef enum : NSUInteger {
    LLTailorCoverViewPanDirectionNone = 0,
    LLTailorCoverViewPanDirectionTop,
    LLTailorCoverViewPanDirectionLeft,
    LLTailorCoverViewPanDirectionBottom,
    LLTailorCoverViewPanDirectionRight,
    LLTailorCoverViewPanDirectionLeftTop,
    LLTailorCoverViewPanDirectionRightTop,
    LLTailorCoverViewPanDirectionRightBottom,
    LLTailorCoverViewPanDirectionLeftBottom,
} LLTailorCoverViewPanDirection;

#define kInteractionRange 40

#define kLineWidth 3

#define kShortSegmentHW (_initFrame.size.width/3.0f/4)

@interface LLTailorCoverView ()

@property (nonatomic, assign) LLTailorCoverViewType type; //裁剪视图的类型

@property (nonatomic, assign) CGRect initFrame; //记录最初的frame

@property (nonatomic, assign) CGPoint lastPoint; //记录上一次拖动的点

@property (nonatomic, assign) LLTailorCoverViewPanDirection panDiretion; //记录拖动收拾方向

@property (nonatomic, strong) LLBlackCoverView *blackCoverView;

@end

@implementation LLTailorCoverView

- (id)initWithFrame:(CGRect)frame type:(LLTailorCoverViewType)type{
    if (self = [super initWithFrame:frame]) {
        _type = type;
        _initFrame = frame;
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    _aspectRatio = 2;
    self.backgroundColor = [UIColor clearColor];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panSelf:)];
    [self addGestureRecognizer:pan];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_blackCoverView) {
        _blackCoverView = [[LLBlackCoverView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.superview.bounds), CGRectGetHeight(self.superview.bounds)-kBottomBarHeight)];
        [self.superview addSubview:_blackCoverView];
        _blackCoverView.userInteractionEnabled = NO;
        _blackCoverView.tailorViewFrame = self.frame;
        _blackCoverView.shortSegmentHW = kShortSegmentHW;
        _blackCoverView.backgroundColor = [UIColor clearColor];
    }
}

- (void)dealloc{
    if (_blackCoverView) {
        [_blackCoverView removeFromSuperview];
        _blackCoverView = nil;
    }
}

- (void)showBlackCover{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(performShowBlackCoverAnimation) withObject:nil afterDelay:1];
}

- (void)performShowBlackCoverAnimation{
    _blackCoverView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        _blackCoverView.alpha = 1;
    }];
}

- (void)dismissBlackCover{
    if (_blackCoverView.alpha == 0) {
        return;
    }
    _blackCoverView.alpha = 1;
    [UIView animateWithDuration:0.5 animations:^{
        _blackCoverView.alpha = 0;
    }];
}

- (void)panSelf:(UIPanGestureRecognizer *)pan{
    CGPoint transPoint = [pan translationInView:self];
    CGFloat halfOfInteraction = kInteractionRange / 2;
    CGFloat selfW = CGRectGetWidth(self.bounds);
    CGFloat selfH = CGRectGetHeight(self.bounds);
    CGPoint currentPoint = [pan locationInView:self];
    CGRect frame = self.frame;
    if (pan.state == UIGestureRecognizerStateBegan) {
        _selfFrame = self.frame;
        _lastPoint = [pan locationInView:self];
        [pan setTranslation:CGPointZero inView:self];
        _panDiretion = LLTailorCoverViewPanDirectionNone;
        if (CGRectContainsPoint(CGRectMake(- halfOfInteraction, - halfOfInteraction, kInteractionRange, kInteractionRange), _lastPoint)) {
            _panDiretion = LLTailorCoverViewPanDirectionLeftTop;
        } else if (CGRectContainsPoint(CGRectMake(selfW - halfOfInteraction, 0, kInteractionRange, kInteractionRange), _lastPoint)){
            _panDiretion = LLTailorCoverViewPanDirectionRightTop;
        } else if (CGRectContainsPoint(CGRectMake(selfW - halfOfInteraction, selfH-halfOfInteraction, kInteractionRange, kInteractionRange), _lastPoint)){
            _panDiretion = LLTailorCoverViewPanDirectionRightBottom;
        } else if (CGRectContainsPoint(CGRectMake(- halfOfInteraction, selfH-halfOfInteraction, kInteractionRange, kInteractionRange), _lastPoint)){
            _panDiretion = LLTailorCoverViewPanDirectionLeftBottom;
        } else if (_lastPoint.x > selfW - halfOfInteraction && _lastPoint.x < selfW + halfOfInteraction){
            _panDiretion = LLTailorCoverViewPanDirectionRight;
        } else if (_lastPoint.x < halfOfInteraction && _lastPoint.x > -halfOfInteraction){
            _panDiretion = LLTailorCoverViewPanDirectionLeft;
        } else if (_lastPoint.y < halfOfInteraction && _lastPoint.y > -halfOfInteraction){
            _panDiretion = LLTailorCoverViewPanDirectionTop;
        } else if (_lastPoint.y < selfH + halfOfInteraction && _lastPoint.y > selfH - halfOfInteraction){
            _panDiretion = LLTailorCoverViewPanDirectionBottom;
        }
    } else if (pan.state == UIGestureRecognizerStateChanged){
        
        if (_panDiretion == LLTailorCoverViewPanDirectionLeftTop) {
            //拖动左上角
            if ((currentPoint.x > _lastPoint.x && currentPoint.y > _lastPoint.y) || (currentPoint.x < _lastPoint.x && currentPoint.y < _lastPoint.y) ){
                //拖动左部
                frame.size.width = _selfFrame.size.width - transPoint.x;
                frame.origin.x = _selfFrame.origin.x + transPoint.x;
                if (_type == LLTailorCoverViewTypeFreeDragging) {
                    //拖动上部
                    frame.size.height = _selfFrame.size.height - transPoint.y;
                    frame.origin.y = _selfFrame.origin.y + transPoint.y;
                } else {
                    frame.size.height = frame.size.width / _aspectRatio;
                    frame.origin.y += self.frame.size.height - frame.size.height;
                }
            }
        } else if (_panDiretion == LLTailorCoverViewPanDirectionRightTop){
            //拖动右上角
            if ((currentPoint.x < _lastPoint.x && currentPoint.y > _lastPoint.y) || (currentPoint.x > _lastPoint.x && currentPoint.y < _lastPoint.y)) {
                //拖动上部
                frame.size.height = _selfFrame.size.height - transPoint.y;
                frame.origin.y = _selfFrame.origin.y + transPoint.y;
                if (_type == LLTailorCoverViewTypeFreeDragging) {
                    //拖动右部
                    frame.size.width = _selfFrame.size.width + transPoint.x;
                } else {
                    frame.size.width = frame.size.height * _aspectRatio;
                }
            }
        } else if (_panDiretion == LLTailorCoverViewPanDirectionRightBottom){
            //拖动右下角
            if ((currentPoint.x > _lastPoint.x && currentPoint.y > _lastPoint.y) || (currentPoint.x < _lastPoint.x && currentPoint.y < _lastPoint.y) ) {
                //拖动右部
                frame.size.width = _selfFrame.size.width + transPoint.x;
                if (_type == LLTailorCoverViewTypeFreeDragging) {
                    //拖动下部
                    frame.size.height = _selfFrame.size.height + transPoint.y;
                } else {
                    frame.size.height = frame.size.width / _aspectRatio;
                }
            }
        } else if (_panDiretion == LLTailorCoverViewPanDirectionLeftBottom){
            //拖动左下角
            if ((currentPoint.x < _lastPoint.x && currentPoint.y > _lastPoint.y) || (currentPoint.x > _lastPoint.x && currentPoint.y < _lastPoint.y)) {
                //拖动左部
                frame.size.width = _selfFrame.size.width - transPoint.x;
                frame.origin.x = _selfFrame.origin.x + transPoint.x;
                if (_type == LLTailorCoverViewTypeFreeDragging) {
                    //拖动下部
                    frame.size.height = _selfFrame.size.height + transPoint.y;
                } else {
                    frame.size.height = frame.size.width / _aspectRatio;
                }
            }
        } else if (_panDiretion == LLTailorCoverViewPanDirectionRight) {
            //拖动右部
            if (_type == LLTailorCoverViewTypeSpecialAspectRatio) {
                //固定纵横比模式下，禁止拖动右部
                return;
            }
            frame.size.width = _selfFrame.size.width + transPoint.x;
        } else if (_panDiretion == LLTailorCoverViewPanDirectionLeft){
            //拖动左部
            if (_type == LLTailorCoverViewTypeSpecialAspectRatio) {
                //固定纵横比模式下，禁止拖动左部
                return;
            }
            frame.size.width = _selfFrame.size.width - transPoint.x;
            frame.origin.x = _selfFrame.origin.x + transPoint.x;
        } else if (_panDiretion == LLTailorCoverViewPanDirectionTop){
            //拖动上部
            if (_type == LLTailorCoverViewTypeSpecialAspectRatio) {
                //固定纵横比模式下，禁止拖动上部
                return;
            }
            frame.size.height = _selfFrame.size.height - transPoint.y;
            frame.origin.y = _selfFrame.origin.y + transPoint.y;
        } else if(_panDiretion == LLTailorCoverViewPanDirectionBottom) {
            //拖动下部
            if (_type == LLTailorCoverViewTypeSpecialAspectRatio) {
                //固定纵横比模式下，禁止拖动下部
                return;
            }
            frame.size.height = _selfFrame.size.height + transPoint.y;
        }
        
        //限制frame最大最小范围
        if (frame.size.width < _initFrame.size.width / 3.0f) {
            frame.size.width = _initFrame.size.width / 3.0f;
            frame.origin.x = self.frame.origin.x;
        }
        if (frame.size.height < _initFrame.size.height / 3.0f){
            frame.size.height = _initFrame.size.height / 3.0f;
            frame.origin.y = self.frame.origin.y;
        }
        if (frame.origin.x < _initFrame.origin.x) {
            frame.origin.x = _initFrame.origin.x;
        }
        if (frame.origin.y < _initFrame.origin.y) {
            frame.origin.y  = _initFrame.origin.y;
        }
        if (frame.origin.x > _initFrame.size.width - _initFrame.size.width / 3.0f + _initFrame.origin.x) {
            frame.origin.x = _initFrame.size.width - _initFrame.size.width / 3.0f + _initFrame.origin.x;
        }
        if (frame.origin.y > _initFrame.size.height - _initFrame.size.height / 3.0f + _initFrame.origin.y) {
            frame.origin.y = _initFrame.size.height - _initFrame.size.height / 3.0f + _initFrame.origin.y;
        }
        if (CGRectGetMaxX(frame) > CGRectGetMaxX(_initFrame) || CGRectGetMaxY(frame) > CGRectGetMaxY(_initFrame) || CGRectGetMinX(frame) < CGRectGetMinX(_initFrame) || CGRectGetMinY(frame) < CGRectGetMinY(_initFrame)) {
            _lastPoint = [pan locationInView:self];
            return;
        }
        self.frame = frame;
        [self setNeedsDisplay];
        _lastPoint = [pan locationInView:self];
        
        _blackCoverView.tailorViewFrame = frame;
        [_blackCoverView setNeedsDisplay];
    } else if (pan.state == UIGestureRecognizerStateEnded){
        _panDiretion = LLTailorCoverViewPanDirectionNone;
        if (_onPanGestureDidEnd) {
            _onPanGestureDidEnd(self);
        }
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGFloat halfOfInteraction = kInteractionRange / 2;
    BOOL isInsideInLeftBorder = point.x < halfOfInteraction && point.x > -halfOfInteraction;
    BOOL isInsideInRightBorder = point.x > CGRectGetWidth(self.bounds)-halfOfInteraction && point.x < CGRectGetWidth(self.bounds)+halfOfInteraction;
    BOOL isInsideInTopBorder = point.y < halfOfInteraction && point.y > -halfOfInteraction;
    BOOL isInsideInBottomBorder = point.y > CGRectGetHeight(self.bounds) - halfOfInteraction && point.y < CGRectGetHeight(self.bounds) + halfOfInteraction;
    BOOL isBetweenInLeftRight = point.x > 0 && point.x < CGRectGetWidth(self.bounds);
    BOOL isBetweenInTopBottom = point.y > 0 && point.y < CGRectGetHeight(self.bounds);
    if (((isInsideInLeftBorder || isInsideInRightBorder) && isBetweenInTopBottom) || ((isInsideInTopBorder || isInsideInBottomBorder) && isBetweenInLeftRight)) {
        return YES;
    }
    return NO;
}

- (void)drawRect:(CGRect)rect{
    CGFloat lineWidth = kLineWidth;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, lineWidth); //线宽
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
    
    CGFloat maxWidth = CGRectGetWidth(self.frame);
    CGFloat maxHeight = CGRectGetHeight(self.frame);
    CGFloat segmentWidth = maxWidth / 3.0f;
    CGFloat segmentHeight = maxHeight / 3.0f;
    CGFloat shortSegmentH = kShortSegmentHW;
    
    //画边角
    CGFloat halfOfLineWidth = lineWidth / 2.0f;
    CGPoint points[][3] = {{CGPointMake(shortSegmentH, halfOfLineWidth),CGPointMake(halfOfLineWidth, halfOfLineWidth),CGPointMake(halfOfLineWidth, shortSegmentH)},
                           {CGPointMake(maxWidth - shortSegmentH, halfOfLineWidth),CGPointMake(maxWidth - halfOfLineWidth, halfOfLineWidth),CGPointMake(maxWidth - halfOfLineWidth, shortSegmentH)},
                           {CGPointMake(maxWidth - halfOfLineWidth, maxHeight - shortSegmentH),CGPointMake(maxWidth - halfOfLineWidth, maxHeight - halfOfLineWidth),CGPointMake(maxWidth - shortSegmentH, maxHeight - halfOfLineWidth)},
                           {CGPointMake(shortSegmentH, maxHeight - halfOfLineWidth),CGPointMake(halfOfLineWidth, maxHeight - halfOfLineWidth),CGPointMake(halfOfLineWidth, maxHeight - shortSegmentH)},
                          };
    for (int i = 0; i < 4; i++) {
        [self drawLine:context points:points[i] count:3];
    }
    
    CGContextSetLineWidth(context, 1.3f); //线宽
    //画矩形
    CGContextStrokeRect(context, CGRectMake(lineWidth, lineWidth, CGRectGetWidth(self.bounds) - lineWidth*2, CGRectGetHeight(self.bounds) - lineWidth*2));
    
    //画线
    CGPoint startPoints[] = {CGPointMake(lineWidth, segmentHeight),CGPointMake(lineWidth, segmentHeight*2),CGPointMake(segmentWidth, lineWidth),CGPointMake(segmentWidth*2, lineWidth)};
    CGPoint endPoints[] = {CGPointMake(maxWidth - lineWidth, segmentHeight),CGPointMake(maxWidth - lineWidth, segmentHeight*2),CGPointMake(segmentWidth, maxHeight - lineWidth),CGPointMake(segmentWidth*2, maxHeight - lineWidth)};
    for (int i = 0; i < 4; i++) {
        CGPoint points[] = {startPoints[i],endPoints[i]};
        [self drawLine:context points:points count:2];
    }
}

//画线
- (void)drawLine:(CGContextRef)context points:(CGPoint[])points count:(NSUInteger)count{
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, points[0].x, points[0].y);
    for (int i = 1; i < count; i++) {
        CGContextAddLineToPoint(context, points[i].x, points[i].y);
    }
    CGContextStrokePath(context);
}

@end

@implementation LLBlackCoverView

// draw black cover view out of range in tailor cover view
- (void)drawRect:(CGRect)rect{
    //return;
    CGFloat lineWidth = kLineWidth;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGFloat selfWidth = CGRectGetWidth(self.bounds);
    CGFloat selfHeight = CGRectGetHeight(self.bounds);
    CGFloat tailorWidth = CGRectGetWidth(self.tailorViewFrame);
    CGFloat tailorHeight = CGRectGetHeight(self.tailorViewFrame);
    CGFloat tailorX = CGRectGetMinX(self.tailorViewFrame);
    CGFloat tailorY = CGRectGetMinY(self.tailorViewFrame);
    CGPoint points[] = {CGPointMake(0, selfHeight),
                        CGPointMake(selfWidth, selfHeight),
                        CGPointMake(selfWidth, 0),
                        CGPointMake(tailorX+tailorWidth, 0),
                        CGPointMake(tailorX+tailorWidth, tailorY),
                        CGPointMake(tailorX+tailorWidth, tailorY+_shortSegmentHW),
                        CGPointMake(tailorX+tailorWidth-lineWidth, tailorY+_shortSegmentHW),
                        CGPointMake(tailorX+tailorWidth-lineWidth, tailorY+tailorHeight-_shortSegmentHW),
                        CGPointMake(tailorX+tailorWidth, tailorY+tailorHeight-_shortSegmentHW),
                        CGPointMake(tailorX+tailorWidth, tailorY+tailorHeight),
                        CGPointMake(tailorX+tailorWidth-_shortSegmentHW, tailorY+tailorHeight),
                        CGPointMake(tailorX+tailorWidth-_shortSegmentHW, tailorY+tailorHeight-lineWidth),
                        CGPointMake(tailorX+_shortSegmentHW, tailorY+tailorHeight-lineWidth),
                        CGPointMake(tailorX+_shortSegmentHW, tailorY+tailorHeight),
                        CGPointMake(tailorX, tailorY+tailorHeight),
                        CGPointMake(tailorX, tailorY+tailorHeight-_shortSegmentHW),
                        CGPointMake(tailorX+lineWidth, tailorY+tailorHeight-_shortSegmentHW),
                        CGPointMake(tailorX+lineWidth, tailorY+_shortSegmentHW),
                        CGPointMake(tailorX, tailorY+_shortSegmentHW),
                        CGPointMake(tailorX, tailorY),
                        CGPointMake(tailorX+_shortSegmentHW, tailorY),
                        CGPointMake(tailorX+_shortSegmentHW, tailorY+lineWidth),
                        CGPointMake(tailorX+tailorWidth-_shortSegmentHW, tailorY+lineWidth),
                        CGPointMake(tailorX+tailorWidth-_shortSegmentHW, tailorY),
                        CGPointMake(tailorX+tailorWidth, tailorY),
                        CGPointMake(tailorX+tailorWidth, 0),
                        CGPointMake(0, 0),
                    };
    NSUInteger count = sizeof(points) / sizeof(points[0]);
    for (int i = 0; i < count; i++) {
        CGContextAddLineToPoint(context, points[i].x, points[i].y);
    }
    UIColor*aColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
    CGContextDrawPath(context, kCGPathFill); //绘制路径加填充
}

@end
