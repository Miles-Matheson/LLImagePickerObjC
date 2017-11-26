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

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _mainImgView.userInteractionEnabled = YES;
    
    _checkedBtn.tintColor = [UIColor clearColor];
    _checkedBtn.layer.cornerRadius = 12.5f;
    _checkedBtn.layer.masksToBounds = YES;
    [_checkedBtn setTitleColor:[LLAssetsPickerConfig shared].checkedTintColor?:[UIColor whiteColor] forState:UIControlStateSelected];
    
    _icloudImageView = [[UIImageView alloc] initWithImage:[LLAssetsPickerConfig shared].iCloudDownloadImage?:[UIImage imageNamed:@"llimagepicker_iclouddownload"]];
    [self.contentView addSubview:_icloudImageView];
    _icloudImageView.contentMode = UIViewContentModeCenter;
    _icloudImageView.userInteractionEnabled = YES;
    _icloudImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _icloudImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[icloudImageView]|" options:0 metrics:nil views:@{@"icloudImageView":_icloudImageView}]];
    NSArray<NSLayoutConstraint *> *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[icloudImageView]|" options:0 metrics:nil views:@{@"icloudImageView":_icloudImageView}];
    if (constraints.count > 0) {
        _iCloudViewTopCons = constraints[0];
    }
    [self.contentView addConstraints:constraints];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickIcloudImage)];
    [_icloudImageView addGestureRecognizer:tap];
}

- (IBAction)clickCheckedBtn:(UIButton *)sender {
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
