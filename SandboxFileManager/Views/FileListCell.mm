#import "FileListCell.h"

@interface FileListCell ()
@property (nonatomic, strong, readwrite) UIImageView *fileIconView;
@property (nonatomic, strong, readwrite) UILabel *fileNameLabel;
@property (nonatomic, strong, readwrite) UILabel *fileSizeLabel;
@property (nonatomic, strong, readwrite) UILabel *detailLabel;
@property (nonatomic, strong, readwrite) UIButton *checkButton;
@property (nonatomic, strong, readwrite) UIButton *actionButton;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) FileModel *currentModel;
@end

@implementation FileListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.containerView];

    self.fileIconView = [[UIImageView alloc] init];
    self.fileIconView.contentMode = UIViewContentModeScaleAspectFit;
    [self.containerView addSubview:self.fileIconView];

    self.fileNameLabel = [[UILabel alloc] init];
    self.fileNameLabel.font = [UIFont systemFontOfSize:16];
    self.fileNameLabel.textColor = [UIColor labelColor];
    self.fileNameLabel.numberOfLines = 1;
    [self.containerView addSubview:self.fileNameLabel];

    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.font = [UIFont systemFontOfSize:11];
    self.detailLabel.textColor = [UIColor secondaryLabelColor];
    self.detailLabel.numberOfLines = 1;
    [self.containerView addSubview:self.detailLabel];

    self.checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.checkButton setImage:[UIImage systemImageNamed:@"circle"] forState:UIControlStateNormal];
    [self.checkButton setImage:[UIImage systemImageNamed:@"checkmark.circle.fill"] forState:UIControlStateSelected];
    self.checkButton.hidden = YES;
    [self.checkButton addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.checkButton];

    self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.actionButton setImage:[UIImage systemImageNamed:@"ellipsis.circle"] forState:UIControlStateNormal];
    [self.actionButton addTarget:self action:@selector(actionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.actionButton];

    self.isBatchEditing = NO;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.containerView.frame = self.contentView.bounds;

    CGFloat height = self.contentView.bounds.size.height;
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat actionButtonWidth = 44;
    CGFloat leftPadding = 15;
    CGFloat iconSize = 32;

    if (self.isBatchEditing) {
        self.checkButton.frame = CGRectMake(10, (height - 24) / 2, 24, 24);
        self.actionButton.frame = CGRectMake(width - actionButtonWidth, (height - 24) / 2, 24, 24);
        self.fileIconView.frame = CGRectMake(44, (height - iconSize) / 2, iconSize, iconSize);
        self.fileNameLabel.frame = CGRectMake(86, (height / 2) - 18, width - 86 - actionButtonWidth - 10, 18);
        self.detailLabel.frame = CGRectMake(86, (height / 2) + 2, width - 86 - actionButtonWidth - 10, 14);
    } else {
        self.checkButton.frame = CGRectMake(-44, 0, 0, 0);
        self.actionButton.frame = CGRectMake(width - actionButtonWidth, (height - 24) / 2, 24, 24);
        self.fileIconView.frame = CGRectMake(leftPadding, (height - iconSize) / 2, iconSize, iconSize);
        self.fileNameLabel.frame = CGRectMake(leftPadding + iconSize + 10, (height / 2) - 18, width - leftPadding - iconSize - actionButtonWidth - 20, 18);
        self.detailLabel.frame = CGRectMake(leftPadding + iconSize + 10, (height / 2) + 2, width - leftPadding - iconSize - actionButtonWidth - 20, 14);
    }
}

- (void)configWithFileModel:(FileModel *)model {
    self.currentModel = model;
    self.fileNameLabel.text = model.fileName;

    NSString *sizeStr = [model formattedFileSize];
    NSString *dateStr = [model formattedModificationDate];
    self.detailLabel.text = [NSString stringWithFormat:@"%@  %@", sizeStr, dateStr];

    if (model.itemType == FileItemTypeFolder) {
        self.fileIconView.image = [UIImage systemImageNamed:@"folder.fill"];
    } else {
        self.fileIconView.image = [UIImage systemImageNamed:@"doc.fill"];
    }

    if (model.isFavorite) {
        self.containerView.backgroundColor = [UIColor systemBackgroundColor];
        self.fileIconView.tintColor = [UIColor systemOrangeColor];
    } else {
        self.containerView.backgroundColor = [UIColor clearColor];
        if (model.itemType == FileItemTypeFolder) {
            self.fileIconView.tintColor = [UIColor systemBlueColor];
        } else {
            self.fileIconView.tintColor = [UIColor systemGrayColor];
        }
    }

    self.checkButton.selected = model.isSelected;
    self.checkButton.hidden = !self.isBatchEditing;
    self.actionButton.hidden = self.isBatchEditing;
}

- (void)checkButtonTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.currentModel.isSelected = sender.selected;

    if ([self.cellDelegate respondsToSelector:@selector(fileListCell:didSelectCheckBox:forFileModel:)]) {
        [self.cellDelegate fileListCell:self didSelectCheckBox:sender.selected forFileModel:self.currentModel];
    }
}

- (void)actionButtonTapped:(UIButton *)sender {
    if ([self.cellDelegate respondsToSelector:@selector(fileListCell:didTapActionButtonForFileModel:)]) {
        [self.cellDelegate fileListCell:self didTapActionButtonForFileModel:self.currentModel];
    }
}

- (void)setIsBatchEditing:(BOOL)isBatchEditing {
    _isBatchEditing = isBatchEditing;
    self.checkButton.hidden = !isBatchEditing;
    self.actionButton.hidden = isBatchEditing;
    [self setNeedsLayout];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.fileIconView.image = nil;
    self.fileNameLabel.text = nil;
    self.fileSizeLabel.text = nil;
    self.checkButton.selected = NO;
    self.containerView.backgroundColor = [UIColor clearColor];
}

@end