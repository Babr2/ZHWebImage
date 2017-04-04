
//
//  UIImageView+Cache.m
//  ZHWebImage
//
//  Created by Babr2 on 17/4/4.
//  Copyright © 2017年 Babr2. All rights reserved.
//

#import "UIImageView+Cache.h"
#import <objc/runtime.h>
#import "ZHImageCache.h"

const char *kImageUrlStringKey      ="kImageUrlStringKey";

@implementation UIImageView (Cache)

-(void)zh_setImageWithUrlString:(NSString *)urlString{
    
    if(!urlString || urlString.length==0 ||![urlString isKindOfClass:[NSString class]]){
        
        return;
    }
    __weak typeof(self) wkself=self;
    [[ZHImageCache shared] imageWithUrl:urlString completion:^(UIImage *image) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
           
            wkself.image=image;
        });
    }];
}
-(void)zh_setImageWihtUrlString:(NSString *)urlString placeHolder:(UIImage *)placeHolderImage{
    
    self.image=placeHolderImage;
    [self zh_setImageWithUrlString:urlString];
}

@end
