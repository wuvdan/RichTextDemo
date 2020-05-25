//
//  RichTextView.h
//  RichTextView
//
//  Created by wudan on 2020/5/21.
//  Copyright © 2020 wudan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RichTextView : UITextView<UITextViewDelegate>

@property (nonatomic, assign) CGFloat  fontSize;        // 字体大小
@property (nonatomic, strong) UIColor *fontColor;       // 字体颜色
@property (nonatomic, assign) CGFloat lineSapce;        // 行间距
@property (nonatomic, assign) BOOL isDelete;            // 是否是回删
@property (nonatomic, copy) NSString *content;          // 编辑富文本，设置内容
/// 选择图片后，设置图片
/// @param img 图片
/// @param range 显示位置
/// @param appe 是否换行
- (void)setImageText:(UIImage *)img withRange:(NSRange)range appenReturn:(BOOL)appe;

/// 初始化页面默认样式
- (void)initPropertys;
@end

NS_ASSUME_NONNULL_END
