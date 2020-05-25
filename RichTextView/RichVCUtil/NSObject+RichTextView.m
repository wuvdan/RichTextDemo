//
//  NSObject+RichTextView.m
//  RichTextView
//
//  Created by wudan on 2020/5/22.
//  Copyright © 2020 wudan. All rights reserved.
//

#import "NSObject+RichTextView.h"

#pragma mark - UIColor

CGFloat colorComponentFrom(NSString *string, NSUInteger start, NSUInteger length) {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

@implementation UIColor (RichTextView)

+ (UIColor *)colorWithHex:(UInt32)hex{
    return [UIColor colorWithHex:hex andAlpha:1];
}

+ (UIColor *)colorWithHex:(UInt32)hex andAlpha:(CGFloat)alpha{
    return [UIColor colorWithRed:((hex >> 16) & 0xFF)/255.0
                           green:((hex >> 8) & 0xFF)/255.0
                            blue:(hex & 0xFF)/255.0
                           alpha:alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    CGFloat alpha, red, blue, green;
    
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = colorComponentFrom(colorString, 0, 1);
            green = colorComponentFrom(colorString, 1, 1);
            blue  = colorComponentFrom(colorString, 2, 1);
            break;
            
        case 4: // #ARGB
            alpha = colorComponentFrom(colorString, 0, 1);
            red   = colorComponentFrom(colorString, 1, 1);
            green = colorComponentFrom(colorString, 2, 1);
            blue  = colorComponentFrom(colorString, 3, 1);
            break;
            
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = colorComponentFrom(colorString, 0, 2);
            green = colorComponentFrom(colorString, 2, 2);
            blue  = colorComponentFrom(colorString, 4, 2);
            break;
            
        case 8: // #AARRGGBB
            alpha = colorComponentFrom(colorString, 0, 2);
            red   = colorComponentFrom(colorString, 2, 2);
            green = colorComponentFrom(colorString, 4, 2);
            blue  = colorComponentFrom(colorString, 6, 2);
            break;
            
        default:
            return nil;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (NSString *)HEXString{
    UIColor* color = self;
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0]
                                green:components[0]
                                 blue:components[0]
                                alpha:components[1]];
    }
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }
    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)((CGColorGetComponents(color.CGColor))[0]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[1]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
}

+ (UIColor *)colorWithWholeRed:(CGFloat)red
                         green:(CGFloat)green
                          blue:(CGFloat)blue
                         alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.f
                           green:green/255.f
                            blue:blue/255.f
                           alpha:alpha];
}

+ (UIColor *)colorWithWholeRed:(CGFloat)red
                         green:(CGFloat)green
                          blue:(CGFloat)blue {
    return [self colorWithWholeRed:red
                             green:green
                              blue:blue
                             alpha:1.0];
}
@end


#pragma mark - NSString

@implementation NSString (RichTextView)
- (NSAttributedString *)toAttributedString {
    NSData * htmlData=[self dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * importParams=@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType};
    NSError * error=nil;
    NSAttributedString * htmlString=[[NSAttributedString alloc]initWithData:htmlData options:importParams documentAttributes:NULL error:&error];
    return htmlString;
}

// 输出正则里面的内容//输出正则里面的内容
- (NSDictionary *)RXImageUrl {
    NSString *pattern = @"<img src=\"([^\\s]*)\" width=\"([^\\s]*)\" height=\"([^\\s]*)\"\\s*/>";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                options:0
                                                                                  error:NULL];
    NSArray *lines = [expression matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    
    NSMutableArray * resultArr=[NSMutableArray array];
    for (NSTextCheckingResult *textCheckingResult in lines) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        
        //0 代表整个正则内容
        NSString* value1 = [self substringWithRange:[textCheckingResult rangeAtIndex:1]];
        NSString* value2 = [self substringWithRange:[textCheckingResult rangeAtIndex:2]];
        NSString* value3 = [self substringWithRange:[textCheckingResult rangeAtIndex:3]];
        
        result[@"src"] = value1;
        result[@"width"] = value2;
        result[@"height"] = value3;
        [resultArr addObject:result];
        
    }
    return resultArr.firstObject;
}

// 输出正则里面的内容
- (NSArray *)RXToArray {
    NSString *pattern = @"<img src=\"([^\\s]*)\" width=\"([^\\s]*)\" height=\"([^\\s]*)\"\\s*/>";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                options:0
                                                                                  error:NULL];
    NSArray *lines = [expression matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    
    NSMutableArray * resultArr=[NSMutableArray array];
    for (NSTextCheckingResult *textCheckingResult in lines) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        
        //0 代表整个正则内容
        NSString* value1 = [self substringWithRange:[textCheckingResult rangeAtIndex:1]];
        NSString* value2 = [self substringWithRange:[textCheckingResult rangeAtIndex:2]];
        NSString* value3 = [self substringWithRange:[textCheckingResult rangeAtIndex:3]];
        
        result[@"src"] = value1;
        result[@"width"] = value2;
        result[@"height"] = value3;
        [resultArr addObject:result];
        
    }
    return resultArr;
}

// 替换正则
- (NSString *)RXToString {
    NSString *pattern = @"<img src=\"([^\\s]*)\" width=\"([^\\s]*)\" height=\"([^\\s]*)\"\\s*/>";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSString *rxString = [regex stringByReplacingMatchesInString:self
                                                         options:0
                                                           range:NSMakeRange(0, [self length])
                                                    withTemplate:RICHTEXT_IMAGE];
    return rxString;
}

- (NSString *)RXToStringWithString:(NSString *)string {
    NSString *pattern = @"<img src=\"([^\\s]*)\" width=\"([^\\s]*)\" height=\"([^\\s]*)\"\\s*/>";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSString *rxString = [regex stringByReplacingMatchesInString:self
                                                         options:0
                                                           range:NSMakeRange(0, [self length])
                                                    withTemplate:string];
    return rxString;
}

// 分隔成字符串数组
- (NSArray *)RXToStringArray {
    NSString *pattern = @"<img src=\"([^\\s]*)\" width=\"([^\\s]*)\" height=\"([^\\s]*)\"\\s*/>";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSString *rxString = [regex stringByReplacingMatchesInString:self
                                                         options:0
                                                           range:NSMakeRange(0, [self length])
                                                    withTemplate:RICHTEXT_IMAGE];
    //这里是把字符串分割成数组，
    NSArray * strArr=[rxString  componentsSeparatedByString:RICHTEXT_IMAGE];
    return strArr;
}
@end

#pragma mark - NSAttributedString

@implementation NSAttributedString (RichTextView)
- (NSString *)getPlainString {
    NSMutableString *plainString = [NSMutableString stringWithString:self.string];
    __block NSUInteger base = 0;
    
    [self enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.length)
                     options:0
                  usingBlock:^(id value, NSRange range, BOOL *stop) {
                      if (value && [value isKindOfClass:[WDImageTextAttachment class]]) {
                          [plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length)
                                                     withString:((WDImageTextAttachment *) value).imageTag];
                          base += ((WDImageTextAttachment *) value).imageTag.length - 1;
                      }
                  }];
    
    return plainString;
}

- (NSArray *)getImgaeArray {
    NSMutableArray * imageArr=[NSMutableArray array];
    [self enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.length)
                     options:0
                  usingBlock:^(id value, NSRange range, BOOL *stop) {
                
                      if (value && [value isKindOfClass:[NSTextAttachment class]]) {
                          NSTextAttachment* TA=(NSTextAttachment*)value;
                          if (TA.image) {
                              [imageArr addObject:TA.image];
                          } else  {
                              [imageArr addObject:TA.fileWrapper.preferredFilename];
                          }
                      }
                  }];
    
    return imageArr;
}

- (NSMutableArray *)getArrayWithAttributed {
    static NSDictionary *nameToWeight;
    nameToWeight = @{@"normal": @(UIFontWeightRegular),
                     @"bold": @(UIFontWeightBold),
                     @"ultralight": @(UIFontWeightUltraLight),
                     @"thin": @(UIFontWeightThin),
                     @"light": @(UIFontWeightLight),
                     @"regular": @(UIFontWeightRegular),
                     @"medium": @(UIFontWeightMedium),
                     @"semibold": @(UIFontWeightSemibold),
                     @"bold": @(UIFontWeightBold),
                     @"heavy": @(UIFontWeightHeavy),
                     @"black": @(UIFontWeightBlack)};
                    
    NSMutableArray * array=[NSMutableArray array];

    //枚举出所有的附件字符串-这个是顺序来的NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
    [self enumerateAttributesInRange:NSMakeRange(0, self.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *Attributes, NSRange range, BOOL *stop) {
        
       
        NSMutableDictionary * AttributeDict=[NSMutableDictionary dictionary];
        //1.  通过range取出相应的字符串
        NSString * title=[self.string substringWithRange:range];
        //1.把属性字典和相应字符串成为一个大字典
        if (title!=nil) {
            [AttributeDict setObject:title forKey:@"title"];
        }
        //2.把属性存储为一个字典
        //2.取出相应的属性
        //2.字体－大小－加粗:NSOriginalFont,NSFont这里有两个
        UIFont * font= Attributes[@"NSFont"];
        if (font!=nil) {
            //这里这两种都可以
            //             NSLog(@"fontSize1--%@",[font.fontDescriptor objectForKey:@"NSFontSizeAttribute"]);
            //             NSLog(@"fontSize2--%f",font.fontDescriptor.pointSize);
            CGFloat size=font.fontDescriptor.pointSize;
            [AttributeDict setObject:[NSNumber numberWithFloat:size] forKey:@"font"];
        }
        //2.取出字体描述fontDescriptor
        NSDictionary *traits = [font.fontDescriptor objectForKey:UIFontDescriptorTraitsAttribute];
        CGFloat weight=[traits[UIFontWeightTrait] doubleValue];

        
        if (weight>0.0) {
            [AttributeDict setObject:[NSNumber numberWithBool:YES] forKey:@"bold"];
        }
        else
        {
            [AttributeDict setObject:[NSNumber numberWithBool:NO] forKey:@"bold"];
        }

        //2.字体－颜色
        UIColor * fontColor= Attributes[@"NSColor"];
        if (fontColor!=nil) {
            
            [AttributeDict setObject:[fontColor HEXString] forKey:@"color"];
        }
        //2.图片
        WDImageTextAttachment * ImageAtt = Attributes[@"NSAttachment"];
        if (ImageAtt!=nil) {
            [AttributeDict setObject:ImageAtt.image forKey:@"image"];
            //这里为title加上图片标示
            [AttributeDict setObject:ImageAtt.imageTag forKey:@"title"];
        }
        //2.行间距
        NSParagraphStyle * paragraphStyle= Attributes[@"NSParagraphStyle"];
        [AttributeDict setObject:[NSNumber numberWithFloat:paragraphStyle.lineSpacing] forKey:@"lineSpace"];
        
        //4.返回一个数组
        [array addObject:AttributeDict];
    }];
    
    return array;
}

- (NSDictionary *)getRGBDictionaryByColor:(UIColor *)originColor {
    CGFloat r=0,g=0,b=0,a=0;
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [originColor getRed:&r green:&g blue:&b alpha:&a];
    } else {
        const CGFloat *components = CGColorGetComponents(originColor.CGColor);
        
        r = components[0];
        
        g = components[1];
        
        b = components[2];
        
        a = components[3];
    }
    
    return @{@"R":@(r),
             
             @"G":@(g),
             
             @"B":@(b),
             
             @"A":@(a)};
}

- (NSString *)toHtmlString {
    NSString *htmlString;
    NSDictionary *exportParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                   NSCharacterEncodingDocumentAttribute:[NSNumber numberWithInt:NSUTF8StringEncoding]};
    NSData *htmlData = [self dataFromRange:NSMakeRange(0, self.length) documentAttributes:exportParams error:nil];
    htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    return htmlString;
}
@end

