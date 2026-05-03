//
//  ViewController.h
//  SandboxFileManager
//
//  主视图控制器 - 示例如何使用FileListViewController
//

#import <UIKit/UIKit.h>
#import "FileManagerDelegate.h"

#pragma mark - ViewController

/// 主视图控制器
/// 展示如何集成和使用FileListViewController文件管理器
@interface ViewController : UIViewController <FileManagerDelegate>

@end
