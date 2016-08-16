//
//  HKMessageTextTableViewCell.m
//  HouseKeeper
//
//  Created by KudoCC on 15/11/8.
//  Copyright © 2015年 KudoCC. All rights reserved.
//

#import "HKMessageTextTableViewCell.h"
#import "UIView+Coordinate.h"
#import "UIColor+Util.h"
#import "UIImage+Util.h"

#define ScreenHeight         [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth          [[UIScreen mainScreen] bounds].size.width

#define BACKGROUND_COLOR @"#f2f2f2"
#define LINE_COLOR @"#e4e4e4"

static const CGFloat paddingTextY = 10.0;
static const CGFloat minHeight = 40.0;
static const CGFloat widthTime = 120.0;
static const CGFloat heightTime = 20.0;

@interface HKMessageTextTableViewCell ()

@property (nonatomic, strong) UIImageView *imageViewBackground;
@property (nonatomic, strong) UILabel *labelText;

@end

@implementation HKMessageTextTableViewCell

+ (CGSize)cellSizeForMessage:(Message *)message {
    NSString *str = message.text;
    CGSize inSize = CGSizeMake(ScreenWidth-50.0, 10240.0);
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    CGRect rect = [str boundingRectWithSize:inSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    CGSize size = CGSizeMake(ceil(rect.size.width), ceil(rect.size.height));
    CGFloat height = size.height < minHeight ? minHeight : size.height;
    return CGSizeMake(size.width, height + paddingTextY*2 + heightTime);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.contentView.backgroundColor = [UIColor opaqueColorWithHexString:BACKGROUND_COLOR];
    
    _imageViewBackground = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_imageViewBackground];
    
    _labelText = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_labelText];
    _labelText.font = [UIFont systemFontOfSize:14];
    _labelText.textColor = [UIColor opaqueColorWithHexString:@"#333333"];
    _labelText.numberOfLines = 0;
    
    _labelTime = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, widthTime, heightTime)];
    [self.contentView addSubview:_labelTime];
    _labelTime.font = [UIFont systemFontOfSize:12];
    _labelTime.textColor = [UIColor opaqueColorWithHexString:@"#333333"];
    _labelTime.textAlignment = NSTextAlignmentRight;
}

- (void)setMessage:(Message *)message {
    _message = message;
    
    _labelText.text = message.text;
    if (!_message.peer) {
        // from myself
        _imageViewBackground.image = [UIImage imageWithColor:[UIColor opaqueColorWithHexString:@"#ffffff"]
                                                        size:CGSizeMake(1.0, 1.0)];
    } else {
        // others
        _imageViewBackground.image = [UIImage imageWithColor:[UIColor opaqueColorWithHexString:@"#11fc22"]
                                                        size:CGSizeMake(1.0, 1.0)];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sizeIn = CGSizeZero;
    if ([_labelText.text length] > 0) {
        sizeIn = [self.class cellSizeForMessage:_message];
    }
    if (sizeIn.width < widthTime) {
        sizeIn.width = widthTime;
    }
    CGFloat x = 0.0;
    if (!_message.peer) {
        x = self.contentView.width - sizeIn.width - 10;
    }
    _imageViewBackground.frame = CGRectMake(x, 10,
                                            sizeIn.width + 2*10,
                                            self.contentView.bounds.size.height - 10*2);
    
    CGRect rect = _imageViewBackground.frame;
    rect.size.height -= heightTime;
    _labelText.frame = CGRectInset(rect, 10/2, 0.0);
    
    _labelTime.frame = CGRectMake(self.contentView.width-_labelText.width-10, _labelText.bottom, _labelText.width, _labelTime.height);
}

@end
