//
//  ViewController.m
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/8.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "ViewController.h"
#import "LLAlbumsViewController.h"
#import "LLConfigTableCell.h"
#import "LLImgSelectorTableCell.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) LLImgSelectorTableCell *imgSelectorTableCell;

@end

@implementation ViewController

- (id)init{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTableView];
}

- (void)commonInit{
    LLAssetsPickerConfig *config = [LLAssetsPickerConfig shared];
    config.isShowAssetControllerDirect = YES; //直接显示资源列表
    config.photoBrowserStyle = LLPhotoBrowserStyleEditAndCheck; //裁剪和选中模式
    config.maximumNumberOfSelection = 3; //最大选择数
    config.minimumNumberOfSelection = 1; //最小选择数
    config.numberOfColumns = 4;  //资源列表的显示列数
    config.clipViewType = LLTailorCoverViewTypeSpecialAspectRatio;
    config.clipAspectRatio = 2.0f; //裁剪框的固定宽高比
}

- (void)setTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:@{@"_tableView":_tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:@{@"_tableView":_tableView}]];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"LLConfigTableCell" bundle:nil] forCellReuseIdentifier:@"LLConfigTableCell"];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 2 ? [self.imgSelectorTableCell sizeThatFits:[UIScreen mainScreen].bounds.size].height : 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? 3 : section == 1 ? 4 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LLAssetsPickerConfig *config = [LLAssetsPickerConfig shared];
    LLConfigTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LLConfigTableCell"];
    if (indexPath.section == 0) {
        cell.contentTF.hidden = YES;
        cell.titleLbl.text = @[@"是否直接显示图片列表",@"是否显示裁剪",@"是否等比例裁剪"][indexPath.row];
        cell.onContentSwitchValueChanged = ^(UISwitch *contentSwitch) {
            if (indexPath.row == 0) {
                config.isShowAssetControllerDirect = contentSwitch.on;
            } else if (indexPath.row == 1) {
                config.photoBrowserStyle = contentSwitch.on ? LLPhotoBrowserStyleEditAndCheck : LLPhotoBrowserStyleCheck;
            } else {
                config.clipViewType = contentSwitch.on ? LLTailorCoverViewTypeSpecialAspectRatio : LLTailorCoverViewTypeFreeDragging;
            }
        };
        if (indexPath.row == 0) {
            cell.contentSwitch.on = config.isShowAssetControllerDirect;
        } else if (indexPath.row == 1) {
            cell.contentSwitch.on = config.photoBrowserStyle == LLPhotoBrowserStyleEditAndCheck;
        } else {
            cell.contentSwitch.on = config.clipViewType == LLTailorCoverViewTypeSpecialAspectRatio;
        }
    } else if (indexPath.section == 1) {
        cell.contentSwitch.hidden = YES;
        cell.titleLbl.text = @[@"最大选择数",@"最小选择数",@"图片显示列数",@"裁剪比例"][indexPath.row];
        cell.onContentTFEditingChanged = ^(UITextField *contentTF) {
            switch (indexPath.row) {
                case 0:{
                    config.maximumNumberOfSelection = contentTF.text.integerValue;
                }
                    break;
                case 1:{
                    config.minimumNumberOfSelection = contentTF.text.integerValue;
                }
                    break;
                case 2:{
                    config.numberOfColumns = contentTF.text.integerValue;
                }
                    break;
                case 3:{
                    config.clipAspectRatio = contentTF.text.floatValue;
                }
                    break;
                    
                default:
                    break;
            }
        };
        cell.contentTF.keyboardType = UIKeyboardTypeNumberPad;
        switch (indexPath.row) {
            case 0:{
                cell.contentTF.text = [NSString stringWithFormat:@"%lu",(unsigned long)config.maximumNumberOfSelection];
            }
                break;
            case 1:{
                cell.contentTF.text = [NSString stringWithFormat:@"%lu",(unsigned long)config.minimumNumberOfSelection];
            }
                break;
            case 2:{
                cell.contentTF.text = [NSString stringWithFormat:@"%lu",(unsigned long)config.numberOfColumns];
            }
                break;
            case 3:{
                cell.contentTF.keyboardType = UIKeyboardTypeDecimalPad;
                cell.contentTF.text = [NSString stringWithFormat:@"%lu",(unsigned long)config.clipAspectRatio];
            }
                break;
                
            default:
                break;
        }
    } else {
        self.imgSelectorTableCell.imageSelector.pickerConfig = config;
        return _imgSelectorTableCell;
    }
    return cell;
}

- (LLImgSelectorTableCell *)imgSelectorTableCell{
    if (!_imgSelectorTableCell) {
        _imgSelectorTableCell = [LLImgSelectorTableCell new];
        __weak typeof(self) weakself = self;
        _imgSelectorTableCell.imageSelector.didFinishPickingAssets = ^(IHImageSelector *imageSelector, NSArray<IHImageSelectorModel *> *assets) {
            NSLog(@"已选%lu张图片",(unsigned long)assets.count);
            [weakself.tableView reloadData];
        };
    }
    return _imgSelectorTableCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
