//
//  ViewController.m
//  test_gifImage_02
//
//  Created by admin on 15/11/16.
//  Copyright © 2015年 admin. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>
#import "YLGIFImage.h"
#import "YLImageView.h"

#define GIFINBOUNDLENAME        @"joy"
//#define GIFINBOUNDLENAME        @"jiafei"
#define DIRECTORYNAME_NORMAL          @"Normal"
#define DIRECTORYNAME_GIF           @"gif"

#define compressionQuality_Decode   0.5
//#define compressionQuality_Create   0.75

//NSData* dataObj = UIImageJPEGRepresentation(img, compressionQuality_Create);

@interface ViewController ()
{
    CGFloat duration;
    CGSize size;
}
@property(nonatomic, strong)NSMutableArray *gifFrameProperties;
@property(nonatomic, strong)NSDictionary *gifProperties_jeffasd;

@end

@implementation ViewController

- (NSMutableArray *)gifFrameProperties
{
    if (_gifFrameProperties == nil) {
        _gifFrameProperties = [NSMutableArray new];
    }
    return _gifFrameProperties;
}

- (NSDictionary *)gifProperties_jeffasd
{
    if (_gifProperties_jeffasd == nil) {
        _gifProperties_jeffasd = [NSDictionary new];
    }
    return _gifProperties_jeffasd;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSData *data1 = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:GIFINBOUNDLENAME ofType:@"gif"]];
    [self decodeWithData:data1 GIFName:GIFINBOUNDLENAME];
    NSArray *fileList = [self findGIFImageInNormal:GIFINBOUNDLENAME];
    [self createGIFImage:fileList GIFName:@"jiafeimiao"];
    [self showGIF:@"jiafeimiao.gif"];
    
}

-(void)decodeWithData:(NSData *)data GIFName:(NSString *)gifName;
{
    //通过data获取image的数据源
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    //获取帧数
    size_t count = CGImageSourceGetCount(source);
    NSMutableArray* tmpArray = [NSMutableArray array];
    NSDictionary *imageProperties = CFBridgingRelease(CGImageSourceCopyProperties(source, NULL));
    self.gifProperties_jeffasd = [imageProperties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
    NSLog(@"the gifPropertiy is %@", _gifProperties_jeffasd);
    for (size_t i = 0; i < count; i++)
    {
        //获取图像
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
        //生成image
        UIImage *image = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
                //获取每一帧的图片信息
                NSDictionary* frameProperties = (__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(source, i, NULL) ;
                //保存每一帧图片信息
//                [self.gifFrameProperties addObject:frameProperties];
                NSLog(@"the frameproperty is %@", frameProperties);
        
//                // get gif size
//                if (i == 0) {
//                    size.width = [[frameProperties valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
//                    size.height = [[frameProperties valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
//                    NSLog(@"the size is %@", NSStringFromCGSize(size));
//                }
        
                float frameDuration = [self frameDurationAtIndex:i source:source];
                [self.gifFrameProperties addObject:[NSNumber numberWithFloat:frameDuration]];
//                duration = [[[frameProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary] objectForKey:(NSString*)kCGImagePropertyGIFDelayTime] doubleValue];
//                duration = MAX(duration, 0.01);
        
        [tmpArray addObject:image];
        CGImageRelease(imageRef);
    }
//    NSLog(@"thd count is %lu, %@", (unsigned long)_gifFrameProperties.count, _gifFrameProperties);
    CFRelease(source);
    
    int i = 0;
    NSString *dircetoryPath = [self backPath:DIRECTORYNAME_NORMAL];
    for (UIImage *img in tmpArray) {
        
//        NSData *imageData = UIImagePNGRepresentation(img);
        NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality_Decode);
        NSString *pathNum = [dircetoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png",gifName, i]];
        
//        NSData *imageData = UIImageJPEGRepresentation(img, 1);
//        NSString *pathNum = [[self backPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.jpeg",gifName, i]];
        
        [imageData writeToFile:pathNum atomically:NO];
        i++;
    }
}
/** gif的制作 */
- (void)createGIFImage:(NSArray *)fileList GIFName:(NSString *)gifName
{
    //创建图像目标
    CGImageDestinationRef destination;
    //创建输出路径
    NSString *documentStr = [self backPath:DIRECTORYNAME_GIF];
    NSString *pathName = [NSString stringWithFormat:@"%@.gif",gifName];
    NSString *path = [documentStr stringByAppendingPathComponent:pathName];
    NSLog(@"%@",path);
    
    //创建CFURL对象
    /*
     CFURLCreateWithFileSystemPath(CFAllocatorRef allocator, CFStringRef filePath, CFURLPathStyle pathStyle, Boolean isDirectory)
     
     allocator : 分配器,通常使用kCFAllocatorDefault
     filePath : 路径
     pathStyle : 路径风格,我们就填写kCFURLPOSIXPathStyle 更多请打问号自己进去帮助看
     isDirectory : 一个布尔值,用于指定是否filePath被当作一个目录路径解决时相对路径组件
     */
    CFURLRef url = CFURLCreateWithFileSystemPath (
                                                  kCFAllocatorDefault,
                                                  (CFStringRef)path,
                                                  kCFURLPOSIXPathStyle,
                                                  false);
    
    //通过一个url返回图像目标
    destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, fileList.count, NULL);
//    destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, imgs.count, NULL);
    
#pragma 如果之前没有gif图片，在创建gif图片时要自己生成frameProperties和gifProperty
//    //设置gif的信息,播放间隔时间,基本数据,和delay时间
//    NSDictionary *frameProperties = [NSDictionary
//                                     dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.3], (NSString *)kCGImagePropertyGIFDelayTime, nil]
//                                     forKey:(NSString *)kCGImagePropertyGIFDictionary];
//
//    //设置gif信息
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
//    
//    [dict setObject:[NSNumber numberWithBool:YES] forKey:(NSString*)kCGImagePropertyGIFHasGlobalColorMap];
//    
//    [dict setObject:(NSString *)kCGImagePropertyColorModelRGB forKey:(NSString *)kCGImagePropertyColorModel];
//    
//    [dict setObject:[NSNumber numberWithInt:8] forKey:(NSString*)kCGImagePropertyDepth];
//    
//    [dict setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount];
//    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:dict
//                                                              forKey:(NSString *)kCGImagePropertyGIFDictionary];
//    //合成gif
//    for (UIImage* dImg in imgs)
//    {
//        CGImageDestinationAddImage(destination, dImg.CGImage, (__bridge CFDictionaryRef)frameProperties);
//    }
#pragma end 如果之前没有gif图片，在创建gif图片时要自己生成frameProperties和gifProperty
    
    //合成gif
    int i = 0;
    NSString *filePath = [self imageDirectoryPath:DIRECTORYNAME_NORMAL];
    for (NSString *gifName in fileList) {
        float frameDuration = [(NSNumber *)_gifFrameProperties[i] floatValue];
        NSDictionary *frameProperty = [NSDictionary
                                         dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:frameDuration], (NSString *)kCGImagePropertyGIFDelayTime, nil]
                                         forKey:(NSString *)kCGImagePropertyGIFDictionary];
        NSString *fileURL = [filePath stringByAppendingPathComponent:gifName];
        
////        CGSize size = self.view.frame.size;
//        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), FALSE, 1);
//        UIView* gifBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
//        gifBgView.backgroundColor = [UIColor clearColor];
//        UIImageView* dImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
//        dImgView.center = gifBgView.center;
//        [dImgView setBackgroundColor:[UIColor clearColor]];
//        [dImgView setImage:[UIImage imageWithContentsOfFile:fileURL]];
//        [dImgView setContentMode:UIViewContentModeScaleAspectFill];
//        [gifBgView addSubview:dImgView];
//        [[gifBgView layer] renderInContext:UIGraphicsGetCurrentContext()];
//        UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        CGImageDestinationAddImage(destination, img.CGImage, (__bridge CFDictionaryRef)frameProperty);
        
        //            CGImageDestinationAddImage(destination, img.CGImage, (__bridge CFDictionaryRef)frameProperties);
        
        
        CGImageDestinationAddImage(destination, [UIImage imageWithContentsOfFile:fileURL].CGImage, (__bridge CFDictionaryRef)frameProperty);
        
//        CGImageDestinationAddImage(destination, dImg.CGImage, (__bridge CFDictionaryRef)_gifFrameProperties[i]);
//        NSLog(@"the frameproperty is %@", _gifFrameProperties[i]);
        i++;
    }
    NSLog(@"---------------- Terminated due to memory issue");
//    for (UIImage* dImg in imgs)
//    {
//        CGImageDestinationAddImage(destination, dImg.CGImage, (__bridge CFDictionaryRef)frameProperties);
//    }
    
//    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)gifProperties);
    //gifProperties
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)_gifProperties_jeffasd);
    
    bool isFinalize = NO;
    isFinalize = CGImageDestinationFinalize(destination);
    if (isFinalize) {
        NSLog(@"isFinalize");
    }else{
         CFRelease(destination);
        NSLog(@"error");
    }

    CFRelease(destination);
}


- (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source
{
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source,index,nil);
    NSDictionary *frameProperties = (__bridge NSDictionary*)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString*)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString*)kCGImagePropertyGIFUnclampedDelayTime];
    if(delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    } else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString*)kCGImagePropertyGIFDelayTime];
        if(delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 0.011f)
        frameDuration = 0.100f;
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

//返回保存图片的路径
-(NSString *)backPath:(NSString *)directoryName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *imageDirectory = [path stringByAppendingPathComponent:directoryName];
    
//    [fileManager createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    if (![fileManager fileExistsAtPath:imageDirectory]) {
        NSLog(@"there is no Directory: %@",imageDirectory);
        [fileManager createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"create Directory: Documents/%@",directoryName);
    }
    NSLog(@"the Directory is exist %@",imageDirectory);
    return imageDirectory;
}

//返回保存图片的路径
-(NSString *)imageDirectoryPath:(NSString *)directoryName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *imageDirectory = [path stringByAppendingPathComponent:directoryName];
    return imageDirectory;
}

- (void)showGIF:(NSString *)gifName
{
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *strPath = [documentsDirectory stringByAppendingPathComponent:@"gif/"];
    NSString *strFile = [strPath stringByAppendingPathComponent:gifName];
//    NSLog(@"strFile: %@", strFile);
    
    if (![fileManage fileExistsAtPath:strFile]) {
        NSLog(@"there is no file: %@",strFile);
    }else{
        //有文件
//        NSData *gif1 = [NSData dataWithContentsOfFile:strFile];
//        CGRect frame1 = CGRectMake(0,20,self.view.frame.size.width, 0.75*self.view.frame.size.width);
////        frame1.size = [UIImage imageWithData:gif1].size;
//        // view生成
//        UIWebView *webView = [[UIWebView alloc] initWithFrame:frame1];
//        webView.userInteractionEnabled = NO;//用户不可交互
//        
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wnonnull"
//// 被夹在这中间的代码针对于此警告都会无视并且不显示出来
//        [webView loadData:gif1 MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
//#pragma clang diagnostic pop
//        [self.view addSubview:webView];
        
        YLImageView *imageView1 = [[YLImageView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 0.75*self.view.frame.size.width)];
        NSLog(@"the frame is %@", NSStringFromCGRect(imageView1.frame));
        [self.view addSubview:imageView1];
//        imageView1.image = [YLGIFImage imageNamed:@"jiafeimiao.gif"];
        imageView1.image = [YLGIFImage imageWithContentsOfFile:strFile];
        
        
        //有文件
//        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"test101" ofType:@"gif"]];
        
//        [[imageName componentsSeparatedByString:@"."] objectAtIndex:0];
//        NSString *bundleName = [[gifName componentsSeparatedByString:@"."] objectAtIndex:0];
        
//        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:GIFINBOUNDLENAME ofType:@"gif"];
//                                
//        NSData *gif2 = [NSData dataWithContentsOfFile:bundlePath];
//        CGRect frame2 = CGRectMake(20,480,400,500);
////        frame2.size = [UIImage imageWithData:gif1].size;
//        // view生成
//        UIWebView *webView1 = [[UIWebView alloc] initWithFrame:frame2];
//        webView1.userInteractionEnabled = NO;//用户不可交互
//        
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wnonnull"
//        // 被夹在这中间的代码针对于此警告都会无视并且不显示出来
//        [webView1 loadData:gif2 MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
//#pragma clang diagnostic pop
//        [self.view addSubview:webView1];
        
        
        
        
        YLImageView* imageView = [[YLImageView alloc] initWithFrame:CGRectMake(0, 360, self.view.frame.size.width, 0.75*self.view.frame.size.width)];
        NSLog(@"the frame is %@", NSStringFromCGRect(imageView.frame));
        [self.view addSubview:imageView];
        imageView.image = [YLGIFImage imageNamed:@"joy.gif"];
    }
}

- (NSArray *)findGIFImageInNormal:(NSString *)gifName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *strFile = [documentsDirectory stringByAppendingPathComponent:@"hello/config.plist"];
//    NSLog(@"strFile: %@", strFile);
    
    NSString *strPath = [documentsDirectory stringByAppendingPathComponent:@"Normal"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:strPath]) {
        NSLog(@"there is no Directory: %@",strPath);
//        [[NSFileManager defaultManager] createDirectoryAtPath:strPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //取得当前目录下的全部文件
//    NSFileManager *fileManage = [NSFileManager defaultManager];
//    NSArray *file = [fileManage subpathsOfDirectoryAtPath:strPath error:nil];
//    NSArray *file = [self getFilenamelistOfType:@"png" fromDirPath:strPath];
    NSArray *file = [self getFilenamelistOfType:@"png" fromDirPath:strPath GIFName:gifName];
//    NSLog(@"the file is %@", file);
    return file;

}

-(NSArray *) getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath GIFName:(NSString *)gifName
{
    NSArray *tempList = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil]
                         pathsMatchingExtensions:[NSArray arrayWithObject:type]];
    NSMutableArray *fileList = [NSMutableArray array];
    for (NSString *fileName in tempList) {
//       NSString *name = [[fileName componentsSeparatedByString:@"."] objectAtIndex:0];
//        if ([fileName isEqualToString:gifName] ) {
////            [fileList removeObject:fileName];
//            [fileList addObject:fileName];
//        }
        if ([fileName rangeOfString:gifName].location != NSNotFound) {
//        if ([fileName rangeOfString:gifName] ) {
            //            [fileList removeObject:fileName];
            [fileList addObject:fileName];
        }

//        NSLog(@"fileName is %@", name);
    }
    tempList = nil;
    
//    //block比较方法，数组中可以是NSInteger，NSString（需要转换）
//    NSComparator finderSort = ^(id string1,id string2){
//        
//        if ([string1 integerValue] > [string2 integerValue]) {
//            return (NSComparisonResult)NSOrderedDescending;
//        }else if ([string1 integerValue] < [string2 integerValue]){
//            return (NSComparisonResult)NSOrderedAscending;
//        }
//        else
//            return (NSComparisonResult)NSOrderedSame;
//    };
//    
//    //数组排序：
//    NSArray *resultArray = [fileList sortedArrayUsingComparator:finderSort];
//    NSLog(@"第一种排序结果：%@",resultArray);
    
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|
    NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    NSComparator sort = ^(NSString *obj1,NSString *obj2){
        NSRange range = NSMakeRange(0,obj1.length);
        return [obj1 compare:obj2 options:comparisonOptions range:range];
    };
    NSArray *resultArray2 = [fileList sortedArrayUsingComparator:sort];
//    NSLog(@"字符串数组排序结果%@",resultArray2);
    
    
    return resultArray2;
//    return fileList;
}

//int intSort(id string2, id string1, void *locale)
//{
////    static NSStringCompareOptions comparisonOptions =
////    NSCaseInsensitiveSearch | NSNumericSearch |
////    NSWidthInsensitiveSearch | NSForcedOrderingSearch;
////    NSRange string1Range = NSMakeRange(0, [string1 length]);
////    return [string1 compare:string2  options:comparisonOptions range:string1Range locale:(__bridge NSLocale *)locale];
//    
////    [[imageName componentsSeparatedByString:@"."] objectAtIndex:0]
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
