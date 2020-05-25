//
//  NSObject+RichTextView.h
//  RichTextView
//
//  Created by wudan on 2020/5/22.
//  Copyright © 2020 wudan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WDImageTextAttachment.h"

//富文本编辑 图片标识
#define RICHTEXT_IMAGE (@"[UIImageView]")
#define IMAGE_MAX_SIZE ([[UIScreen mainScreen] bounds].size.width - 10)

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (RichTextView)
+ (UIColor *)colorWithHex:(UInt32)hex;
+ (UIColor *)colorWithHex:(UInt32)hex andAlpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)hexString;
- (NSString *)HEXString;

+ (UIColor *)colorWithWholeRed:(CGFloat)red
                         green:(CGFloat)green
                          blue:(CGFloat)blue
                         alpha:(CGFloat)alpha;

+ (UIColor *)colorWithWholeRed:(CGFloat)red
                         green:(CGFloat)green
                          blue:(CGFloat)blue;
@end

@interface NSString (RichTextView)
- (NSAttributedString *)toAttributedString;
/**
 *  输出正则里面的内容
 *
 *  @return NSDictionary
 */
- (NSDictionary *)RXImageUrl;

/**
 *  输出正则里面的内容
 *
 *  @return NSArray
 */
- (NSArray *)RXToArray;

/**
 *  富文本图片标识 替换正则
 *
 *  @return NSString
 */
- (NSString *)RXToString;

/**
 *  富文本 按照图片标示 分隔成字符串数组
 *
 *  @return NSArray
 */
- (NSArray *)RXToStringArray;

/**
 *  富文本图片标识 替换正则
 *
 *  @return NSString
 */
- (NSString *)RXToStringWithString:(NSString *)string;
@end


@interface NSAttributedString (RichTextView)
/**
 *  获取带有图片标示的一个普通字符串
 *
 *  @return NSString
 */
- (NSString *)getPlainString;

//返回一个图片数组
- (NSArray *)getImgaeArray;

//返回数组，每个数组是一种属性和对应的内容
- (NSMutableArray *)getArrayWithAttributed;


//获取有 rgb，alpha的字典
- (NSDictionary *)getRGBDictionaryByColor:(UIColor *)originColor;
/**
*  textview的内容转化为html格式的字符串
*
*  @return 普通字符串 html
*/
- (NSString *)toHtmlString;
@end



NS_ASSUME_NONNULL_END
