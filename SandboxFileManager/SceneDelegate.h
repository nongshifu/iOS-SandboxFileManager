//
//  SceneDelegate.h
//  SandboxFileManager
//
//  场景代理
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <HWPanModal/HWPanModal.h>
#import <MJRefresh/MJRefresh.h>
#import <LGSideMenuController/LGSideMenuController.h>

#pragma mark - SceneDelegate

/// 场景代理
/// 负责窗口和场景的生命周期管理（iOS 13+）
@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

/// 窗口
@property (strong, nonatomic) UIWindow *window;

@end
