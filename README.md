###Introduction
ZHWebImage是一个轻量级的网络图片加载框架，包含完整的三级缓存机制，类似于`SDWebImage`。
###Installtion
下载`ZHWebImage`并导入`UIImageView+Cache.h`文件。
###Usage
- 用法一：
```
[imageView zh_setImageWihtUrlString:urlString placeHolder:[UIImage imageNamed:@"placeHolder"]];
```
- 用法二：
```
[imageView zh_setImageWihtUrlString:urlString];
```
- 清内存缓存
```
[[ZHImageCache shared] clearMemory]; 
```
- 清磁盘缓存
```
[[ZHImageCache shared] clearDisk];
```
- 计算磁盘缓存大小，单位：字节
```
NSUInteger size=[[ZHImageCache shared] cacheSize];

```

###Additional
Github源码地址：[ZHWebImage](https://github.com/Babr2/ZHWebImage)，欢迎pull request。。
