//
//  LLAlbum.h
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/8.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface LLAlbum : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) PHFetchResult <PHAsset *> *fetchResult;

- (id)initWithTitle:(NSString *)title fetchResult:(PHFetchResult <PHAsset *> *)fetchResult;

@end
