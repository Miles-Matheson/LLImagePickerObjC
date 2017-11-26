//
//  UIView+LLToast.m
//  InstalmenHelp
//
//  Created by fqb on 2017/11/16.
//  Copyright © 2017年 XQT-zfd. All rights reserved.
//

#import "UIView+LLToast.h"

@implementation UIView (LLToast)

/**
 show a toast in self center position

 @param toast the toast which will show
 */
- (void)show:(NSString *)toast{
    UIView *oldToastLbl = [self viewWithTag:201711];
    if (oldToastLbl) {
        [oldToastLbl removeFromSuperview];
    }
    UILabel *toastLbl = [UILabel new];
    toastLbl.text = toast;
    toastLbl.textAlignment = NSTextAlignmentCenter;
    toastLbl.textColor = [UIColor whiteColor];
    toastLbl.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    toastLbl.layer.cornerRadius = 5;
    toastLbl.layer.masksToBounds = YES;
    [self addSubview:toastLbl];
    [toastLbl sizeToFit];
    CGFloat width = CGRectGetWidth(toastLbl.frame) + 40;
    toastLbl.bounds = CGRectMake(0, 0, width > [UIScreen mainScreen].bounds.size.width ? [UIScreen mainScreen].bounds.size.width : width, CGRectGetHeight(toastLbl.frame)+40);
    toastLbl.center = self.center;
    toastLbl.tag = 201711;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5f animations:^{
            toastLbl.alpha = 0;
        } completion:^(BOOL finished) {
            [toastLbl removeFromSuperview];
        }];
    });
}

@end
