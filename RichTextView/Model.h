//
//  Model.h
//  RichTextView
//
//  Created by wudan on 2020/5/21.
//  Copyright © 2020 wudan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Model : NSObject
/** 主键 */
@property (nonatomic, assign) NSInteger pkid;
/** 生成的HTML内容 */
@property (nonatomic, copy) NSString *html;
/** 生成的文字内容 */
@property (nonatomic, copy) NSString *contentText;
/** 第一张图片链接 */
@property (nonatomic, copy) NSString *firstImageUrl;
/** 创建时间 */
@property (nonatomic, copy) NSString *createTime;
@end

NS_ASSUME_NONNULL_END
