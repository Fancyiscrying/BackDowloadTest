//
//  ViewController.h
//  BackDowloadTest
//
//  Created by Fancy on 16/2/29.
//  Copyright © 2016年 Fancy. All rights reserved.
//

#import <UIKit/UIKit.h>
//头文件
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<NSURLSessionDelegate,NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate,UIDocumentInteractionControllerDelegate>
{
    IBOutlet UIProgressView *progressView;
    

}
//属性
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (strong,nonatomic)UIDocumentInteractionController *documentInteractionController;

- (IBAction)startDownload:(id)sender;//单击按钮实现下载的动作




@end

