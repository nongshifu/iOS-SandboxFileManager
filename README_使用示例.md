# 沙盒文件管理器 - 使用示例

## 概述

这个文件管理器提供三种使用方式，可以根据需求灵活选择。

---

## 使用方式

### 1. 完整文件管理器（带底部导航）

适合作为独立功能模块，包含文件浏览、历史、收藏、回收站、窗口管理等完整功能。

```objective-c
// 方式1：直接创建并显示
#import "SandboxFileManager.h"

UIViewController *fileManager = [SandboxFileManager fullFileManager];
[self presentViewController:fileManager animated:YES completion:nil];

// 方式2：使用便捷方法
[SandboxFileManager presentFullFileManagerFrom:self];
```

### 2. 文件浏览器（仅文件列表）

适合只需要文件浏览功能，可以自定义初始路径。

```objective-c
#import "SandboxFileManager.h"

// 指定初始路径
NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
UIViewController *fileBrowser = [SandboxFileManager fileBrowserWithPath:docsPath];
[self presentViewController:fileBrowser animated:YES completion:nil];

// 或者使用便捷方法
[SandboxFileManager presentFileBrowserFrom:self path:docsPath];
```

### 3. 文件选择器（用于选择文件）

适合需要用户选择文件的场景，支持单选/多选。

```objective-c
#import "SandboxFileManager.h"

// 单选文件
[SandboxFileManager presentFilePickerFrom:self
                               initialPath:nil
                    allowsMultipleSelection:NO
                                  completion:^(NSArray<FileModel *> * _Nullable selectedFiles) {
    if (selectedFiles.count > 0) {
        FileModel *file = selectedFiles.firstObject;
        NSLog(@"选择的文件: %@", file.fileName);
    }
}];

// 多选文件
[SandboxFileManager presentFilePickerFrom:self
                               initialPath:nil
                    allowsMultipleSelection:YES
                                  completion:^(NSArray<FileModel *> * _Nullable selectedFiles) {
    NSLog(@"选择了 %ld 个文件", (long)selectedFiles.count);
}];
```

---

## 高级用法

### 使用代理方式

```objective-c
#import "SandboxFileManager.h"

@interface ViewController () <SandboxFileManagerDelegate>
@end

@implementation ViewController

- (void)showFileManager {
    SandboxFileManager *manager = [SandboxFileManager sharedManager];
    manager.delegate = self;
    manager.style = SandboxFileManagerStyleFilePicker;
    manager.allowsMultipleSelection = YES;
    
    UIViewController *filePicker = [SandboxFileManager filePickerWithInitialPath:nil
                                                          allowsMultipleSelection:YES
                                                                      completion:nil];
    [self presentViewController:filePicker animated:YES completion:nil];
}

#pragma mark - SandboxFileManagerDelegate

- (void)fileManager:(SandboxFileManager *)manager didSelectFiles:(NSArray<FileModel *> *)files {
    NSLog(@"选择了 %ld 个文件", (long)files.count);
}

- (void)fileManagerDidClose:(SandboxFileManager *)manager {
    NSLog(@"文件管理器关闭");
}

@end
```

### 集成到现有导航流程中

```objective-c
// 不使用 present，而是 push 到导航栈
UIViewController *fileBrowser = [SandboxFileManager fileBrowserWithPath:path];
[self.navigationController pushViewController:fileBrowser animated:YES];
```

---

## 架构说明

### 主要组件

1. **SandboxFileManager** - 统一入口类，提供便捷方法
2. **RootViewController** - 完整文件管理器（带底部导航）
3. **FileListViewController** - 文件列表控制器
4. **FileOperationToolbar** - 悬浮操作工具栏

### 三种样式对比

| 特性 | 完整模式 | 文件浏览器 | 文件选择器 |
|------|---------|----------|----------|
| 底部导航 | ✅ | ❌ | ❌ |
| 历史记录 | ✅ | ❌ | ❌ |
| 收藏功能 | ✅ | ❌ | ❌ |
| 回收站 | ✅ | ❌ | ❌ |
| 窗口管理 | ✅ | ❌ | ❌ |
| 文件操作 | ✅ | ✅ | ❌ |
| 文件选择 | ✅ | ✅ | ✅ |
| 悬浮工具栏 | 可选 | 可选 | 可选 |

---

## 自定义悬浮工具栏

如果你想在自己的控制器中使用悬浮工具栏：

```objective-c
#import "FileOperationToolbar.h"

@interface MyViewController () <FileOperationToolbarDelegate>
@property (nonatomic, strong) FileOperationToolbar *toolbar;
@end

@implementation MyViewController

- (void)showToolbar {
    self.toolbar = [FileOperationToolbar toolbar];
    self.toolbar.delegate = self;
    self.toolbar.selectedCount = 0;
    self.toolbar.showsDoneButton = YES;
    [self.toolbar showInView:self.view animated:YES];
}

- (void)updateSelectionCount:(NSInteger)count {
    [self.toolbar updateSelectedCount:count];
}

#pragma mark - FileOperationToolbarDelegate

- (void)toolbar:(FileOperationToolbar *)toolbar didSelectAction:(FileOperationAction)action {
    switch (action) {
        case FileOperationActionCopy:
            [self handleCopy];
            break;
        case FileOperationActionMove:
            [self handleMove];
            break;
        case FileOperationActionDelete:
            [self handleDelete];
            break;
        case FileOperationActionDone:
            [self.toolbar hideAnimated:YES];
            break;
        default:
            break;
    }
}

@end
```

---

## 更新 SceneDelegate 集成

保持当前的 SceneDelegate 不变，它仍然使用完整模式：

```objective-c
// SceneDelegate.m
#import "RootViewController.h"

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    
    // 仍然使用完整模式作为主界面
    LGSideMenuController *sideMenuController = [[LGSideMenuController alloc] initWithRootViewController:[RootViewController rootController] leftViewController:nil rightViewController:nil];
    
    self.window.rootViewController = sideMenuController;
    self.window.backgroundColor = [UIColor systemBackgroundColor];
    [self.window makeKeyAndVisible];
}
```

---

## 最佳实践

1. **选择合适的使用方式**
   - 需要完整功能 → 使用 `fullFileManager`
   - 只需要文件浏览 → 使用 `fileBrowserWithPath`
   - 需要用户选择文件 → 使用 `filePickerWithInitialPath`

2. **内存管理**
   - 文件选择器模式使用 completion block，会自动清理
   - 长期驻留的文件管理器建议使用代理方式

3. **路径处理**
   - 可以传入任意有效路径作为初始路径
   - 不传路径默认使用 Documents 目录
