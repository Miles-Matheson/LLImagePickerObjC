//
//  LLAlbumsViewController.m
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/8.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLAlbumsViewController.h"
#import <Photos/Photos.h>
#import "LLAlbumCell.h"
#import "LLAlbum.h"
#import "LLAssetsViewController.h"

static NSString *LLAlbumCellIdentifier = @"LLAlbumCell";

@interface LLAlbumsViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray <LLAlbum *> *items; //dataSource

@property (nonatomic, assign) BOOL saveTranslucent; //record translute

@end

@implementation LLAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTableView];
    [self commonInit];
    [self setNavigationBar];
}

- (void)dealloc{
    self.navigationController.navigationBar.translucent = _saveTranslucent;
}

- (void)setTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:NSClassFromString(LLAlbumCellIdentifier) forCellReuseIdentifier:LLAlbumCellIdentifier];
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)commonInit{
    _items = [NSMutableArray array];
    __weak typeof(self) selfWeak = self;
    [self photoAuthorStatusHandle:^(BOOL isAuthorized) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isAuthorized) {
                [selfWeak enumerateAssetCollections:[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:[PHFetchOptions new]]];
                if ([LLAssetsPickerConfig shared].isShowAssetControllerDirect) {
                    [selfWeak jumpToMaxCountAssetVC];
                }
            } else {
                //user denied or restricted
                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请先前往设置打开App访问相册权限" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:confirmAction];
                [selfWeak presentViewController:alertController animated:YES completion:nil];
            }
        });
    }];
}

- (void)photoAuthorStatusHandle:(void(^)(BOOL isAuthorized))callback{
    PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
    if (photoAuthorStatus == PHAuthorizationStatusAuthorized) {
        //already authorized
        if (callback) {
            callback(true);
        }
    } else if (photoAuthorStatus == PHAuthorizationStatusNotDetermined){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                //user authorized
                if (callback) {
                    callback(true);
                }
            } else {
                //user denied or restricted
                if (callback) {
                    callback(false);
                }
            }
        }];
    } else {
        if (callback) {
            callback(false);
        }
    }
}

- (void)setNavigationBar{
    self.title = @"相册";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(clickLeftBarBtnItem)];
    _saveTranslucent = self.navigationController.navigationBar.translucent;
    self.navigationController.navigationBar.translucent = YES;
}

- (void)clickLeftBarBtnItem{
    if (_didCancelPickingAssets) {
        _didCancelPickingAssets(self);
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)enumerateAssetCollections:(PHFetchResult<PHAssetCollection *> *)assetCollections{
    PHFetchOptions *options = [PHFetchOptions new];
    options.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    PHFetchResult <PHAsset *> *result = nil;
    for (int i = 0; i < assetCollections.count; i++) {
        result = [PHAsset fetchAssetsInAssetCollection:assetCollections[i] options:options];
        if(result.count == 0){
            continue;
        }
        [_items addObject:[[LLAlbum alloc] initWithTitle:assetCollections[i].localizedTitle fetchResult:result]];
    }
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LLAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LLAlbumCell"];
    cell.album = _items[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self jumpToAssetVC:indexPath.row animated:YES];
}

- (void)jumpToMaxCountAssetVC{
    if (!_items.count) {
        return;
    }
    NSInteger maxCountIndex = 0;
    LLAlbum *album = nil;
    for (NSInteger i = 1; i < _items.count; i++) {
        album = _items[i];
        if (album.fetchResult.count > _items[maxCountIndex].fetchResult.count) {
            maxCountIndex = i;
        }
    }
    if (maxCountIndex >= 0 && maxCountIndex < _items.count) {
        [self jumpToAssetVC:maxCountIndex animated:NO];
    }
}

- (void)jumpToAssetVC:(NSInteger)index animated:(BOOL)animated{
    __weak typeof(self) selfWeak = self;
    LLAssetsViewController *assetVC = [[LLAssetsViewController alloc] init];
    assetVC.album = _items[index];
    assetVC.pickingMoreThanMaxNum = _pickingMoreThanMaxNum;
    assetVC.didFinishPickingAssets = ^(NSArray<LLPhoto *> *assets) {
        if (selfWeak.didFinishPickingAssets) {
            selfWeak.didFinishPickingAssets(selfWeak, assets);
        }
    };
    [self.navigationController pushViewController:assetVC animated:animated];
}

@end
