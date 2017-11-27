//
//  LLAssetCell.m
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/8.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLAssetCell.h"
#import "UIView+LLToast.h"

@interface LLAssetCell ()

@property (nonatomic, strong) NSLayoutConstraint *iCloudViewTopCons;

@property (nonatomic, strong) UIImageView *icloudImageView;

@property (nonatomic, assign) BOOL isDownloading;

@end

@implementation LLAssetCell

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _mainImgView = [UIImageView new];
    [self.contentView addSubview:_mainImgView];
    _mainImgView.userInteractionEnabled = YES;

    _checkedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_checkedBtn];
    _checkedBtn.tintColor = [UIColor clearColor];
    _checkedBtn.layer.cornerRadius = 12.5f;
    _checkedBtn.layer.masksToBounds = YES;
    _checkedBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_checkedBtn setTitleColor:[LLAssetsPickerConfig shared].checkedTintColor?:[UIColor whiteColor] forState:UIControlStateSelected];
    [_checkedBtn addTarget:self action:@selector(clickCheckedBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _icloudImageView = [[UIImageView alloc] initWithImage:[LLAssetsPickerConfig shared].iCloudDownloadImage?:[UIImage imageNamed:@"llimagepicker_iclouddownload"]];
    [self.contentView addSubview:_icloudImageView];
    _icloudImageView.contentMode = UIViewContentModeCenter;
    _icloudImageView.userInteractionEnabled = YES;
    _icloudImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickIcloudImage)];
    [_icloudImageView addGestureRecognizer:tap];
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints{
    [super updateConstraints];
    _mainImgView.translatesAutoresizingMaskIntoConstraints     = NO;
    _checkedBtn.translatesAutoresizingMaskIntoConstraints      = NO;
    _icloudImageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(_mainImgView,_checkedBtn);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainImgView]|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainImgView]|" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_checkedBtn(25)]-2.5-|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2.5-[_checkedBtn(25)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[icloudImageView]|" options:0 metrics:nil views:@{@"icloudImageView":_icloudImageView}]];
    NSArray<NSLayoutConstraint *> *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[icloudImageView]|" options:0 metrics:nil views:@{@"icloudImageView":_icloudImageView}];
    if (constraints.count > 0) {
        _iCloudViewTopCons = constraints[0];
    }
    [self.contentView addConstraints:constraints];
}

- (void)clickCheckedBtn:(UIButton *)sender {
    if (_onClickCheckBtn) {
        _onClickCheckBtn(sender);
    }
}

- (void)setPhoto:(LLPhoto *)photo itemSize:(CGSize)itemSize{
    _photo = photo;
    
    //reset
    self.icloudImageView.hidden = YES;
    self.mainImgView.image = nil;
    _isDownloading = NO;
    self.iCloudViewTopCons.constant = 0;
    
    if (photo.tailorImage) {
        _mainImgView.image = photo.tailorImage;
    } else if (self.photo.originImage){
        //reset
        self.mainImgView.image = self.photo.originImage;
    } else if (self.photo.placeholderImage) {
        self.mainImgView.image = self.photo.placeholderImage;
        self.icloudImageView.hidden = !self.photo.isInCloud;
    } else {
        //request PHImageManager to know whether the image is in icloud or not.
        [self requestImage:NO progressHandler:nil];
        //request PHImageManager to get placeholder image.
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = false;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        __weak typeof(self) selfWeak = self;
        [[PHImageManager defaultManager] requestImageForAsset:photo.asset targetSize:itemSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            selfWeak.photo.placeholderImage = result;
            selfWeak.mainImgView.image = result;
        }];
    }
}

- (void)clickIcloudImage{
    // download iCloud image
    if (_isDownloading) {
        return;
    }
    _isDownloading = YES;
    [[UIApplication sharedApplication].keyWindow show:@"正在从iCloud下载该照片，请稍后"];
    __weak typeof(self) selfWeak = self;
    [self requestImage:YES progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        //confirm progress >= 0 && progress <= 1
        progress = MIN(MAX(progress, 0), 1);
        selfWeak.photo.progress = progress;
        if (selfWeak.iCloudViewTopCons) {
            dispatch_async(dispatch_get_main_queue(), ^{
                selfWeak.iCloudViewTopCons.constant = CGRectGetWidth(selfWeak.contentView.bounds) * progress;
            });
        }
    }];
}

- (void)requestImage:(BOOL)networkAccessAllowed progressHandler:(PHAssetImageProgressHandler)progressHandler{
    __weak typeof(self) weakSelf = self;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = false;
    options.networkAccessAllowed = networkAccessAllowed;
    options.progressHandler = progressHandler;
    [[PHImageManager defaultManager] requestImageDataForAsset:_photo.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        weakSelf.photo.isInCloud = [info[PHImageResultIsInCloudKey] boolValue];
        weakSelf.photo.originImage = [UIImage imageWithData:imageData];
        weakSelf.mainImgView.image = weakSelf.photo.originImage;
        weakSelf.icloudImageView.hidden = !weakSelf.photo.isInCloud;
    }];
}

@end
