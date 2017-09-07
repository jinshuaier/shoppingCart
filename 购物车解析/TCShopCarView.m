//
//  TCShopCarView.m
//  购物车解析
//
//  Created by 胡高广 on 2017/9/5.
//  Copyright © 2017年 jinshuaier. All rights reserved.
//

#import "TCShopCarView.h"
#import "TCShopCarTableViewCell.h"
#import "FMDB.h"
#import "TCAlertView.h"
//数据库路径
#define SqlPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"ShopCar.sqlite"]
#define WIDHT [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define backGgray [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1]//背景颜色  淡灰色
#define RGB(r, g, b)    [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]


@interface TCShopCarView ()<UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *jisuan;
@property (nonatomic, strong) UILabel *allPrice;
@property (nonatomic, strong) UITableView *tableviews;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *numlb;
@property (nonatomic, strong) NSMutableArray *arrs;
@property (nonatomic, strong) NSString *qisong;
@property (nonatomic, strong) NSString *peisong;
@property (nonatomic, strong) NSUserDefaults *userdefaults;
@property (nonatomic, strong) NSMutableArray *sqlMuArr;
@property (nonatomic, strong) FMDatabase *database;
@end


@implementation TCShopCarView

- (id)initWithFrame:(CGRect)frame andData:(NSMutableArray *)arr andqisong:(NSString *)qisong andPeisong:(NSString *)peisong
{
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(leftc) name:@"leftchick" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rightc) name:@"rightchick" object:nil];
        _userdefaults = [NSUserDefaults standardUserDefaults];
        [_userdefaults setObject:@"122" forKey:@"shopid"];
        _arrs = arr;
        _qisong = qisong;
        _peisong = peisong;
        _sqlMuArr = [NSMutableArray array];
        _database = [FMDatabase databaseWithPath: SqlPath];
        [self createView];
    }
    return self;

}
//清空购物车
- (void)leftc{
    if ([_database open]) {
        BOOL success = [_database executeUpdate:@"delete from ShopCar where storeid = ?", [_userdefaults valueForKey:@"shopid"]];
        if (success) {
            [UIView animateWithDuration:0.3 animations:^{
                [TCAlertView miss];
                _topView.frame = CGRectMake(0, 300 , WIDHT, 0);
            } completion:^(BOOL finished) {
                _block();
            }];
        }
    }
}

- (void)rightc{
    [TCAlertView miss];
}

- (void)createView{
    CGFloat tbh;
    if (_arrs.count >= 5) {
        tbh = 5 * 52;
    }else{
        tbh = _arrs.count * 52 ;
    }
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 300 , WIDHT, 0)];
    _topView.clipsToBounds = YES;
    [self addSubview: _topView];
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDHT, 40 )];
    view1.backgroundColor = RGB(237, 237, 237);
    [_topView addSubview: view1];
    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(10 , 5 , 4 , view1.frame.size.height - 10)];
    line.backgroundColor = RGB(255, 219, 77);
    [view1 addSubview: line];
    UILabel *lbb = [[UILabel alloc]initWithFrame:CGRectMake(line.frame.origin.x + line.frame.size.width + 5, line.frame.origin.y, 60, line.frame.size.height)];
    lbb.text = @"购物车";
    lbb.textColor = RGB(51, 51, 51);
    lbb.font = [UIFont systemFontOfSize:14];
    [view1 addSubview: lbb];
    UIButton *btns = [[UIButton alloc]initWithFrame:CGRectMake(WIDHT - 70 , 0, 70 , view1.frame.size.height)];
    [btns setTitleColor:RGB(153, 153, 153) forState:UIControlStateNormal];
    btns.titleLabel.font = [UIFont systemFontOfSize:14 ];
    [btns setTitle:@"清空" forState:UIControlStateNormal];
    [btns addTarget:self action:@selector(mis) forControlEvents:UIControlEventTouchUpInside];
    btns.titleEdgeInsets = UIEdgeInsetsMake(0, 8 , 0, 0);
    [btns setImage: [UIImage imageNamed:@"清除购物车图标.png"] forState:UIControlStateNormal];
    [view1 addSubview: btns];
    
    if (_arrs.count >= 5) {
        _tableviews = [[UITableView alloc]initWithFrame:CGRectMake(0, 40 , WIDHT, 52  * 5) style:UITableViewStylePlain];
    }else{
        _tableviews = [[UITableView alloc]initWithFrame:CGRectMake(0, 40 , WIDHT, 52  * _arrs.count) style:UITableViewStylePlain];
    }
    _tableviews.delegate = self;
    _tableviews.dataSource = self;
    [_topView addSubview: _tableviews];
    
    //底部view
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 50 , WIDHT, 50 )];
    _bottomView.backgroundColor = backGgray;
    [self addSubview: _bottomView];
    UILabel *line1 = [[UILabel alloc]initWithFrame:CGRectMake(0, _bottomView.frame.origin.y - 0.5, WIDHT, 0.5)];
    line1.backgroundColor = RGB(174, 174, 174);
    [self addSubview: line1];
    UIImageView *im1 = [[UIImageView alloc]initWithFrame:CGRectMake(12 , _bottomView.frame.origin.y + _bottomView.frame.size.height - 6.5  - 60 , 60 , 60 )];
    im1.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dis)];
    [im1 addGestureRecognizer: tap];
    im1.image = [UIImage imageNamed:@"顺道嘉标志购物车.png"];
    [self addSubview: im1];
    _numlb = [[UILabel alloc]initWithFrame:CGRectMake(im1.frame.size.width + im1.frame.origin.x - 19 , im1.frame.origin.y, 18 , 18 )];
    _numlb.layer.cornerRadius = 9 ;
    _numlb.layer.masksToBounds = YES;
    _numlb.backgroundColor = [UIColor redColor];
    _numlb.text = @"";
    _numlb.textAlignment = NSTextAlignmentCenter;
    _numlb.font = [UIFont systemFontOfSize:12 ];
    _numlb.textColor = [UIColor whiteColor];
    [self addSubview: _numlb];
    
    
    //结算按钮
    _jisuan = [UIButton buttonWithType:UIButtonTypeCustom];
    _jisuan.frame = CGRectMake(WIDHT - 120 , 0, 120 , _bottomView.frame.size.height);
    _jisuan.backgroundColor = RGB(204, 204, 204);
    [_jisuan setTitle:[NSString stringWithFormat:@"¥%@起送", _qisong] forState:UIControlStateNormal];
    [_jisuan setTitleColor:RGB(51, 51, 51) forState:UIControlStateNormal];
    [_jisuan addTarget:self action:@selector(qujiesuan) forControlEvents:UIControlEventTouchUpInside];
    _jisuan.titleLabel.font = [UIFont systemFontOfSize:15 ];
    [_bottomView addSubview: _jisuan];
    //总计
    UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(im1.frame.origin.x + im1.frame.size.width + 8 , 12 , 20, 20 )];
    lb.text = @"总计:";
    lb.font = [UIFont boldSystemFontOfSize:15 ];
    CGSize size = [lb sizeThatFits:CGSizeMake(50, 30 )];
    lb.frame = CGRectMake(im1.frame.origin.x + im1.frame.size.width + 8 , 12 , size.width, 15 );
    [_bottomView addSubview: lb];
    //价格
    _allPrice = [[UILabel alloc]initWithFrame:CGRectMake(lb.frame.origin.x + lb.frame.size.width + 5 , lb.frame.origin.y, _jisuan.frame.origin.x - lb.frame.origin.x - lb.frame.size.width - 5  - 12 , lb.frame.size.height)];
    _allPrice.text = @"¥0.00";
    _allPrice.textColor = [UIColor redColor];
    _allPrice.font = [UIFont boldSystemFontOfSize:15 ];
    [_bottomView addSubview: _allPrice];
    //配送费
    UILabel *lb2 = [[UILabel alloc]initWithFrame:CGRectMake(lb.frame.origin.x, lb.frame.origin.y + lb.frame.size.height + 4 , 10, 15 )];
    lb2.text = @"配送费:";
    lb2.font = [UIFont systemFontOfSize:11 ];
    lb2.textColor = RGB(102, 102, 102);
    CGSize size1 = [lb2 sizeThatFits:CGSizeMake(50, 15 )];
    lb2.frame = CGRectMake(lb.frame.origin.x, lb.frame.origin.y + lb.frame.size.height + 4 , size1.width, 15 );
    [_bottomView addSubview: lb2];
    //配送费
    UILabel *lb3 = [[UILabel alloc]initWithFrame:CGRectMake(lb2.frame.origin.x + lb2.frame.size.width + 5 , lb2.frame.origin.y, _jisuan.frame.origin.x - lb2.frame.origin.x - lb2.frame.size.width - 5  - 12 , lb2.frame.size.height)];
    lb3.text = [NSString stringWithFormat:@"¥%@", _peisong];
    lb3.font = [UIFont systemFontOfSize:11 ];
    lb3.textColor = RGB(102, 102, 102);
    [_bottomView addSubview: lb3];
    
    //更新总价钱 与 角标
    float x = 0;
    int y = 0;
    for (int i = 0; i < _arrs.count ; i++) {
        x += [_arrs[i][@"amount"] floatValue] * [_arrs[i][@"price"] floatValue];
        y += [_arrs[i][@"amount"] intValue];
    }
    _allPrice.text = [NSString stringWithFormat:@"¥%.2f", x];
    _numlb.text = [NSString stringWithFormat:@"%d", y];
    
    //判断是否达到起送价格
    float cha = [_qisong floatValue] - x;
    if (cha > 0) {
        if (x == 0) {
            [_jisuan setTitle:[NSString stringWithFormat:@"¥%.2f起送", [_qisong floatValue]] forState:UIControlStateNormal];
        }else{
            [_jisuan setTitle:[NSString stringWithFormat:@"还差¥%.2f", cha] forState:UIControlStateNormal];
        }
        _jisuan.userInteractionEnabled = NO;
        _jisuan.backgroundColor = RGB(204, 204, 204);
    }else{
        [_jisuan setTitle:[NSString stringWithFormat:@"提交订单"] forState:UIControlStateNormal];
        _jisuan.userInteractionEnabled = YES;
        _jisuan.backgroundColor = [UIColor brownColor];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _topView.frame = CGRectMake(0, self.frame.size.height - 50 - tbh - 40 , WIDHT, 300 );
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView registerClass:[TCShopCarTableViewCell class] forCellReuseIdentifier:[NSString stringWithFormat:@"cell%ld%ld", (long)indexPath.section, (long)indexPath.row]];
    TCShopCarTableViewCell *cell = [[TCShopCarTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"cell%ld%ld", (long)indexPath.section, (long)indexPath.row] andData:_arrs[indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell bianliSQL:^{
        //遍历数据库
        [self bianli];
    }];
    [cell reloadTableview:^{
        //遍历数据库
        [self bianli];
        _arrs = _sqlMuArr;
        [_tableviews reloadData];
        CGFloat tbh;
        if (_arrs.count >= 5) {
            tbh = 5 * 52 ;
        }else{
            tbh = _arrs.count * 52 ;
        }
        [UIView animateWithDuration:0.3 animations:^{
            _topView.frame = CGRectMake(0, self.frame.size.height - 50 - tbh - 40 , WIDHT, 300 );
        }];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52 ;
}

- (void)disBackView:(dismiss)blocks{
    _block = blocks;
}

- (void)shuaxin:(shuaxin)shuaxinBlock
{
    _shuaxinBlock = shuaxinBlock;
}

//购物车点击事件
- (void)dis{
    [UIView animateWithDuration:0.3 animations:^{
        _topView.frame = CGRectMake(0, 300 , WIDHT, 0);
    } completion:^(BOOL finished) {
        _block();
    }];
}

//清空按钮事件
- (void)mis{
    [TCAlertView showAlertTitle:@"顺道嘉提示" andBtnTitle:@[@"确定", @"取消"] andShowMes:@"确认要清空您的购物车吗？"];
    
}



//遍历数据库
- (void)bianli{
    //获取之前先移除之前数据
    [_sqlMuArr removeAllObjects];
    //遍历数据库  更改底部购物车view的数据
    if ([_database open]) {
        FMResultSet *res = [_database executeQuery:@"select *from ShopCar where storeid = ?", [_userdefaults valueForKey:@"shopid"]];
        while ([res next]) {
            NSDictionary *dic = @{@"id":[res stringForColumn:@"shopid"], @"price":[res stringForColumn:@"shopprice"], @"amount":[res stringForColumn:@"shopcount"], @"name":[res stringForColumn:@"shopname"], @"pic":[res stringForColumn:@"shopPic"], @"stockcount":[res stringForColumn:@"stockcount"]};
            [_sqlMuArr addObject: dic];
        }
    }
    //更新总价钱 与 角标
    float x = 0;
    int y = 0;
    for (int i = 0; i < _sqlMuArr.count ; i++) {
        x += [_sqlMuArr[i][@"amount"] floatValue] * [_sqlMuArr[i][@"price"] floatValue];
        y += [_sqlMuArr[i][@"amount"] intValue];
    }
    _allPrice.text = [NSString stringWithFormat:@"¥%.2f", x];
    _numlb.text = [NSString stringWithFormat:@"%d", y];
    
    //去除数组中数量为0的元素
    NSMutableArray *muarr = [NSMutableArray array];
    for (int i = 0; i < _sqlMuArr.count; i++) {
        if ([_sqlMuArr[i][@"amount"] intValue] != 0) {
            //如果不等于0  取出
            [muarr addObject:_sqlMuArr[i]];
        }
    }
    [_sqlMuArr removeAllObjects];
    //重新赋值
    _sqlMuArr = muarr;
    
    //判断是否达到起送价格
    float cha = [_qisong floatValue] - x;
    if (cha > 0) {
        if (x == 0) {
            [_jisuan setTitle:[NSString stringWithFormat:@"¥%.2f起送", [_qisong floatValue]] forState:UIControlStateNormal];
        }else{
            [_jisuan setTitle:[NSString stringWithFormat:@"还差¥%.2f", cha] forState:UIControlStateNormal];
        }
        _jisuan.userInteractionEnabled = NO;
        _jisuan.backgroundColor = RGB(204, 204, 204);
    }else{
        [_jisuan setTitle:[NSString stringWithFormat:@"提交订单"] forState:UIControlStateNormal];
        _jisuan.userInteractionEnabled = YES;
        _jisuan.backgroundColor = [UIColor brownColor];
    }
    NSLog(@"当前数据元素 %@", _sqlMuArr);
    if (_sqlMuArr.count == 0){
        _block();
    }else{
        //我不想加通知啊
        _shuaxinBlock();
    }
}

- (void)qujiesuan{
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
//    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
//    [SVProgressHUD setBackgroundColor:[[UIColor darkGrayColor]colorWithAlphaComponent:0.9]];
//    if ([[_userdefaults valueForKey:@"shopjuli"] intValue] > ShopDistance) {
//        [SVProgressHUD showErrorWithStatus:@"距离过远，无法为您提供配送服务！"];
//    }else{
        [self bianli];
        if (_sqlMuArr.count != 0) {
            [UIView animateWithDuration:0.3 animations:^{
                _topView.frame = CGRectMake(0, 300 , WIDHT, 0);
            } completion:^(BOOL finished) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"shopcarpush" object:nil];
            }];
        }else{
            NSLog(@"您还没有选购商品");
            //[SVProgressHUD showErrorWithStatus:@"您还没有选购商品！"];
       // }
    }
    
}

@end
