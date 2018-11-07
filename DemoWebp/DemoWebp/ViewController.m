//
//  ViewController.m
//  DemoWebp
//
//  Created by wu yutian on 2018/6/29.
//  Copyright © 2018年 wu yutian. All rights reserved.
//

#import "ViewController.h"
#import "WebViewVC.h"
#import "DecodeImageVC.h"
#ifdef SD_WEBP
#import "UIImage+WebP.h"
#endif

@interface ViewController ()
@property (strong, nonatomic) UILabel *pngSize;
@property (strong, nonatomic) UILabel *wepSize;
@property (strong, nonatomic) UIImage *pngImg;
@property (strong, nonatomic) UIImage *webpImg;
@end

@implementation ViewController

- (UILabel *)sizeLabel {
    UILabel *sizeLabel = [UILabel new];
    sizeLabel.textAlignment = NSTextAlignmentCenter;
    sizeLabel.textColor = [UIColor blueColor];
    sizeLabel.numberOfLines = 0;
    sizeLabel.font = [UIFont systemFontOfSize:15];
    return sizeLabel;
}

- (UILabel *)createLabel {
    return [UILabel new];
}

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


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"数据对比";
    self.view.backgroundColor = [UIColor cyanColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIImage *img = [UIImage imageNamed:@"test2"];
    /*
     获取图像原始数据
     */
    CFDataRef rawData = CGDataProviderCopyData(CGImageGetDataProvider(img.CGImage));
    NSLog(@"原始数据------%@\n",rawData);
    /*
     获取图像大小
     */
//    NSData *pngImageData = UIImagePNGRepresentation(img);
//    NSLog(@"PNGimageFileSize--------:%ld",(long)pngImageData.length);
//
//    NSData *jepgImageData = UIImageJPEGRepresentation(img, 0.9);
//    NSLog(@"JEPGimageFileSize--------:%ld",(long)jepgImageData.length);
    self.pngImg = img;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    imageView.userInteractionEnabled = true;
    imageView.frame = CGRectMake(20, 20, 120, 120);
    imageView.backgroundColor = [UIColor redColor];
    [self.view addSubview:imageView];
    UILabel *dataFormat = [self createLabel];
    dataFormat.frame = CGRectMake(20, imageView.frame.origin.y + CGRectGetHeight(imageView.frame), 120, 20);
    dataFormat.backgroundColor = [UIColor redColor];
    dataFormat.text = @"png";
    dataFormat.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:dataFormat];
    UITapGestureRecognizer *pngTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageSize:)];
    pngTap.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:pngTap];
    self.pngSize = [self sizeLabel];
    [self.view addSubview:self.pngSize];
    self.pngSize.frame = CGRectMake(imageView.frame.origin.x + 120 + 20, 20, 200, 100);
    
    
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"testWebp" ofType:@"webp"];
    NSData *webpData = [NSData dataWithContentsOfFile:path];
    UIImage *image = [UIImage sd_imageWithWebPData:webpData];
    self.webpImg = image;
    NSData *webPImageData = UIImageJPEGRepresentation(image, 0.9);
    UIImageView *webpImageView = [[UIImageView alloc] initWithImage:image];
    webpImageView.userInteractionEnabled = true;
    webpImageView.frame = CGRectMake(20, 200, 120, 120);
    [self.view addSubview:webpImageView];
    UILabel *webpDataFormat = [self createLabel];
    webpDataFormat.frame = CGRectMake(20, webpImageView.frame.origin.y + CGRectGetHeight(webpImageView.frame), 120, 20);
    webpDataFormat.backgroundColor = [UIColor redColor];
    webpDataFormat.text = @"webp";
    webpDataFormat.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:webpDataFormat];
    UITapGestureRecognizer *webpTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageSize:)];
    webpTap.numberOfTapsRequired = 2;
    [webpImageView addGestureRecognizer:webpTap];
    self.wepSize = [self sizeLabel];
    [self.view addSubview:self.wepSize];
    self.wepSize.frame = CGRectMake(webpImageView.frame.origin.x + 120 + 20, 200, 200, 100);
    NSLog(@"WEBPimageFileSize--------:%ld",(long)webPImageData.length);
    
    self.navigationItem.leftBarButtonItem = [self plazaBarButtonItemWithTarget:self action:@selector(loccal) title:@"Local" backgroundImageName:nil];
    self.navigationItem.rightBarButtonItem = [self plazaBarButtonItemWithTarget:self action:@selector(remote) title:@"Remote" backgroundImageName:nil];
    
    UIButton *decodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [decodeBtn setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 50 - 64, [UIScreen mainScreen].bounds.size.width, 50)];
    [decodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [decodeBtn setTitle:@"Decode" forState:UIControlStateNormal];
    [decodeBtn setBackgroundColor:[UIColor orangeColor]];
    [decodeBtn addTarget:self action:@selector(decodeImgVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:decodeBtn];
}

- (void)decodeImgVC {
    [self.navigationController pushViewController:[DecodeImageVC new] animated:true];
}

- (void)loccal {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"file" ofType:@"html"];
    WebViewVC *webView = [[WebViewVC alloc] init];
    webView.URL = path;
    webView.loadType = 1;
    [self.navigationController pushViewController:webView animated:true];
}

- (void)remote {
    WebViewVC *webView = [[WebViewVC alloc] init];
    webView.URL = @"http://m.hxb.renrendai.com/mo/activity/2018/worldCup";
    webView.loadType = 2;
    [self.navigationController pushViewController:webView animated:true];
}

- (void)showImageSize:(UITapGestureRecognizer *)tap {
    UIImage *image = tap.numberOfTapsRequired == 1 ? self.pngImg : self.webpImg;
    NSData *pngImageData = UIImagePNGRepresentation(image);
    NSData *jepgImageData = UIImageJPEGRepresentation(image, 0.9);
    NSString *jpgLength = [NSString stringWithFormat:@"%ld",(long)jepgImageData.length];
    NSString *pngLength = [NSString stringWithFormat:@"%ld",(long)pngImageData.length];
    NSString *result = [NSString stringWithFormat:@"conver to jepg size: %@ byte\n\nconver to png size %@ byte",jpgLength,pngLength];
    if (tap.numberOfTapsRequired == 1) {
        //png
        self.pngSize.text = result;
    } else {
        //webp
        self.wepSize.text = result;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
