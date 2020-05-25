//
//  WDImageTextAttachment.m
//  RichTextView
//
//  Created by wudan on 2020/5/22.
//  Copyright © 2020 wudan. All rights reserved.
//

#import "WDImageTextAttachment.h"
//获取屏幕 宽度、高度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@implementation WDImageTextAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    return CGRectMake(SCREEN_WIDTH / 2 - _imageSize.width / 2, 0, _imageSize.width, _imageSize.height);
}

- (UIImage *)scaleImage:(UIImage *)image withSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)getMaxImage:(UIImage *)image withSize:(CGSize)size {
    if (size.width == 0 || size.height == 0) {
        return image;
    }
    
    CGSize imgSize = image.size;
    float scale    = size.height / size.width;
    float imgScale = imgSize.height / imgSize.width;
    float width    = 0.0f;
    float height   = 0.0f;
    
    if (imgScale < scale && imgSize.width > size.width) {
        width  = size.width;
        height = width * imgScale;
    } else if (imgScale > scale && imgSize.height > size.height) {
        height = size.height;
        width  = height / imgScale;
    } else {
        width  = size.width;
        height = size.height;
    }
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIImage* imagemax= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imagemax;
}
@end
