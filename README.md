# SandboxFileManager

一个功能完整的 iOS 沙盒文件管理器，基于 Objective-C 开发，支持文件搜索、排序、收藏、批量操作、压缩解压等常用功能。

## 功能特性

### 📁 文件浏览
- 浏览 iOS 沙盒目录（Documents、Library、Caches、Tmp）
- 支持按名称、类型、日期、大小排序
- 支持升序/降序切换
- 支持筛选显示（全部/仅文件夹）
- 右滑快速返回上级目录

### 🔍 搜索功能
- 支持关键词搜索
- 可选择搜索范围（当前目录/全部目录）
- 实时显示搜索结果

### ⭐ 收藏功能
- 一键收藏文件/文件夹
- 快速访问收藏列表
- 收藏状态持久化存储

### ✏️ 批量编辑
- 长按进入批量编辑模式
- 支持全选/取消全选
- 批量复制、移动、删除文件
- 批量压缩文件

### 📦 压缩解压
- 支持 ZIP 压缩
- 压缩文件名可自定义（默认使用日期时间）
- 自动处理同名文件冲突
- 压缩完成后可快速查看

### 🔧 文件操作
- 创建文件夹/文件
- 重命名
- 删除
- 复制路径
- 分享文件
- 用其他应用打开

### 📱 UI 特性
- 适配深色/浅色模式
- 空视图提示
- 操作成功/失败提示
- 左滑快捷操作（删除、重命名、收藏）

## 项目结构

```
SandboxFileManager/
├── AppDelegate.h/m          # 应用代理
├── SceneDelegate.h/m        # 场景代理
├── ViewController.h/m       # 主控制器（示例）
├── Controllers/
│   └── FileListViewController.h/m  # 文件列表控制器（核心）
├── Models/
│   └── FileModel.h/m        # 文件模型
├── Views/
│   └── FileListCell.h/m    # 文件列表单元格
├── Managers/
│   └── FavoriteManager.h/m  # 收藏管理器
├── Tools/
│   ├── FileActionHandler.h/m   # 文件操作处理
│   ├── FileOperateTool.h/m     # 文件系统操作
│   └── SandboxTool.h/m         # 沙盒路径工具
├── Enum/
│   └── FileEnum.h           # 枚举定义
├── Protocols/
│   └── FileManagerDelegate.h   # 代理协议
├── Notifications/
│   └── FileNotification.h   # 通知名称
└── UNZip/                   # 第三方 ZIP 库
```

## 快速开始

### 基本使用

```objc
#import "FileListViewController.h"

// 创建文件管理器
FileListViewController *fileListVC = [[FileListViewController alloc] init];

// 设置代理接收回调
fileListVC.delegate = self;

// 以模态方式弹出
UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:fileListVC];
[self presentViewController:navController animated:YES completion:nil];
```

### 实现代理

```objc
#import "FileManagerDelegate.h"

@interface YourViewController () <FileManagerDelegate>
@end

@implementation YourViewController

// 点击文件/文件夹时调用
- (void)fileManagerDidClickItem:(FileModel *)itemModel itemName:(NSString *)itemName currentDirPath:(NSString *)currentDirPath {
    if (itemModel.itemType == FileItemTypeFolder) {
        // 进入文件夹
    } else {
        // 打开文件
    }
}

// 文件列表发生变化时调用
- (void)fileManagerDidChangeFileList {
    NSLog(@"文件列表已更新");
}

// 文件管理器关闭时调用（可选）
- (void)fileManagerDidCloseWithSelectedFiles:(NSArray<FileModel *> *)selectedFiles currentDirPath:(NSString *)currentDirPath controller:(UIViewController *)controller {
    NSLog(@"选中了 %lu 个文件", (unsigned long)selectedFiles.count);
}

@end
```

## 主要类说明

### FileListViewController
文件管理器主控制器，提供完整的文件管理界面。

**重要属性：**
- `delegate` - 代理对象
- `currentDirPath` - 当前目录路径
- `fileList` - 文件列表数据源
- `selectedFileList` - 已选择的文件列表
- `isBatchEditing` - 是否处于批量编辑模式

**主要方法：**
- `refreshFileList` - 刷新文件列表
- `navigateToDirectory:` - 导航到指定目录
- `enterBatchEditMode` - 进入批量编辑模式
- `exitBatchEditMode` - 退出批量编辑模式

### FileModel
文件模型，表示一个文件或文件夹。

**属性：**
- `fileName` - 文件名
- `filePath` - 文件完整路径
- `itemType` - 文件类型（文件夹/文件）
- `fileSize` - 文件大小
- `modificationDate` - 修改日期
- `isFavorite` - 是否已收藏
- `isSelected` - 是否已选中

### FileManagerDelegate
代理协议，用于 FileListViewController 与外部通信。

**必须实现：**
- `fileManagerDidClickItem:itemName:currentDirPath:` - 点击文件回调
- `fileManagerDidChangeFileList` - 文件列表变化回调

**可选实现：**
- `fileManagerDidCloseWithSelectedFiles:currentDirPath:controller:` - 关闭回调
- `fileManagerDidEnterDirectory:` - 进入目录回调
- `fileManagerDidExitDirectory` - 退出目录回调

### FavoriteManager
收藏管理器单例，负责收藏功能的数据持久化。

```objc
// 添加收藏
[[FavoriteManager sharedManager] addFavorite:fileModel];

// 移除收藏
[[FavoriteManager sharedManager] removeFavorite:fileModel];

// 判断是否已收藏
BOOL isFav = [[FavoriteManager sharedManager] isFavorite:filePath];

// 获取所有收藏
NSArray *favorites = [[FavoriteManager sharedManager] getAllFavorites];
```

### FileOperateTool
文件操作工具类，提供基础文件系统操作。

```objc
// 创建文件夹
[FileOperateTool createFolderWithName:@"新建文件夹" atPath:parentPath];

// 创建文件
[FileOperateTool createFileWithName:@"new.txt" atPath:parentPath];

// 删除
[FileOperateTool deleteItemAtPath:filePath];

// 重命名
[FileOperateTool renameItemAtPath:filePath newName:@"新名称"];

// 复制
[FileOperateTool copyItemAtPath:srcPath toPath:destPath];

// 移动
[FileOperateTool moveItemAtPath:srcPath toPath:destPath];
```

### SandboxTool
沙盒路径工具类，获取各目录路径。

```objc
// 获取沙盒目录路径
NSString *docsPath = [SandboxTool getSandboxDirectoryPath:SandboxDirectoryTypeDocuments];
NSString *cachesPath = [SandboxTool getSandboxDirectoryPath:SandboxDirectoryTypeCaches];

// 获取文件列表
NSArray *files = [SandboxTool getFirstLevelFilesWithDirPath:path displayType:DisplayTypeAll];
```

## 通知

项目使用 NSNotificationCenter 进行事件通知：

| 通知名称 | 用途 |
|---------|------|
| `kNotificationFileListChanged` | 文件列表发生变化 |
| `kNotificationFavoriteChanged` | 收藏状态发生变化 |
| `kNotificationDirectoryChanged` | 当前目录发生变化 |

```objc
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(handleChange:)
                                             name:kNotificationFileListChanged
                                           object:nil];
```

## 枚举说明

### SandboxDirectoryType
```objc
typedef NS_ENUM(NSInteger, SandboxDirectoryType) {
    SandboxDirectoryTypeDocuments,  // Documents目录
    SandboxDirectoryTypeLibrary,    // Library目录
    SandboxDirectoryTypeCaches,     // Caches目录
    SandboxDirectoryTypeTmp          // Tmp目录
};
```

### FileItemType
```objc
typedef NS_ENUM(NSInteger, FileItemType) {
    FileItemTypeFolder = 0,  // 文件夹
    FileItemTypeFile         // 文件
};
```

### DisplayType
```objc
typedef NS_ENUM(NSInteger, DisplayType) {
    DisplayTypeAll = 0,        // 显示全部
    DisplayTypeFolderOnly      // 仅显示文件夹
};
```

## 环境要求

- iOS 13.0+
- Xcode 12.0+
- Objective-C

## 安装

本项目为纯 Objective-C 项目，直接将源码拖入项目即可使用。

### 依赖

- SSZipArchive（已集成在项目中，用于 ZIP 压缩/解压）

## 使用示例

### 1. 集成到现有项目

1. 复制 `SandboxFileManager` 文件夹到你的项目
2. 确保你的项目已经导入 `SSZipArchive` 或使用项目中自带的版本

### 2. 自定义配置

可以在初始化 FileListViewController 后进行配置：

```objc
FileListViewController *fileListVC = [[FileListViewController alloc] init];
fileListVC.delegate = self;

// 设置初始目录（可选，默认 Documents）
// fileListVC.currentDirPath = customPath;

// 设置初始显示类型（可选，默认全部）
// fileListVC.currentDisplayType = DisplayTypeFolderOnly;

// 设置初始排序方式（可选，默认按名称升序）
// fileListVC.currentSortType = 0;
// fileListVC.isSortAscending = YES;
```

## 注意事项

1. 由于 iOS 沙盒机制，应用只能访问自身沙盒目录下的文件
2. 收藏数据存储在 UserDefaults 中
3. 批量删除操作会同时删除文件夹内的所有内容，请谨慎操作

## License

MIT License
