//
//  LLAlbum.m
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/8.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLAlbum.h"

@implementation LLAlbum

- (id)initWithTitle:(NSString *)title fetchResult:(PHFetchResult <PHAsset *> *)fetchResult{
    if(self = [super init]){
        self.title = title;
        self.fetchResult = fetchResult;
    }
    return self;
}

@end
