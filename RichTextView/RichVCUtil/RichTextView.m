//
//  RichTextView.m
//  RichTextView
//
//  Created by wudan on 2020/5/21.
//  Copyright © 2020 wudan. All rights reserved.
//

#import "RichTextView.h"
#import "SDWebImageDownloader.h"
#import "SDWebImageManager.h"
#import "WDRichTextHeader.h"

@interface RichTextView ()
@property (nonatomic, assign) NSUInteger finishImageNum;                // 纪录图片下载完成数目
@property (nonatomic, assign) NSUInteger apperImageNum;                 // 纪录图片将要下载数目
@property (nonatomic, assign) NSRange pickerRange;                      // 记录选择图片的位置
@property (nonatomic, assign) NSRange newRange;                         // 记录最新内容的range
@property (nonatomic, strong) NSString *newstr;                         // 记录最新内容的字符串
@property (nonatomic, assign) NSUInteger location;                      // 纪录变化的起始位置
@property (nonatomic, strong) NSMutableAttributedString * locationStr;  // 纪录变化时的内容，即是
@end

@implementation RichTextView

- (void)dealloc {
    NSLog(@"控制销毁");
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initPropertys];
    }
    return self;
}

- (void)setContent:(NSString *)content {
    _content = content;
    [self setRichTextViewContent:content];
}

// 把最新内容都赋给self.locationStr
- (void)setInitLocation {
    self.locationStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
}

- (void)initPropertys {
    self.fontColor = [UIColor blackColor];
    self.location = 0;
    self.lineSapce = 5;
    self.fontSize = 16;
    
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.delegate = self;
    self.dataDetectorTypes = UIDataDetectorTypeNone;
    self.font = [UIFont fontWithName:@"xiaonantongxue" size:self.fontSize];
    
    NSRange wholeRange = NSMakeRange(0, self.textStorage.length);

    // 移除之前显示的效果
    [self.textStorage removeAttribute:NSFontAttributeName range:wholeRange];
    [self.textStorage removeAttribute:NSForegroundColorAttributeName range:wholeRange];
    [self.textStorage removeAttribute:NSParagraphStyleAttributeName range:wholeRange];

    // 字体颜色
    [self.textStorage addAttribute:NSForegroundColorAttributeName value:self.fontColor range:wholeRange];

    // 字体大小
    [self.textStorage addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"xiaonantongxue" size:self.fontSize] range:wholeRange];

    // 字体的行间距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = self.lineSapce;
    [self.textStorage addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:wholeRange];

    [self setInitLocation];
}

#pragma mark  设置内容，二次编辑
- (void)setRichTextViewContent:(NSString *)content {
    NSString *textStr = content;

    // 先赋值富文本
    self.attributedText = [[textStr RXToStringWithString:@"<br />"] toAttributedString];
    [self setInitLocation];
    
    // 开始加载图片
    textStr = [textStr RXToString];
    NSAttributedString * attStr = [textStr toAttributedString];

    if (self.content != nil) {
        NSMutableArray *modelArr = [NSMutableArray array];
        NSArray *imageOfWH = [content RXToArray];
        if (modelArr != nil) {
            [modelArr removeAllObjects];
        }
        // 获取字符串中的图片
        for (NSDictionary * dict in imageOfWH) {
            if ([dict isKindOfClass:[NSDictionary class]]) {
                PictureModel *model = [[PictureModel alloc]init];
                model.imageurl = dict[@"src"];
                model.width = [dict[@"width"] floatValue];;
                model.height = [dict[@"height"] floatValue];
                [modelArr addObject:model];
            }
        }
        [self setAttributedContentStr:attStr withImageArr:modelArr];
    }
}

- (void)setContentStr:(NSString *)contentStr withImageArr:(NSArray *)imageArr {
    NSMutableString * mutableStr = [[NSMutableString alloc] initWithString:contentStr];
    
    NSString * plainStr = [mutableStr stringByReplacingOccurrencesOfString:RICHTEXT_IMAGE withString:@"\n"];
    NSMutableAttributedString * attrubuteStr = [[NSMutableAttributedString alloc] initWithString:plainStr];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = self.lineSapce; // 字体的行间距
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"xiaonantongxue" size:self.fontSize],
                                 NSForegroundColorAttributeName : self.fontColor,
                                 NSParagraphStyleAttributeName : paragraphStyle};
    [attrubuteStr addAttributes:attributes range:NSMakeRange(0, attrubuteStr.length)];
    self.attributedText = attrubuteStr;
    
    
    if (imageArr.count == 0) {
        return;
    }
    
    self.apperImageNum = imageArr.count;
    self.finishImageNum = 0;
    
    NSArray * strArr = [contentStr  componentsSeparatedByString:RICHTEXT_IMAGE];
    NSUInteger locLength = 0;
    for (int i = 0; i < imageArr.count; i++) {
        NSString *locStr = [strArr objectAtIndex:i];
        locLength += locStr.length;
        id image = [imageArr objectAtIndex:i];
        if ([image isKindOfClass:[UIImage class]]) {
            [self setImageText:image withRange:NSMakeRange(locLength + i, 1) appenReturn:NO];
        } else if([image isKindOfClass:[PictureModel class]]) {
            PictureModel * model=(PictureModel *)image;
            [self downLoadImageWithUrl:model.imageurl WithRange:NSMakeRange(locLength+i, 1)];
        } else if([image isKindOfClass:[NSString class]]) {
            [self downLoadImageWithUrl:(NSString *)image WithRange:NSMakeRange(locLength+i, 1)];
        }
    }
    
    // 设置光标到末尾
    self.selectedRange = NSMakeRange(self.attributedText.length, 0);
}

#pragma mark - 添加图片的时候前后自动换行
- (NSAttributedString *)appenReturn:(NSAttributedString*)imageStr {
    NSAttributedString * returnStr = [[NSAttributedString alloc] initWithString:@"\n"];
    NSMutableAttributedString * att = [[NSMutableAttributedString alloc] initWithAttributedString:imageStr];
    [att appendAttributedString:returnStr];
    [att insertAttributedString:returnStr atIndex:0];
    return att;
}

- (void)downLoadImageWithUrl:(NSString *)url WithRange:(NSRange)range {
    if ([[SDImageCache sharedImageCache] diskImageExistsWithKey:url] == NO) {
        __weak typeof(self) weakSelf = self;
        SDWebImageDownloader *manager = [SDWebImageDownloader sharedDownloader];
        
        [manager downloadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            if (error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    UIImage *tempImage = [RichTextView wd_imageWithColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1] size:CGSizeMake(IMAGE_MAX_SIZE, 120)];
                    [weakSelf setImageText:tempImage withRange:range appenReturn:NO];
                });
            } else {
                if(finished) {
                    self.finishImageNum ++;
                    if (self.finishImageNum == self.apperImageNum) {
                        
                    }
                    [[SDWebImageManager sharedManager] saveImageToCache:image forURL:[NSURL URLWithString:url]];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf setImageText:image withRange:range appenReturn:NO];
                    });
                } else {
                    
                }
            }
            
        }];
    } else {
        UIImage * image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:url];
        [self setImageText:image withRange:range appenReturn:NO];
    }
}

- (void)setContentArr:(NSArray *)content {
    //将要下载的图片数目
    self.apperImageNum = 0;
    
    NSMutableArray *imageArr=[NSMutableArray array];
    NSMutableAttributedString * mutableAttributedStr = [[NSMutableAttributedString alloc] init];
    for (NSDictionary * dict in content) {
        if (dict[@"image"] != nil) {
            NSMutableDictionary * imageMutableDict = [NSMutableDictionary dictionaryWithDictionary:[dict[@"image"] RXImageUrl]];
            [imageMutableDict setObject:[NSNumber numberWithInteger:mutableAttributedStr.length] forKey:@"locLenght"];
            [imageArr addObject:imageMutableDict];
            self.apperImageNum ++;
            
            //默认图片
            UIImage * image = [RichTextView wd_imageWithColor:[UIColor lightGrayColor] size:CGSizeMake(UIScreen.mainScreen.bounds.size.width - 20, 100)];
            CGFloat ImgeHeight = image.size.height * IMAGE_MAX_SIZE / image.size.width;
            if (ImgeHeight > IMAGE_MAX_SIZE * 2) {
                ImgeHeight = IMAGE_MAX_SIZE * 2;
            }
            WDImageTextAttachment *imageTextAttachment = [WDImageTextAttachment new];
            imageTextAttachment.image = image;
            
            //Set image size
            imageTextAttachment.imageSize = CGSizeMake(IMAGE_MAX_SIZE, ImgeHeight);
            
            //Insert image image
            [mutableAttributedStr insertAttributedString:[NSAttributedString attributedStringWithAttachment:imageTextAttachment]
                                                 atIndex:mutableAttributedStr.length];
            continue;
        }
        
        NSString * plainStr = dict[@"title"];
        NSMutableAttributedString *attrubuteStr = [[NSMutableAttributedString alloc]initWithString:plainStr];
        //设置初始内容
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = [dict[@"lineSpace"] floatValue];// 字体的行间距
        
        //是否加粗
        if ([dict[@"bold"] boolValue]) {
            NSDictionary *attributes =[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:[dict[@"font"] floatValue] ],NSFontAttributeName,[UIColor colorWithHexString:dict[@"color"]],NSForegroundColorAttributeName,paragraphStyle,NSParagraphStyleAttributeName,nil ];
            [attrubuteStr addAttributes:attributes range:NSMakeRange(0, attrubuteStr.length)];
        } else {
            
            NSDictionary *attributes =[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"xiaonantongxue" size:[dict[@"font"] floatValue]],NSFontAttributeName,[UIColor colorWithHexString:dict[@"color"]],NSForegroundColorAttributeName,paragraphStyle,NSParagraphStyleAttributeName,nil ];
            [attrubuteStr addAttributes:attributes range:NSMakeRange(0, attrubuteStr.length)];
        }
        [mutableAttributedStr appendAttributedString:attrubuteStr];
    }
    
    self.attributedText = mutableAttributedStr;
    
    //没有图片需要下载
    if (self.apperImageNum == 0) {
        return;
    }
    
    self.finishImageNum = 0;
    
    NSUInteger locLength = 0;
    //替换带有图片标签的,设置图片
    for (int i = 0; i < imageArr.count; i++) {
        NSDictionary * imageDict = [imageArr objectAtIndex:i];
        locLength = [imageDict[@"locLenght"]integerValue] ;
        //只取第一个
        [self downLoadImageWithUrl:(NSString *)imageDict[@"src"] WithRange:NSMakeRange(locLength, 1)];
    }
    //设置光标到末尾
    self.selectedRange = NSMakeRange(self.attributedText.length, 0);
}

- (void)setAttributedContentStr:(NSAttributedString *)contentStr withImageArr:(NSArray *)imageArr {
    if (imageArr.count == 0) {
        return;
    }
    
    self.apperImageNum = imageArr.count;
    self.finishImageNum = 0;
    
    //2.这里是把字符串分割成数组，
    NSArray * strArr = [contentStr.string  componentsSeparatedByString:RICHTEXT_IMAGE];
    NSUInteger locLength = 0;
    //替换带有图片标签的,设置图片
    for (int i = 0; i < imageArr.count; i++) {
        NSString *locStr = [strArr objectAtIndex:i];
        locLength += locStr.length;
        id image = [imageArr objectAtIndex:i];
        if ([image isKindOfClass:[UIImage class]]) {
            [self setImageText:image withRange:NSMakeRange(locLength + i, 1) appenReturn:NO];
        } else if([image isKindOfClass:[PictureModel class]]) {
            PictureModel *model=(PictureModel *)image;
            [self downLoadImageWithUrl:model.imageurl WithRange:NSMakeRange(locLength + i, 1)];
        } else if([image isKindOfClass:[NSString class]]) {
            [self downLoadImageWithUrl:(NSString *)image WithRange:NSMakeRange(locLength + i, 1)];
        } else {
            NSLog(@"Other Condition ...");
        }
    }
    //设置光标到末尾
    self.selectedRange = NSMakeRange(self.attributedText.length, 0);
}

#pragma mark - Public Method
// 设置图片
- (void)setImageText:(UIImage *)img withRange:(NSRange)range appenReturn:(BOOL)appen {
    UIImage * image = img;
    if (image == nil) {
        return;
    }
    
    if (![image isKindOfClass:[UIImage class]]) {
        return;
    }
    
    CGFloat ImgeHeight = image.size.height * IMAGE_MAX_SIZE / image.size.width;
    
    if (ImgeHeight > IMAGE_MAX_SIZE * 2) {
        ImgeHeight = IMAGE_MAX_SIZE * 2;
    }
    
    WDImageTextAttachment *imageTextAttachment = [WDImageTextAttachment new];
    
    //Set tag and image
    imageTextAttachment.imageTag = RICHTEXT_IMAGE;
    imageTextAttachment.image = image;
    
    //Set image size
    imageTextAttachment.imageSize = CGSizeMake(IMAGE_MAX_SIZE, ImgeHeight);
    
    if (appen) {
        NSAttributedString * imageAtt = [self appenReturn:[NSAttributedString attributedStringWithAttachment:imageTextAttachment]];
        //Insert image image-
        [self.textStorage insertAttributedString:imageAtt atIndex:range.location];
    } else {
        if (self.textStorage.length > 0) {
            //replace image image-二次编辑
            [self.textStorage replaceCharactersInRange:range withAttributedString:[NSAttributedString attributedStringWithAttachment:imageTextAttachment]];
        }
    }
    
    //Move selection location
    self.selectedRange = NSMakeRange(range.location + 1, range.length);
    
    //设置locationStr的设置
    [self setInitLocation];
}

#pragma mark - Private Tool Method
/** 用颜色返回指定尺寸的一张图片 */
+ (nullable UIImage *)wd_imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
