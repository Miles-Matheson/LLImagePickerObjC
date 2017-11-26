//
//  LLConfigTableCell.h
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/23.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLConfigTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UITextField *contentTF;
@property (weak, nonatomic) IBOutlet UISwitch *contentSwitch;

@property (nonatomic, copy) void(^onContentTFEditingChanged)(UITextField *contentTF);
@property (nonatomic, copy) void(^onContentSwitchValueChanged)(UISwitch *contentSwitch);

@end
