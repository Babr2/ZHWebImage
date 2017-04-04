//
//  ZhRequest.h
//  我的日记本
//
//  Created by 周浩 on 16/12/29.
//  Copyright © 2016年 周浩. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ZHCompletionHandler)(NSData *data);
typedef void(^ZHErrorHandler)(NSError *error);

@interface ZhRequest : NSObject


+(instancetype)request;

-(void)get:(NSString *)urlString success:(ZHCompletionHandler)completion failure:(ZHErrorHandler)failure;
-(void)post:(NSString *)host params:(NSString *)prams success:(ZHCompletionHandler)completion failure:(ZHErrorHandler)failure;
-(void)uploadFileToHost:(NSString *)urlString fileData:(NSData *)fileData name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType paramaters:(NSString *)paramaters success:(void (^) (NSData *data, NSURLResponse *response)) success failure:(void (^) (NSError *error))failure;
-(void)uploadMultiFileToHost:(NSString *)urlString data:(NSArray *)datas name:(NSString *)name mimeType:(NSString *)mimeType paramaters:(NSString *)paramaters success:(void (^)(NSData *data, NSURLResponse *response))success failure:(void (^)(NSError *error))failure;
@end
