//
//  RecordModel.h
//  RichTextView
//
//  Created by wudan on 2020/5/25.
//  Copyright © 2020 wudan. All rights reserved.
//

#import "RLMObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface RecordModel : RLMObject
/** 主键 */
@property (nonatomic, assign) NSInteger m_id;
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
