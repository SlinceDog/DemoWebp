//
//  WebViewVC.m
//  DemoWebp
//
//  Created by wu yutian on 2018/7/2.
//  Copyright © 2018年 wu yutian. All rights reserved.
//

#import "WebViewVC.h"
#import "RRDWebPURLProtocol.h"

@interface WebViewVC ()
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation WebViewVC

- (UIBarButtonItem *)plazaBarButtonItemWithTarget:(id)target action:(SEL)action title:(NSString *)title backgroundImageName:(NSString *)backgroundImageName
{
    UIFont *font = [UIFont boldSystemFontOfSize:17];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 7, 50, 50);
    btn.titleLabel.font = font;
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (UIBarButtonItem *)createEmptyBarItem {
    UIBarButtonItem *custom = [[UIBarButtonItem alloc] initWithCustomView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)]];
    return custom;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSURLProtocol registerClass:[RRDWebPURLProtocol class]];
    
    self.title = @"测试WebView";
    UIWebView *aWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    aWebView.scalesPageToFit = YES;
    aWebView.allowsInlineMediaPlayback = YES;
    aWebView.mediaPlaybackRequiresUserAction = NO;
    self.webView = aWebView;
    self.webView.delegate = self;
    self.navigationItem.rightBarButtonItem = [self createEmptyBarItem];
    self.navigationItem.leftBarButtonItem = [self plazaBarButtonItemWithTarget:self action:@selector(back) title:@"返回" backgroundImageName:nil];
    [self.view addSubview:aWebView];
    [self loadWebView];
}

- (void)back {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadWebView
{
    if (self.URL == nil) {
        return;
    }
    if (self.loadType == 1) {
        NSURL* url = [NSURL fileURLWithPath:self.URL];//创建URL
        NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
        [self.webView loadRequest:request];//加载
    } else {
        NSString *URLString = [self.URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *URL = [NSURL URLWithString:URLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        [self.webView loadRequest:request];
    }
}

- (void)dealloc {
    [NSURLProtocol unregisterClass:[RRDWebPURLProtocol class]];
}

@end
