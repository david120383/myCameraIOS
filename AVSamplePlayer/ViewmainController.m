//
//  ViewmainController.m
//  AVSamplePlayer
//
//  Created by cloudforce on 2020/4/14.
//  Copyright © 2020 cloudforce. All rights reserved.
//
#import "ViewmainController.h"
#import "ViewaddController.h"
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Client.h"
#import "H264Decoder.h"
#import "FMDB.h"
#import "TEST.h"
#import "OpenAL2.h"
#import "PCMDataPlayer.h"
#import "PCMAudioRecorder.h"
#import "AVAPIs.h"
#import "AVIOCTRLDEFs.h"
#import "IOTCAPIs.h"
#import "AVFRAMEINFO.h"

#define KViewMargin 10
#define KscreenW [UIScreen mainScreen].bounds.size.width

//代理

@interface ViewmainController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    NSMutableArray *_dataArry;//创建数据源数组
}
@end

@implementation ViewmainController {
    
}
UITableView *tableview;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
}


- (void)initView {
    
    UILabel *label =[[UILabel alloc] initWithFrame:CGRectMake(10,  50, KscreenW-2*KViewMargin,  40)];
       label.text = @"UbibotPlayer";
       label.textColor = [UIColor blackColor];
       label.font = [UIFont systemFontOfSize:16];
       label.textAlignment = NSTextAlignmentCenter;//设置文本的对齐方式
       label.highlighted = YES;
       label.numberOfLines = 1;
       [self.view addSubview:label];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 100, KscreenW-2*KViewMargin, 40)];
    button.backgroundColor = [UIColor blueColor];
    button.layer.cornerRadius = 8;
    button.layer.masksToBounds = YES;
    [button setTitle:@"添加摄像头" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(gotoAddCameraPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    tableview = [[UITableView alloc]initWithFrame:CGRectMake(10, 150, self.view.frame.size.width-2*KViewMargin, self.view.frame.size.height-160) style:UITableViewStylePlain];
    tableview.dataSource =self;//设置数据源
    tableview.delegate = self;//设置代理
    tableview.allowsMultipleSelection = NO;
    tableview.allowsSelectionDuringEditing = NO;
    tableview.allowsMultipleSelectionDuringEditing = NO;
    tableview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tableview];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

//设置有多少分区
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArry.count;
}
//每个分区有多少行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataArry[section] count];
}
//获取cell  每次显示cell 之前都要调用这个方法
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //创建复用标识符
    static NSString *identifire = @"identifier";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:identifire];
    if (!cell) {//如果没有可以复用的
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifire];
    }
    //填充cell  把数据模型中的存储数据 填充到cell中
    cell.backgroundColor = [UIColor grayColor];
    cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor grayColor];
    cell.textLabel.text = _dataArry[indexPath.section][indexPath.row];
    
    //    NSLog(@"cellForRowAtIndexPath:%@",_dataArry[indexPath.section][indexPath.row]);
    if(indexPath.row == 0||indexPath.row == 2||indexPath.row == 3||indexPath.row == 4){
        cell.hidden = YES;//重点
        //        cell.heightAnchor
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0||indexPath.row == 2||indexPath.row == 3||indexPath.row == 4){
        return 0;//重点
    }else{
        return 50;
    }
}
////设置头标
//-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return [NSString stringWithFormat:@"这是第%ld组",section];
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewController *next = [[ViewController alloc]init];
    next.name = self->_dataArry[indexPath.section][1];
    next.UID = self->_dataArry[indexPath.section][2];
    next.account = self->_dataArry[indexPath.section][3];
    next.password = self->_dataArry[indexPath.section][4];
//    [self presentViewController:next animated:YES completion:nil];
    //    [self.navigationController pushViewController:next animated:YES];
    [self.view.window setRootViewController:next];
}

- (void) initData {
    NSString *path = [NSString stringWithFormat:@"%@/Documents/record.rdb",NSHomeDirectory()];
    FMDatabase *_database = [[FMDatabase alloc]initWithPath:path];
    if(!_database.open){
        NSLog(@"open database failed");
        return;
    }else{
        //判断是否有表
        BOOL isok = [self isTableOK:_database tableName:@"cameraInfo"];
        if(isok == NO){
            //创建摄像头信息表
            BOOL iscreate = [self CreateTable:_database tableName:@"cameraInfo"];
            if(iscreate == NO){
                return ;
            }
        }
        [self QueryData:_database tableName:@"cameraInfo"];
    }
}


- (void)gotoAddCameraPage {
    ViewaddController *next = [[ViewaddController alloc] init];
    next.cid = @"-1";
    [self.view.window setRootViewController:next];
//    [self presentViewController:next animated:YES completion:nil];
}
- (void)QueryData:(FMDatabase *)db tableName:(NSString *) tableName
{
    _dataArry=[[NSMutableArray alloc]init];
    //查询所有数据, 显示所有数据
    NSString* sql =[[NSString alloc]  initWithFormat:@"SELECT * FROM %@ ", tableName];
    
    //执行查询语句
    FMResultSet *resultSet = [db executeQuery:sql];
    //注意: 取得每一行使用[resultSet next];
    while ([resultSet next]) {
        NSString *cid = [resultSet stringForColumn:@"cid"];
        NSString *name = [resultSet stringForColumn:@"name"];
        NSString *uid = [resultSet stringForColumn:@"uid"];
        NSString *account = [resultSet stringForColumn:@"account"];
        NSString *password = [resultSet stringForColumn:@"password"];
        NSMutableArray *arr=[[NSMutableArray alloc]init];
        [arr addObject:cid];
        [arr addObject:name];
        [arr addObject:uid];
        [arr addObject:account];
        [arr addObject:password];
        [_dataArry addObject:arr];
    }
}

-(BOOL)CreateTable:(FMDatabase *)db tableName:(NSString *) tableName
{
    NSString *sql1 = @"CREATE TABLE IF NOT EXISTS ";
    NSString *sql2 = @" (cid INTEGER,name varchar(32),uid varchar(32),account varchar(32),password varchar(32))";
    NSString* sql =[[NSString alloc]  initWithFormat:@"%@ %@ %@", sql1, tableName, sql2];
    
    //除了查询语句, 其他语句使用executeUpdate执行
    BOOL b = [db executeUpdate: sql];
    return b;
}

- (BOOL) isTableOK :(FMDatabase *)db tableName:(NSString *) tableName
{
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next])
    {
        NSInteger count = [rs intForColumn:@"count"];
        if (0 == count){
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    NSLog(@"canEditRowAtIndexPath section == %ld",indexPath.section);
//    //第二组可以左滑删除
////    if (indexPath.section == 2) {
////        NSLog(@"section == 2");
////        return YES;
////    }
////
////    NSLog(@"section != 2");
////    return NO;
//    return YES;
//}

// 定义编辑样式
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellEditingStyleDelete;
//}

// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSLog(@"section == %ld",indexPath.section);
//        if (indexPath.section == 2) {
////            NSLog(@"section == 2");
//            //取消该演员的申请
////            NSString *user_no = [self.actor_cpllaboredArray[indexPath.row] valueForKey:@"name"];
////            [self fetch_api_Recruit_withdraw:user_no];
//
//        }
//    }
//}

// 修改编辑按钮文字
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return @"删除";
//}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //        tableView.editing = NO;
        ViewaddController *next = [[ViewaddController alloc] init];
        next.cid = self->_dataArry[indexPath.section][0];
        next.name = self->_dataArry[indexPath.section][1];
        next.UID = self->_dataArry[indexPath.section][2];
        next.account = self->_dataArry[indexPath.section][3];
        next.password = self->_dataArry[indexPath.section][4];
        [self.view.window setRootViewController:next];
//        [self presentViewController:next animated:YES completion:nil];
    }];
    
    UITableViewRowAction *action2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        NSString *cid = self->_dataArry[indexPath.section][0];
        int result = [self deleteCamera:cid];
        if(result == 1){
            [self initData];
            [self initView];
            //            [self->_dataArry removeObjectAtIndex:indexPath.row];
            //            [self->_tableView removeRowsAtIndexPaths:[NSArray arrayWithObject:indexPath.row] withRowAnimation:UITableViewRowAnimationNone];
            //[self->_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            //            NSIndexPath *newPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            //            [self->_tableView deleteRowsAtIndexPaths:@[newPath] withRowAnimation:UITableViewRowAnimationFade];
            //            [self->_tableView dataSource:self];
            //            self->_tableview.dataSource =self;//设置数据源
            //            self->_tableview.delegate = self;//设置代理
            NSLog(@"delete camera success %d",result);
            //            NSLog(@"count :%lu",self->_dataArry.count);
        }else{
            NSLog(@"delete camera fail %d",result);
        }
    }];
    
    return @[action1,action2];
}
- (int)deleteCamera:(NSString *)cid {
    NSString* tableName = @"cameraInfo";
    //FMDB中?作为数据占位符, 和%d类似
    NSString* sql =[[NSString alloc]  initWithFormat:@"DELETE FROM %@ WHERE cid = %@", tableName,cid];
    
    NSString *path = [NSString stringWithFormat:@"%@/Documents/record.rdb",NSHomeDirectory()];
    FMDatabase *_database = [[FMDatabase alloc]initWithPath:path];
    if(!_database.open){
        return -1;
    }else{
        BOOL isupdate = [_database executeUpdate:sql];
        if(isupdate == YES){
            return 1;
        }else{
            return -2;
        }
    }
}
@end
