//
//  LLConfigTableCell.m
//  LLImagePickerDemo
//
//  Created by fqb on 2017/11/23.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLConfigTableCell.h"

@implementation LLConfigTableCell

- (IBAction)contentTFEditingChanged:(UITextField *)sender {
    if (_onContentTFEditingChanged) {
        _onContentTFEditingChanged(sender);
    }
}

- (IBAction)contentSwitchValueChanged:(UISwitch *)sender {
    if (_onContentSwitchValueChanged) {
        _onContentSwitchValueChanged(sender);
    }
}

@end
