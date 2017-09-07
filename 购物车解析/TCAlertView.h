//
//  TCAlertView.h
//  弹出框
//
//  Created by 某某 on 16/9/14.
//  Copyright © 2016年 北京同创共享网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^leftBtn)(void);
typedef void(^rightBtn)(void);

@interface TCAlertView : UIView
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, copy) leftBtn leftblock;
@property (nonatomic, copy) rightBtn rightblock;

+ (id)showAlertTitle:(NSString *)titleStr andBtnTitle:(NSArray *)titleArr andShowMes:(NSString *)mes;

+ (void)miss;
- (void)leftBtnTouch:(leftBtn)left;
- (void)rightBtnTouch:(rightBtn)right;

@end
