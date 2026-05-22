#import "FileModel.h"
#import "RemarkManager.h"
#import "FavoriteManager.h"
#import "FileSelectionManager.h"

@implementation FileModel

+ (instancetype)modelWithFilePath:(NSString *)filePath {
    FileModel *model = [[FileModel alloc] init];
    model.filePath = filePath;
    model.fileName = [filePath lastPathComponent];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:nil];

    if (attributes) {
        NSString *itemType = attributes[NSFileType];
        if ([itemType isEqualToString:NSFileTypeDirectory]) {
            model.itemType = FileItemTypeFolder;
            model.fileSize = 0;
        } else {
            model.itemType = FileItemTypeFile;
            model.fileSize = [attributes[NSFileSize] unsignedLongLongValue];
        }
        model.modificationDate = attributes[NSFileModificationDate];
    }

    model.parentDirPath = [filePath stringByDeletingLastPathComponent];
    model.isFavorite = [[FavoriteManager sharedManager] isFavorite:filePath];
    model.isSelected = [[FileSelectionManager sharedManager] isFileSelected:model];;
    model.lastAccessTime = [NSDate date]; // 设置为当前时间
    
    // 从本地加载备注
    model.remark = [[RemarkManager sharedManager] getRemarkForFilePath:filePath];

    return model;
}

- (NSString *)formattedFileSize {
    if (self.itemType == FileItemTypeFolder) {
        return @"文件夹";
    }

    unsigned long long bytes = self.fileSize;
    if (bytes < 1024) {
        return [NSString stringWithFormat:@"%llu B", bytes];
    } else if (bytes < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.1f KB", bytes / 1024.0];
    } else if (bytes < 1024 * 1024 * 1024) {
        return [NSString stringWithFormat:@"%.1f MB", bytes / (1024.0 * 1024.0)];
    } else {
        return [NSString stringWithFormat:@"%.1f GB", bytes / (1024.0 * 1024.0 * 1024.0)];
    }
}

- (NSString *)formattedModificationDate {
    if (!self.modificationDate) {
        return @"--";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    return [formatter stringFromDate:self.modificationDate];
}

- (BOOL)isHiddenFile {
    if (self.fileName.length > 0 && [self.fileName hasPrefix:@"."]) {
        return YES;
    }
    return NO;
}

/// 转换为字典（用于持久化）
- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.fileName) dict[@"fileName"] = self.fileName;
    if (self.filePath) dict[@"filePath"] = self.filePath;
    if (self.parentDirPath) dict[@"parentDirPath"] = self.parentDirPath;
    dict[@"itemType"] = @(self.itemType);
    dict[@"fileSize"] = @(self.fileSize);
    if (self.modificationDate) dict[@"modificationDate"] = @([self.modificationDate timeIntervalSince1970]);
    if (self.lastAccessTime) dict[@"lastAccessTime"] = @([self.lastAccessTime timeIntervalSince1970]);
    if (self.remark) dict[@"remark"] = self.remark;
    dict[@"isFavorite"] = @(self.isFavorite);
    dict[@"isSelected"] = @(self.isSelected);
    
    return dict;
}

/// 从字典初始化（用于从持久化恢复）
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self && dict) {
        self.fileName = dict[@"fileName"];
        self.filePath = dict[@"filePath"];
        self.parentDirPath = dict[@"parentDirPath"];
        self.itemType = [(NSNumber *)dict[@"itemType"] integerValue];
        self.fileSize = [(NSNumber *)dict[@"fileSize"] unsignedLongLongValue];
        
        NSNumber *dateNum = dict[@"modificationDate"];
        if (dateNum) {
            self.modificationDate = [NSDate dateWithTimeIntervalSince1970:dateNum.doubleValue];
        }
        
        NSNumber *accessDateNum = dict[@"lastAccessTime"];
        if (accessDateNum) {
            self.lastAccessTime = [NSDate dateWithTimeIntervalSince1970:accessDateNum.doubleValue];
        }
        
        self.remark = dict[@"remark"];
        self.isFavorite = [(NSNumber *)dict[@"isFavorite"] boolValue];
        self.isSelected = [(NSNumber *)dict[@"isSelected"] boolValue];
    }
    return self;
}

@end
