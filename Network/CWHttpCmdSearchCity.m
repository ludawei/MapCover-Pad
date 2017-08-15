//
//  CWHttpCmdSearchCity.m
//  chinaweathernews
//
//  Created by 卢大维 on 14-11-6.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "CWHttpCmdSearchCity.h"
#import "Util.h"
#import "DecStr.h"
#import "ZipStr.h"
#import "CWHttpCmdWeather.h"

@implementation CWHttpCmdSearchCity

-(NSString *)path
{
    NSMutableString *superPath = [NSMutableString stringWithString:[super path]];
    return [superPath stringByAppendingString:@"http://app.weather.com.cn/second/area/town/search.do"];
}

- (NSString *)method
{
    return @"POST";
}

- (NSData *)data
{
    NSMutableDictionary* queryJson = [NSMutableDictionary dictionary];
    
    NSMutableDictionary* condition = [NSMutableDictionary dictionary];
    if(self.nameZh)     [condition setValue: self.nameZh forKey: @"nameZh"];
    if(self.nameEn)     [condition setValue: self.nameEn forKey: @"nameEn"];
    if(self.areaId)     [condition setValue: self.areaId forKey: @"areaId"];
    if(self.postCode)   [condition setValue: self.postCode forKey: @"postCode"];
    if(self.telCode)    [condition setValue: self.telCode forKey: @"telCode"];
    if(self.keyWord)    [condition setValue: self.keyWord forKey: @"keyWord"];
    
    NSMutableDictionary* pagination = [NSMutableDictionary dictionary];
    [pagination setValue:[NSNumber numberWithInt:0] forKey: @"start"];
    [pagination setValue:[NSNumber numberWithInt:300] forKey: @"limit"];
    
    [queryJson setValue: condition forKey: @"condition"];
    [queryJson setValue: pagination forKey: @"pagination"];
    [queryJson setValue: [Util getAppKey] forKey: @"appKey"];
    
    return [NSJSONSerialization dataWithJSONObject:queryJson options:0 error:nil];
}

- (BOOL)isResponseZipped
{
    return YES;
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
        
        responseObject = errorData;
        
        responseObject = [self decodeResponseZippedData:errorData];
        
        if (responseObject) {
            [self didSuccess:responseObject];
        }
        else
        {
            [self didFailed:nil];
        }
        
    }] resume];
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
