//
// Created by jason on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "HSUSuggestMentionCell.h"
#import "UIImageView+AFNetworking.h"


@implementation HSUSuggestMentionCell {

    UIImageView *avatarIV;
    UILabel *nameL;
    UILabel *screenNameL;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        avatarIV = [[UIImageView alloc] init];
        [self addSubview:avatarIV];
        avatarIV.frame = ccr(0, 0, 37, 37);

        screenNameL = [[UILabel alloc] init];
        [self addSubview:screenNameL];
        screenNameL.textColor = kBlackColor;
        screenNameL.font = [UIFont systemFontOfSize:12];
        screenNameL.leftTop = ccp(avatarIV.right + 10, 6);
        screenNameL.backgroundColor = kClearColor;

        nameL = [[UILabel alloc] init];
        [self addSubview:nameL];
        nameL.textColor = bw(100);
        nameL.font = [UIFont boldSystemFontOfSize:12];
        nameL.leftTop = ccp(screenNameL.left, screenNameL.top + 12 + 1);
        nameL.backgroundColor = kClearColor;

        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setAvatar:(NSString *)avatar name:(NSString *)name screenName:(NSString *)screenName {
    [avatarIV setImageWithURL:[NSURL URLWithString:avatar]];
    nameL.text = name;
    [nameL sizeToFit];
    screenNameL.text = screenName;
    [screenNameL sizeToFit];
    [self setNeedsLayout];
}

@end