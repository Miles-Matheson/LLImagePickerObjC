//
//  IHImageSelector.m
//  InstalmenHelp
//
//  Created by kevin on 2017/8/3.
//  Copyright © 2017年 XQT-zfd. All rights reserved.
//

#import "IHImageSelector.h"
#import <LXReorderableCollectionViewFlowLayout.h>
#import <UIImageView+WebCache.h>

@interface IHImageSelector () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,LXReorderableCollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LXReorderableCollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) NSMutableArray <IHImageSelectorModel *> *items;  //数据源

@end

@implementation IHImageSelector


/**
 通过网络图片路径数组来设置图片选择器数据源

 @param imageUrls 网络图片地址数组
 */
- (void)setItemsWithImageUrls:(NSArray <NSString *> *)imageUrls{
    _items = [NSMutableArray array];
    for (NSString *imageUrl in imageUrls) {
        [_items addObject:[[IHImageSelectorModel alloc] initWithImageUrl:imageUrl]];
    }
    if (_didFinishPickingAssets) {
        _didFinishPickingAssets(self,_items);
    }
    [_collectionView reloadData];
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
        [self setupUI];
    }
    return self;
}

- (void)commonInit{
    _items = [NSMutableArray array];
    _pickerAssets = _items;
}

- (void)setupUI{
    _flowLayout = [[LXReorderableCollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
    [self addSubview:_collectionView];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|" options:0 metrics:nil views:@{@"_collectionView":_collectionView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView]|" options:0 metrics:nil views:@{@"_collectionView":_collectionView}]];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.scrollEnabled = NO;
    [_collectionView registerClass:[IHImageSelectorCell class] forCellWithReuseIdentifier:@"IHImageSelectorCell"];
}

#pragma mark - UICollectionViewDelegate && DataSource

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat itemW = IMG_SELECTOR_ITEM_WIDTH;
    return CGSizeMake(itemW, itemW);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    //设置区的内嵌left,right == 15 ; top,bottom == 0
    return UIEdgeInsetsMake(0, 15, 0, 15);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 13;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 13;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _items.count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    IHImageSelectorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"IHImageSelectorCell" forIndexPath:indexPath];
    cell.deleteBtn.hidden = NO;
    if (_items.count == indexPath.row) {
        cell.mainImgView.image = [UIImage imageNamed:@"shop_add_photo"];
        cell.deleteBtn.hidden = YES;
    } else if (_items[indexPath.row].clipImage){
        cell.mainImgView.image = _items[indexPath.row].clipImage;
    } else if (_items[indexPath.row].asset) {
        [[PHImageManager defaultManager] requestImageForAsset:_items[indexPath.row].asset targetSize:cell.frame.size contentMode:PHImageContentModeAspectFit options:[PHImageRequestOptions new] resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            cell.mainImgView.image = result;
        }];
    } else {
        [cell.mainImgView sd_setImageWithURL:[NSURL URLWithString:_items[indexPath.row].imgPath?:@""]];
    }
    __weak typeof(self) weakself = self;
    cell.onClickMainImgView = ^(IHImageSelectorCell *cell) {
        NSIndexPath *realIndexPath = [self.collectionView indexPathForCell:cell];
        if (realIndexPath.row == self.items.count) {
            //点击添加图片
            LLAlbumsViewController *albumsVC = [[LLAlbumsViewController alloc] init];
            albumsVC.didFinishPickingAssets = ^(LLAlbumsViewController *albumsVC, NSArray<LLPhoto *> *assets) {
                [weakself.items addObjectsFromArray:[IHImageSelectorModel modelArrayWithPhotoArray:assets]];
                if (weakself.didFinishPickingAssets) {
                    weakself.didFinishPickingAssets(weakself, weakself.items);
                }
                [weakself.collectionView reloadData];
                [albumsVC dismissViewControllerAnimated:YES completion:nil];
            };
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:albumsVC] animated:YES completion:nil];
        } else {
            //查看图片
            LLPhotoBrowser *browser = [[LLPhotoBrowser alloc] initWithStyle:LLPhotoBrowserStyleDefault];
            browser.items = [IHImageSelectorModel photoArrayWithModelArray:self.items];
            browser.currentIndex = realIndexPath.row;
            [browser setTopBarRightBtn:^(LLPhotoBrowser *browser,UIButton *rightBtn) {
                [rightBtn setTitle:@"删除" forState:UIControlStateNormal];
                [rightBtn setImage:nil forState:UIControlStateNormal];
            } clickHandler:^(LLPhotoBrowser *browser, UIButton *rightBtn) {
                //点击删除
                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    //确定删除
                    if (browser.currentIndex < weakself.items.count) {
                        [weakself.items removeObjectAtIndex:browser.currentIndex];
                        if (weakself.didFinishPickingAssets) {
                            weakself.didFinishPickingAssets(weakself, weakself.items);
                        }
                        [weakself.collectionView reloadData];
                        if (weakself.items.count) {
                            browser.items = [IHImageSelectorModel photoArrayWithModelArray:weakself.items];
                            [browser reloadData];
                        } else {
                            if (browser.navigationController) {
                                [browser.navigationController popViewControllerAnimated:YES];
                            } else {
                                [browser.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                            }
                        }
                    }
                }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定删除？" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:confirmAction];
                [alertController addAction:cancelAction];
                [browser presentViewController:alertController animated:YES completion:nil];
            }];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:browser animated:YES completion:nil];
        }
    };
    cell.onClickDeleteBtn = ^(IHImageSelectorCell *cell, UIButton *deleteBtn) {
        //点击删除按钮
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //确定删除
            NSIndexPath *realIndexPath = [weakself.collectionView indexPathForCell:cell];
            if (realIndexPath.row < weakself.items.count) {
                [weakself.items removeObjectAtIndex:realIndexPath.row];
                if (weakself.didFinishPickingAssets) {
                    weakself.didFinishPickingAssets(weakself, weakself.items);
                }
                [weakself.collectionView deleteItemsAtIndexPaths:@[realIndexPath]];
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定删除？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    };
    return cell;
}

#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    IHImageSelectorModel *model = self.items[fromIndexPath.item];
    
    [self.items removeObjectAtIndex:fromIndexPath.item];
    [self.items insertObject:model atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row != self.items.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
    return toIndexPath.row != self.items.count;
}

@end

@implementation IHImageSelectorCell

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    _mainImgView = [UIImageView new];
    [self.contentView addSubview:_mainImgView];
    _mainImgView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainImgView]|" options:0 metrics:nil views:@{@"_mainImgView":_mainImgView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainImgView]|" options:0 metrics:nil views:@{@"_mainImgView":_mainImgView}]];
    _mainImgView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapMainImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMainImg:)];
    [_mainImgView addGestureRecognizer:tapMainImg];
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteBtn setImage:[UIImage imageNamed:@"llimagepicker_delete"] forState:UIControlStateNormal];
    [self.contentView addSubview:_deleteBtn];
    _deleteBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_deleteBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-3]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_deleteBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:3]];
    [_deleteBtn addTarget:self action:@selector(clickDeleteBtn) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tapMainImg:(UITapGestureRecognizer *)tap{
    if (_onClickMainImgView) {
        _onClickMainImgView(self);
    }
}

- (void)clickDeleteBtn{
    if (_onClickDeleteBtn) {
        _onClickDeleteBtn(self,_deleteBtn);
    }
}

@end

@implementation IHImageSelectorModel


/**
 通过网络图片地址初始化图片选择器模型

 @param imageUrl 网络图片地址
 @return 初始化后的图片选择器对象
 */
- (id)initWithImageUrl:(NSString *)imageUrl{
    if (self = [super init]) {
        self.type = IHImageSelectorModelTypeImgPath;
        self.imgPath = imageUrl;
        self.llPhoto = [LLPhoto photoWithURL:[NSURL URLWithString:imageUrl]];
    }
    return self;
}

- (id)initWithPhotoAsset:(LLPhoto *)photoAsset{
    if (self = [super init]) {
        self.type = IHImageSelectorModelTypeAsset;
        self.clipImage = photoAsset.tailorImage;
        self.asset = photoAsset.asset;
        self.llPhoto = photoAsset;
    }
    return self;
}

/**
 photo数组转model数组
 
 @param photoArray 待转换的photo数组
 @return 转换后的model数组
 */
+ (NSArray <IHImageSelectorModel *>*)modelArrayWithPhotoArray:(NSArray <LLPhoto *>*)photoArray{
    NSMutableArray <IHImageSelectorModel *> *modelArray = [NSMutableArray array];
    for (LLPhoto *photo in photoArray) {
        [modelArray addObject:[[IHImageSelectorModel alloc] initWithPhotoAsset:photo]];
    }
    return modelArray;
}

/**
 model数组转photo数组
 
 @param modelArray 待转换的model数组
 @return 转换后的photo数组
 */
+ (NSArray <LLPhoto *> *)photoArrayWithModelArray:(NSArray <IHImageSelectorModel *>*)modelArray{
    NSMutableArray *photoArray = [NSMutableArray array];
    for (IHImageSelectorModel *model in modelArray) {
        [photoArray addObject:model.llPhoto];
    }
    return photoArray;
}

/**
 获取图片的二进制数据

 @param resultHandler 获取完成回调
 */
- (void)getImageDataWithResultHandler:(void(^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info))resultHandler{
    if (self.llPhoto.tailorImage) {
        resultHandler([self dataWithImage:self.llPhoto.tailorImage],nil,0,nil);
    } else if (self.llPhoto.originImage){
        resultHandler([self dataWithImage:self.llPhoto.originImage],nil,0,nil);
    } else {
        [[PHImageManager defaultManager] requestImageDataForAsset:self.asset options:[PHImageRequestOptions new] resultHandler:resultHandler];
    }
}

//UIImage ===> NSData
- (NSData *)dataWithImage:(UIImage *)image
{
    NSData *data = nil;
    if (UIImagePNGRepresentation(image) == nil) {
        data = UIImageJPEGRepresentation(image, 1);
    } else {
        data = UIImagePNGRepresentation(image);
    }
    return data;
}

/**
 通过model数组获取逗号拼接后的图片路径

 @param modelArray model数组
 @return 拼接后的图片路径
 */
+ (NSString *)imgsPathWithModelArray:(NSArray <IHImageSelectorModel *>*)modelArray{
    NSMutableArray *imgPathArr = [NSMutableArray array];
    for (IHImageSelectorModel *model in modelArray) {
        if (!model.imgPath || [model.imgPath isEqualToString:@""]) {
            continue;
        }
        [imgPathArr addObject:model.imgPath];
    }
    return [imgPathArr componentsJoinedByString:@","];
}

@end
