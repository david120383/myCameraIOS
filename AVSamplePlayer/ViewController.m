//
//  ViewController.m
//  AVSamplePlayer
//
//  Created by bingcai on 16/6/27.
//  Copyright © 2016年 sharetronic. All rights reserved.
//

#import "ViewController.h"
#import "ViewmainController.h"
#import <AVFoundation/AVFoundation.h>

#import "Client.h"
#import "UbibotClient.h"
#import "H264Decoder.h"

#import "TEST.h"
#import "OpenAL2.h"
#import "PCMDataPlayer.h"
#import "PCMAudioRecorder.h"

#import "AVAPIs.h"
#import "AVIOCTRLDEFs.h"
#import "IOTCAPIs.h"
#import "AVFRAMEINFO.h"
#import <pthread.h>

#define MAX_SIZE_IOCTRL_BUF		1024
#define KViewMargin 10
#define KscreenW [UIScreen mainScreen].bounds.size.width

@interface ViewController () <PCMAudioRecorderDelegate>
//@property (copy,nonatomic) NSString *cid;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation ViewController {
    
    BOOL                isFindIFrame;
    BOOL                _firstDecoded;
    CGRect              rect;
    
    H264Decoder         *_decoder;
    //    openal
    OpenAL2 *_openAl2;
    PCMDataPlayer *_pcmDataPlayer;
    PCMAudioRecorder *_pcmRecorder;
    int  _avchannelForSendAudioData;
    FILE *_pcmFile;
    unsigned int _timeStamp;
}
pthread_t client_thread;
Client *client;
//UbibotClient *client;
UILabel *labelErrorMessage;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //    NSLog(@"*****************");
    //    NSLog(_UID);
    //    NSLog(_account);
    //    NSLog(_password);
    //    NSString *clinetStartString =[[NSString alloc]initWithFormat:@"%@|!|%@|!|%@", _UID,_account,_password];
    //    NSLog(clinetStartString);
    //    NSLog(@"*****************");
    
    client = [[Client alloc] init];
    //    client = [[UbibotClient alloc] init];
    
    // #warning 换成自己摄像头的UID
    //    [client start:@"CHPA9X74URV4UNPGYHEJ"]; // Put your device's UID here.
    //    [client start:@"866J62HYSHPRYJ19111A"]; // Put your device's UID here.
    //    client_thread = [client start:clinetStartString]; // Put your device's UID here.
    client_thread = [client start:_UID account:_account password:_password]; // Put your device's UID here.
    //    [client start:_UID]; // Put your device's UID here.
    //    [client start:clinetStartString]; // Put your device's UID here.
    //    NSLog(@"ViewController pthreadID:%u", client_thread);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveBuffer:) name:@"client" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveAudioData:) name:@"audio" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveErrorData:) name:@"error" object:nil];
    
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    //10, 60, 100, 40
    UILabel *labelName =[[UILabel alloc] initWithFrame:CGRectMake(10,  110, screenWidth-20, 40)];
    labelName.text = _name;
    labelName.textColor = [UIColor blackColor];
    labelName.font = [UIFont systemFontOfSize:16];
    labelName.textAlignment = NSTextAlignmentCenter;//设置文本的对齐方式
    labelName.highlighted = YES;
    labelName.numberOfLines = 1;
    //    labelName.backgroundColor = [UIColor grayColor];
    [self.view addSubview:labelName];
    
    labelErrorMessage =[[UILabel alloc] initWithFrame:CGRectMake(10,  160+screenWidth * 3 / 4, screenWidth-20, screenHeight -200 -screenWidth * 3 / 4)];
    //    label2.text = @"12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890";
    labelErrorMessage.textColor = [UIColor blackColor];
    labelErrorMessage.font = [UIFont systemFontOfSize:16];
    labelErrorMessage.textAlignment = NSTextAlignmentLeft;//设置文本的对齐方式
    labelErrorMessage.highlighted = YES;
    labelErrorMessage.numberOfLines = 0;
    labelErrorMessage.lineBreakMode = NSLineBreakByClipping;
    [self.view addSubview:labelErrorMessage];
    
    
    
    rect = CGRectMake(0, 75, screenWidth, screenWidth * 3 / 4);
    UIView *containerView = [[UIView alloc] initWithFrame:rect];
    
    //    containerView.backgroundColor = [UIColor grayColor];
    
    self.imageView = [[UIImageView alloc] initWithFrame:rect];
    self.imageView.image = [self getBlackImage];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.frame = CGRectMake((rect.size.width / 2 )-13, (rect.size.height / 2)+55, self.indicatorView.frame.size.width, self.indicatorView.frame.size.height);
    
    [containerView addSubview:self.imageView];
    [containerView addSubview:self.indicatorView];
    [self.view addSubview:containerView];
    [self.indicatorView startAnimating];
    
    //    NSLog(@"*****************1111");
    [self initData];
    //    NSLog(@"*****************2222");
    [self addButton];
    //    NSLog(@"*****************3333");
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    //        [self receiveIOCtrl];
    //    });
    
    //     _pcmFile = fopen("/Users/XCHF-ios/Documents/first.pcm", "w");
}

- (void)initData {
    
    _decoder = [[H264Decoder alloc] init];
    [_decoder videoDecoder_init];
    
    //    音频播放
    _openAl2     = [[OpenAL2 alloc] init];
    [_openAl2 initOpenAl];
    
    _pcmDataPlayer = [[PCMDataPlayer alloc] init];
    _pcmRecorder   = [[PCMAudioRecorder alloc] init];
    _pcmRecorder.delegate = self;
    _timeStamp = 750492;
}

- (void)addButton {
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 60, 100, 40)];
    button.backgroundColor = [UIColor blueColor];
    button.layer.cornerRadius = 8;
    button.layer.masksToBounds = YES;
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)gotoBack {
    NSString *dict = @"aaa";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopstop" object:dict];
    //    NSLog(@"stopstopstopstopstopstop");
    ////    NSLog(@"pthreadID join_thread_test:%u", client.join_thread_test);
    ////////    pthread_exit(0);
    ////////    pthread_t client_thread;
    int kill_ret = pthread_kill(client_thread,0);
    ////    int kill_ret = pthread_kill(*(client.join_thread_test),0);
    if(kill_ret == ESRCH){
        NSLog(@"指定的线程不存在或者是已经终止");
    }else if(kill_ret == EINVAL){
        NSLog(@"调用传递一个无用的信号");
    }else{
        NSLog(@"线程存在");
    }
    //    client.stop = @"stop";
    //    avClientStop([self.mAvIndex intValue] );
    //    IOTC_Session_Close([self.mSID intValue]);
//    avDeInitialize();
//    IOTC_DeInitialize();
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"client" object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"audio" object:nil];
    
    ViewmainController *next = [[ViewmainController alloc] init];
    [self.view.window setRootViewController:next];
    //    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Receive Audio Data
- (void)DidGetAudioData:(void *const)buffer size:(int)dataSize {
    
    FRAMEINFO_t frameInfo;
    frameInfo.codec_id = 0x89;
    frameInfo.flags =0;
    frameInfo.cam_index=0;
    frameInfo.onlineNum =1;
    //    frameInfo.timestamp = (unsigned int)([[NSDate date] timeIntervalSince1970]*1000);
    //    NSLog(@"%d", frameInfo.timestamp);
    frameInfo.timestamp = _timeStamp ++;
    
    unsigned char requestBuf[dataSize / 2];
    G711Encoder(buffer, requestBuf, dataSize / 2, 1);
    
    int ret = avSendAudioData(_avchannelForSendAudioData, (char *)requestBuf,dataSize/2,(char *)&frameInfo, sizeof(FRAMEINFO_t));
    if (ret>=0) {
        //        NSLog(@"send  audio success");
        NSLog(@"%d", frameInfo.timestamp);
    }else
        NSLog(@"send audio failed---->%d",ret);
    
    short decodeBuf[dataSize];
    G711Decode(decodeBuf, requestBuf, dataSize / 2);
    //    fwrite(decodeBuf, 1, dataSize, _pcmFile);
}

- (void)stopRecord {
    [_pcmRecorder stopRecord];
}

- (void)sendTest {
    
    SMsgAVIoctrlGetStreamCtrlReq *s = (SMsgAVIoctrlGetStreamCtrlReq *)malloc(sizeof(SMsgAVIoctrlGetStreamCtrlReq));
    s->channel = 0;
    int ret = avSendIOCtrl(0, IOTYPE_USER_IPCAM_GETSTREAMCTRL_REQ, (char *)s, sizeof(SMsgAVIoctrlGetStreamCtrlReq));
    free(s);
    NSLog(@"%d",ret);
}

- (void)listWiFiAP {
    
    SMsgAVIoctrlListWifiApReq *structListWiFi = (SMsgAVIoctrlListWifiApReq *)malloc(sizeof(SMsgAVIoctrlListWifiApReq));
    memset(structListWiFi, 0, sizeof(SMsgAVIoctrlListWifiApReq));
    int ret = avSendIOCtrl(0, IOTYPE_USER_IPCAM_LISTWIFIAP_REQ, (char *)structListWiFi, sizeof(SMsgAVIoctrlListWifiApReq));
    NSLog(@"listWiFiAP: %d", ret);
    free(structListWiFi);
}

#pragma mark receive IO ctrl
- (void)receiveIOCtrl {
    
    int ret;
    unsigned int ioType;
    char ioCtrlBuf[MAX_SIZE_IOCTRL_BUF];
    
    while (1) {
        ret = avRecvIOCtrl(0, &ioType, (char *)&ioCtrlBuf, MAX_SIZE_IOCTRL_BUF, 1000);
        usleep(1000000);
        NSLog(@"avRecvIOCtrl: %d, %d", ioType, ret);
        if (ret > 0) {
            NSLog(@"avRecvIOCtrl: %d", ioType);
        }
        
        if (ioType == IOTYPE_USER_IPCAM_LISTWIFIAP_RESP) {
            SMsgAVIoctrlListWifiApResp *s = (SMsgAVIoctrlListWifiApResp *)ioCtrlBuf;
            for (int i = 0; i < s->number; ++i) {
                
                SWifiAp ap = s->stWifiAp[i];
                NSLog(@"WiFi Name: %s", ap.ssid);
            }
        }
    }
}

#pragma mark 音频处理
- (void)receiveAudioData:(NSNotification *)notification {
    
    if (!isFindIFrame) {
        return;
    }
    
    NSDictionary *dict = (NSDictionary *)notification.object;
    NSLog(@"receive: %d", [[dict objectForKey:@"sequence"] intValue]);
    NSData *audioData = [dict objectForKey:@"data"];
    uint8_t *buf = (uint8_t *)[audioData bytes];
    int length = (int)[audioData length];
    //    fwrite(buf, 1, length, _pcmFile);
    short  requestBuf[length * 2];
    //    int l = G711Decode(requestBuf, (unsigned char*)buf, length);
    int l = g711u_decode(requestBuf, (unsigned char *)buf, length);
    
    //open AL
    //    NSData *data = [NSData dataWithBytes:requestBuf length:l];
    //    [_openAl2 openAudio:data length:l];
    
    //    audio queue
    //    fwrite(requestBuf, 1, l, _pcmFile);
    [_pcmDataPlayer play:requestBuf length:l];
}

- (void)receiveErrorData:(NSNotification *)notification{
    NSString *NotificationString = (NSString *)notification.object;
    NSString *errorType ;
    NSString *errorRet ;
    NSString *errorMessage ;
    NSArray *array = [NotificationString componentsSeparatedByString:@"|"];//通过空格符来分隔字符串
    for(int i=0; i<array.count ; i++){
        if(i == 0){
            errorType = array[i];
        }else if (i == 1){
            errorRet = array[i];
        }else if (i == 2){
            errorMessage = array[i];
        }
    }
    labelErrorMessage.text = errorMessage;
    if ([NotificationString rangeOfString:@"avClientStart|-20009"].location !=  NSNotFound) {
        // The client fails in authentication due to incorrect view account or password
        labelErrorMessage.text = @"设备用户名或者密码错误";
    }
    if ([NotificationString rangeOfString:@"IOTC_Connect_ByUID_Parallel|-14"].location != NSNotFound) {
        // The specified IOTC session ID is not valid
        labelErrorMessage.text = @"设备离线";
    }
}

//- (void)receiveVideoThread:(NSNotification *)notification{
//    //    NSString *NotificationString = (NSString *)notification.object;
//    //
//    //    NSArray *array = [NotificationString componentsSeparatedByString:@"|!|"];//通过空格符来分隔字符串
//    //    for(int i=0; i<array.count ; i++)    {
//    //        if(i == 0){
//    //            self.mAvIndex = array[i];
//    //        }else if (i == 1){
//    //            self.mSID = array[i];
//    //        }
//    //    }
//    NSLog(@"receiveVideoThread ");
//}

#pragma mark select decode way
- (void)receiveBuffer:(NSNotification *)notification{
    //    NSLog(@"receiveBuffer");
    NSDictionary *dict = (NSDictionary *)notification.object;
    NSData *dataBuffer = [dict objectForKey:@"data"];
    unsigned int videoPTS = [[dict objectForKey:@"timestamp"] unsignedIntValue];
    //    NSLog(@"receive: %d", [[dict objectForKey:@"sequence"] intValue]);
    int number =  (int)[dataBuffer length];
    uint8_t *buf = (uint8_t *)[dataBuffer bytes];
    
    if (!isFindIFrame && ![self detectIFrame:buf size:number]) {
        return;
    }
    
    [self decodeFramesToImage:buf size:number timeStamp:videoPTS];
}

- (void)decodeFramesToImage:(uint8_t *)nalBuffer size:(int)inSize timeStamp:(unsigned int)pts {
    
    //    调节分辨率后，能自适应，但清晰度有问题
    //    经过确认，是output值设置的问题。outputWidth、outputHeight代表输出图像的宽高，设置的和分辨率一样，是最清晰的效果
    CGSize fSize = [_decoder videoDecoder_decodeToImage:nalBuffer size:inSize timeStamp:pts];
    if (fSize.width == 0) {
        return;
    }
    
    UIImage *image = [_decoder currentImage];
    
    if (image) {
        //        NSLog(@"check bug dispatch_async");
        // 只是将block加入到队列。执行顺序按照队列顺序
        // sync/async的区别在于 调用diapatch的线程是否等待dispatch执行完。sync的线程会等/async的线程不会等
        dispatch_async(dispatch_get_main_queue(), ^{
            //只能在主线程中执行的处理，更新UI
            self.imageView.image = image;
        });
    }
}


#pragma mark public method
- (BOOL)detectIFrame:(uint8_t *)nalBuffer size:(int)size {
    
    NSString *string1 = @"";
    int dataLength = size > 100 ? 100 : size;
    for (int i = 0; i < dataLength; i ++) {
        NSString *temp = [NSString stringWithFormat:@"%x", nalBuffer[i]&0xff];
        if ([temp length] == 1) {
            temp = [NSString stringWithFormat:@"0%@", temp];
        }
        string1 = [string1 stringByAppendingString:temp];
    }
//    NSLog(@"%d,,%@",size,string1);
    NSRange range = [string1 rangeOfString:@"00000000165"];//rangeOfString查找字符串是否包含'00000000165'
    if (range.location == NSNotFound) {
        NSLog(@"00000000165 NSNotFound,%@",string1);
        labelErrorMessage.text = [NSString stringWithFormat:@"%@",string1];
        isFindIFrame = NO;
        return NO;
    } else {
        NSLog(@"00000000165 NSFound,%@",string1);
        labelErrorMessage.text = [NSString stringWithFormat:@"%@",string1];
        isFindIFrame = YES;
        [self.indicatorView stopAnimating];
        return YES;
    }
    
}

- (UIImage *)getBlackImage {
    
    CGSize imageSize = CGSizeMake(50, 50);
    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0] set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *pressedColorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return pressedColorImg;
}

@end
