//
//  LLZoomScrollView.m
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/9.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLZoomScrollView.h"
#import "DACircularProgressView.h"
#import "LLAssetsPickerConfig.h"

@interface LLZoomScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) LLZoomImageView *bgZoomView;

@property (nonatomic, strong) DACircularProgressView *loadingIndicator;
@property (nonatomic, strong) UIImageView *loadingError;

@end

@implementation LLZoomScrollView

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

- (void)setPhoto:(LLPhoto *)photo{
    if (_photo != photo) {
        _photo = photo;
        [self reloadData];
    }
}


/**
 reload zoom image view's image and reset scroll max min scale.
 */
- (void)reloadData{
    __weak typeof(self) weakSelf = self;
    [self hideImageFailure];
    if (!_zoomImageView.image) {
        weakSelf.loadingIndicator.hidden = NO;
    }
    [_photo getImageWithTargetSize:_zoomImageView.frame.size resultHandler:^(UIImage *result, NSDictionary *info) {
        if (result) {
            weakSelf.loadingIndicator.hidden = YES;
            [weakSelf hideImageFailure];
            
            weakSelf.zoomImageView.image = result;
            
            // Setup photo frame
            CGRect photoImageViewFrame;
            photoImageViewFrame.origin = CGPointZero;
            photoImageViewFrame.size = result.size;
            _zoomImageView.frame = photoImageViewFrame;
            weakSelf.contentSize = photoImageViewFrame.size;
            
            // Set zoom to minimum zoom
            [weakSelf setScrollMaxMinZoomScale];
            
            [weakSelf setNeedsLayout];
        } else {
            if ([info[PHImageCancelledKey] boolValue]) {
                //cancel load
                return ;
            }
            // load image failed!
            [weakSelf displayImageFailure];
        }
    } progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.loadingIndicator.progress = MIN(MAX(progress, 0), 1);
            if (progress >= 1) {
                weakSelf.loadingIndicator.hidden = YES;
            } else {
                weakSelf.loadingIndicator.hidden = NO;
            }
        });
    }];
}

- (void)setUI{
    self.backgroundColor = [UIColor blackColor];
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.alwaysBounceHorizontal = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.clipsToBounds = NO;
    
    __weak typeof(self) weakSelf = self;
    
    // Tap view for background
    _bgZoomView = [[LLZoomImageView alloc] initWithFrame:self.bounds];
    _bgZoomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _bgZoomView.backgroundColor = [UIColor blackColor];
    [self addSubview:_bgZoomView];
    _bgZoomView.onSingleClick = ^(LLZoomImageView *imageView,UITapGestureRecognizer *tap) {
        // Translate touch location to image view location
        CGFloat touchX = [tap locationInView:weakSelf].x;
        CGFloat touchY = [tap locationInView:weakSelf].y;
        touchX *= 1/weakSelf.zoomScale;
        touchY *= 1/weakSelf.zoomScale;
        touchX += weakSelf.contentOffset.x;
        touchY += weakSelf.contentOffset.y;
        if (weakSelf.onSingleClick) {
            weakSelf.onSingleClick(CGPointMake(touchX, touchY));
        }
    };
    _bgZoomView.onDoubleClick = ^(LLZoomImageView *imageView, UITapGestureRecognizer *tap) {
        // Translate touch location to image view location
        CGFloat touchX = [tap locationInView:weakSelf].x;
        CGFloat touchY = [tap locationInView:weakSelf].y;
        touchX *= 1/weakSelf.zoomScale;
        touchY *= 1/weakSelf.zoomScale;
        touchX += weakSelf.contentOffset.x;
        touchY += weakSelf.contentOffset.y;
        [weakSelf handleDoubleClick:CGPointMake(touchX, touchY)];
    };
    
    _zoomImageView = [[LLZoomImageView alloc] initWithFrame:self.bounds];
    _zoomImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:_zoomImageView];
    _zoomImageView.onSingleClick = ^(LLZoomImageView *imageView, UITapGestureRecognizer *tap) {
        if (weakSelf.onSingleClick) {
            weakSelf.onSingleClick([tap locationInView:weakSelf]);
        }
    };
    _zoomImageView.onDoubleClick = ^(LLZoomImageView *imageView, UITapGestureRecognizer *tap) {
        [weakSelf handleDoubleClick:[tap locationInView:weakSelf]];
    };
    
    // Loading indicator
    _loadingIndicator = [[DACircularProgressView alloc] initWithFrame:CGRectMake(140.0f, 30.0f, 40.0f, 40.0f)];
    _loadingIndicator.userInteractionEnabled = NO;
    _loadingIndicator.thicknessRatio = 0.1;
    _loadingIndicator.roundedCorners = NO;
    _loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:_loadingIndicator];
}

// Image failed so just show black!
- (void)displayImageFailure {
    _loadingIndicator.hidden = YES;
    _zoomImageView.image = nil;
    
    // Show if image is not empty
    if (!_loadingError) {
        _loadingError = [UIImageView new];
        _loadingError.image = [LLAssetsPickerConfig shared].loadFailedImage?:[UIImage imageNamed:@"llimagepicker_loadfailed"];
        _loadingError.userInteractionEnabled = NO;
        _loadingError.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        [_loadingError sizeToFit];
        [self addSubview:_loadingError];
    }
    _loadingError.frame = CGRectMake(floorf((self.bounds.size.width - _loadingError.frame.size.width) / 2.),
                                     floorf((self.bounds.size.height - _loadingError.frame.size.height) / 2),
                                     _loadingError.frame.size.width,
                                     _loadingError.frame.size.height);
}

- (void)hideImageFailure {
    if (_loadingError) {
        [_loadingError removeFromSuperview];
        _loadingError = nil;
    }
}

- (void)setScrollMaxMinZoomScale{
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    if (!_zoomImageView.image) {
        return;
    }
    // Reset position
    _zoomImageView.frame = CGRectMake(0, 0, _zoomImageView.image.size.width, _zoomImageView.image.size.height);
    CGFloat minXScale = CGRectGetWidth(self.bounds) / _zoomImageView.image.size.width;
    CGFloat minYScale = CGRectGetHeight(self.bounds) / _zoomImageView.image.size.height;
    CGFloat minZoomScale = MIN(minXScale, minYScale);
    CGFloat maxZoomScale = 3;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // ipad
        maxZoomScale = 4;
    }
    // Image is smaller than screen so no zooming!
    if (minXScale >= 1 && minYScale >= 1) {
        minZoomScale = 1.0;
    }
    self.minimumZoomScale = minZoomScale;
    self.maximumZoomScale = maxZoomScale;
    // Initial zoom
    self.zoomScale = self.minimumZoomScale;
    // If we're zooming to fill then centralise
    if (self.zoomScale != minZoomScale) {
        // Centralise
        self.contentOffset = CGPointMake(_zoomImageView.image.size.width * self.zoomScale - CGRectGetWidth(self.bounds)/ 2.0,
                                         (_zoomImageView.image.size.height * self.zoomScale - CGRectGetHeight(self.bounds)) / 2.0);
    }
    // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
    self.scrollEnabled = NO;
    [self layoutSubviews];
}

- (void)handleDoubleClick:(CGPoint)touchPoint{
    if (!_loadingIndicator.hidden || _loadingError) {
        //loading or load failed disable handle double click event.
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.zoomScale != self.minimumZoomScale) {
        //缩放到最小
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        touchPoint.x /= self.zoomScale;
        touchPoint.y /= self.zoomScale;
        CGFloat zoomScale = (self.minimumZoomScale + self.maximumZoomScale) / 2.0f;
        CGFloat width = self.frame.size.width / zoomScale;
        CGFloat height = self.frame.size.height / zoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - width / 2.0f, touchPoint.y - height / 2.0f, width, height) animated:YES];
    }
}

- (void)layoutSubviews{
    // Update tap view frame
    _bgZoomView.frame = self.bounds;
    // Position indicators (centre does not seem to work!)
    if (!_loadingIndicator.hidden)
        _loadingIndicator.frame = CGRectMake(floorf((self.bounds.size.width - _loadingIndicator.frame.size.width) / 2.),
                                             floorf((self.bounds.size.height - _loadingIndicator.frame.size.height) / 2),
                                             _loadingIndicator.frame.size.width,
                                             _loadingIndicator.frame.size.height);
    
    if (_loadingError)
        _loadingError.frame = CGRectMake(floorf((self.bounds.size.width - _loadingError.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingError.frame.size.height) / 2),
                                         _loadingError.frame.size.width,
                                         _loadingError.frame.size.height);
    
    [super layoutSubviews];
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _zoomImageView.frame;
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    // Center
    if (!CGRectEqualToRect(_zoomImageView.frame, frameToCenter))
        _zoomImageView.frame = frameToCenter;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _zoomImageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.scrollEnabled = YES; // reset
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_onScrollViewWillBeginDragging) {
        _onScrollViewWillBeginDragging(scrollView);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_onScrollViewDidEndDragging) {
        _onScrollViewDidEndDragging(scrollView);
    }
}

//- (void)dealloc{
//    [_photo cancelAllLoading];
//}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if (CGRectContainsPoint(self.zoomImageView.frame, point)) {
        return YES;
    }
    return [super pointInside:point withEvent:event];
}

@end
