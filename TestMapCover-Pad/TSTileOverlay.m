//
//  TSTileOverlay.m
//  Map
//
//  Created by 卢大维 on 15/4/9.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "TSTileOverlay.h"
#import "CWEncode.h"
#import <CommonCrypto/CommonDigest.h>

@interface TSTileOverlay ()

@property NSCache *cache;
@property NSOperationQueue *operationQueue;

@end

@implementation TSTileOverlay

//- (void)loadTileAtPath:(MKTileOverlayPath)path
//                result:(void (^)(NSData *data, NSError *error))result
//{
//    if (!result) {
//        return;
//    }
//    
//    NSData *cachedData = [self.cache objectForKey:[self URLForTilePath:path]];
//    if (cachedData) {
//        result(cachedData, nil);
//    } else {
////        NSURL *imageUrl = [NSURL URLWithString:[self finalUrlAtPath:path]];
//        
//        NSURLRequest *request = [NSURLRequest requestWithURL:[self URLForTilePath:path]];
//        [NSURLConnection sendAsynchronousRequest:request queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//            [self.cache setObject:data forKey:[self URLForTilePath:path]];
//            result(data, connectionError);
//        }];
//    }
//}

- (void)loadTileAtPath:(MKTileOverlayPath)path
                result:(void (^)(NSData *data, NSError *error))result
{
    if (!result) {
        return;
    }
    
    if (!self.operationQueue) {
        self.operationQueue = [NSOperationQueue mainQueue];
    }
    
    NSString *url = [[self URLForTilePath:path] description];
    NSString *cacheKey = [self imagePathForUrl:url];
    UIImage *image = [self imageFromDiskForUrl:cacheKey];
    NSData *cachedData = UIImagePNGRepresentation(image);//[self.cache objectForKey:[self URLForTilePath:path]];
    if (cachedData) {
        result(cachedData, nil);
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[self URLForTilePath:path]];
        [NSURLConnection sendAsynchronousRequest:request queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//            [self.cache setObject:data forKey:url];
            
//            [data writeToFile:[self imagePathForUrl:[[self URLForTilePath:path] description]] atomically:YES];
            [self storeImage:data withUrl:cacheKey];
            
            result(data, connectionError);
        }];
    }
}

-(NSString *)imagePathForUrl:(NSString *)url
{
    NSString *_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _path = [_path stringByAppendingPathComponent:@"tileImages"];
    
    [self ensurePathExists:_path];
    
    NSString *filename = [self cachedFileNameForKey:url];
    return [_path stringByAppendingPathComponent:filename];
}

- (void)ensurePathExists:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
}

- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

-(void)storeImage:(id)image withUrl:(NSString *)url
{
    NSString *imagePath = [self imagePathForUrl:url];
    
    if ([image isKindOfClass:[UIImage class]]) {
        NSData *imageData = UIImagePNGRepresentation(image);
        [imageData writeToFile:imagePath atomically:YES];
    }
    
    if ([image isKindOfClass:[NSData class]]) {
        [image writeToFile:imagePath atomically:YES];
    }
}

-(UIImage *)imageFromDiskForUrl:(NSString *)url
{
    NSString *imagePath = [self imagePathForUrl:url];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:imagePath]) {
        
        NSData *data = [NSData dataWithContentsOfFile:imagePath];
        UIImage *image = [UIImage imageWithData:data];
        return image;
    }
    return nil;
}

//- (NSURL *)URLForTilePath:(MKTileOverlayPath)path
//{
//    return [NSURL URLWithString:[self finalUrlAtPath:path]];
//}
//
//-(NSString *)finalUrlAtPath:(MKTileOverlayPath)path
//{
//    // key
//    NSString *public_key = [NSString stringWithFormat:@"http://scapi.weather.com.cn/product/worldele/TEMP/test.png?level=%ld&x=%ld&y=%ld&date=201504210533&appid=6f688d62594549a2", path.z, path.x, path.y];
//    NSString *key = [CWEncode encodeByPublicKey:public_key privateKey:@"chinaweather_data"];
//    key = AFPercentEscapedQueryStringPairMemberFromStringWithEncoding(key, NSUTF8StringEncoding);
//    
//    NSString *url = [NSString stringWithFormat:@"http://scapi.weather.com.cn/product/worldele/TEMP/test.png?level=%ld&x=%ld&y=%ld&date=201504210533&appid=6f688d&key=%@", path.z, path.x, path.y, key];
//    return url;
////    return @"http://scapi.weather.com.cn/product/worldele/TEMP/test.png?level=7&x=20&y=40&date=201504210533&appid=6f688d&key=FGm6z%2BLphJ7GgTU5s2NRge%2F5Olc%3D";
//}
//
//static NSString * AFPercentEscapedQueryStringPairMemberFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
//    static NSString * const kAFCharactersToBeEscaped = @":/?&=;+!@#$()',*";
//    static NSString * const kAFCharactersToLeaveUnescaped = @"[].";
//    
//    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kAFCharactersToLeaveUnescaped, (__bridge CFStringRef)kAFCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding));
//}
@end
