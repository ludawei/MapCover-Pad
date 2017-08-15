//
//  CWHttpCmdWeather.m
//  ChinaWeather
//
//  Created by davlu on 7/5/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import "CWHttpCmdWeather.h"
#import "DecStr.h"
#import "ZipStr.h"
#import "PLHttpManager.h"

// http://data.weather.com.cn/cwapidata/zh_cn.html?uk=
// http://data.weather.com.cn/cwapidata/??zh_cn/101010100.html,zh_cn/101010200.html?uk=NmY2ODhkNjI1OTQ1NDlhMnwyMDEzLTA3LTEw
// 获取城市的 时间、城市信息、实况、预报、指数、预警、广告、天气解读八方面数据内容的异步线程类

@implementation CWHttpCmdWeather

- (NSString *)path
{
    NSString *language = @"zh_cn";
    if(self.cityIds && self.cityIds.count > 0)
    {
        NSMutableString *string = [NSMutableString stringWithFormat:@"http://data.tianqi.cn/cwapidatanew/??"];
        for (int i = 0; i < self.cityIds.count; ++i)
        {
            if(i > 0) [string appendString:@","];

            NSString *cityId = self.cityIds[i];
//            if (cityId.length > 9) {
//                cityId = [cityId substringToIndex:9];
//            }
            [string appendFormat:@"%@/%@.html", language, cityId];
        }
        return string;
    }

    // should not happen
    return @"cwapidata";
}

- (NSDictionary *)queries
{
    return nil;
}

- (NSDictionary *)headers
{
    return @{@"Accept" :@"application/json"};
}

- (void)didSuccess:(id)object
{
    NSMutableDictionary *ret_dict = nil;
    if([object isKindOfClass:[NSArray class]])
    {
        ret_dict = [NSMutableDictionary dictionary];
        
        NSArray *components = object;

        for (NSData *rawData in components)
        {
            id jsonObject = nil;
            char* decryptStr = (char*) malloc([rawData length] + 1); // need to free
            memcpy(decryptStr, (const char*) [rawData bytes], [rawData length]);
            [DecStr decrypt: decryptStr length: (int)[rawData length]];
            decryptStr[[rawData length]] = '\0';
            
            char* uncomStr = [ZipStr Uncompress:decryptStr length:(int)[rawData length]]; // need to free
            if(uncomStr)
            {
                // the ownership of uncomStr is transferred
                NSData *decodedResponseData = [NSData dataWithBytesNoCopy:uncomStr length:strlen(uncomStr)];
                jsonObject = [NSJSONSerialization JSONObjectWithData:decodedResponseData options:NSJSONReadingMutableContainers error:nil];
                // free is not necessary
                // free(uncomStr);
            }
            
            if(jsonObject)
            {
                // log city name for debug
                NSString *cityId = [[jsonObject objectForKey:@"c"] objectForKey:@"c1"];

                if (cityId) {
                    [ret_dict setObject:jsonObject forKey:cityId];
                }
                //返回数据后收集用户信息
                // 成功后请求historyWeather
            }

            free(decryptStr);
        }
    }
    // else unknown data, should not happen

    if (ret_dict) {
        [super didSuccess:ret_dict];
    }
    else
    {
        [super didSuccess:object];
    }
}

-(void)startRequest
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"application/octet-stream",@"multipart/form-data", @"text/html; charset=ISO-8859-1", @"application/javascript", @"text/plain", nil];
    manager.responseSerializer = [JSONResponseSerializerWithData serializer];
//    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:self.method URLString:self.path parameters:self.queries error:nil];
    request.timeoutInterval = 5;
    
    if(self.headers)
    {
        NSArray *keys = self.headers.allKeys;
        for(NSString *key in keys)
        {
            [request addValue:[self.headers objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    NSData *data = self.data;
    if(data)
    {
        int len = (int)[data length];
        char* encryStr = (char*) malloc(len);
        if(encryStr)
        {
            memcpy(encryStr, [data bytes], len);
            [DecStr encrypt: encryStr length: len];
            NSData *_data = [NSData dataWithBytes:encryStr length:len];
            free(encryStr);
            
            [request setHTTPBody:_data];
        }
    }
    
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        
        responseObject = errorData;//[errResponse dataUsingEncoding:NSUTF8StringEncoding];//[NSJSONSerialization dataWithJSONObject:responseObject options:0 error:nil];//operation.responseData;
//        if ([(NSHTTPURLResponse *)response respondsToSelector:@selector(allHeaderFields)])
//        {
//            //                    NSDictionary *dictionary = [(NSHTTPURLResponse *)response allHeaderFields];
//            //                    NSLog([dictionary description]);
//            
//            NSString *multipartLength = [[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:@"lengthn"];
//            if([responseObject isKindOfClass:[NSData class]] &&
//               multipartLength)
//            {
//                responseObject = [self splitMultiWeather:responseObject andLength:multipartLength];
//            }
//        }
        
        responseObject = [self decodeResponseZippedData:errorData];
        
        NSString *cityId = [[responseObject objectForKey:@"c"] objectForKey:@"c1"];
        
        if (cityId) {
            [self didSuccess:@{cityId:responseObject}];
        }
        else
        {
            [self didFailed:nil];
        }
    }] resume];
}

#pragma mark - 针对多城市数据的分割方法
- (NSArray *)splitMultiWeather:(NSData *)data andLength:(NSString *)length
{
    NSArray *lens;
    if(!length)
    {
        lens = [NSArray arrayWithObject:[NSString stringWithFormat:@"%td", data.length]];
    }
    else
    {
        lens = [length componentsSeparatedByString:@","];
    }
    
    int offset = 0;
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:lens.count];
    for (NSString *lenStr in lens)
    {
        int len = [lenStr intValue];
        if(offset + len > data.length)
        {
            // out of range
            break;
        }
        NSData *subdata = [data subdataWithRange:NSMakeRange(offset, len)];
        offset += len;
        [components addObject:subdata];
    }
    
    return components;
}

- (id)decodeResponseZippedData:(id)object
{
    NSData *rawData = object;
    
    id jsonObject = nil;
    
    char* decryptStr = (char*) malloc([rawData length] + 1); // need to free
    memcpy(decryptStr, (const char*) [rawData bytes], [rawData length]);
    [DecStr decrypt: decryptStr length: (int)[rawData length]];
    decryptStr[[rawData length]] = '\0';
    
#if 0
    NSData *data = [NSData dataWithBytes:decryptStr length:[rawData length]];
    jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    free(decryptStr);
#else
    char* uncomStr = [ZipStr Uncompress:decryptStr length:(int)[rawData length]]; // need to free
    if(uncomStr)
    {
        NSData *decodedResponseData = [NSData dataWithBytesNoCopy:uncomStr length:strlen(uncomStr)];
        jsonObject = [NSJSONSerialization JSONObjectWithData:decodedResponseData options:NSJSONReadingMutableContainers error:nil];
    }
    else
    {
        NSData *decodedResponseData = [NSData dataWithBytesNoCopy:decryptStr length:[rawData length]];
        jsonObject = [NSJSONSerialization JSONObjectWithData:decodedResponseData options:NSJSONReadingMutableContainers error:nil];
    }
#endif
    
    return jsonObject;
}

@end

@implementation JSONResponseSerializerWithData

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    id JSONObject = [super responseObjectForResponse:response data:data error:error];
    if (*error != nil) {
        NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
        if (data == nil) {
            //          // NOTE: You might want to convert data to a string here too, up to you.
            //          userInfo[JSONResponseSerializerWithDataKey] = @"";
            userInfo[JSONResponseSerializerWithDataKey] = [NSData data];
        } else {
            //          // NOTE: You might want to convert data to a string here too, up to you.
            //          userInfo[JSONResponseSerializerWithDataKey] = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            userInfo[JSONResponseSerializerWithDataKey] = data;
        }
        NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
        (*error) = newError;
    }
    
    return (JSONObject);
}
@end
