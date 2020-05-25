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
@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray<Model *> *modelArray;
@end

@implementation HomeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.modelArray = [[[[JQFMDB shareDatabase] jq_lookupTable:@"MyNote" dicOrModel:[Model class] whereFormat:nil] reverseObjectEnumerator] allObjects];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"日记";
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.ly_emptyView = [LYEmptyView emptyViewWithImageStr:@"icon_text_no"
                                                            titleStr:@"暂无数据记录"
                                                           detailStr:@""];

}
- (IBAction)clearAllData:(id)sender {
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"是否确认删除所有数据?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alter addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[JQFMDB shareDatabase] jq_deleteAllDataFromTable:@"MyNote"];
        self.modelArray = [[[[JQFMDB shareDatabase] jq_lookupTable:@"MyNote" dicOrModel:[Model class] whereFormat:nil] reverseObjectEnumerator] allObjects];
        [self.tableView reloadData];
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
