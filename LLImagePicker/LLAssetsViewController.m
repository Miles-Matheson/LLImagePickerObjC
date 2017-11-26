//
//  LLAssetsViewController.m
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/8.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLAssetsViewController.h"
#import "LLAssetCell.h"
#import "LLPhotoBrowser.h"
#import "LLToolbar.h"

static NSString *LLAssetCellIdentifier = @"LLAssetCell";

@interface LLAssetsViewController () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) UIView *btmView;
@property (nonatomic, strong) UILabel *btmLbl;

@property (nonatomic, strong) NSMutableArray <LLPhoto *> *items;

@property (nonatomic, assign) CGSize itemSize;

@property (nonatomic, strong) LLCheckManager *checkManager;

@property (nonatomic, strong) LLToolbar *topBar;

@end

@implementation LLAssetsViewController

- (void)setAlbum:(LLAlbum *)album{
    if (_album != album) {
        _album = album;
        
        // setup dataSource
        _items = [NSMutableArray array];
        NSUInteger index = 0;
        for (PHAsset *asset in album.fetchResult) {
            [_items addObject:[[LLPhoto alloc] initWithAsset:asset photoIndex:index++ checkIndex:NSUIntegerMax]];
        }

        self.title = album.title;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self commonInit];
    [self setNavigation];
    [self setCollectionView];
    if ([LLAssetsPickerConfig shared].photoBrowserStyle != LLPhotoBrowserStyleDefault) {
        [self setBtmLbl];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_collectionView reloadData];
    //refresh bottom label
    self.btmLbl.text = [NSString stringWithFormat:[LLAssetsPickerConfig shared].alreadySelectPrompt?:@"已选%ld张",(unsigned long)self.checkManager.checkedPhotos.count];
    //refresh navigation bar right button status
    [self updateDoneBtnStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    // cancel visible asset loading
    NSArray *visibleCells = [self.collectionView visibleCells];
    if (visibleCells) {
        for (LLAssetCell *cell in visibleCells) {
            [cell.photo cancelAllLoading];
        }
    }
    [super viewWillDisappear:animated];
}

- (void)commonInit{
    LLAssetsPickerConfig *pickerConfig = [LLAssetsPickerConfig shared];
    NSInteger interval = 5*(pickerConfig.numberOfColumns-1)+5;
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - interval) / pickerConfig.numberOfColumns;
    _itemSize = CGSizeMake(width, width);
    _checkManager = [[LLCheckManager alloc] init];
    _checkManager.pickingMoreThanMaxNum = _pickingMoreThanMaxNum;
}

- (void)setBtmLbl{
    _btmView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame), CGRectGetWidth(self.view.bounds), 50)];
    [self.view addSubview:_btmView];
    _btmLbl = [[UILabel alloc] initWithFrame:_btmView.bounds];
    [_btmView addSubview:_btmLbl];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.frame = _btmLbl.bounds;
    [_btmLbl addSubview:effectView];
    _btmLbl.text = [NSString stringWithFormat:[LLAssetsPickerConfig shared].alreadySelectPrompt?:@"已选%ld张",(unsigned long)_checkManager.checkedPhotos.count];
    _btmLbl.textAlignment = NSTextAlignmentCenter;
}

- (void)setCollectionView{
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.itemSize = _itemSize;
    _layout.sectionInset = UIEdgeInsetsMake(2.5, 2.5, 2.5, 2.5);
    _layout.minimumLineSpacing = 5;
    _layout.minimumInteritemSpacing = 5;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64 - ([LLAssetsPickerConfig shared].photoBrowserStyle != LLPhotoBrowserStyleDefault ? 50 : 0)) collectionViewLayout:_layout];
    [self.view addSubview:_collectionView];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerNib:[UINib nibWithNibName:LLAssetCellIdentifier bundle:LLImagePickerBundle] forCellWithReuseIdentifier:LLAssetCellIdentifier];
    
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    NSUInteger rowCount = [_collectionView numberOfItemsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:rowCount-1 inSection:0];
    // scroll to the row in last item
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
}

- (void)setNavigation{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(clickDoneBtn)];
}

- (void)clickDoneBtn{
    if (_didFinishPickingAssets) {
        NSMutableArray <LLPhoto *> *checkAssets = [NSMutableArray array];
        LLPhoto *photo = nil;
        for (NSNumber *photoIndex in _checkManager.checkedPhotos) {
            photo = _checkManager.checkedPhotos[photoIndex];
            if (photo.checkIndex < checkAssets.count) {
                [checkAssets insertObject:photo atIndex:photo.checkIndex];
            } else {
                [checkAssets addObject:photo];
            }
        }
        _didFinishPickingAssets(checkAssets);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LLAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LLAssetCellIdentifier forIndexPath:indexPath];
    __weak typeof(self) selfWeak = self;
    cell.onClickCheckBtn = ^(UIButton *checkBtn) {
        LLPhoto *checkPhoto = selfWeak.items[indexPath.row];
        if (checkPhoto.isInCloud) {
            // the photo which was selected is in iCloud, instead of in local Photos.
            return;
        }
        [selfWeak.checkManager clickCheckBtn:checkBtn currentIndex:indexPath.row photo:checkPhoto];
        if (!checkBtn.selected && selfWeak.checkManager.checkedPhotos.count != [LLAssetsPickerConfig shared].maximumNumberOfSelection) {
            [selfWeak.collectionView reloadData];
        }
        // refresh bottom label text
        selfWeak.btmLbl.text = [NSString stringWithFormat:[LLAssetsPickerConfig shared].alreadySelectPrompt?:@"已选%ld张",(unsigned long)selfWeak.checkManager.checkedPhotos.count];
        // refresh navigation bar right button status
        [selfWeak updateDoneBtnStatus];
    };
    if ([LLAssetsPickerConfig shared].photoBrowserStyle != LLPhotoBrowserStyleDefault) {
        [_checkManager initCheckBtnStatus:cell.checkedBtn currentIndex:indexPath.row];
    } else {
        cell.checkedBtn.hidden = YES;
    }
    [cell setPhoto:_items[indexPath.row] itemSize:_itemSize];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LLPhoto *selectPhoto = _items[indexPath.row];
    if (selectPhoto.isInCloud) {
        // the photo which was selected is in iCloud, instead of in local Photos.
        return;
    }
    __weak typeof(self) selfWeak = self;
    LLPhotoBrowser *photoBrowser = [[LLPhotoBrowser alloc] initWithStyle:[LLAssetsPickerConfig shared].photoBrowserStyle];
    photoBrowser.items = _items;
    photoBrowser.currentIndex = indexPath.row;
    photoBrowser.checkManager = _checkManager;
    photoBrowser.onClickConfirmBtn = ^(LLPhotoBrowser *photoBrowser) {
        //on click confirm button
        [selfWeak clickDoneBtn];
    };
    [self.navigationController pushViewController:photoBrowser animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [((LLAssetCell *)cell).photo cancelAllLoading];
}

- (void)updateDoneBtnStatus{
    if (_checkManager.checkedPhotos.count >= [LLAssetsPickerConfig shared].minimumNumberOfSelection) {
        //设置done按钮可交互
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

@end
