//
//  RRDWebPURLProtocol.m
//  investment
//
//  Created wu yutian on 04/04/2018.
//  Copyright © 2018 RRD. All rights reserved.
//
//  Refer: https://www.raywenderlich.com/59982/nsurlprotocol-tutorial
//         https://github.com/chuliangliang/TalentCWebp
//

#import "RRDWebPURLProtocol.h"
#ifdef SD_WEBP
#import "UIImage+WebP.h"
#endif

static NSString* const RRDWebPURLProtocolKey = @"RRDWebPURLProtocolHandledKey";

@interface RRDWebPURLProtocol () <NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *recData;

@end

@implementation RRDWebPURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    BOOL useCustomUrlProtocol = NO;
#ifdef SD_WEBP
    NSString *urlString = request.URL.absoluteString;
    if ([[urlString.pathExtension lowercaseString] compare:@"webp"] == NSOrderedSame
        && [NSURLProtocol propertyForKey:RRDWebPURLProtocolKey inRequest:request] == nil) {
        useCustomUrlProtocol = YES;
    }
#endif
    return useCustomUrlProtocol;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [newRequest setValue:@"image/webp,image/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [NSURLProtocol setProperty:@YES forKey:RRDWebPURLProtocolKey inRequest:newRequest];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:newRequest delegate:self];
}

- (void)stopLoading
{
    [self.connection cancel];
    self.connection = nil;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    /**
     * 收到服务器响应
     */
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    self.recData = [NSMutableData new];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    /**
     * 接收数据
     */
    if (data) {
        [self.recData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    /**
     * 加载完毕
     */
    NSData *imageData = self.recData;
#ifdef SD_WEBP
    UIImage *image = [UIImage sd_imageWithWebPData:self.recData];
    imageData = UIImagePNGRepresentation(image);
    if (!imageData) {
        imageData = UIImageJPEGRepresentation(image, 1);
    }
#endif
    [self.client URLProtocol:self didLoadData:imageData];
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    /**
     * 加载失败
     */
    [self.client URLProtocol:self didFailWithError:error];
}

@end
