//
//  TCShopDetailViewController.h
//  顺道嘉(新)
//
//  Created by 某某 on 16/9/30.
//  Copyright © 2016年 Macx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCShopDetailViewController : UIViewController
@property (nonatomic, strong) NSDictionary *shopMesDic;//接收店铺信息 ：起送、配送费
@property (nonatomic, strong) NSDictionary *shopDetailDic;//接收商品详情
@property (nonatomic, assign) BOOL isHinddenAddBtn;//用来判断 从特殊店铺进入  需要隐藏添加商品按钮
@end
