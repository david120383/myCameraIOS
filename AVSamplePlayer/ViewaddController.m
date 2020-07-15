//
//  ViewmainController.m
//  AVSamplePlayer
//
//  Created by cloudforce on 2020/4/14.
//  Copyright © 2020 cloudforce. All rights reserved.
//


#import "ViewaddController.h"
#import "ViewmainController.h"
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

@implementation ViewaddController {
    
}

UITextField *textFieldName;
UITextField *textFieldUID;
UITextField *textFieldAccount;
UITextField *textFieldPassword;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}


- (void)initView {
    
    UIButton *buttonback = [[UIButton alloc] initWithFrame:CGRectMake(10, 60, 100, 40)];
    buttonback.backgroundColor = [UIColor blueColor];
    buttonback.layer.cornerRadius = 8;
    buttonback.layer.masksToBounds = YES;
    [buttonback setTitle:@"返回" forState:UIControlStateNormal];
    [buttonback addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonback];
    
    UILabel *label =[[UILabel alloc] initWithFrame:CGRectMake(10,  110, 100,  40)];
    label.text = @"摄像头名称:";
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentRight;//设置文本的对齐方式
    label.highlighted = YES;
    label.numberOfLines = 1;
    [self.view addSubview:label];
    
    textFieldName = [[UITextField alloc] initWithFrame:CGRectMake(120,  110, KscreenW-2*KViewMargin-110,  40)];
    textFieldName.placeholder = @"请输入摄像头名称";
    textFieldName.text = @"摄像头1";
    textFieldName.backgroundColor = [UIColor whiteColor];
    textFieldName.textColor = [UIColor blackColor];
    textFieldName.font = [UIFont systemFontOfSize:16];
    textFieldName.borderStyle = UITextBorderStyleBezel;
    [self.view addSubview:textFieldName];
    
    UILabel *label2 =[[UILabel alloc] initWithFrame:CGRectMake(10,  160, 100,  40)];
    label2.text = @"UID:";
    label2.textColor = [UIColor blackColor];
    label2.font = [UIFont systemFontOfSize:16];
    label2.textAlignment = NSTextAlignmentRight;//设置文本的对齐方式
    label2.highlighted = YES;
    label2.numberOfLines = 1;
    [self.view addSubview:label2];
    
    textFieldUID = [[UITextField alloc] initWithFrame:CGRectMake(120,  160, KscreenW-2*KViewMargin-110,  40)];
    textFieldUID.placeholder = @"请输入UID";
    textFieldUID.text = @"866J62HYSHPRYJ19111A";
    textFieldUID.backgroundColor = [UIColor whiteColor];
    textFieldUID.textColor = [UIColor blackColor];
    textFieldUID.font = [UIFont systemFontOfSize:16];
    textFieldUID.borderStyle = UITextBorderStyleBezel;
    [self.view addSubview:textFieldUID];
    
    UILabel *label3 =[[UILabel alloc] initWithFrame:CGRectMake(10,  210, 100,  40)];
    label3.text = @"账号:";
    label3.textColor = [UIColor blackColor];
    label3.font = [UIFont systemFontOfSize:16];
    label3.textAlignment = NSTextAlignmentRight;//设置文本的对齐方式
    label3.highlighted = YES;
    label3.numberOfLines = 1;
    [self.view addSubview:label3];
    
    textFieldAccount = [[UITextField alloc] initWithFrame:CGRectMake(120,  210, KscreenW-2*KViewMargin-110,  40)];
    textFieldAccount.placeholder = @"请输入账号";
    textFieldAccount.text = @"admin";
    textFieldAccount.backgroundColor = [UIColor whiteColor];
    textFieldAccount.textColor = [UIColor blackColor];
    textFieldAccount.font = [UIFont systemFontOfSize:16];
    textFieldAccount.borderStyle = UITextBorderStyleBezel;
    [self.view addSubview:textFieldAccount];
    
    UILabel *label4 =[[UILabel alloc] initWithFrame:CGRectMake(10,  260, 100,  40)];
    label4.text = @"密码:";
    label4.textColor = [UIColor blackColor];
    label4.font = [UIFont systemFontOfSize:16];
    label4.textAlignment = NSTextAlignmentRight;//设置文本的对齐方式
    label4.highlighted = YES;
    label4.numberOfLines = 1;
    [self.view addSubview:label4];
    
    textFieldPassword = [[UITextField alloc] initWithFrame:CGRectMake(120,  260, KscreenW-2*KViewMargin-110,  40)];
    textFieldPassword.placeholder = @"请输入密码";
    textFieldPassword.text = @"ipc12345";
    textFieldPassword.backgroundColor = [UIColor whiteColor];
    textFieldPassword.textColor = [UIColor blackColor];
    textFieldPassword.font = [UIFont systemFontOfSize:16];
    textFieldPassword.borderStyle = UITextBorderStyleBezel;
    textFieldPassword.secureTextEntry = YES;//设置编辑框中的内容密码显示
    [self.view addSubview:textFieldPassword];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 310, KscreenW-2*KViewMargin, 40)];
    button.backgroundColor = [UIColor blueColor];
    button.layer.cornerRadius = 8;
    button.layer.masksToBounds = YES;
    //    [button setTitle:@"添加摄像头" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addCamera) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if(self.cid != @"-1"){
        textFieldName.text = self.name;
        textFieldUID.text = self.UID;
        textFieldAccount.text = self.account;
        textFieldPassword.text = self.password;
        [button setTitle:@"修改摄像头" forState:UIControlStateNormal];
    }else{
        [button setTitle:@"添加摄像头" forState:UIControlStateNormal];
    }
    
}

- (void) addCamera{
    int result = -99;
    if(self.cid != @"-1"){
        result = [self updateCamera];
    }else{
        result = [self addNewCamera];
    }
    //    NSLog(@"result is %d",result);
    if(result == 1){
        ViewmainController *next = [[ViewmainController alloc] init];
        [self.view.window setRootViewController:next];
        //        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        NSLog(@"add camera fail %d",result);
    }
}

- (void)gotoBack {
    ViewmainController *next = [[ViewmainController alloc] init];
    [self.view.window setRootViewController:next];
    //    [self dismissViewControllerAnimated:YES completion:nil];
}

- (int)updateCamera {
    NSString* cid = self.cid;
    NSString* name = textFieldName.text;
    NSString* uid = textFieldUID.text;
    NSString* account = textFieldAccount.text;
    NSString* password = textFieldPassword.text;
    NSString* tableName = @"cameraInfo";
    //FMDB中?作为数据占位符, 和%d类似
    NSString* sql =[[NSString alloc]  initWithFormat:@"UPDATE %@ SET name = '%@',uid = '%@',account = '%@',password = '%@'WHERE cid = %@", tableName, name,uid,account, password,cid];
    
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

- (int)addNewCamera {
    NSString *path = [NSString stringWithFormat:@"%@/Documents/record.rdb",NSHomeDirectory()];
    FMDatabase *_database = [[FMDatabase alloc]initWithPath:path];
    if(!_database.open){
        return -1;
    }else{
        //判断是否有表
        BOOL isok = [self isTableOK:_database tableName:@"cameraInfo"];
        if(isok == NO){
            //创建摄像头信息表
            BOOL iscreate = [self CreateTable:_database tableName:@"cameraInfo"];
            NSLog(@"create table result: %@",iscreate?@"YES":@"NO");
            if(iscreate == NO){
                return -3;
            }
        }
        int newkey = [self findMaxKey:_database tableName:@"cameraInfo"];
        //        NSLog(@"new key is %d",newkey);
        NSString* cid = [NSString stringWithFormat:@"%d",newkey];;
        NSString* name = textFieldName.text;
        NSString* uid = textFieldUID.text;
        NSString* account = textFieldAccount.text;
        NSString* password = textFieldPassword.text;
        BOOL isinsert = [self InsertData:_database tableName:@"cameraInfo" cid:cid name:name uid:uid account:account password:password ];
        //        NSLog(@"insert result result: %@",isinsert?@"YES":@"NO");
        if(isinsert == YES){
            return 1;
        }else{
            return -3;
        }
    }
}
- (int)findMaxKey:(FMDatabase *)db tableName:(NSString *) tableName
{
    int cid = 1;
    NSString* sql =[[NSString alloc]  initWithFormat:@"SELECT max(cid) as cid FROM %@ ", tableName];
    FMResultSet *resultSet = [db executeQuery:sql];
    while ([resultSet next]) {
        cid = [resultSet intForColumn:@"cid"];
    }
    return cid + 1;
}

-(BOOL)InsertData:(FMDatabase *)db tableName:(NSString *) tableName cid:(NSString *) cid name:(NSString *) name uid:(NSString *) uid account:(NSString *) account password:(NSString *) password
{
    //FMDB中?作为数据占位符, 和%d类似
    NSString* sql =[[NSString alloc]  initWithFormat:@"INSERT INTO %@ (cid,name,uid,account,password) VALUES( %@,'%@','%@','%@','%@')", tableName, cid,name,uid,account, password];
    
    //特别注意:  ?处需要的时字符串, 其他数据转化为字符串传入
    BOOL b = [db executeUpdate:sql];
    return b;
}

-(BOOL)CreateTable:(FMDatabase *)db tableName:(NSString *) tableName
{
    NSString *sql1 = @"CREATE TABLE IF NOT EXISTS ";
    NSString *sql2 = @" (cid INTEGER,name varchar(32),uid varchar(32),account varchar(32),password varchar(32))";
    NSString* sql =[[NSString alloc]  initWithFormat:@"%@ %@ %@", sql1, tableName, sql2];
    //执行查询语句
    //执行SELECT, 使用executeQuery
    //_databse executeQuery:<#(NSString *), ...#>
    //除了查询语句, 其他语句使用executeUpdate执行
    BOOL b = [db executeUpdate: sql];
    return b;
}

- (BOOL) isTableOK :(FMDatabase *)db tableName:(NSString *) tableName
{
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next])
    {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        if (0 == count){
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}

@end

