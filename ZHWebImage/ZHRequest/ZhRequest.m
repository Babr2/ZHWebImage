//
//  ZhRequest.m
//  我的日记本
//
//  Created by 周浩 on 16/12/29.
//  Copyright © 2016年 周浩. All rights reserved.
//

#import "ZhRequest.h"

@interface ZhRequest ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
@property(nonatomic,strong)NSURLConnection *connection;
@property(nonatomic,strong)NSMutableData   *resultData;
@property(nonatomic,copy)void (^comletionHandle)(NSData *data);
@property(nonatomic,strong)NSURLSession     *session;
@property(nonatomic,copy)void (^errorHandle)(NSError *error);

@end

static NSString *const boundaryStr=@"--";
static NSString *const randomIDStr=@"haha";


@implementation ZhRequest

+(instancetype)request{
    
    return [[ZhRequest alloc] init];
}
-(instancetype)init{
    
    if (self=[super init]) {
        
        _resultData=[NSMutableData data];
        _session=[NSURLSession sharedSession];
    }
    return  self;
}
-(void)get:(NSString *)urlString success:(ZHCompletionHandler)completion failure:(ZHErrorHandler)failure{
    
    if(!urlString || urlString.length==0 || ![urlString hasPrefix:@"http"]){
        
        NSError *error=[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"ZHRequest Error:地址错误"}];
        if(failure){
            
            failure(error);
        }
        return;
    }
    _comletionHandle=[completion copy];
    _errorHandle=[failure copy];
    NSURL *url=[NSURL URLWithString:urlString];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    _connection=[NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)post:(NSString *)host params:(NSString *)prams success:(ZHCompletionHandler)completion failure:(ZHErrorHandler)failure{
    
    if(!host || host.length==0 || ![host hasPrefix:@"http"]){
        
        NSError *error=[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"ZHRequest Error:地址错误"}];
        if(failure){
            
            failure(error);
        }
        return;
    }
    _comletionHandle=[completion copy];
    _errorHandle=[failure copy];
    NSURL *url=[NSURL URLWithString:host];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod=@"POST";
    request.HTTPBody=[prams dataUsingEncoding:NSUTF8StringEncoding];
    _connection=[NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    if (self.errorHandle) {
        self.errorHandle(error);
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [_resultData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    if (self.comletionHandle) {
        self.comletionHandle(_resultData);
    }
}
-(void)uploadFileToHost:(NSString *)urlString fileData:(NSData *)fileData name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType paramaters:(NSString *)paramaters success:(void (^)(NSData *, NSURLResponse *))success failure:(void (^)(NSError *))failure{
    
    if((urlString.length==0)||(!urlString)){
        
        NSLog(@"---DataService---:主地址不能为空");
        return;
    }
    
    //固定拼接格式第一部分
    NSMutableString *top = [NSMutableString string];
    [top appendFormat:@"%@%@\n", boundaryStr, randomIDStr];
    [top appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\n", name, fileName];
    [top appendFormat:@"Content-Type: %@\n\n", mimeType];
    
    //固定拼接第二部分
    NSMutableString *buttom = [NSMutableString string];
    [buttom appendFormat:@"%@%@\n", boundaryStr, randomIDStr];
    [buttom appendString:@"Content-Disposition: form-data; name=\"submit\"\n\n"];
    [buttom appendString:@"Submit\n"];
    [buttom appendFormat:@"%@%@--\n", boundaryStr, randomIDStr];
    
    //容器
    NSMutableData *fromData=[NSMutableData data];
    //非文件参数
    [fromData appendData:[paramaters dataUsingEncoding:NSUTF8StringEncoding]];
    [fromData appendData:[top dataUsingEncoding:NSUTF8StringEncoding]];
    //文件数据部分
    [fromData appendData:fileData];
    [fromData appendData:[buttom dataUsingEncoding:NSUTF8StringEncoding]];
    
    //可变请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPBody=fromData;
    request.HTTPMethod=@"POST";
    [request addValue:@(fromData.length).stringValue forHTTPHeaderField:@"Content-Length"];
    NSString *strContentType=[NSString stringWithFormat:@"multipart/form-data; boundary=%@", randomIDStr];
    [request setValue:strContentType forHTTPHeaderField:@"Content-Type"];
    
    [[_session uploadTaskWithRequest:request fromData:nil completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!error){
                
                if(success)
                    success(data,response);
            }
            else{
                
                if(failure)
                    failure(error);
            }
        });
    }] resume];
}

-(void)uploadMultiFileToHost:(NSString *)urlString data:(NSArray *)datas name:(NSString *)name mimeType:(NSString *)mimeType paramaters:(NSString *)paramaters success:(void (^)(NSData *data, NSURLResponse *response))success failure:(void (^)(NSError *error))failure{
    
    if((urlString.length==0)||(!urlString)){
        
        NSLog(@"---DataService---:主地址不能为空");
        return;
    }
    //容器
    NSMutableData *fromData=[NSMutableData data];
    
    NSString *end=[NSString stringWithFormat:@"%@%@--\n", boundaryStr, randomIDStr];
    for(int i=0;i<datas.count;i++){
        
        NSString *varName=[NSString stringWithFormat:@"%@%d",name,i];
        NSString *fileName=[NSString stringWithFormat:@"notes%d.json",i+1];
        //固定拼接格式第一部分
        NSMutableString *top = [NSMutableString string];
        [top appendFormat:@"%@%@\n", boundaryStr, randomIDStr];
        [top appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\n", varName, fileName];
        [top appendFormat:@"Content-Type: %@\n\n", mimeType];
        
        //固定拼接第二部分
        NSString *buttom =@"\n";
        
        [fromData appendData:[top dataUsingEncoding:NSUTF8StringEncoding]];
        //文件数据部分
        [fromData appendData:datas[i]];
        [fromData appendData:[buttom dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [fromData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    //非文件参数
    [fromData appendData:[paramaters dataUsingEncoding:NSUTF8StringEncoding]];
    //可变请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPBody=fromData;
    request.HTTPMethod=@"POST";
    [request setValue:@(fromData.length).stringValue forHTTPHeaderField:@"Content-Length"];
    NSString *strContentType=[NSString stringWithFormat:@"multipart/form-data; boundary=%@", randomIDStr];
    [request setValue:strContentType forHTTPHeaderField:@"Content-Type"];
    
    [[_session uploadTaskWithRequest:request fromData:nil completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!error){
                
                if(success)
                    success(data,response);
            }
            else{
                
                if(failure)
                    failure(error);
            }
        });
    }] resume];
}
    
@end
