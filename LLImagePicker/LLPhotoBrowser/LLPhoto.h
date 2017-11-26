//
//  LLPhoto.h
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/9.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef enum : NSUInteger {
    LLPhotoTypeImage,
    LLPhotoTypeURL,
    LLPhotoTypeAsset,
} LLPhotoType;

@interface LLPhoto : NSObject

/**
 The checked index of Photo in checkedPhotos dictionary
 */
@property (nonatomic, assign) NSUInteger checkIndex;

/**
 The index of Photo in fetchResult array
 */
@property (nonatomic, assign) NSUInteger photoIndex;

/**
 the original image
 */
@property (nonatomic, strong) UIImage *originImage;

/**
 the image which was cliped
 */
@property (nonatomic, strong) UIImage *tailorImage;

/**
 the placeholder image
 */
@property (nonatomic, strong) UIImage *placeholderImage;

/**
 The Network Image URL
 */
@property (nonatomic, strong) NSURL *url;

/**
 The Image Asset
 */
@property (nonatomic, strong) PHAsset *asset;

/**
 The image noumenon is in icloud or not
 */
@property (nonatomic, assign) BOOL isInCloud;

/**
 The current progress of download icloud image
 */
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) LLPhotoType type;

#pragma mark - Create Method

+ (LLPhoto *)photoWithImage:(UIImage *)image;
+ (LLPhoto *)photoWithURL:(NSURL *)url;
+ (LLPhoto *)photoWithAsset:(PHAsset *)asset;

- (id)initWithAsset:(PHAsset *)asset photoIndex:(NSUInteger)photoIndex checkIndex:(NSUInteger)checkIndex;


/**
 get special size image

 @param targetSize special size
 @param resultHandler fetch request callback
 @param progressHandler the progress callback of fetch request
 */
- (void)getImageWithTargetSize:(CGSize)targetSize resultHandler:(void (^)(UIImage *result, NSDictionary *info))resultHandler progressHandler:(PHAssetImageProgressHandler)progressHandler;


/**
 cancel current all asset loading
 */
- (void)cancelAllLoading;

@end
