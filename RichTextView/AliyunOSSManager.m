//
//  AliyunOSSManager.m
//  RichTextView
//
//  Created by wudan on 2020/5/23.
//  Copyright © 2020 wudan. All rights reserved.
//

#import "AliyunOSSManager.h"

@implementation AliyunOSSImageModel

@end

@implementation AliyunOSSManager
+ (void)uploadFilesWithModels:(NSArray<AliyunOSSImageModel *> *)models complete:(void (^)(NSArray<AliyunOSSImageModel *> * _Nonnull, UploadImageState))complete {
    
    [[AliyunOSSTool sharedInstance] configAccessKeyId:@"LTAIAu0TDnOmGxCR" accessKeySecret:@"xNhsXgFjmcseYdb17D8ZxzgRHyAPZE" endPoint:@"https://oss-cn-shanghai.aliyuncs.com" bucket:@"mmnote-app"];
    NSMutableArray *array = [NSMutableArray array];
    __block NSUInteger count = 0;
    [models enumerateObjectsUsingBlock:^(AliyunOSSImageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 开始上传
        if (obj.image) {
            [[AliyunOSSTool sharedInstance] uploadImages:@[obj.image] objectPrePath:@"MyNote" complete:^(NSArray<NSString *> *names, UploadImageState state) {
                count ++;
                AliyunOSSImageModel *tempModel = [[AliyunOSSImageModel alloc] init];
                tempModel.url = [NSString stringWithFormat:@"https://mmnote-app.oss-cn-shanghai.aliyuncs.com/%@", names.firstObject];
                tempModel.index = idx;
                [array addObject:tempModel];
                if (count == models.count) {
                    complete(array, UploadImageSuccess);
                }
            }];
        } else {
            count ++;
            AliyunOSSImageModel *tempModel = [[AliyunOSSImageModel alloc] init];
            tempModel.url = [NSString stringWithFormat:@"https://mmnote-app.oss-cn-shanghai.aliyuncs.com/MyNote/%@", obj.url];
            tempModel.index = idx;
            [array addObject:tempModel];
            if (count == models.count) {
                complete(array, UploadImageSuccess);
            }
        }
    }];
    
}
@end
