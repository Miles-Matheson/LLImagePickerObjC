//
//  LLPhoto.m
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/9.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLPhoto.h"
#import <SDWebImageDownloader.h>

@interface LLPhoto ()

@property (nonatomic, assign) PHImageRequestID requestId;
@property (nonatomic, strong) SDWebImageDownloadToken *downloadToken;

@end

@implementation LLPhoto

+ (LLPhoto *)photoWithImage:(UIImage *)image{
    return [[self alloc] initWithImage:image];
}
+ (LLPhoto *)photoWithURL:(NSURL *)url{
    return [[self alloc] initWithURL:url];
}
+ (LLPhoto *)photoWithAsset:(PHAsset *)asset{
    return [[self alloc] initWithAsset:asset];
}

#pragma mark - init section

- (id)init{
    if (self = [super init]) {
        self.requestId = PHInvalidImageRequestID;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image{
    if (self = [super init]) {
        self.type = LLPhotoTypeImage;
        self.originImage = image;
    }
    return self;
}
- (id)initWithURL:(NSURL *)url{
    if (self = [super init]) {
        self.type = LLPhotoTypeURL;
        self.url = url;
    }
    return self;
}
- (id)initWithAsset:(PHAsset *)asset{
    if (self = [super init]) {
        self.type = LLPhotoTypeAsset;
        self.asset = asset;
    }
    return self;
}

- (id)initWithAsset:(PHAsset *)asset photoIndex:(NSUInteger)photoIndex checkIndex:(NSUInteger)checkIndex{
    if (self = [super init]) {
        self.type = LLPhotoTypeAsset;
        self.asset = asset;
        self.photoIndex = photoIndex;
        self.checkIndex = checkIndex;
    }
    return self;
}

- (void)getImageWithTargetSize:(CGSize)targetSize resultHandler:(void (^)(UIImage *result, NSDictionary *info))resultHandler progressHandler:(PHAssetImageProgressHandler)progressHandler{
    if (_type == LLPhotoTypeImage) {
        if (resultHandler) {
            resultHandler(_originImage,nil);
        }
    } else if (_type == LLPhotoTypeURL){
        if (resultHandler && _url) {
            __weak typeof(self) selfWeak = self;
            _downloadToken = [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:_url options:SDWebImageDownloaderHighPriority|SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
               //update the download progress
                if (progressHandler && expectedSize > 0) {
                    float progress = receivedSize / (float)expectedSize;
                    BOOL stop = NO;
                    progressHandler(progress,nil,&stop,nil);
                    if (stop && selfWeak.downloadToken) {
                        //stop this download task
                        [[SDWebImageDownloader sharedDownloader] cancel:selfWeak.downloadToken];
                        selfWeak.downloadToken = nil;
                    }
                }
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                //download task completion
                if (!error && resultHandler) {
                    //suceess
                    resultHandler(image,nil);
                }
            }];
        }
    } else {
        //type == LLPhotoTypeAsset
        if (_tailorImage && resultHandler) {
            resultHandler(_tailorImage,nil);
            return;
        }
        __weak typeof(self) selfWeak = self;
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = false;
        options.progressHandler = progressHandler;
        _requestId = [[PHImageManager defaultManager] requestImageDataForAsset:_asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                UIImage *image = [UIImage imageWithData:imageData];
                selfWeak.originImage = image;
                selfWeak.isInCloud = imageData == nil;
                if (resultHandler) {
                    resultHandler(image,info);
                }
        }];
    }
}

/*
 {
 PHImageResultDeliveredImageFormatKey = 9998;
 PHImageResultIsDegradedKey = 0;
 PHImageResultIsInCloudKey = 1;
 PHImageResultIsPlaceholderKey = 0;
 PHImageResultWantedImageFormatKey = 9998;
 }
 */

- (void)dealloc{
    [self cancelAllLoading];
}

/**
 cancel current all asset loading
 */
- (void)cancelAllLoading{
    if (_downloadToken) {
        [[SDWebImageDownloader sharedDownloader] cancel:_downloadToken];
        _downloadToken = nil;
    }
    if (_requestId != PHInvalidImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:_requestId];
        _requestId = PHInvalidImageRequestID;
    }
}

@end
