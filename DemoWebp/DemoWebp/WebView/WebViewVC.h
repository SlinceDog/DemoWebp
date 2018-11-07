//
//  WebViewVC.h
//  DemoWebp
//
//  Created by wu yutian on 2018/7/2.
//  Copyright © 2018年 wu yutian. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface WebViewVC : UIViewController<UIWebViewDelegate>
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, assign) NSInteger loadType;

@end
