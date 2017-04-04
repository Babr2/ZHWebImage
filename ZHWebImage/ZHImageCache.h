//
//  ZHImageCache.h
//  ZHWebImage
//
//  Created by Babr2 on 17/4/4.
//  Copyright © 2017年 Babr2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZHImageCache : NSObject

+(instancetype)shared;

-(void)imageWithUrl:(NSString *)url completion:(void(^)(UIImage *image))competionHanlder;

/**
 清内存缓存
 */
-(void)clearMemory;

/**
 清理磁盘
 */
-(void)clearDisk;

/**
 计算缓存大小，单位：字节
 */
-(NSUInteger)cacheSize;
@end
