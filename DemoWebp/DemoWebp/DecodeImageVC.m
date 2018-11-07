//
//  DecodeImageVC.m
//  DemoWebp
//
//  Created by wu yutian on 2018/7/4.
//  Copyright © 2018年 wu yutian. All rights reserved.
//

#import "DecodeImageVC.h"

@interface DecodeImageVC ()

@end

@implementation DecodeImageVC

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

- (void)setLeftBarItem {
    self.navigationItem.leftBarButtonItem = [self plazaBarButtonItemWithTarget:self action:@selector(backAction) title:@"返回" backgroundImageName:nil];
}

- (void)back {
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Decode";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setLeftBarItem];
    self.view.backgroundColor = [UIColor redColor];
    
    UIImageView *centerImg = [[UIImageView alloc] initWithImage:[self decodeForImageIO]];
    centerImg.center = self.view.center;
    [self.view addSubview:centerImg];
}

//一个输入的二进制Data，转换为上层UI组件渲染所用的UIImage对象。
- (UIImage *)decodeForImageIO {
    NSString *resource = [[NSBundle mainBundle] pathForResource:@"alerttip_seemore@2x"ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:resource options:0 error:nil];
    CFDataRef dataRef = (__bridge CFDataRef)data;
    /*
     表示的是一个待解码数据的输入。之后的一系列操作（读取元数据，解码）都需要到这个Source，与解码流程一一对应。
     CGImageSourceCreateWithData： 从一个内存中的二进制数据（CGData）中创建ImageSource，相对来说最为常用的一个
     CGImageSourceCreateWithURL： 从一个URL（支持网络图的HTTP URL，或者是文件系统的fileURL）创建ImageSource，
     CGImageSourceCreateWithDataProvider：从一个DataProvide中创建ImageSource，DataProvider提供了很多种输入，包括内存，文件，网络，流等。很多CG的接口会用到这个来避免多个额外的接口。
     */
    CGImageSourceRef source = CGImageSourceCreateWithData(dataRef, nil);
    /*
     通过Image/IO解码到CGImage确实非常简单，整个解码只需要一个方法CGImageSourceCreateImageAtIndex。对于静态图来说，index始终是0，调用之后会立即开始解码，直到解码完成。
     值得注意的是，Image/IO所有的方法都是线程安全的，而且基本上也都是同步的，因此确保大图像文件的解码最好不要放到主线程。
     解码图片
    */
    CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil);
    
    /*
     获取图片原始数据
     */
    CFDataRef rawData =CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CFRelease(source);
    CGImageRelease(cgImage);
    return image;
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImage *)decodedImageWithImage:(UIImage *)image {
    // while downloading huge amount of images
    // autorelease the bitmap context
    // and all vars to help system to free memory
    // when there are memory warning.
    // on iOS7, do not forget to call
    // [[SDImageCache sharedImageCache] clearMemory];
    
    if (image == nil) { // Prevent "CGBitmapContextCreateImage: invalid context 0x0" error
        return nil;
    }
    
    @autoreleasepool{
        // do not decode animated images
        if (image.images != nil) {
            return image;
        }
        
        CGImageRef imageRef = image.CGImage;
        
        CGImageAlphaInfo alpha = CGImageGetAlphaInfo(imageRef);
        BOOL anyAlpha = (alpha == kCGImageAlphaFirst ||
                         alpha == kCGImageAlphaLast ||
                         alpha == kCGImageAlphaPremultipliedFirst ||
                         alpha == kCGImageAlphaPremultipliedLast);
        if (anyAlpha) {
            return image;
        }
        
        // current
        CGColorSpaceModel imageColorSpaceModel = CGColorSpaceGetModel(CGImageGetColorSpace(imageRef));
        CGColorSpaceRef colorspaceRef = CGImageGetColorSpace(imageRef);
        
        BOOL unsupportedColorSpace = (imageColorSpaceModel == kCGColorSpaceModelUnknown ||
                                      imageColorSpaceModel == kCGColorSpaceModelMonochrome ||
                                      imageColorSpaceModel == kCGColorSpaceModelCMYK ||
                                      imageColorSpaceModel == kCGColorSpaceModelIndexed);
        if (unsupportedColorSpace) {
            colorspaceRef = CGColorSpaceCreateDeviceRGB();
        }
        
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel * width;
        NSUInteger bitsPerComponent = 8;
        
        
        // kCGImageAlphaNone is not supported in CGBitmapContextCreate.
        // Since the original image here has no alpha info, use kCGImageAlphaNoneSkipLast
        // to create bitmap graphics contexts without alpha info.
        /*
         CGContextRef __nullable CGBitmapContextCreate(void * __nullable data,
         size_t width, size_t height, size_t bitsPerComponent, size_t bytesPerRow,
         CGColorSpaceRef cg_nullable space, uint32_t bitmapInfo)
         CG_AVAILABLE_STARTING(__MAC_10_0, __IPHONE_2_0);
         
         data 指向要渲染的绘制内存的地址。这个内存块的大小至少是（bytesPerRow*height）个字节
         width  bitmap的宽度,单位为像素
         height bitmap的高度,单位为像素
         bitsPerComponent  内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8.
         bytesPerRow  bitmap的每一行在内存所占的比特数
         colorspace  bitmap上下文使用的颜色空间。
         bitmapInfo  指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串。
         */
        //函数创建一个位图上下文；
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     width,
                                                     height,
                                                     bitsPerComponent,
                                                     bytesPerRow,
                                                     colorspaceRef,
                                                     kCGBitmapByteOrderDefault|kCGImageAlphaNoneSkipLast);
        
        // Draw the image into the context and retrieve the new bitmap image without alpha
        //函数将原始位图绘制到上下文中；
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        //函数创建一张新的解压缩后的位图,解码。
        CGImageRef imageRefWithoutAlpha = CGBitmapContextCreateImage(context);
        UIImage *imageWithoutAlpha = [UIImage imageWithCGImage:imageRefWithoutAlpha
                                                         scale:image.scale
                                                   orientation:image.imageOrientation];
        
        if (unsupportedColorSpace) {
            CGColorSpaceRelease(colorspaceRef);
        }
        
        CGContextRelease(context);
        CGImageRelease(imageRefWithoutAlpha);
        
        return imageWithoutAlpha;
    }
}


@end
