//
//  Client.m
//  Sample_AVAPIs
//
//  Created by tutk on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Client.h"
#import "ViewController.h"
#import "IOTCAPIs.h"
#import "AVAPIs.h"
#import "AVIOCTRLDEFs.h"
#import "AVFRAMEINFO.h"
#import <sys/time.h>
#import <pthread.h>
#import "TEST.h"
#import "PCMDataPlayer.h"

#define AUDIO_BUF_SIZE	1024
//#define VIDEO_BUF_SIZE	100000
#define VIDEO_BUF_SIZE    500000

@implementation Client

bool bolCheck = false;
//unsigned int _getTickCount() {
//
//    struct timeval tv;
//
//    if (gettimeofday(&tv, NULL) != 0)
//        return 0;
//
//    return (tv.tv_sec * 1000 + tv.tv_usec / 1000);
//}

void *thread_ReceiveAudio(void *arg)
{
    NSLog(@"[thread_ReceiveAudio] Starting...");
    
    int avIndex = *(int *)arg;
    //    char buf[AUDIO_BUF_SIZE];
    char *buf = malloc(AUDIO_BUF_SIZE);
    unsigned int frmNo;
    int ret;
    FRAMEINFO_t frameInfo;
    __block int sequenceNumber = 0;
    
    //    FILE *pcmFile = fopen("/Users/XCHF-ios/Documents/avSample.pcm", "w");
    PCMDataPlayer *_pcmPlayer = [[PCMDataPlayer alloc] init];
    while (1)
    {
        if(bolCheck == true){
            NSLog(@"gotoback");
            break;
        }
        ret = avCheckAudioBuf(avIndex);
        if (ret < 0) break;
        if (ret < 3) // determined by audio frame rate
        {
            usleep(120000);
            continue;
        }
        
        ret = avRecvAudioData(avIndex, buf, AUDIO_BUF_SIZE, (char *)&frameInfo, sizeof(FRAMEINFO_t), &frmNo);
        //        NSLog(@"%d", frameInfo.timestamp);
        
        if(ret == AV_ER_SESSION_CLOSE_BY_REMOTE)
        {
            NSLog(@"[thread_ReceiveAudio] AV_ER_SESSION_CLOSE_BY_REMOTE");
            break;
        }
        else if(ret == AV_ER_REMOTE_TIMEOUT_DISCONNECT)
        {
            NSLog(@"[thread_ReceiveAudio] AV_ER_REMOTE_TIMEOUT_DISCONNECT");
            break;
        }
        else if(ret == IOTC_ER_INVALID_SID)
        {
            NSLog(@"[thread_ReceiveAudio] Session cant be used anymore");
            break;
        }
        else if (ret == AV_ER_LOSED_THIS_FRAME)
        {
            continue;
        }
        
        if (ret>0) {
            
            short  requestBuf[ret * 2];
            int l = G711Decode(requestBuf, (unsigned char*)buf, ret);
            //            fwrite(requestBuf, 1, l, pcmFile);
            
            [_pcmPlayer play:requestBuf length:l];
        }
        
        // Now the data is ready in audioBuffer[0 ... ret - 1]
        // Do something here
        
        //        NSString *string1 = @"";
        //        int dataLength = ret > 100 ? 100 : ret;
        //        for (int i = 0; i < dataLength; i ++) {
        //            NSString *temp = [NSString stringWithFormat:@"%x", buf[i]&0xff];
        //            if ([temp length] == 1) {
        //                temp = [NSString stringWithFormat:@"0%@", temp];
        //            }
        //            string1 = [string1 stringByAppendingString:temp];
        //        }
        //        NSLog(@"%@", string1);
        
        //        最初用的是main thread，此时视频会出现的严重的卡顿。所以，把声音放在单独的线程中
        //        short  requestBuf[ret * 2];
        //        int l = G711Decode(requestBuf, (unsigned char*)buf, ret);
        //        fwrite(requestBuf, 1, l, pcmFile);
        
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //
        ////            NSData *data = [NSData dataWithBytes:buf length:ret];
        //
        //            NSDictionary *dict = @{@"data":[NSData dataWithBytes:buf length:ret],
        //                                   @"sequence":[NSNumber numberWithInt:sequenceNumber ++]};
        //            [[NSNotificationCenter defaultCenter] postNotificationName:@"audio" object:dict];
        //        });
    }
    
    NSLog(@"[thread_ReceiveAudio] thread exit");
    return 0;
}


void *thread_ReceiveTest(void *arg)
{
    int avIndex = *(int *)arg;
    NSLog(@"[thread_ReceiveTest] Starting...");
//    int max = 50;
//    int step = 1;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveVideoThread:) name:@"childthread" object:nil];
    while (1)
    {
        NSLog(@"[thread_ReceiveTest] thread ......%d  %d",bolCheck,avIndex);
        if(bolCheck == true){
            break;
        }
//        NSLog(@"[thread_ReceiveTest] thread ......%d",avIndex);
        usleep(30000*5);
//        step +=1;
    }
    NSLog(@"[thread_ReceiveTest] thread exit");
    return 0;
}

void *thread_ReceiveVideo(void *arg)
{
//    NSLog(@"[thread_ReceiveVideo] Starting...");
    
    int avIndex = *(int *)arg;
    char *buf = malloc(VIDEO_BUF_SIZE);
    unsigned int frmNo;
    int ret;
    FRAMEINFO_t frameInfo;
    
    int pActualFrameSize[] = {0};
    int pExpectedFameSize[] = {0};
    int pActualFrameInfoSize[] = {0};
    
    __block int videoOrder = 0;
    
    while (1)
    {
        if(bolCheck == true){
            break;
        }
//        NSLog(@"[thread_ReceiveTest] thread ......%d  %d",bolCheck,avIndex);
        //        ret = avRecvFrameData(avIndex, buf, VIDEO_BUF_SIZE, (char *)&frameInfo, sizeof(FRAMEINFO_t), &frmNo);
        ret = avRecvFrameData2(avIndex, buf, VIDEO_BUF_SIZE, pActualFrameSize, pExpectedFameSize, (char *)&frameInfo, sizeof(FRAMEINFO_t), pActualFrameInfoSize, &frmNo);
        
        //        if(frameInfo.flags == IPC_FRAME_FLAG_IFRAME)
        
//        NSLog(@"[thread_ReceiveTest] thread ret ......%d  %d",ret,ret);
        if (ret > 0)
        {
//            NSLog(@"[thread_ReceiveTest] thread ret ......%d  %d",ret,ret);
            // got an IFrame, draw it.
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *dict = @{@"data":[NSData dataWithBytes:buf length:ret],
                                       @"timestamp":[NSNumber numberWithUnsignedInt:frameInfo.timestamp]};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"client" object:dict];
            });
            usleep(30000);
        }
        else if(ret == AV_ER_DATA_NOREADY)
        {
            //-20012 The data is not ready for receiving yet.
            usleep(10000);
            continue;
        }
        else if(ret == AV_ER_LOSED_THIS_FRAME)
        {
            //-20014
            //            NSLog(@"Lost video frame NO[%d]", frmNo);
            continue;
        }
        else if(ret == AV_ER_INCOMPLETE_FRAME)
        {
            //-20013
            //            NSLog(@"Incomplete video frame NO[%d]", frmNo);
            continue;
        }
        else if(ret == AV_ER_SESSION_CLOSE_BY_REMOTE)
        {
            //-20015
            NSLog(@"[thread_ReceiveVideo] AV_ER_SESSION_CLOSE_BY_REMOTE");
            break;
        }
        else if(ret == AV_ER_REMOTE_TIMEOUT_DISCONNECT)
        {
            //-20016
            NSLog(@"[thread_ReceiveVideo] AV_ER_REMOTE_TIMEOUT_DISCONNECT");
            break;
        }
        else if(ret == IOTC_ER_INVALID_SID)
        {
            //-14
            NSLog(@"[thread_ReceiveVideo] Session cant be used anymore");
            break;
        }
        
        
    }
    free(buf);
    NSLog(@"[thread_ReceiveVideo] thread exit");
    return 0;
    
}

int start_ipcam_stream (int avIndex) {
    
    int ret;
    unsigned short val = 0;
    
    printf("Step 32 \n");
    if ((ret = avSendIOCtrl(avIndex, IOTYPE_INNER_SND_DATA_DELAY, (char *)&val, sizeof(unsigned short)) < 0))
    {
        NSLog(@"start_ipcam_stream_failed[%d]", ret);
        NSString *message = [[NSString alloc]initWithFormat:@"start_ipcam_stream|%d|start_ipcam_stream_failed[%d]", ret, ret];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:message];
        return 0;
    }
    
    printf("Step 33 \n");
    SMsgAVIoctrlAVStream ioMsg;
    memset(&ioMsg, 0, sizeof(SMsgAVIoctrlAVStream));
    if ((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_START, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream)) < 0))
    {
        NSLog(@"start_ipcam_stream_failed[%d]", ret);
        NSString *message = [[NSString alloc]initWithFormat:@"start_ipcam_stream|%d|start_ipcam_stream_failed[%d]", ret, ret];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:message];
        return 0;
    }
    
    printf("Step 34 \n");
    if ((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_AUDIOSTART, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream)) < 0))
    {
        NSLog(@"start_ipcam_stream_failed[%d]", ret);
        NSString *message = [[NSString alloc]initWithFormat:@"start_ipcam_stream|%d|start_ipcam_stream_failed[%d]", ret, ret];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:message];
        return 0;
    }
    
    printf("Step 35 \n");
    return 1;
}

//void *start_main (NSString *clientStartString) {
//    NSLog(@"AVStream Client Start");
//    if(clientStartString == nil){
//        NSLog(@"start_main clientStartString is null");
//       return NULL;
//    }
////    NSLog(@"start_main clientStartString %@",clientStartString);
//    NSString *UID ;
//    NSString *Account ;
//    NSString *Password ;
//    NSArray *array = [clientStartString componentsSeparatedByString:@"|!|"];//通过空格符来分隔字符串
//    for(int i=0; i<array.count ; i++){
//        if(i == 0){
//            UID = array[i];
//        }else if (i == 1){
//            Account = array[i];
//        }else if (i == 2){
//            Password = array[i];
//        }
//    }
//    int ret, SID;
//
////    NSLog(@"AVStream Client Start");
//
////    ret = IOTC_Initialize2(0);
//    ret = IOTC_Initialize(0, "46.137.188.54", "122.226.84.253", "m2.iotcplatform.com", "m5.iotcplatform.com");
//    NSLog(@"IOTC_Initialize() ret = %d", ret);
//
//    if (ret != IOTC_ER_NoERROR) {
//        NSLog(@"IOTCAPIs exit...");
//        return NULL;
//    }
//
//    // alloc 4 sessions for video and two-way audio
//    avInitialize(4);
//
//    SID = IOTC_Get_SessionID();
////    mSID = @"";
//    ret = IOTC_Connect_ByUID_Parallel((char *)[UID UTF8String], SID);
//
//    printf("Step 2: call IOTC_Connect_ByUID_Parallel(%s) ret(%d).......\n", [UID UTF8String], ret);
//    struct st_SInfo Sinfo;
//    ret = IOTC_Session_Check(SID, &Sinfo);
//
//    if (ret >= 0)
//    {
//        if(Sinfo.Mode == 0)
//            printf("Device is from %s:%d[%s] Mode=P2P\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
//        else if (Sinfo.Mode == 1)
//            printf("Device is from %s:%d[%s] Mode=RLY\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
//        else if (Sinfo.Mode == 2)
//            printf("Device is from %s:%d[%s] Mode=LAN\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
//    }
//
//    unsigned int srvType;
////        NSLog(@"Client UID %@",UID);
////        NSLog(@"Client Account %@",Account);
////        NSLog(@"Client Password %@",Password);
////    int avIndex = avClientStart(SID, "admin", "ipc12345", 20000, &srvType, 0);
//    int avIndex = avClientStart(SID, (char *)[Account UTF8String], (char *)[Password UTF8String], 20000, &srvType, 0);
////    mAvIndex = @"";
//    //    int nResend;
//    //    unsigned int srvType;
//    //     int avIndex = avClientStart2(SID, "admin", "12345678", 20000, &srvType, 0, &nResend);
//    printf("Step 3: call avClientStart(%d).......\n", avIndex);
//
//    if(avIndex < 0)
//    {
//        printf("avClientStart failed[%d]\n", avIndex);
////        avClientStop(avIndex);
//        IOTC_Session_Close(SID);
//        avDeInitialize();
//        IOTC_DeInitialize();
//        return NULL;
//    }
//
//    NSLog(@"Step 31 \n");
//    if (start_ipcam_stream(avIndex)>0)
//    {
//        NSLog(@"Step 36 \n");
//        NSLog(@"check start_ipcam_stream  success");
////        thread_ReceiveVideo(avIndex);
////        int x = arc4random() % 100;
//        pthread_t ThreadVideo_ID;
////        pthread_t ThreadAudio_ID;
////        pthread_t join_thread_1;
//        pthread_create(&ThreadVideo_ID, NULL, &thread_ReceiveVideo, (void *)&avIndex);
////        pthread_create(&ThreadAudio_ID, NULL, &thread_ReceiveAudio, (void *)&avIndex);
////        pthread_create(&join_thread_1, NULL, &thread_ReceiveTest, (void *)&x);
//        pthread_join(ThreadVideo_ID, NULL);//即是子线程合入主线程，主线程阻塞等待子线程结束，然后回收子线程资源。
////        pthread_join(ThreadAudio_ID, NULL);//即是子线程合入主线程，主线程阻塞等待子线程结束，然后回收子线程资源。
////        pthread_join(join_thread_1, NULL);//即是子线程合入主线程，主线程阻塞等待子线程结束，然后回收子线程资源。
//    }
//
//    printf("Step 37 \n");
//    avClientStop(avIndex);
//    NSLog(@"avClientStop OK");
//    IOTC_Session_Close(SID);
//    NSLog(@"IOTC_Session_Close OK");
//    avDeInitialize();
//    IOTC_DeInitialize();
////    NSLog(@"start step 5");
//    NSLog(@"StreamClient exit...");
//    return nil;
//}

void *start_main2 () {
//    NSLog(@"start_main clientStartString %@",clientStartString);
    NSString *UID = mUID ;
    NSString *Account = mAccount ;
    NSString *Password = mPassword ;
//    NSLog(@"start_main2 UID:%@", UID);
//    NSLog(@"start_main2 account:%@", Account);
//    NSLog(@"start_main2 password:%@", Password);
    int ret, SID;
    
//    NSLog(@"AVStream Client Start");

//    ret = IOTC_Initialize2(0);
    ret = IOTC_Initialize(0, "46.137.188.54", "122.226.84.253", "m2.iotcplatform.com", "m5.iotcplatform.com");
    NSLog(@"IOTC_Initialize() ret = %d", ret);

    if (ret != IOTC_ER_NoERROR) {
        NSLog(@"IOTCAPIs exit...");
        IOTC_DeInitialize();
        NSString *message = [[NSString alloc]initWithFormat:@"IOTC_Initialize|%d|IOTCAPIs exit...", ret];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:message];
        return NULL;
    }
    
    // alloc 4 sessions for video and two-way audio
    avInitialize(4);
    
    SID = IOTC_Get_SessionID();
//    mSID = @"";
    ret = IOTC_Connect_ByUID_Parallel((char *)[UID UTF8String], SID);
    
    printf("Step 2: call IOTC_Connect_ByUID_Parallel(%s) ret(%d).......\n", [UID UTF8String], ret);
    struct st_SInfo Sinfo;
    ret = IOTC_Session_Check(SID, &Sinfo);
    
    if (ret >= 0)
    {
        if(Sinfo.Mode == 0)
            printf("Device is from %s:%d[%s] Mode=P2P\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
        else if (Sinfo.Mode == 1)
            printf("Device is from %s:%d[%s] Mode=RLY\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
        else if (Sinfo.Mode == 2)
            printf("Device is from %s:%d[%s] Mode=LAN\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
    }else{
        NSLog(@"IOTCAPIs exit...");
        IOTC_Session_Close(SID);
        IOTC_DeInitialize();
        NSString *message = [[NSString alloc]initWithFormat:@"IOTC_Connect_ByUID_Parallel|%d|IOTCAPIs exit...", ret];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:message];
        return NULL;
    }
    
    unsigned int srvType;
//        NSLog(@"Client UID %@",UID);
//        NSLog(@"Client Account %@",Account);
//        NSLog(@"Client Password %@",Password);
//    int avIndex = avClientStart(SID, "admin", "ipc12345", 20000, &srvType, 0);
//    int avIndex = avClientStart(SID, (char *)[Account UTF8String], (char *)[Password UTF8String], 20000, &srvType, 0);
    int avIndex = avClientStart(SID, (char *)[Account UTF8String], (char *)[Password UTF8String], 20000, &srvType, 0);
//    mAvIndex = @"";
    //    int nResend;
    //    unsigned int srvType;
    //     int avIndex = avClientStart2(SID, "admin", "12345678", 20000, &srvType, 0, &nResend);
    printf("Step 3: call avClientStart(%d).......\n", avIndex);
    
    if(avIndex < 0)
    {
        //-14 The specified IOTC session ID is not valid
        printf("avClientStart failed[%d]\n", avIndex);
        IOTC_Session_Close(SID);
//        avDeInitialize();
        IOTC_DeInitialize();
        NSString *message = [[NSString alloc]initWithFormat:@"avClientStart|%d|avClientStart failed[%d]", avIndex, avIndex];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:message];
        return NULL;
    }
    
    if (start_ipcam_stream(avIndex)>0)
    {
//        thread_ReceiveVideo(avIndex);
//        int x = arc4random() % 100;
        pthread_t ThreadVideo_ID;
//        pthread_t ThreadAudio_ID;
//        pthread_t join_thread_1;
        pthread_create(&ThreadVideo_ID, NULL, &thread_ReceiveVideo, (void *)&avIndex);
//        pthread_create(&ThreadAudio_ID, NULL, &thread_ReceiveAudio, (void *)&avIndex);
//        pthread_create(&join_thread_1, NULL, &thread_ReceiveTest, (void *)&x);
        pthread_join(ThreadVideo_ID, NULL);//即是子线程合入主线程，主线程阻塞等待子线程结束，然后回收子线程资源。
//        pthread_join(ThreadAudio_ID, NULL);//即是子线程合入主线程，主线程阻塞等待子线程结束，然后回收子线程资源。
//        pthread_join(join_thread_1, NULL);//即是子线程合入主线程，主线程阻塞等待子线程结束，然后回收子线程资源。
    }else{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:dict];
    }
    
    avClientStop(avIndex);
    NSLog(@"avClientStop OK");
    IOTC_Session_Close(SID);
    NSLog(@"IOTC_Session_Close OK");
    avDeInitialize();
    IOTC_DeInitialize();
//    NSLog(@"start step 5");
    NSLog(@"StreamClient exit...");
    return nil;
}


- (void)receiveVideoThread:(NSNotification *)notification{
//    NSString *NotificationString = (NSString *)notification.object;
//
//    NSArray *array = [NotificationString componentsSeparatedByString:@"|!|"];//通过空格符来分隔字符串
//    for(int i=0; i<array.count ; i++)    {
//        if(i == 0){
//            self.mAvIndex = array[i];
//        }else if (i == 1){
//            self.mSID = array[i];
//        }
//    }
    bolCheck = true;
//    NSLog(@"stopstopstopstopstopstop receiveVideoThread stopstopstopstopstopstop");
}

//pthread_t join_thread_1;
- (pthread_t)start:(NSString *)clientStartString {
    bolCheck = false;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveVideoThread:) name:@"stopstop" object:nil];
//    NSLog(@"pthreadID Client join_thread_1:%u", join_thread_1);
//    NSLog(@"pthreadID Client join_thread_test:%u", self.join_thread_test);
//    self.join_thread_test = &(join_thread_1);
//    NSLog(@"pthreadID Client join_thread_1:%u", join_thread_1);
    NSLog(@"start clientStartString:%@", clientStartString);
    
//    NSLog(@"start %@", clientStartString);
    pthread_t main_thread;
//    pthread_create(&main_thread, NULL, &start_main, (__bridge void *)clientStartString);
//    pthread_detach(main_thread);//即主线程与子线程分离，子线程结束后，资源自动回收。
//    NSLog(@"Client pthreadID:%u", main_thread);
    return main_thread;
}

NSString *mUID;
NSString *mAccount ;
NSString *mPassword;

- (pthread_t)start:(NSString *)UID account:(NSString *)account password:(NSString *)password {
    bolCheck = false;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveVideoThread:) name:@"stopstop" object:nil];
//    NSLog(@"start UID:%@", UID);
//    NSLog(@"start account:%@", account);
//    NSLog(@"start password:%@", password);
    mUID = UID;
    mAccount = account;
    mPassword = password;
    pthread_t main_thread;
    pthread_create(&main_thread, NULL, &start_main2, NULL);
    pthread_detach(main_thread);//即主线程与子线程分离，子线程结束后，资源自动回收。
    return main_thread;
}

@end
