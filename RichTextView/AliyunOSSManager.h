//
//  AliyunOSSManager.h
//  RichTextView
//
//  Created by wudan on 2020/5/23.
//  Copyright © 2020 wudan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliyunOSSTool.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliyunOSSImageModel : NSObject
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) NSUInteger index;

@end

@interface AliyunOSSManager : NSObject
+ (void)uploadFilesWithModels:(NSArray<AliyunOSSImageModel *> *)models complete:(void(^)(NSArray<AliyunOSSImageModel *> *names, UploadImageState state))complete;
@end

NS_ASSUME_NONNULL_END
