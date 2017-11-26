//
//  LLAlbumCell.h
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/8.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLAlbum.h"

@interface LLAlbumCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *btmImgView;
@property (weak, nonatomic) IBOutlet UIImageView *centerImgView;
@property (weak, nonatomic) IBOutlet UIImageView *topImgView;

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *contentLbl;

@property (nonatomic, strong) LLAlbum *album;

@end
