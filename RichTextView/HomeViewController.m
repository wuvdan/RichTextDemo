//
//  HomeViewController.m
//  RichTextView
//
//  Created by wudan on 2020/5/21.
//  Copyright © 2020 wudan. All rights reserved.
//

#import "HomeViewController.h"
#import "ViewController.h"
#import <JQFMDB.h>
#import "Model.h"
#import "Demo1ViewController.h"
#import <LYEmptyView/LYEmptyViewHeader.h>
#import "ICloudDocument.h"
#import <XNProgressHUD.h>

@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray<Model *> *modelArray;
@end

@implementation HomeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"日记";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:kICloudDataUpdateNotificationName object:nil];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.ly_emptyView = [LYEmptyView emptyViewWithImageStr:@"icon_text_no"
                                                            titleStr:@"暂无数据记录"
                                                           detailStr:@""];
}

- (void)MetadataQueryDidUpdate:(NSNotification *)note {
    NSLog(@"icloud数据有更新");
}

- (NSURL *)icloudContainerBaseURL {
    if ([NSFileManager defaultManager].ubiquityIdentityToken) {
        return [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    }
    return nil;
}


- (IBAction)uploadData:(id)sender {
    NSString *fileName = @"*DoNotDelete.db";

    ICloudDocument *documents = [[ICloudDocument alloc] initWithFileURL:[self icloudContainerBaseURL]];
    [XNHUD showLoadingWithTitle:@"数据上传中..."];

    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", documentPath, fileName]];
    if (data) {
        // 如果本地有数据库，就同步到云端
        documents.data = data;
        [documents saveToURL:[self icloudContainerBaseURL] forSaveOperation:(UIDocumentSaveForCreating) completionHandler:^(BOOL success) {
            if (success) {
                [XNHUD showSuccessWithTitle:@"数据上传成功"];
            } else {
                [XNHUD showErrorWithTitle:@"数据上传失败"];
            }
        }];
    } else {
        [XNHUD showErrorWithTitle:@"暂无数据可以上传"];
    }
}

- (IBAction)downloadData:(id)sender {
    
    // 下载文件
    NSString *fileName = @"*DoNotDelete.db";

    NSURLSession *session = [NSURLSession sharedSession];
    [XNHUD showLoadingWithTitle:@"数据下载中..."];
    [[session downloadTaskWithURL:[self icloudContainerBaseURL] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 获取到文件路径
        if (!error) {
            NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:&error];
            [self updateData];
            [XNHUD showSuccessWithTitle:@"数据下载成功"];
        } else {
            [XNHUD showErrorWithTitle:@"数据下载失败"];
        }
    }] resume];
}

- (void)updateData {
    self.modelArray = [[[[JQFMDB shareDatabase] jq_lookupTable:@"MyNote" dicOrModel:[Model class] whereFormat:nil] reverseObjectEnumerator] allObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (IBAction)clearAllData:(id)sender {
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"是否确认删除所有数据?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alter addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[JQFMDB shareDatabase] jq_deleteAllDataFromTable:@"MyNote"];
        [self updateData];
    }]];
    
    [alter addAction: [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil]];
    
    [self presentViewController:alter animated:YES completion:nil];
}

- (IBAction)handleAddRecordAction:(id)sender {
    Demo1ViewController *vc = [[Demo1ViewController alloc] init];
    
//    ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"CellID"];
    }
    cell.textLabel.text = self.modelArray[indexPath.row].contentText;
    cell.detailTextLabel.text = self.modelArray[indexPath.row].createTime;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];
    Demo1ViewController *vc = [[Demo1ViewController alloc] init];
    vc.model = self.modelArray[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
