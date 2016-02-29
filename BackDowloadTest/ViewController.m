//
//  ViewController.m
//  BackDowloadTest
//
//  Created by Fancy on 16/2/29.
//  Copyright © 2016年 Fancy. All rights reserved.
//


//添加AVFoundation.framework到创建的项目中
//打开代理文件，编写代码，实现属性的声明




#define DownloadURLString  @"http://www.zyprosoft.com/samplesource/love.mp3"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.session = [self backgroundSession];
    progressView.progress =0;
    progressView.hidden =YES;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma 开始下载
- (IBAction)startDownload:(id)sender
{
    
    NSLog(@"点击了此按钮");
    if (self.downloadTask) {
        return;
    }
//创建URL对象
    NSURL  *downloadURL = [NSURL URLWithString:DownloadURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    //创建下载任务
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask resume];
    //显示进度条
    progressView.hidden = NO;
    

}

#pragma 此方法用来对session 的获取

- (NSURLSession *)backgroundSession
{
    static NSURLSession *session  = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.zyprosoft.backgroundsession"];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    return  session;




}

#pragma 用来跟踪下载数据，并且根据进度刷新进度条的显示
- (void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (downloadTask == self.downloadTask) {
        double progress =(double) totalBytesExpectedToWrite /(double) totalBytesExpectedToWrite;
        NSLog(@"下载任务：%@ 进度： %lf",downloadTask,progress);
        dispatch_async(dispatch_get_main_queue(), ^{progressView.progress = progress;
        });
        
    }

}




#pragma 方法在下载完成后调用，它包含了已经完成了下载任务的绘会话任务，下载任务和一个指向临时下载的文件路径
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{

    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentationDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    NSURL *originalURL = [[downloadTask originalRequest] URL];
    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    NSError *errorCopy;
    [fileManager removeItemAtURL:destinationURL error:NULL];
    BOOL success =[fileManager copyItemAtURL:location toURL:destinationURL error:&errorCopy];
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{});
        
    }
else
{
    NSLog(@"复制文件发成错误：%@", [errorCopy localizedDescription]);

}

}



#pragma 方法在完成任务的数据传输后调用，对进度条的进度进行刷新

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
//判断是否出现错误
    if (error == nil) {
        NSLog(@"任务：%@ 成功完成", task);//输出
    }
else
{
    NSLog(@"任务  ：%@ 发成错误: %@",task, [error localizedDescription]);
    

}
    
    double progress = (double)task.countOfBytesReceived /(double)task.countOfBytesExpectedToReceive;
    dispatch_async(dispatch_get_main_queue(),^{
        progressView.progress = progress;
    } );
    self.downloadTask = nil;

}

#pragma 方法在实现一个会话结束之后，在后台调用

- (void) URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void(^completionHandeler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandeler();
        
    }
    NSLog(@"所有任务已经完成！");

}


@end
