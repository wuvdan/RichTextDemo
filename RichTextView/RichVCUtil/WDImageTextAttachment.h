//
//  WDImageTextAttachment.h
//  RichTextView
//
//  Created by wudan on 2020/5/22.
//  Copyright © 2020 wudan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WDImageTextAttachment : NSTextAttachment
@property(nonatomic, copy) NSString *imageTag;
@property(nonatomic, assign) CGSize imageSize;

- (UIImage *)scaleImage:(UIImage *)image withSize:(CGSize)size;
- (UIImage *)getMaxImage:(UIImage *)image withSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
