//
//  UIImageView+Cache.h
//  ZHWebImage
//
//  Created by Babr2 on 17/4/4.
//  Copyright © 2017年 Babr2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Cache)

-(void)zh_setImageWithUrlString:(NSString *)urlString;
-(void)zh_setImageWihtUrlString:(NSString *)urlString placeHolder:(UIImage *)placeHolderImage;

@end
