//
//  LLPhotoBrowser.m
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/8.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLPhotoBrowser.h"
#import "LLZoomScrollView.h"
#import "LLToolbar.h"
#import "UIView+LLToast.h"

#define kPageSize 3  //分页尺寸

@interface LLPhotoBrowser () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *bgScrollView;
@property (nonatomic, assign) NSInteger lastIndex;
@property (nonatomic, assign) NSInteger oldIndex;

@property (nonatomic, strong) LLToolbar *topBar;
@property (nonatomic, strong) LLToolbar *bottomBar;

@property (nonatomic, strong) LLToolbar *tailorBtmBar;

@property (nonatomic, strong) LLTailorCoverView *tailorCoverView;

@property (nonatomic, copy) void(^clickTopRightBtnHandler)(LLPhotoBrowser *browser,UIButton *rightBtn);
@property (nonatomic, copy) void(^setRightBtnCallback)(LLPhotoBrowser *browser,UIButton *rightBtn);

@end

@implementation LLPhotoBrowser

- (id)initWithStyle:(LLPhotoBrowserStyle)style{
    if (self = [super init]) {
        self.style = style;
    }
    return self;
}

- (LLToolbar *)tailorBtmBar{
    if (!_tailorBtmBar) {
        __weak typeof(self) selfWeak = self;
        _tailorBtmBar = [[LLToolbar alloc] initWithBottomBarWithStyle:LLToolBarStyleThreeItems leftBtnClickHandler:^{
            // click close button. exit clip status to preview page.
            [selfWeak exitClipStatus];
        } confirmBtnClickHandler:^(UIButton *confirmBtn) {
            //click confirm button. clip the image and exit clip status to preview page.
            [selfWeak clipImage];
            [selfWeak exitClipStatus];
        }];
        _tailorBtmBar.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - kBottomBarHeight, CGRectGetWidth(self.view.bounds), kBottomBarHeight);
        [self.view addSubview:_tailorBtmBar];
        [_tailorBtmBar showDismiss];
    }
    return _tailorBtmBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setScrollView];
    _lastIndex = _currentIndex;
    _oldIndex = _currentIndex;
    [self prepareSubviews];
    _bgScrollView.contentOffset = CGPointMake(_currentIndex * CGRectGetWidth(self.view.bounds), 0);
    [self setTopBottomBar];
    [self updateDoneBtnStatus];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 开启返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setScrollView{
    _bgScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_bgScrollView];
    if (@available(iOS 11.0, *)) {
        _bgScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _bgScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _bgScrollView.delegate = self;
    _bgScrollView.pagingEnabled = YES;
    _bgScrollView.showsHorizontalScrollIndicator = NO;
    _bgScrollView.showsVerticalScrollIndicator = NO;
    _bgScrollView.backgroundColor = [UIColor blackColor];
    _bgScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setTopBarRightBtn:(void(^)(LLPhotoBrowser *browser,UIButton *rightBtn))setRightBtnCallback clickHandler:(void(^)(LLPhotoBrowser *browser,UIButton *rightBtn))clickHandler{
    _setRightBtnCallback = setRightBtnCallback;
    _clickTopRightBtnHandler = clickHandler;
}

/**
 reload dataSource of the photo browser
 */
- (void)reloadData{
    for (UIView *subView in _bgScrollView.subviews) {
        [subView removeFromSuperview];
    }
    [self prepareSubviews];
    //refresh title of the top bar
    [self refreshTopBarTitle];
}

- (void)prepareSubviews{
    __weak typeof(self) selfWeak = self;
    NSInteger leftIndex = _currentIndex - kPageSize / 2;
    if (leftIndex < 0) {
        leftIndex = 0;
    }
    int page = 0;
    for (NSInteger i = leftIndex; i < leftIndex+kPageSize; i++) {
        if ([_bgScrollView viewWithTag:i+100] || i >=  _items.count) {
            continue;
        }
        LLZoomScrollView *zoomScroll = [[LLZoomScrollView alloc] initWithFrame:CGRectMake(i*CGRectGetWidth(_bgScrollView.bounds), 0, CGRectGetWidth(_bgScrollView.bounds), CGRectGetHeight(_bgScrollView.bounds))];
        zoomScroll.photo = _items[i];
        zoomScroll.tag = i+100;
        zoomScroll.onScrollViewWillBeginDragging = ^(UIScrollView *scrollView) {
            if (selfWeak.tailorCoverView) {
                [selfWeak.tailorCoverView dismissBlackCover];
            }
        };
        zoomScroll.onScrollViewDidEndDragging = ^(UIScrollView *scrollView) {
            if (selfWeak.tailorCoverView) {
                [selfWeak.tailorCoverView showBlackCover];
            }
        };
        zoomScroll.onSingleClick = ^(CGPoint point) {
            if (selfWeak.topBar) {
                [selfWeak.topBar showDismiss];
            }
            if (selfWeak.bottomBar) {
                [selfWeak.bottomBar showDismiss];
            }
        };
        [_bgScrollView addSubview:zoomScroll];
        page++;
    }
    LLZoomScrollView *oldScroll = [_bgScrollView viewWithTag:(_lastIndex < _currentIndex ? (_currentIndex-kPageSize/2-1) : (_currentIndex+kPageSize/2+1))+100];
    if (oldScroll) {
        [oldScroll removeFromSuperview];
    }
    _bgScrollView.contentSize = CGSizeMake((_currentIndex+kPageSize > _items.count ? _items.count : (_currentIndex+kPageSize))*CGRectGetWidth(_bgScrollView.bounds), CGRectGetHeight(_bgScrollView.bounds));
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
    if (index == _currentIndex || index >= _items.count) {
        return;
    }
    _lastIndex = _currentIndex;
    _currentIndex = index;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self prepareSubviews];
    });
}

- (void)setTopBottomBar{
    __weak typeof(self) selfWeak = self;
    _topBar = [[LLToolbar alloc] initTopBarWithStyle:self.style == LLPhotoBrowserStyleDefault ? LLToolBarStyleDefault : LLToolBarStyleThreeItems rightImageName:@"check" backBtnClickHandler:^{
        if (selfWeak.navigationController) {
            [selfWeak.navigationController popViewControllerAnimated:YES];
        } else {
            [selfWeak.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    } rightBtnClickHandler:^(UIButton *rightBtn) {
        if (selfWeak.style == LLPhotoBrowserStyleDefault) {
            if (selfWeak.clickTopRightBtnHandler) {
                selfWeak.clickTopRightBtnHandler(selfWeak,rightBtn);
            }
        } else {
            LLZoomScrollView *currentScroll = [selfWeak.bgScrollView viewWithTag:100+selfWeak.currentIndex];
            if (currentScroll.photo.isInCloud) {
                // the current image is in iCloud , instead of in local Photos. so ignore this click
                return ;
            }
            [selfWeak.checkManager clickCheckBtn:rightBtn currentIndex:selfWeak.currentIndex photo:selfWeak.items[selfWeak.currentIndex]];
            // refresh bottom bar right button status
            [selfWeak updateDoneBtnStatus];
        }
    }];
    _topBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64);
    //refresh title of the top bar
    [self refreshTopBarTitle];
    [self.view addSubview:_topBar];
    if (_setRightBtnCallback) {
        _setRightBtnCallback(self,_topBar.rightBtn);
    }
    
    if (self.style == LLPhotoBrowserStyleDefault) {
        //default style not contain bottom bar.
        return;
    }
    
    _bottomBar = [[LLToolbar alloc] initWithBottomBarWithStyle:self.style == LLPhotoBrowserStyleCheck ? LLToolBarStyleTitleAndRightItem : LLToolBarStyleDefault leftBtnClickHandler:^{
        //click tailor button
        LLZoomScrollView *currentScroll = [selfWeak.bgScrollView viewWithTag:100+selfWeak.currentIndex];
        if (currentScroll.photo.isInCloud) {
            // the current image is in iCloud , instead of in local Photos. so ignore this click
            return ;
        }
        selfWeak.bgScrollView.scrollEnabled = NO;
        //scale the background scrollview
        [selfWeak.topBar showDismiss];
        [selfWeak.bottomBar showDismiss];
        selfWeak.topBar.isDisableShowDismiss = YES;
        selfWeak.bottomBar.isDisableShowDismiss = YES;
        
        [UIView animateWithDuration:0.3f animations:^{
            currentScroll.bounds = CGRectMake(0, 0, CGRectGetWidth(currentScroll.bounds)*0.70f, CGRectGetHeight(currentScroll.bounds)*0.70f);
            [currentScroll setScrollMaxMinZoomScale];
        } completion:^(BOOL finished) {
            LLAssetsPickerConfig *pickerConfig = [LLAssetsPickerConfig shared];
            CGRect frame = currentScroll.frame;
            frame.origin.x -= selfWeak.currentIndex * CGRectGetWidth(selfWeak.view.bounds);
            if (pickerConfig.clipViewType == LLTailorCoverViewTypeSpecialAspectRatio) {
                frame.size.height = CGRectGetWidth(frame) / pickerConfig.clipAspectRatio;
                if (CGRectGetHeight(frame) > CGRectGetHeight(currentScroll.frame)) {
                    frame.size.height = CGRectGetHeight(currentScroll.frame);
                }
            } else {
                frame.size.height = CGRectGetHeight(currentScroll.zoomImageView.frame);
            }
            frame.origin.y = currentScroll.center.y - CGRectGetHeight(frame) / 2;
            selfWeak.tailorCoverView = [[LLTailorCoverView alloc] initWithFrame:frame type:pickerConfig.clipViewType];
            selfWeak.tailorCoverView.onPanGestureDidEnd = ^(LLTailorCoverView *tailorView) {
                if (CGRectGetWidth(currentScroll.bounds) != CGRectGetWidth(tailorView.bounds) || CGRectGetHeight(currentScroll.bounds) != CGRectGetHeight(tailorView.bounds)) {
                    CGPoint contentOffset = currentScroll.contentOffset;
                    currentScroll.frame = [selfWeak.view convertRect:tailorView.frame toView:selfWeak.bgScrollView];
                    currentScroll.contentOffset = CGPointMake(contentOffset.x + tailorView.frame.origin.x - tailorView.selfFrame.origin.x,contentOffset.y + tailorView.frame.origin.y - tailorView.selfFrame.origin.y);
                }
            };
            [selfWeak.view addSubview:selfWeak.tailorCoverView];
            if (pickerConfig.clipViewType == LLTailorCoverViewTypeSpecialAspectRatio) {
                currentScroll.scrollEnabled = YES;
                currentScroll.bounds = selfWeak.tailorCoverView.bounds;
                currentScroll.center = [selfWeak.view convertPoint:selfWeak.tailorCoverView.center toView:selfWeak.bgScrollView];
                currentScroll.contentOffset = CGPointMake(0, currentScroll.contentSize.height / 2 - selfWeak.tailorCoverView.bounds.size.height / 2);
                selfWeak.tailorCoverView.aspectRatio = pickerConfig.clipAspectRatio;
            }
            [selfWeak.tailorBtmBar showDismiss];
        }];
        
    } confirmBtnClickHandler:^(UIButton *confirmBtn){
        //click confirm button
        //callback to pass the checked photos
        if (selfWeak.onClickConfirmBtn) {
            selfWeak.onClickConfirmBtn(selfWeak);
        }
    }];
    _bottomBar.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49, CGRectGetWidth(self.view.bounds), 49);
    [self.view addSubview:_bottomBar];
    
    if (_style != LLPhotoBrowserStyleDefault) {
        [_checkManager initCheckBtnStatus:_topBar.rightBtn currentIndex:_currentIndex];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (_style != LLPhotoBrowserStyleDefault) {
        [_checkManager initCheckBtnStatus:_topBar.rightBtn currentIndex:_currentIndex];
    }
    NSInteger index = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
    if (index != _oldIndex) {
        _oldIndex = index;
        LLZoomScrollView *currentScroll = [self.bgScrollView viewWithTag:100+self.currentIndex];
        [currentScroll reloadData];
        
        //refresh title of the top bar
        [self refreshTopBarTitle];
    }
}

- (void)clipImage{
    LLZoomScrollView *currentScroll = [_bgScrollView viewWithTag:100+_currentIndex];
    CGRect tailorFrame = [self.view convertRect:_tailorCoverView.frame toView:currentScroll.zoomImageView];
    CGFloat xScale = currentScroll.zoomImageView.bounds.size.width / currentScroll.zoomImageView.image.size.width;
    CGFloat yScale = currentScroll.zoomImageView.bounds.size.height / currentScroll.zoomImageView.image.size.height;
    CGFloat x = tailorFrame.origin.x * xScale;
    CGFloat y = tailorFrame.origin.y * yScale;
    CGFloat width = tailorFrame.size.width * xScale;
    CGFloat height = tailorFrame.size.height * yScale;
    UIImage *tailorImage = [self tailorImageFromImage:currentScroll.photo.tailorImage?:currentScroll.photo.originImage inRect:CGRectMake(x, y, width, height)];
    
    _items[_currentIndex].tailorImage = tailorImage;
    currentScroll.photo.tailorImage = tailorImage;
    [currentScroll reloadData];
}


/**
 exit clip status to preview status
 */
- (void)exitClipStatus{
    self.bgScrollView.scrollEnabled = YES;
    //scale the background scrollview
    self.topBar.isDisableShowDismiss = NO;
    self.bottomBar.isDisableShowDismiss = NO;
    [self.topBar showDismiss];
    [self.bottomBar showDismiss];
    [self.tailorBtmBar showDismiss];
    if (_tailorCoverView) {
        [_tailorCoverView removeFromSuperview];
        _tailorCoverView = nil;
    }
    
    LLZoomScrollView *currentScroll = [self.bgScrollView viewWithTag:100+self.currentIndex];
    [UIView animateWithDuration:0.3f animations:^{
        currentScroll.frame = CGRectMake(self.currentIndex*CGRectGetWidth(_bgScrollView.bounds), 0, CGRectGetWidth(_bgScrollView.bounds), CGRectGetHeight(_bgScrollView.bounds));
        [currentScroll setScrollMaxMinZoomScale];
    }];
}

/**
 * 按指定的位置大小从图片中截取图片
 * UIImage image 原始的图片
 * CGRect rect 要截取的矩形区域
 */
- (UIImage *)tailorImageFromImage:(UIImage *)image inRect:(CGRect)rect{
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}

- (void)updateDoneBtnStatus{
    if (_checkManager.checkedPhotos.count >= [LLAssetsPickerConfig shared].minimumNumberOfSelection) {
        //设置done按钮可交互
        _bottomBar.rightBtn.enabled = YES;
        _bottomBar.rightBtn.alpha = 1;
    } else {
        _bottomBar.rightBtn.enabled = NO;
        _bottomBar.rightBtn.alpha = 0.2;
    }
}

- (void)refreshTopBarTitle{
    _topBar.titleLbl.text = [NSString stringWithFormat:@"%ld/%lu",(long)_currentIndex+1,(unsigned long)_items.count];
}

@end
