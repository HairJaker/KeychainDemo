//
//  CTM_HTTPCommunicate.m
//  KeychainDemo
//
//  Created by yujie on 17/1/9.
//  Copyright © 2017年 yujie. All rights reserved.
//

#import "CTM_HTTPCommunicate.h"
#import "AFNetworking/AFHTTPSessionManager.h"
#import "MBProgressHUD+Add.h"

#define TIME_NETOUT     20.0f
#define BASE_URL       @"http://baidu.com"

@implementation CTM_HTTPCommunicate
{
    AFHTTPSessionManager * httpSessionManager;
}

+ (id)sharedInstance
{
    static CTM_HTTPCommunicate * httpCommunicate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpCommunicate = [[CTM_HTTPCommunicate alloc] init];
    });
    return httpCommunicate;
}

- (id)init
{
    if (self = [super init])
    {
        httpSessionManager = [AFHTTPSessionManager manager];
        httpSessionManager.requestSerializer.HTTPShouldHandleCookies = YES;
        
        httpSessionManager.requestSerializer  = [AFHTTPRequestSerializer serializer];
        httpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        //  超时时间
        [httpSessionManager.requestSerializer setTimeoutInterval:TIME_NETOUT];
        //  把版本号信息传导请求头中
        [httpSessionManager.requestSerializer setValue:[NSString stringWithFormat:@"iOS-%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]] forHTTPHeaderField:@"CTM-Version"];
        
        [httpSessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept" ];
        httpSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",@"text/html", @"text/plain",nil];

    }
    return self;
}

#pragma mark  --  网络请求  --

+(void)createRequest:(NSString *)requestUrl withParam:(NSDictionary *)param withMethod:(HTTPRequestMethod)method success:(void (^)(id))success failure:(void (^)(NSError *))failure showHUD:(UIView *)showView
{
    if (requestUrl) {
        [[CTM_HTTPCommunicate sharedInstance] request:requestUrl withParam:param withMethod:method success:success failure:failure showHUD:showView];
    }
}

- (void)request:(NSString *)requestUrl withParam:(NSDictionary *)param withMethod:(HTTPRequestMethod)method success:(void(^)(id result))success failure:(void(^)(NSError *erro))failure showHUD:(UIView *)showView
{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    //  请求的时候给一个转圈的状态
    
    if (showView) {
        [MBProgressHUD showProgress:showView];
    }

    NSString *URLString = [NSString stringWithFormat:@"%@%@",BASE_URL,requestUrl];
    
//    [self setRequestCookie];  //将cookie通过请求头的形式传到服务器，比较是否和服务器一致
    
    NSMutableURLRequest *request = [httpSessionManager.requestSerializer requestWithMethod:[self getStringForRequestType:method] URLString:[[NSURL URLWithString:URLString relativeToURL:httpSessionManager.baseURL] absoluteString] parameters:param error:nil];
    
    NSURLSessionDataTask *dataTask = [httpSessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (showView) {
            [MBProgressHUD hideHUDForView:showView];
        }
        
        if (error) {
            
            [self showErrorWithError:error]; //  显示错误

            if (failure != nil){
                failure(error);
            }
            
        }else{
            
            if (success != nil){
                
                id result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                
                success(result);
            }
        }
    }];
    
    [dataTask resume];
}

-(void)setRequestCookie{
    
    NSData *cookiesData = [[NSUserDefaults standardUserDefaults] objectForKey:@"Cookie"];
    
    if([cookiesData length]) {
        /**
         *  拿到所有的cookies
         */
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesData];
        
        for (NSHTTPCookie *cookie in cookies) {
            /**
             *  判断cookie是否等于服务器约定的ECM_ID
             */
            if ([cookie.name isEqualToString:@"ECM_ID"]) {
                //实现了一个管理cookie的单例对象,每个cookie都是NSHTTPCookie类的实例,将cookies传给服务器
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            }
        }
    }
    
}

-(void)showErrorWithError:(NSError *)error
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (error.code == -1009) {
        [MBProgressHUD showError:@"网络已断开" toView:window];
    }else if (error.code == -1005){
        [MBProgressHUD showError:@"网络连接已中断" toView:window];
    }else if(error.code == -1001){
        [MBProgressHUD showError:@"请求超时" toView:window];
    }else if (error.code == -1003){
        [MBProgressHUD showError:@"未能找到使用指定主机名的服务器" toView:window];
    }else{
        [MBProgressHUD showError:[NSString stringWithFormat:@"code:%ld %@",(long)error.code,error.localizedDescription] toView:window];
    }
}
//  上传
+ (void)createRequest:(NSString *)requestUrl
            WithParam:(NSDictionary*)param
          withExParam:(NSDictionary*)Exparam
           withMethod:(HTTPRequestMethod)method
              success:(void (^)(id result))success
   uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
              failure:(void (^)(NSError* erro))failure

{
    [[CTM_HTTPCommunicate sharedInstance] createUnloginedRequest:requestUrl WithParam:param withExParam:Exparam withMethod:method success:success failure:failure uploadFileProgress:uploadFileProgress];
}


- (void)createUnloginedRequest:(NSString *)requestUrl WithParam:(NSDictionary *)param withExParam:(NSDictionary*)Exparam withMethod:(HTTPRequestMethod)method success:(void(^)(id result))success failure:(void(^)(NSError *erro))failure uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSString *URLString = [NSString stringWithFormat:@"%@%@",BASE_URL,requestUrl];

    NSMutableURLRequest *request = [httpSessionManager.requestSerializer multipartFormRequestWithMethod:[self getStringForRequestType:method] URLString:URLString parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //图片上传
        if (Exparam) {
            for (NSString *key in [Exparam allKeys]) {
                [formData appendPartWithFileData:[Exparam objectForKey:key] name:key fileName:[NSString stringWithFormat:@"%@.png",key] mimeType:@"image/jpeg"];
            }
        }
        
    } error:nil];
    
    NSURLSessionDataTask *dataTask = [httpSessionManager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
        
        if (uploadProgress) { //上传进度
            uploadFileProgress (uploadProgress);
        }
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            
            [self showErrorWithError:error];
            
            if (failure != nil){
                failure(error);
            }
            
        } else {
            
            if (success != nil)
            {
                
                id result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                
                success(result);
            }
        }
        
    }];
    
    [dataTask resume];
}
//  下载
+ (void)createDownloadFileWithURLString:(NSString *)URLString
                   downloadFileProgress:(void(^)(NSProgress *downloadProgress))downloadFileProgress
                          setupFilePath:(NSURL*(^)(NSURLResponse *response))setupFilePath
              downloadCompletionHandler:(void (^)(NSURL *filePath, NSError *error))downloadCompletionHandler
{
        [[CTM_HTTPCommunicate sharedInstance]createUnloginedDownloadFileWithURLString:URLString downloadFileProgress:downloadFileProgress setupFilePath:setupFilePath downloadCompletionHandler:downloadCompletionHandler];
}

- (void)createUnloginedDownloadFileWithURLString:(NSString *)URLString
                            downloadFileProgress:(void(^)(NSProgress *downloadProgress))downloadFileProgress
                                   setupFilePath:(NSURL*(^)(NSURLResponse *response))setupFilePath
                       downloadCompletionHandler:(void (^)(NSURL *filePath, NSError *error))downloadCompletionHandler
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString] cachePolicy:1 timeoutInterval:15];
    
    NSURLSessionDownloadTask *dataTask = [httpSessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        // 下载进度

        downloadFileProgress(downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //  设置保存目录
        return setupFilePath(response);
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        //  下载完成
        downloadCompletionHandler(filePath,error);
        
    }];
    
    [dataTask resume];
}


#pragma mark - GET Request type as string

-(NSString *)getStringForRequestType:(HTTPRequestMethod)type {
    
    NSString *requestTypeString;
    
    switch (type) {
        case POST:
            requestTypeString = @"POST";
            break;
            
        case GET:
            requestTypeString = @"GET";
            break;
            
        case PUT:
            requestTypeString = @"PUT";
            break;
            
        case DELETE:
            requestTypeString = @"DELETE";
            break;
            
        default:
            requestTypeString = @"POST";
            break;
    }
    
    return requestTypeString;
}


@end
