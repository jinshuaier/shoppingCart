//
//  TCShopCarTableViewCell.m
//  顺道嘉(新)
//
//  Created by 某某 on 16/9/29.
//  Copyright © 2016年 Macx. All rights reserved.
//

#import "TCShopCarTableViewCell.h"
#import "TCDeliverView.h"
//数据库路径
#define SqlPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"ShopCar.sqlite"]
#define RGB(r, g, b)    [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define WIDHT [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@implementation TCShopCarTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andData:(NSDictionary *)dic{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _dics = dic;
        _database = [FMDatabase databaseWithPath: SqlPath];
        _userdefaults = [NSUserDefaults standardUserDefaults];
        [self create];
    }
    return self;
}

- (void)create{
    UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 180 , 52 )];
    lb.text = _dics[@"name"];
    lb.font = [UIFont systemFontOfSize:15];
    lb.textColor = RGB(77, 77, 77);
    lb.numberOfLines = 1;
    [self addSubview: lb];
    
    UIButton *add = [[UIButton alloc]initWithFrame:CGRectMake(WIDHT - 10 - 22 , 26  - 11, 22 , 22)];
    [add setImage:[UIImage imageNamed:@"商品加号图标.png"] forState:UIControlStateNormal];
    [add addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: add];
    
    _lb2 = [[UILabel alloc]initWithFrame:CGRectMake(add.frame.origin.x - 35, add.frame.origin.y, 35 , add.frame.size.height)];
    _lb2.text = _dics[@"amount"];
    _lb2.font = [UIFont systemFontOfSize:15 ];
    _lb2.textAlignment = NSTextAlignmentCenter;
    [self addSubview: _lb2];
    
    UIButton *cut = [[UIButton alloc]initWithFrame:CGRectMake(_lb2.frame.origin.x - 22 , _lb2.frame.origin.y, 22 , 22 )];
    [cut setImage:[UIImage imageNamed:@"商品减号.png"] forState:UIControlStateNormal];
    [cut addTarget:self action:@selector(cut) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: cut];
    
    UILabel *lb3 = [[UILabel alloc]initWithFrame:CGRectMake(lb.frame.origin.x + lb.frame.size.width + 10 , 0, cut.frame.origin.x - lb.frame.origin.x - lb.frame.size.width - 10 , 52 )];
    lb3.font = [UIFont systemFontOfSize:15 ];
    lb3.textAlignment = NSTextAlignmentCenter;
    lb3.textColor = [UIColor redColor];
    lb3.text = [NSString stringWithFormat:@"¥%@", _dics[@"price"]];
    [self addSubview: lb3];
}

- (void)bianliSQL:(SQLBlock)sql{
    _sqlBlock = sql;
}

- (void)reloadTableview:(reloadBlock)reload{
    _block = reload;
}
//添加
- (void)add{
    if ([_lb2.text intValue] + 1 > [_dics[@"stockcount"] intValue]) {
        [TCDeliverView ShowHubViewWith:@"超出库存量啦!"];
    }else{
        _lb2.text = [NSString stringWithFormat:@"%d", [_lb2.text intValue] + 1];
        //添加商品信息到数据库
        if ([_database open]) {
            //查找数据库 该店铺下是否有该商品
            FMResultSet *re = [_database executeQuery:@"select *from ShopCar where storeid = ? and shopid = ?", [_userdefaults valueForKey:@"shopid"], _dics[@"id"]];
            if ([re next]) {
                //如果有  更新个数
                BOOL isSuccess = [_database executeUpdate:@"update ShopCar set shopcount = ? where shopid = ? and storeid = ?", _lb2.text, _dics[@"id"], [_userdefaults valueForKey:@"shopid"]];
                if (isSuccess) {
                    NSLog(@"更新数据成功");
                }
            }else{
                //如果没有  创建该记录
                NSString *shopname = @"";
                if ([_dics[@"spec"] isEqualToString:@""]) {
                    shopname = _dics[@"name"];
                }else{
                    shopname = [_dics[@"name"] stringByAppendingString: [NSString stringWithFormat:@"(%@)", _dics[@"spec"]]];
                }
                BOOL isSuccess = [_database executeUpdate:@"insert into ShopCar (storeid, shopid, shopprice, shopname, shopcount, shopPic, stockcount) values (?, ?, ?, ?, ?, ?, ?)", [_userdefaults valueForKey:@"shopid"], _dics[@"id"], _dics[@"price"], shopname, _lb2.text, _dics[@"pic"], _dics[@"stockcount"]];
                if (isSuccess) {
                    NSLog(@"记录创建成功");
                }
            }
        }
        _sqlBlock();//要求之前页面遍历数据库
    }
}

//减少
- (void)cut{
    _lb2.text = [NSString stringWithFormat:@"%d", [_lb2.text intValue] - 1];
    //添加商品信息到数据库
    if ([_database open]) {
        //查找数据库 该店铺下是否有该商品
        FMResultSet *re = [_database executeQuery:@"select *from ShopCar where storeid = ? and shopid = ?", [_userdefaults valueForKey:@"shopid"], _dics[@"id"]];
        if ([re next]) {
            //如果有  更新个数
            BOOL isSuccess = [_database executeUpdate:@"update ShopCar set shopcount = ? where shopid = ? and storeid = ?", _lb2.text, _dics[@"id"], [_userdefaults valueForKey:@"shopid"]];
            if (isSuccess) {
                NSLog(@"更新数据成功");
            }
        }else{
            //如果没有  创建该记录
            BOOL isSuccess = [_database executeUpdate:@"insert into ShopCar (storeid, shopid, shopprice, shopname, shopcount, shopPic, stockcount) values (?, ?, ?, ?, ?, ?, ?)", [_userdefaults valueForKey:@"shopid"], _dics[@"id"], _dics[@"price"], _dics[@"name"], _lb2.text, _dics[@"pic"], _dics[@"stockcount"]];
            if (isSuccess) {
                NSLog(@"记录创建成功");
            }
        }
    }
    _sqlBlock();
    
    //当减到0 的时候  tableview中移除刚数据
    if ([_lb2.text intValue] == 0) {
        _block();//要求之前页面刷新tableview
    }
}










@end
