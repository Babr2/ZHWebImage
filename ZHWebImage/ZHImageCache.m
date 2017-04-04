
//
//  ZHImageCache.m
//  ZHWebImage
//
//  Created by Babr2 on 17/4/4.
//  Copyright © 2017年 Babr2. All rights reserved.
//

#import "ZHImageCache.h"
#import "NSString+Hash.h"
#import "ZhRequest.h"

@interface ZHImageCache()

@property(nonatomic,strong)NSCache               *cache;
@property(nonatomic,strong)NSMutableDictionary   *queue;//下载队列

@end

/*/Library/Caches/ZHImageCache/*/
static NSString *kZHImageCacheFolderName=@"ZHImageCache";
static NSTimeInterval kZHImageVaildateTime=(3600*24*7);

NSString *cachePath(){
    
    NSString *libPath=[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *destinationPath=[NSString stringWithFormat:@"%@/Caches/%@/",libPath,kZHImageCacheFolderName];
    return destinationPath;
}
static ZHImageCache *imageChace=nil;

@implementation ZHImageCache

+(instancetype)shared{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        imageChace=[[ZHImageCache alloc] init];
    });
    return imageChace;
}
-(instancetype)init{
    
    if(self=[super init]){
        
        _cache=[[NSCache alloc] init];
        _queue=[NSMutableDictionary dictionary];
        NSString *path=cachePath();
        BOOL exist=[[NSFileManager defaultManager] fileExistsAtPath:path];
        if(!exist){
            
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSLog(@"%@",path);
    }
    return self;
}
-(void)imageWithUrl:(NSString *)url completion:(void (^)(UIImage *))competionHanlder{
    
    NSData *data=[self.cache objectForKey:url];
    if(data){
        
        UIImage *image=[UIImage imageWithData:data];
        if(competionHanlder){
            
            competionHanlder(image);
            return;
        }
        
    }else{
        
        NSString *path=cachePath();
        NSString *md5Name=[url md5String];
        path=[path stringByAppendingString:md5Name];
        BOOL exist=[[NSFileManager defaultManager] fileExistsAtPath:path];
        if(exist){
            
            BOOL expired=NO;
            NSDictionary *attributes=[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
            NSDate *createDate=[attributes objectForKey:NSFileCreationDate];
            NSDate *now=[NSDate date];
            NSTimeInterval interval=[now timeIntervalSinceDate:createDate];
            if(interval>kZHImageVaildateTime){
                
                expired=YES;
            }
            if(!expired){//存在且未过期
                
                NSData *data=[NSData dataWithContentsOfFile:path];
                UIImage *image=[UIImage imageWithData:data];
                if(competionHanlder){
                    
                    competionHanlder(image);
                }
                if(data){
                    
                    [_cache setObject:data forKey:url];
                }
                
            }else{//存在且过期
                
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                //下载
                __weak typeof(self) wkself=self;
                [self downloadImageWithUrl:url completion:^(NSData *imageData) {
                    
                    if(imageData){
                        
                        UIImage *image=[UIImage imageWithData:imageData];
                        if(competionHanlder){
                            
                            competionHanlder(image);
                        }
                        NSString *md5Name=[url md5String];
                        NSString *path=[cachePath() stringByAppendingString:md5Name];
                        [imageData writeToFile:path atomically:YES];
                        [wkself.cache setObject:imageData forKey:url];
                    }
                }];
            }
            
        }else{//下载
            
            __weak typeof(self) wkself=self;
            [self downloadImageWithUrl:url completion:^(NSData *imageData) {
                
                if(imageData){
                    
                    UIImage *image=[UIImage imageWithData:imageData];
                    if(competionHanlder){
                        
                        competionHanlder(image);
                    }
                    NSString *md5Name=[url md5String];
                    NSString *path=[cachePath() stringByAppendingString:md5Name];
                    [imageData writeToFile:path atomically:YES];
                    [wkself.cache setObject:imageData forKey:url];
                }
            }];
        }
    }
}
-(void)downloadImageWithUrl:(NSString *)url completion:(void(^)(NSData *imageData))completionHandler{
    
    ZhRequest *request=[self.queue objectForKey:url];
    if(request){
        
        return;
    }
    if(request){
     
        [self.queue setObject:request forKey:url];
    }
    __weak typeof(self) wkself=self;
    [[ZhRequest request] get:url success:^(NSData *data) {
       
        if(completionHandler){
            
            completionHandler(data);
        }
        [wkself.queue removeObjectForKey:url];
        
    } failure:^(NSError *error) {
        
        if(completionHandler){
            
            completionHandler(nil);
        }
        [wkself.queue removeObjectForKey:url];
    }];
}
-(void)clearMemory{
    
    [self.cache removeAllObjects];
}
-(void)clearDisk{
    
    NSString *diskPath=cachePath();
    NSArray *array=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:diskPath error:nil];
    if (array.count==0||!array) {
        
        return;
    }
    for (NSString *name in array) {
        
        NSString *filePath=[NSString stringWithFormat:@"%@%@",diskPath,name];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}
-(NSUInteger)cacheSize{
    
    NSUInteger size=0;
    NSString *diskPath=cachePath();
    NSArray *array=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:diskPath error:nil];
    
    for (NSString *name in array) {
        
        NSString *filePath=[NSString stringWithFormat:@"%@%@",diskPath,name];
        NSDictionary *attributes=[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        NSString *fileSize=[attributes objectForKey:NSFileSize];
        size+=[fileSize integerValue];
    }
    return size;
}
@end
