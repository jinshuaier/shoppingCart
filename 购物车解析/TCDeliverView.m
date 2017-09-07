//
//  TCDeliverView.m
//  顺道嘉(新)
//
//  Created by GeYang on 2017/5/15.
//  Copyright © 2017年 Macx. All rights reserved.
//

#import "TCDeliverView.h"
#define WIDHT [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

static TCDeliverView *deliverview = nil;

@interface TCDeliverView ()
@property (nonatomic, strong) UIView *backView;
@end

@implementation TCDeliverView


+ (instancetype)ShowHubViewWith:(NSString *)title{
    [deliverview.backView removeFromSuperview];
    deliverview = [[TCDeliverView alloc]initWithTitle:title];
    return deliverview;
}

- (id)initWithTitle:(NSString *)title{
    if (self == [super init]) {
        [self create:title];
    }
    return self;
}

- (void)create:(NSString *)title{
    _backView = [[UIView alloc]initWithFrame:CGRectMake(WIDHT / 2 - 50, HEIGHT / 2 - 50, 100, 100)];
    _backView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
    [[UIApplication sharedApplication].keyWindow addSubview: _backView];
    
    UILabel *titlelb = [[UILabel alloc]initWithFrame:CGRectMake(18, 19, _backView.frame.size.width - 18 * 2, _backView.frame.size.height - 19 * 2)];
    titlelb.text = title;
    titlelb.numberOfLines = 0;
    titlelb.textAlignment = NSTextAlignmentCenter;
    titlelb.font = [UIFont fontWithName:@"PingFangTC-Regular" size:16];
    titlelb.textColor = [UIColor whiteColor];
    CGSize size = [titlelb sizeThatFits: CGSizeMake(WIDHT - 40, HEIGHT - 40)];
    titlelb.frame = CGRectMake(18, 19, size.width, size.height);
    [_backView addSubview: titlelb];
    
    _backView.frame = CGRectMake(WIDHT / 2 - (size.width + 18 * 2) / 2, HEIGHT / 2 - (size.height + 19 * 2) / 2, size.width + 18 * 2, size.height + 19 * 2);
    
    //3秒后消失
    [self performSelector:@selector(mis) withObject:self afterDelay:2];
    
}

- (void)mis{
    [UIView animateWithDuration:0.3 animations:^{
        _backView.alpha = 0.2;
    } completion:^(BOOL finished) {
        [_backView removeFromSuperview];
    }];
}












@end
