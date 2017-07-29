//
//  ViewController.m
//  MultipleSelectTable
//
//  Created by 赵永杰 on 2017/7/28.
//  Copyright © 2017年 zhaoyongjie. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *selectArray;

/**
 编辑
 */
@property (nonatomic, strong) UIButton *rightBtn;

/**
 删除
 */
@property (nonatomic, strong) UIButton *deleteBtn;

/**
 全选
 */
@property (nonatomic, strong) UIButton *allBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    [self setupChildViews];
}

#pragma mark - private

- (void)initData {
    for (int i = 0; i < 50; i++) {
        [self.dataArray addObject:[NSNumber numberWithInt:i]];
    }
}

- (void)setupChildViews {
    [self.view addSubview:self.tableView];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.rightBtn],[[UIBarButtonItem alloc] initWithCustomView:self.allBtn]];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.deleteBtn];

}

- (void)rightBtnAction {
    self.rightBtn.selected = !self.rightBtn.isSelected;
    self.deleteBtn.hidden = !self.rightBtn.isSelected;
    self.allBtn.hidden = !self.rightBtn.isSelected;
    if (self.rightBtn.isSelected) {
        [self.tableView setEditing:YES animated:YES];
    }else{
        [self.tableView setEditing:NO animated:YES];
    }
}

- (void)deleteBtnAction {
    NSMutableArray<NSIndexPath *> *indexArr = [NSMutableArray array];
    for (int i = 0; i < self.selectArray.count; i++) {
        NSInteger index = [self.dataArray indexOfObject:self.selectArray[i]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [indexArr addObject:indexPath];
    }
    
    // 不能写在上面的for循环里面
    
    [self.selectArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.dataArray containsObject:obj] ) {
            [self.dataArray removeObject:obj];
        }
    }];
    
    [self.selectArray removeAllObjects];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView deleteRowsAtIndexPaths:indexArr withRowAnimation:UITableViewRowAnimationNone];
    });
}

- (void)allBtnAction {
    self.allBtn.selected = !self.allBtn.isSelected;
    self.rightBtn.selected = self.allBtn.isSelected;
    if (self.allBtn.isSelected) {
        
        NSArray<NSIndexPath *> *arr = self.tableView.indexPathsForVisibleRows;
        [self.selectArray removeAllObjects];
        [self.selectArray addObjectsFromArray:self.dataArray];
        for (NSIndexPath *indexPath in arr) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }else{
        [self.selectArray removeAllObjects];
        [self.tableView setEditing:NO];
        self.allBtn.hidden = YES;
        self.deleteBtn.hidden = YES;
    }
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mutiple"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mutiple"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",self.dataArray[indexPath.row]];
    
    NSNumber *data = self.dataArray[indexPath.row];
    if ([self.selectArray containsObject:data]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *select = self.dataArray[indexPath.row];
    if (![self.selectArray containsObject:select]) {
        [self.selectArray addObject:select];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *select = self.dataArray[indexPath.row];
    if ([self.selectArray containsObject:select]) {
        [self.selectArray removeObject:select];
    }
}


#pragma mark - getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)selectArray {
    if (!_selectArray) {
        _selectArray = [NSMutableArray array];
    }
    return _selectArray;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [[UIButton alloc] init];
        _rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [_rightBtn setTitle:@"完成" forState:UIControlStateSelected];

        [_rightBtn setTitleColor:[UIColor blueColor] forState:0];
        [_rightBtn setTitleColor:[UIColor blueColor] forState:1];

        [_rightBtn addTarget:self action:@selector(rightBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_rightBtn sizeToFit];
    }
    return _rightBtn;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [[UIButton alloc] init];
        _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        
        [_deleteBtn setTitleColor:[UIColor blueColor] forState:0];
        
        [_deleteBtn addTarget:self action:@selector(deleteBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_deleteBtn sizeToFit];
        _deleteBtn.hidden = YES;
    }
    return _deleteBtn;
}

- (UIButton *)allBtn {
    if (!_allBtn) {
        _allBtn = [[UIButton alloc] init];
        _allBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_allBtn setTitle:@"全选" forState:UIControlStateNormal];
        [_allBtn setTitle:@"取消" forState:UIControlStateSelected];
        
        [_allBtn setTitleColor:[UIColor blueColor] forState:0];
        [_allBtn setTitleColor:[UIColor blueColor] forState:1];
        
        [_allBtn addTarget:self action:@selector(allBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_allBtn sizeToFit];
        _allBtn.hidden = YES;
    }
    return _allBtn;
}


@end
