//
//  ViewController.m
//  RichTextView
//
//  Created by wudan on 2020/5/21.
//  Copyright © 2020 wudan. All rights reserved.
//

#import "ViewController.h"
#import "WDRichTextHeader.h"
#import "RichTextView.h"
#import "UIView+RichText.h"
#import <JQFMDB.h>
#import "Model.h"
#import "AliyunOSSTool.h"
#import <HXPhotoPicker.h>

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *saveContentButton;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet RichTextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomConstraint;
@property (nonatomic, copy) NSArray *savedImageArray;
@property (nonatomic, strong) HXPhotoManager *manager;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self.addImageButton addTarget:self action:@selector(handleAddImageButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.saveContentButton addTarget:self action:@selector(handleSaveContentButtonEvent:) forControlEvents:UIControlEventTouchUpInside];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
    
    if (self.model) {
        self.title = @"修改";
        self.textView.content = self.model.html;
    } else {
        self.title = [self currentDateStr];
    }
    
    [self.textView initPropertys];
}

//获取当前时间
- (NSString *)currentDateStr{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm"];//设定时间格式,这里可以设置成自己需要的格式
    NSString *dateString = [dateFormatter stringFromDate:currentDate];//将时间转化成字符串
    return dateString;
}

#pragma mark - Keyboard notification

- (void)onKeyboardNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        CGRect keyboardFrame = ((NSValue *) notification.userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue;
        self.textViewBottomConstraint.constant = keyboardFrame.size.height;
    } else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        self.textViewBottomConstraint.constant = 0;
    }

    [UIView animateWithDuration:0.8f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)handleSaveContentButtonEvent:(id)sender {    
    [self.view endEditing:YES];

    __weak __typeof(self)weakSelf = self;
    [self replacetagWithImageArray:[_textView.attributedText getImgaeArray] uploadFinished:^(NSString *content) {
        dispatch_async(dispatch_get_main_queue(), ^{
            Model *model = [[Model alloc] init];
            model.html = content;
            model.contentText = weakSelf.textView.text;
            model.firstImageUrl = weakSelf.savedImageArray.firstObject;
            if (weakSelf.model) {
                model.pkid = weakSelf.model.pkid;
                [[JQFMDB shareDatabase] jq_deleteTable:@"MyNote" whereFormat:[NSString stringWithFormat:@"where pkid = %ld", (long)weakSelf.model.pkid]];
                [[JQFMDB shareDatabase] jq_insertTable:@"MyNote" dicOrModel:model];
            } else {
                [[JQFMDB shareDatabase] jq_insertTable:@"MyNote" dicOrModel:model];
            }
            
            [XNHUD showSuccessWithTitle:@"保存成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        });
    }];
}

// 这里就开始上传图片，拼接图片地址
- (void)replacetagWithImageArray:(NSArray *)picArr uploadFinished:(void(^)(NSString *content))uploadFinished {
    
    NSMutableAttributedString * contentStr = [[NSMutableAttributedString alloc] initWithAttributedString:self->_textView.attributedText];
    [contentStr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, contentStr.length)
                           options:0
                        usingBlock:^(id value, NSRange range, BOOL *stop) {
                            if (value && [value isKindOfClass:[WDImageTextAttachment class]]) {
                                [contentStr replaceCharactersInRange:range withString:RICHTEXT_IMAGE];
                            }
                        }
    ];
        
    NSMutableString *mutableStr = [[NSMutableString alloc] initWithString:[contentStr toHtmlString]];
    
    if (picArr.count > 0) {
        [[AliyunOSSTool sharedInstance] configAccessKeyId:@"LTAIAu0TDnOmGxCR" accessKeySecret:@"xNhsXgFjmcseYdb17D8ZxzgRHyAPZE" endPoint:@"https://oss-cn-shanghai.aliyuncs.com" bucket:@"mmnote-app"];
        [[AliyunOSSTool sharedInstance] uploadImages:picArr objectPrePath:@"MyNote" complete:^(NSArray<NSString *> *names, UploadImageState state) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *newContent = @"";
                NSArray *strArr = [mutableStr componentsSeparatedByString:RICHTEXT_IMAGE];
                NSMutableArray *array = [NSMutableArray array];
                for (int i = 0; i < strArr.count; i++) {
                    NSString * imgTag = @"";
                    if (i < names.count) {
                        NSString *url = names[i];
                        UIImage *uploadBeforeImage = picArr[i];
                        imgTag = [NSString stringWithFormat:@"<img src=\"https://mmnote-app.oss-cn-shanghai.aliyuncs.com/%@\" width=\"%lu\" height=\"%lu\"/>", url, (unsigned long)uploadBeforeImage.size.width, (unsigned long)uploadBeforeImage.size.height];
                        [array addObject:[NSString stringWithFormat:@"https://mmnote-app.oss-cn-shanghai.aliyuncs.com/%@", url]];
                    }
                    NSString *cutStr = [strArr objectAtIndex:i];
                    newContent = [NSString stringWithFormat:@"%@%@%@", newContent, cutStr, imgTag];
                }
                self.savedImageArray = [NSArray arrayWithArray:array];
                uploadFinished(newContent);
            });
        }];
    } else {
        uploadFinished(mutableStr);
    }
}

- (void)handleAddImageButtonEvent:(id)sender {
    [self.view endEditing:YES];
    
//    __weak __typeof(self)weakSelf = self;
//    [self hx_presentSelectPhotoControllerWithManager:self.manager didDone:^(NSArray<HXPhotoModel *> * _Nullable allList, NSArray<HXPhotoModel *> * _Nullable photoList, NSArray<HXPhotoModel *> * _Nullable videoList, BOOL isOriginal, UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
//
//
//        [allList enumerateObjectsUsingBlock:^(HXPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            // 图片添加后 自动换行
//            [weakSelf.textView setImageText:obj.previewPhoto withRange:weakSelf.textView.selectedRange appenReturn:YES];
//        }];
//
//        [weakSelf.manager removeAllTempList];
//
//    } cancel:^(UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
//
//    }];
    
    __weak typeof(self) weakSelf=self;
    UIAlertController * alertVC=[UIAlertController alertControllerWithTitle:@"选择照片" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf selectedImage];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)selectedImage {
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // 图片添加后 自动换行
    [self.textView setImageText:image withRange:self.textView.selectedRange appenReturn:YES];
}


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
