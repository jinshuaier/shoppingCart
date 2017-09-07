//
//  TCRightTableViewCell.h
//  购物车
//
//  Created by 胡高广 on 2017/9/4.
//  Copyright © 2017年 jinshuaier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDB.h"
//数据库的数据
typedef void(^shopMesBlock)(NSString *shopID, NSString *shopName, NSString *shopPrice, NSString *shopCount, NSString *spec, NSString *headPic, NSString *stock);

typedef void(^cutBlock)(NSString *shopID, NSString *shopCount);

@interface TCRightTableViewCell : UITableViewCell

@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) NSUserDefaults *userdefaults;
@property (nonatomic, strong) NSDictionary *myDic;
@property (nonatomic, strong) UILabel *shopName;
@property (nonatomic, strong) UIImageView *im;
@property (nonatomic, strong) UIButton *add; //加号按钮
@property (nonatomic, strong) UILabel *numlb; //数量
@property (nonatomic, strong) UIButton *cut; //减号按钮
@property (nonatomic, strong) UILabel *pricelb;
@property (nonatomic, strong) UILabel *guige;
@property (nonatomic, copy) shopMesBlock shopBlock;
@property (nonatomic, copy) cutBlock cutBlcok;
@property (nonatomic, strong) UILabel *kucunlb;
@property (nonatomic, assign) int count;
@property (nonatomic, strong) UILabel *counts;

- (void)create:(NSDictionary *)myDic andSQLData:(NSMutableArray *)sqlMuArr andNeedHidden:(BOOL)hidden;


- (void)getShopMes:(shopMesBlock)block; //加号的点击事件
- (void)cutBtn:(cutBlock)cut; //减号的点击事件
@end
