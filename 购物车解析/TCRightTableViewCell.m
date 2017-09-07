//
//  TCRightTableViewCell.m
//  购物车
//
//  Created by 胡高广 on 2017/9/4.
//  Copyright © 2017年 jinshuaier. All rights reserved.
//

#import "TCRightTableViewCell.h"
#import "TCDeliverView.h"
#import "UIImageView+WebCache.h"
//数据库路径
#define SqlPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"ShopCar.sqlite"]
#define RGB(r, g, b)    [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
@implementation TCRightTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andData:(NSDictionary *)dic
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _database = [FMDatabase databaseWithPath: SqlPath];
        _userdefaults = [NSUserDefaults standardUserDefaults];
        [_userdefaults setObject:@"122" forKey:@"shopid"];
        //创建视图
        [self create];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _database = [FMDatabase databaseWithPath: SqlPath];
        _userdefaults = [NSUserDefaults standardUserDefaults];
         [_userdefaults setObject:@"122" forKey:@"shopid"];
        //创建视图
        [self create];
    }
    return self;
}

#pragma mark -- 创建视图
- (void)create
{
    self.backgroundColor = [UIColor whiteColor];
    
    //商品头像
    _im = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
    _im.layer.cornerRadius = 20 ;
    _im.layer.masksToBounds = YES;
    [self addSubview: _im];
    
    //商品的名称
    _shopName = [[UILabel alloc] init];
    _shopName.frame = CGRectMake(CGRectGetMaxX(_im.frame) + 10, 10, self.frame.size.width - 10 - CGRectGetMaxX(_im.frame), 15);
    _shopName.textColor = [UIColor blackColor];
    _shopName.font = [UIFont systemFontOfSize:15];
    [self addSubview:_shopName];
    
    //规格
    _guige = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_im.frame) + 10, CGRectGetMaxY(_shopName.frame) + 8 , 100 , 12)];
    _guige.textColor = RGB(102, 102, 102);
    _guige.font = [UIFont systemFontOfSize:12];
    [self addSubview: _guige];
    
    //库存
    _kucunlb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_guige.frame) + 10, CGRectGetMaxY(_shopName.frame) + 8, self.frame.size.width - 10 - CGRectGetMaxX(_guige.frame), 12)];
    _kucunlb.textColor = RGB(102, 102, 102);
    _kucunlb.font = [UIFont systemFontOfSize:12];
    [self addSubview: _kucunlb];
    
    //价格
    _pricelb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_im.frame) + 10, CGRectGetMaxY(_guige.frame) + 10, 100, 16)];
    _pricelb.font = [UIFont boldSystemFontOfSize:16];
    _pricelb.textAlignment = NSTextAlignmentLeft;
    _pricelb.textColor = [UIColor redColor];
    [self addSubview: _pricelb];
    
    //添加按钮
    _add = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 30 - (CGRectGetMaxX(_im.frame) + 10), CGRectGetMaxY(_guige.frame), 30, 30)];
    [_add setImage:[UIImage imageNamed:@"商品加号图标.png"] forState: UIControlStateNormal];
   // _add.imageEdgeInsets = UIEdgeInsetsMake(0, 25, 0, 0);
    [_add addTarget:self action:@selector(chick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: _add];
    
    
    //数量
    _counts = [[UILabel alloc]initWithFrame:CGRectMake(_add.frame.origin.x - 32, _add.frame.origin.y, 32, _add.frame.size.height)];
    _counts.font = [UIFont systemFontOfSize:15];
    _counts.textAlignment = NSTextAlignmentCenter;
    _counts.text = @"";
    [self addSubview:_counts];
    
    
    //减号
    _cut = [[UIButton alloc]initWithFrame:CGRectMake(_counts.frame.origin.x - 25, _add.frame.origin.y, 30 , 30)];
    [_cut setImage:[UIImage imageNamed:@"商品减号.png"] forState:UIControlStateNormal];
    [_cut addTarget:self action:@selector(cutBtn) forControlEvents:UIControlEventTouchUpInside];
    _cut.hidden = YES;
    [self addSubview: _cut];
    //    cutbtn.hidden = YES;
    
    //划线
    UIView *lineView = [[UIView alloc] init];
    lineView.frame = CGRectMake(0, 80 - 1, self.frame.size.width, 1);
    lineView.backgroundColor = [UIColor darkGrayColor];
    [self addSubview:lineView];
    
}

//实现方法
- (void) create:(NSDictionary *)myDic andSQLData:(NSMutableArray *)sqlMuArr andNeedHidden:(BOOL)hidden
{
//    if (hidden) {
//        _add.hidden = YES;
//    }else{
//        _add.hidden = NO;
//    }
    _myDic = myDic;
   // CGFloat w = self.frame.size.width;
    [_im sd_setImageWithURL:[NSURL URLWithString:_myDic[@"headPic"]] placeholderImage:[UIImage imageNamed:@"1.jpg"]];
   
    
    NSLog(@"--- %@",_myDic[@"headPic"]);
    _shopName.text = _myDic[@"name"];
   // _shopName.font = [UIFont systemFontOfSize:15];
//    _shopName.numberOfLines = 2;
//    CGSize size = [_shopName sizeThatFits:CGSizeMake(w - 4, 20 )];
//    _shopName.frame = CGRectMake(CGRectGetMaxX(_im.frame) + 10, 10, self.frame.size.width - 10 - CGRectGetMaxX(_im.frame) - 150, 15);
    _pricelb.text = [NSString stringWithFormat:@"¥%@", _myDic[@"price"]];
    if ([_myDic[@"spec"] isEqualToString:@""]) {
        _guige.text = [NSString stringWithFormat:@"规格:%@", @"暂无"];
    }else{
        _guige.text = [NSString stringWithFormat:@"规格:%@", _myDic[@"spec"]];
    }
//
    //库存
    _kucunlb.text = [NSString stringWithFormat:@"库存：%@", myDic[@"stockCount"]];
    
    //数据库当中要用到
    //很关键的处理 （下方else中可以不再写）
    _counts.text = @"";
    _count = 0;
    
    //判断数据库中是否存在
    for (int i = 0; i < sqlMuArr.count; i++) {
        if ([myDic[@"id"] isEqualToString: sqlMuArr[i][@"id"]]) {
            _counts.text = sqlMuArr[i][@"amount"];
            _count = [sqlMuArr[i][@"amount"] intValue];
            
            //判断减号
            _cut.hidden = NO;
            _numlb.text = [NSString stringWithFormat:@"%d",_count];
            
            return;//很关键的return 否则  假设循环两次 第一个元素相同 counts元素有值  第二次元素不同counts则被覆盖为0；
        }else{
            _counts.text = @"";//否则中也要重新给这两个元素赋值
            _count = 0;
        }
    }
}

- (void)getShopMes:(shopMesBlock)block{
    _shopBlock = block;
}

- (void)cutBtn:(cutBlock)cut
{
    _cutBlcok = cut;
}
#pragma mark -- 点击加号事件
- (void)chick
{
    _count = _count + 1;
    _cut.hidden = NO;
    
    //中间的数量
    _counts.text = [NSString stringWithFormat:@"%d", _count];
    
    
    if (_count > [_myDic[@"stockCount"] intValue]) {
        [TCDeliverView ShowHubViewWith:@"超出库存量啦!"];
    }else{
        _shopBlock(_myDic[@"id"], _myDic[@"name"], _myDic[@"price"], [NSString stringWithFormat:@"%d", _count], _myDic[@"spec"], _myDic[@"headPic"], _myDic[@"stockCount"]);
    }

}

#pragma mark -- 减号的点击事件
- (void)cutBtn
{
    //中间的数量
    _counts.text = [NSString stringWithFormat:@"%d",[_counts.text intValue] - 1];
    if ([_counts.text intValue] == 0) {
        _cut.hidden = YES;
        _counts.text = @"";
    }
        //减号的方法
        
    _cutBlcok(_myDic[@"id"],_counts.text);

        //        _cut.hidden = YES;
        //        _numlb.hidden = YES;
        //        //_cutBlcok();//要求之前页面刷新tableview
        //    }

    
    
    //
    
//    _numlb.text = [NSString stringWithFormat:@"%d",[_numlb.text intValue] - 1];
//    
//    //添加商品信息到数据库
//    if ([_database open]) {
//        //查找数据库 该店铺下是否有该商品
//        FMResultSet *re = [_database executeQuery:@"select *from ShopCar where storeid = ? and shopid = ?", [_userdefaults valueForKey:@"shopid"], _myDic[@"id"]];
//        if ([re next]) {
//            //如果有  更新个数
//            BOOL isSuccess = [_database executeUpdate:@"update ShopCar set shopcount = ? where shopid = ? and storeid = ?", _numlb.text, _myDic[@"id"], [_userdefaults valueForKey:@"shopid"]];
//            if (isSuccess) {
//                NSLog(@"更新数据成功");
//            }
//        }else{
//            //如果没有  创建该记录
//            BOOL isSuccess = [_database executeUpdate:@"insert into ShopCar (storeid, shopid, shopprice, shopname, shopcount, shopPic, stockcount) values (?, ?, ?, ?, ?, ?, ?)", [_userdefaults valueForKey:@"shopid"], _myDic[@"id"], _myDic[@"price"], _myDic[@"name"], _numlb.text, _myDic[@"pic"], _myDic[@"stockcount"]];
//            if (isSuccess) {
//                NSLog(@"记录创建成功");
//            }
//        }
//    }
////     _shopBlock(_myDic[@"id"], _myDic[@"name"], _myDic[@"price"], [NSString stringWithFormat:@"%d", _count], _myDic[@"spec"], _myDic[@"headPic"], _myDic[@"stockCount"]);
//    //当减到0 的时候  tableview中移除刚数据
//    if ([_numlb.text intValue] == 0) {
//        _cut.hidden = YES;
//        _numlb.hidden = YES;
//        //_cutBlcok();//要求之前页面刷新tableview
//    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
