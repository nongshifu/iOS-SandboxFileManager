//
//  ViewController.m
//  iOSSandboxFileManager
//
//  Created by 十三哥 on 2026/5/3.
//

#import "ViewController.h"
#import "FileListViewController.h"
#import "FileModel.h"
#import "FileEnum.h"
#import "SandboxTool.h"

static NSString * const kCellIdentifier = @"DemoCell";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *demoList;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupUI];
}

- (void)setupData {
    _demoList = @[
        @{@"title": @"基础用法", @"type": @"section"},
        @{@"title": @"1. 默认初始化", @"subtitle": @"init 直接进入 SandboxHome 根目录", @"selector": @"demo1_DefaultInit"},

        @{@"title": @"完整路径初始化", @"type": @"section"},
        @{@"title": @"2. 传入完整路径", @"subtitle": @"initWithFullPath: 可指定任意有效路径", @"selector": @"demo2_FullPathInit"},

        @{@"title": @"沙盒目录类型初始化", @"type": @"section"},
        @{@"title": @"3. Documents 目录", @"subtitle": @"initWithSandboxDirectory:Documents] 文档目录", @"selector": @"demo3_DocumentsInit"},
        @{@"title": @"4. Library 目录", @"subtitle": @"initWithSandboxDirectory:Library] 库目录", @"selector": @"demo4_LibraryInit"},
        @{@"title": @"5. Caches 目录", @"subtitle": @"initWithSandboxDirectory:Caches] 缓存目录", @"selector": @"demo5_CachesInit"},
        @{@"title": @"6. Tmp 目录", @"subtitle": @"initWithSandboxDirectory:Tmp] 临时目录", @"selector": @"demo6_TmpInit"},

        @{@"title": @"沙盒目录 + 子路径初始化", @"type": @"section"},
        @{@"title": @"7. Documents/Caches 子目录", @"subtitle": @"initWithSandboxDirectory:Documents subPath:@\"Caches\"]", @"selector": @"demo7_SubPathInit"},
        @{@"title": @"8. Library/Preferences 子目录", @"subtitle": @"initWithSandboxDirectory:Library subPath:@\"Preferences\"]", @"selector": @"demo8_SubPathInit2"},

        @{@"title": @"setInitialPath 方法", @"type": @"section"},
        @{@"title": @"9. 先设置后初始化", @"subtitle": @"[vc setInitialPath:path] 再 init]", @"selector": @"demo9_SetInitialPath"},
    ];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"文件管理器示例";

    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = [UIColor systemBackgroundColor];
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.headerView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"沙盒文件管理器";
    titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:titleLabel];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];

    self.footerView = [[UIView alloc] init];
    self.footerView.backgroundColor = [UIColor systemBackgroundColor];
    self.footerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.footerView];

    UITextView *contactTextView = [[UITextView alloc] init];
    contactTextView.text = @"十三哥QQ: 350722326  微信: ShiSanGe2026";
    contactTextView.font = [UIFont systemFontOfSize:12];
    contactTextView.textColor = [UIColor tertiaryLabelColor];
    contactTextView.textAlignment = NSTextAlignmentCenter;
    contactTextView.editable = NO;
    contactTextView.selectable = YES;
    contactTextView.backgroundColor = [UIColor clearColor];
    contactTextView.translatesAutoresizingMaskIntoConstraints = NO;
    contactTextView.userInteractionEnabled = YES;
    [self.footerView addSubview:contactTextView];

    UIButton *websiteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [websiteButton setTitle:@"官网: https://niceiphone.com/" forState:UIControlStateNormal];
    websiteButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [websiteButton setTitleColor:[UIColor linkColor] forState:UIControlStateNormal];
    websiteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [websiteButton addTarget:self action:@selector(openWebsite) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:websiteButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.headerView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.headerView.heightAnchor constraintEqualToConstant:60],

        [titleLabel.centerXAnchor constraintEqualToAnchor:self.headerView.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:self.headerView.centerYAnchor],

        [self.tableView.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.footerView.topAnchor],

        [self.footerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.footerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.footerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [self.footerView.heightAnchor constraintEqualToConstant:60],

        [contactTextView.centerXAnchor constraintEqualToAnchor:self.footerView.centerXAnchor],
        [contactTextView.topAnchor constraintEqualToAnchor:self.footerView.topAnchor constant:10],
        [contactTextView.widthAnchor constraintEqualToAnchor:self.footerView.widthAnchor multiplier:0.9],
        [contactTextView.heightAnchor constraintEqualToConstant:20],

        [websiteButton.centerXAnchor constraintEqualToAnchor:self.footerView.centerXAnchor],
        [websiteButton.topAnchor constraintEqualToAnchor:contactTextView.bottomAnchor constant:4]
    ]];
}

- (void)openWebsite {
    NSURL *url = [NSURL URLWithString:@"https://niceiphone.com/"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.demoList[indexPath.row];

    if ([item[@"type"] isEqualToString:@"section"]) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = item[@"title"];
        cell.textLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        cell.textLabel.textColor = [UIColor secondaryLabelColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor systemGroupedBackgroundColor];
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.text = item[@"title"];
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        cell.textLabel.textColor = [UIColor labelColor];
        cell.detailTextLabel.text = item[@"subtitle"];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor tertiaryLabelColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor systemBackgroundColor];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *item = self.demoList[indexPath.row];
    NSString *selector = item[@"selector"];

    if (selector) {
        SEL action = NSSelectorFromString(selector);
        if ([self respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:action];
#pragma clang diagnostic pop
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.demoList[indexPath.row];
    if ([item[@"type"] isEqualToString:@"section"]) {
        return 36;
    }
    return 60;
}

#pragma mark - Demo Methods

- (void)openFileListViewController:(FileListViewController *)fileListVC {
    fileListVC.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:fileListVC];
    navController.navigationBar.prefersLargeTitles = NO;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)demo1_DefaultInit {
    FileListViewController *vc = [[FileListViewController alloc] init];
    [self openFileListViewController:vc];
}

- (void)demo2_FullPathInit {
    NSString *docsPath = [SandboxTool getSandboxDirectoryPath:SandboxDirectoryTypeDocuments];
    FileListViewController *vc = [[FileListViewController alloc] initWithFullPath:docsPath];
    [self openFileListViewController:vc];
}

- (void)demo3_DocumentsInit {
    FileListViewController *vc = [[FileListViewController alloc] initWithSandboxDirectory:SandboxDirectoryTypeDocuments];
    [self openFileListViewController:vc];
}

- (void)demo4_LibraryInit {
    FileListViewController *vc = [[FileListViewController alloc] initWithSandboxDirectory:SandboxDirectoryTypeLibrary];
    [self openFileListViewController:vc];
}

- (void)demo5_CachesInit {
    FileListViewController *vc = [[FileListViewController alloc] initWithSandboxDirectory:SandboxDirectoryTypeCaches];
    [self openFileListViewController:vc];
}

- (void)demo6_TmpInit {
    FileListViewController *vc = [[FileListViewController alloc] initWithSandboxDirectory:SandboxDirectoryTypeTmp];
    [self openFileListViewController:vc];
}

- (void)demo7_SubPathInit {
    FileListViewController *vc = [[FileListViewController alloc] initWithSandboxDirectory:SandboxDirectoryTypeDocuments subPath:@"Caches"];
    [self openFileListViewController:vc];
}

- (void)demo8_SubPathInit2 {
    FileListViewController *vc = [[FileListViewController alloc] initWithSandboxDirectory:SandboxDirectoryTypeLibrary subPath:@"Preferences"];
    [self openFileListViewController:vc];
}

- (void)demo9_SetInitialPath {
    FileListViewController *vc = [[FileListViewController alloc] init];
    NSString *docsPath = [SandboxTool getSandboxDirectoryPath:SandboxDirectoryTypeDocuments];
    [vc setInitialPath:docsPath];
    [self openFileListViewController:vc];
}

#pragma mark - FileManagerDelegate

- (void)fileManagerDidCloseWithSelectedFiles:(NSArray<FileModel *> *)selectedFiles currentDirPath:(NSString *)currentDirPath controller:(UIViewController *)controller {
    NSLog(@"========== 文件管理器关闭 ==========");
    NSLog(@"当前目录: %@", currentDirPath);
    NSLog(@"选中文件数量: %lu", (unsigned long)selectedFiles.count);
    NSString *lastFolderName = currentDirPath.lastPathComponent;
    NSLog(@"当前末尾目录: %@", lastFolderName);
    
    for (FileModel *model in selectedFiles) {
        NSLog(@"  - %@ (%@)", model.fileName, model.filePath);
    }
    NSLog(@"==================================");
}

- (void)fileManagerDidClickItem:(FileModel *)itemModel itemName:(NSString *)itemName currentDirPath:(NSString *)currentDirPath {
    NSLog(@"========== 点击了文件 ==========");
    NSLog(@"当前目录: %@", currentDirPath);
    NSLog(@"文件名: %@", itemName);
    NSLog(@"文件路径: %@", itemModel.filePath);
    NSLog(@"文件类型: %@", itemModel.itemType == FileItemTypeFolder ? @"文件夹" : @"文件");
    NSLog(@"==============================");
}

- (void)fileManagerDidChangeFileList {
    NSLog(@"文件列表已更改");
}

@end
