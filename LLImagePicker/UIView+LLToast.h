//
//  UIView+LLToast.h
//  InstalmenHelp
//
//  Created by fqb on 2017/11/16.
//  Copyright © 2017年 XQT-zfd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LLToast)

/**
 show a toast in self center position
 
 @param toast the toast which will show
 */
- (void)show:(NSString *)toast;

@end
