//
//  TCAlertView.m
//  弹出框
//
//  Created by 某某 on 16/9/14.
//  Copyright © 2016年 北京同创共享网络科技有限公司. All rights reserved.
//

#import "TCAlertView.h"

#define ScrWidth    [UIScreen mainScreen].bounds.size.width
#define ScrHeight   [UIScreen mainScreen].bounds.size.height
#define ScaleW      [UIScreen mainScreen].bounds.size.width / 375.0
#define ScaleH      [UIScreen mainScreen].bounds.size.height / 667.0


static TCAlertView *alert = nil;

@implementation TCAlertView

+ (id)showAlertTitle:(NSString *)titleStr andBtnTitle:(NSArray *)titleArr andShowMes:(NSString *)mes{
    if (alert == nil) {
        alert = [[TCAlertView alloc]initShowTitle:titleStr andBtnTitle:titleArr andShowMes:mes];
    }
    return alert;
}

- (id)initShowTitle:(NSString *)titleStr andBtnTitle:(NSArray *)titleArr andShowMes:(NSString *)mes{
    if (self == [super init]) {
        [self createBackViewTitle:titleStr andBtntitle:titleArr andShowMes:mes];
    }
    return self;
}



- (void)createBackViewTitle:(NSString *)titleStr andBtntitle:(NSArray *)titleArr andShowMes:(NSString *)mes{
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScrWidth, ScrHeight)];
    [[UIApplication sharedApplication].keyWindow addSubview: _backView];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(remove)];
//    [_backView addGestureRecognizer: tap];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.alpha = 0.6f;
    effectview.frame = _backView.frame;
    [_backView addSubview: effectview];

    [self alertShowOneTitle:titleStr andBtntitle:titleArr andShowMes:mes];
}

- (void)alertShowOneTitle:(NSString *)titleStr andBtntitle:(NSArray *)titleArr andShowMes:(NSString *)mes{
    _alertView = [[UIView alloc]initWithFrame:CGRectMake(40 * ScaleW, ScrHeight / 2 - (ScrWidth - 120 * ScaleW) / 2, ScrWidth - 80 * ScaleW, ScrWidth - 120 * ScaleW)];
    _alertView.backgroundColor = [UIColor whiteColor];
    _alertView.layer.cornerRadius = 10 * ScaleW;
    _alertView.layer.masksToBounds = YES;

    [_backView addSubview: _alertView];
    UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _alertView.frame.size.width, 55 * ScaleH)];
    lb.backgroundColor = [UIColor colorWithRed:255.0 / 255 green:219 / 255.0 blue:77 / 255.0 alpha:1];
    lb.text = titleStr;
    lb.textColor = [UIColor blackColor];
    lb.font = [UIFont systemFontOfSize:20 * ScaleW];
    lb.textAlignment = NSTextAlignmentCenter;
    [_alertView addSubview: lb];


    UILabel *meslb = [[UILabel alloc]initWithFrame:CGRectMake(20 * ScaleW, lb.frame.origin.y + lb.frame.size.height, _alertView.frame.size.width - 40 * ScaleW, _alertView.frame.size.height - 55 * ScaleH - 55 * ScaleH)];
    meslb.text = mes;
    meslb.textAlignment = NSTextAlignmentCenter;
    meslb.font = [UIFont systemFontOfSize:18 * ScaleW];
    [_alertView addSubview: meslb];

    _leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, _alertView.frame.size.height - 55 * ScaleH, (_alertView.frame.size.width - 2) / 2, 55 * ScaleH)];
    [_leftBtn setTitle:titleArr[0] forState:UIControlStateNormal];
    _leftBtn.backgroundColor = [UIColor colorWithRed:255.0 / 255 green:219 / 255.0 blue:77 / 255.0 alpha:1];
    _leftBtn.titleLabel.font = [UIFont systemFontOfSize:18 * ScaleW];
    [_leftBtn addTarget:self action:@selector(left) forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview: _leftBtn];


    _rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(_leftBtn.frame.origin.x + _leftBtn.frame.size.width + 2, _leftBtn.frame.origin.y, (_alertView.frame.size.width - 2) / 2, 55 * ScaleH)];
    [_rightBtn setTitle:titleArr[1] forState:UIControlStateNormal];
    _rightBtn.backgroundColor = [UIColor colorWithRed:255.0 / 255 green:219 / 255.0 blue:77 / 255.0 alpha:1];
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:18 * ScaleW];
    [_rightBtn addTarget:self action:@selector(right) forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview: _rightBtn];


    _alertView.transform = CGAffineTransformScale(_alertView.transform, 0.01, 0.01);
    [UIView animateWithDuration:0.3 animations:^{
        _alertView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            _alertView.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)leftBtnTouch:(leftBtn)left{
    _leftblock = left;
}

- (void)rightBtnTouch:(rightBtn)right{
    _rightblock = right;
}

- (void)left{
//    _leftblock();
    [[NSNotificationCenter defaultCenter]postNotificationName:@"leftchick" object:nil];
}

- (void)right{
//    _rightblock();
    [[NSNotificationCenter defaultCenter]postNotificationName:@"rightchick" object:nil];
}

+ (void)miss{
    [alert remove];
}



- (void)remove{
    [UIView animateWithDuration:0.1 animations:^{

    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            _alertView.transform = CGAffineTransformScale(_alertView.transform, 1.05, 1.05);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                _alertView.transform = CGAffineTransformScale(_alertView.transform, 0.01, 0.01);
            } completion:^(BOOL finished) {
                [_backView removeFromSuperview];
                alert = nil;
            }];
        }];
    }];
}



@end
