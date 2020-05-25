//
//  Demo1ViewController.m
//  RichTextView
//
//  Created by wudan on 2020/5/23.
//  Copyright © 2020 wudan. All rights reserved.
//

#import "Demo1ViewController.h"
#import "SIXEditorView.h"
#import "SIXHTMLParser.h"
#import <HXPhotoPicker.h>
#import "UIView+RichText.h"
#import "WDRichTextHeader.h"
#import "AliyunOSSTool.h"
#import "Model.h"
#import <JQFMDB.h>
#import "AliyunOSSManager.h"
#import <UITextView+Placeholder.h>

@interface Demo1ViewController ()
@property(nonatomic, strong) SIXEditorView *textView;
@property (nonatomic, strong) HXPhotoManager *manager;

@end

@implementation Demo1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
        
    self.textView = [[SIXEditorView alloc] init];
    self.textView.showsVerticalScrollIndicator = NO;
    self.textView.placeholder = @"尽管吐槽吧~";
    [self.view addSubview:self.textView];
    
    if (self.model) {
        self.title = @"修改";
        self.textView.attributedText = [SIXHTMLParser attributedTextWithHtmlString:self.model.html andImageWidth:self.view.frame.size.width - self.textView.textContainer.lineFragmentPadding * 2 - 30];
    } else {
        self.title = [self currentDateStr];
    }
    
    UIBarButtonItem *image = [[UIBarButtonItem alloc] initWithTitle:@"选取图片" style:(UIBarButtonItemStylePlain) target:self action:@selector(handleAddImageEvent:)];
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(handleSaveContentButtonEvent:)];
    
    self.navigationItem.rightBarButtonItems = @[save, image];
    
    // 注册键盘显示或隐藏的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.textView.frame = CGRectMake(15,
    UIApplication.sharedApplication.statusBarFrame.size.height + 44,
    CGRectGetWidth(self.view.frame) - 30,
    CGRectGetHeight(self.view.frame) - UIApplication.sharedApplication.statusBarFrame.size.height - 44);
}


#pragma mark - Keyboard notification

- (void)onKeyboardNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        CGRect keyboardFrame = ((NSValue *) notification.userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue;
        self.textView.frame = CGRectMake(15,
        UIApplication.sharedApplication.statusBarFrame.size.height + 44,
        CGRectGetWidth(self.view.frame) - 30,
        CGRectGetHeight(self.view.frame) - UIApplication.sharedApplication.statusBarFrame.size.height - 44 - keyboardFrame.size.height);
    } else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        self.textView.frame = CGRectMake(15,
        UIApplication.sharedApplication.statusBarFrame.size.height + 44,
        CGRectGetWidth(self.view.frame) - 30,
        CGRectGetHeight(self.view.frame) - UIApplication.sharedApplication.statusBarFrame.size.height - 44);
    }

    [UIView animateWithDuration:0.8f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)handleAddImageEvent:(id)sender {

    [self hx_presentSelectPhotoControllerWithManager:self.manager didDone:^(NSArray<HXPhotoModel *> * _Nullable allList, NSArray<HXPhotoModel *> * _Nullable photoList, NSArray<HXPhotoModel *> * _Nullable videoList, BOOL isOriginal, UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
        
        [photoList hx_requestImageWithOriginal:NO completion:^(NSArray<UIImage *> * _Nullable imageArray, NSArray<HXPhotoModel *> * _Nullable errorArray) {
            [imageArray enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.textView setImage:obj];
                });
            }];
         }];
        
        [self.manager clearSelectedList];
        
    } cancel:^(UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
        
    }];
    
}

- (void)handleSaveContentButtonEvent:(id)sender {
    [self.view endEditing:YES];
    
    NSArray *imageArray = [self.textView.attributedText getImgaeArray];

    NSMutableArray *array = [NSMutableArray array];
    [imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AliyunOSSImageModel *model = [[AliyunOSSImageModel alloc] init];
        if ([obj isKindOfClass:[NSString class]]) {
            model.url = (NSString *)obj;
        } else {
            model.image = (UIImage *)obj;
        }
        model.index = idx;
        [array addObject:model];
    }];
    
    NSMutableArray *images = [NSMutableArray array];
    
    [SIXHTMLParser htmlStringWithAttributedText:self.textView.attributedText orignalHtml:@"" andCompletionHandler:^(NSString *html) {
        __block NSString *htmlContent = html;
        
        [AliyunOSSManager uploadFilesWithModels:array complete:^(NSArray<AliyunOSSImageModel *> * _Nonnull names, UploadImageState state) {
            
            [names enumerateObjectsUsingBlock:^(AliyunOSSImageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                htmlContent = [htmlContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"[tempImage '%ld']", obj.index]
                                                                     withString:obj.url];
                [images addObject:obj.url];
            }];

            dispatch_async(dispatch_get_main_queue(), ^{
                Model *model = [[Model alloc] init];
                model.html = htmlContent;
                model.contentText = self.textView.text;
                model.firstImageUrl = [images componentsJoinedByString:@","];
                if (self.model) {
                    model.pkid = self.model.pkid;
                    [[JQFMDB shareDatabase] jq_deleteTable:@"MyNote" whereFormat:[NSString stringWithFormat:@"where pkid = %ld", (long)self.model.pkid]];
                    [[JQFMDB shareDatabase] jq_insertTable:@"MyNote" dicOrModel:model];
                } else {
                    model.createTime = [self currentDateStr];
                    [[JQFMDB shareDatabase] jq_insertTable:@"MyNote" dicOrModel:model];
                }

                [XNHUD showSuccessWithTitle:@"保存成功"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            });
        }];
    }];
}

//获取当前时间
- (NSString *)currentDateStr{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm"];//设定时间格式,这里可以设置成自己需要的格式
    NSString *dateString = [dateFormatter stringFromDate:currentDate];//将时间转化成字符串
    return dateString;
}

#pragma mark - Getter Method
- (HXPhotoManager *)manager {
    if (!_manager) {
        _manager = [HXPhotoManager managerWithType:HXPhotoManagerSelectedTypePhoto];
        _manager.configuration.photoMaxNum = 10;
        _manager.configuration.albumShowMode = HXPhotoAlbumShowModePopup;
        _manager.configuration.saveSystemAblum = YES;
    }
    return _manager;
}

@end
