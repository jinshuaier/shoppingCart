//
//  ViewController.m
//  购物车
//
//  Created by 胡高广 on 2017/9/4.
//  Copyright © 2017年 jinshuaier. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"
#import "BQActivityView.h" //加载条

#import "TCLeftTableViewCell.h" //自定义的cell
#import "TCRightTableViewCell.h"

#import "TCDeliverView.h"

#import "TCShopCarView.h"

#import "TCShopDetailViewController.h"
//数据库路径
#define SqlPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"ShopCar.sqlite"]
#define WIDHT [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define backGgray [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1]//背景颜色  淡灰色
#define RGB(r, g, b)    [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

@interface ViewController () <UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *leftTabelView; //左边的tableView
@property (nonatomic, strong) UITableView *rightTableView; //右边的tableView

@property (nonatomic, strong) NSMutableArray *sortMuArr;//记录分类
@property (nonatomic, strong) NSMutableArray *shopMuArr;//记录商品
@property (nonatomic, strong) NSMutableArray *sqlMuArr;//数据库中商品数

@property (nonatomic, strong) NSString *sortID;//记录分类id

@property (nonatomic, strong) NSDictionary *shopMesDic;

@property (nonatomic, strong) FMDatabase *dataBase; //数据库

@property (nonatomic, strong) UIView *bottomView; //底层的view

@property (nonatomic, strong) UIImageView *shopCarIm; //购物车图片
@property (nonatomic, strong) UILabel *numlb;
@property (nonatomic, strong) UIButton *jisuan;
@property (nonatomic, strong) UILabel *allPrice;
@property (nonatomic, assign) NSInteger select; //出现的条

@property (nonatomic, strong) NSUserDefaults *userdefaults;
@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UIButton *cutButton;
@property (nonatomic, strong) UILabel *countsLabel;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self bianliSQL];
    
//    if([_dataBase open]){
//        NSString *deleteSql = @"DROP TABLE shopCar";
//        BOOL res = [_dataBase executeUpdate:deleteSql];
//        if(res){
//            NSLog(@"删除shopCar表成功");
//        }else{
//            NSLog(@"删除shopCar表失败");
//        }
//        [_dataBase close];
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"购物车";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gogo) name:@"shopcarpush" object:nil];//购物车红点击去结算
    //初始化数组
    _sortMuArr = [[NSMutableArray alloc] init];
    _shopMuArr = [[NSMutableArray alloc] init];
    _sqlMuArr = [[NSMutableArray alloc] init];
    
    _userdefaults = [NSUserDefaults standardUserDefaults];
    [_userdefaults setObject:@"122" forKey:@"shopid"];
    _select = 0;

    //创建视图
    [self createUI];
    
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark -- 创建视图
- (void)createUI
{
    //创建数据库
    self.dataBase = [FMDatabase databaseWithPath:SqlPath];
    NSLog(@"SqlPath = %@",SqlPath);
    
    //判断数据库是否打开
    if (![self.dataBase open]) {
        NSLog(@"数据库打开失败");
    }
    else
    {
        //建表 这里是数据库语句 这里是你需要的语句
        BOOL isSuccess = [self.dataBase executeUpdate:@"create table if not exists ShopCar (storeid text, shopid text, shopprice text, shopcount text, shopname text, shopPic text, stockcount text)"];
        
        if (isSuccess) {
            NSLog(@"成功创表");
        } else {
            NSLog(@"创表失败");
        }
        
    }
    
    //请求接口
    [self createQuest];
}

#pragma mark -- 请求接口
- (void)createQuest
{
    [BQActivityView showActiviTy];
    
    //请求的数据
    NSString *strPath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"geojson"];
    NSData *jsonData = [NSData dataWithContentsOfFile:strPath options:NSDataReadingMappedIfSafe error:nil];
    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
    NSString *strPath1 = [[NSBundle mainBundle] pathForResource:@"shop" ofType:@"geojson"];
    NSData *jsonData1 = [NSData dataWithContentsOfFile:strPath1 options:NSDataReadingMappedIfSafe error:nil];
    NSMutableDictionary *dic1 = [NSJSONSerialization JSONObjectWithData:jsonData1 options:NSJSONReadingMutableContainers error:nil];
    
    NSLog(@"--- %@",dic);
    
    if (dic)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [BQActivityView hideActiviTy];
            
            [_sortMuArr addObjectsFromArray: dic[@"data"][@"cat_list"]];
            [_shopMuArr addObjectsFromArray: dic1[@"data"]];
            NSLog(@" --%@ -- %@",_sortMuArr,_shopMuArr);
            _shopMesDic = dic[@"data"][@"shop"];
            [_leftTabelView reloadData];
            //这里是网络请求结束，创建视图
            [self createViews];
        });
        
    }
}

#pragma mark -- 创建视图
- (void)createViews
{
    //底层的view
    self.bottomView = [[UIView alloc] init];
    self.bottomView.frame = CGRectMake(0,HEIGHT - 50 , WIDHT, 50);
    self.bottomView.backgroundColor = backGgray;
    [self.view addSubview:self.bottomView];
    
    //下划线
    UILabel *line1 = [[UILabel alloc]initWithFrame:CGRectMake(0, _bottomView.frame.origin.y - 0.5, WIDHT, 0.5)];
    line1.backgroundColor = RGB(174, 174, 174);
    [self.view addSubview: line1];
    
    //图片
    UIImageView *im1 = [[UIImageView alloc]initWithFrame:CGRectMake(12, _bottomView.frame.origin.y + _bottomView.frame.size.height - 6.5  - 60 , 60 , 60 )];
    im1.image = [UIImage imageNamed:@"顺道嘉标志购物车.png"];
    im1.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(taps)];
    [im1 addGestureRecognizer: tap];
    _shopCarIm = im1;
    [self.view addSubview: im1];
    
    _numlb = [[UILabel alloc]initWithFrame:CGRectMake(im1.frame.size.width + im1.frame.origin.x - 19 , im1.frame.origin.y, 18 , 18 )];
    _numlb.layer.cornerRadius = 9 ;
    _numlb.layer.masksToBounds = YES;
    _numlb.backgroundColor = [UIColor redColor];
    _numlb.text = @"";
    _numlb.hidden = YES;
    _numlb.textAlignment = NSTextAlignmentCenter;
    _numlb.font = [UIFont systemFontOfSize:12 ];
    _numlb.textColor = [UIColor whiteColor];
    [self.view addSubview: _numlb];
    
    //结算按钮
    _jisuan = [UIButton buttonWithType:UIButtonTypeCustom];
    _jisuan.frame = CGRectMake(WIDHT - 120 , 0, 120 , _bottomView.frame.size.height);
    _jisuan.backgroundColor = RGB(204, 204, 204);
    [_jisuan setTitle:[NSString stringWithFormat:@"¥%@起送", @"10"] forState:UIControlStateNormal];
    [_jisuan setTitleColor:RGB(51, 51, 51) forState:UIControlStateNormal];
    _jisuan.titleLabel.font = [UIFont systemFontOfSize:15 ];
    [_jisuan addTarget:self action:@selector(qujiesuan) forControlEvents:UIControlEventTouchUpInside];
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
    lb3.text = [NSString stringWithFormat:@"¥%@", @"10"];
    lb3.font = [UIFont systemFontOfSize:11 ];
    lb3.textColor = RGB(102, 102, 102);
    [_bottomView addSubview: lb3];
    
    //遍历数据库 底部的值
    [self bianliSQL];
    
    //创建左侧的tableView
    self.leftTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDHT * 0.28, HEIGHT - 64 - 60 - 6.5 - 4) style:(UITableViewStylePlain)];
    self.leftTabelView.delegate = self;
    self.leftTabelView.dataSource = self;
    self.leftTabelView.backgroundColor = RGB(242, 242, 242);
    self.leftTabelView.tableFooterView = [[UIView alloc] init];
    self.leftTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview: self.leftTabelView];
    
    //创建右侧的tableView
    self.rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(WIDHT * 0.28, 64,  WIDHT * 0.72, HEIGHT - 64 - 50 - 1) style:(UITableViewStylePlain)];
    self.rightTableView.delegate = self;
    self.rightTableView.dataSource = self;
    self.rightTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.rightTableView.tableFooterView = [[UIView alloc] init];
    self.rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview: self.rightTableView];
    
}

#pragma tableView degate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _leftTabelView)
    {
        return _sortMuArr.count;
    } else {
        return _shopMuArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == _leftTabelView) {
        TCLeftTableViewCell *cell = [[TCLeftTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        if (_sortMuArr.count != 0) {
            cell.title.text = _sortMuArr[indexPath.row][@"name"];
            if (indexPath.row == _select) {
                cell.line.hidden = NO;
                cell.backgroundColor = [UIColor whiteColor];
            }else{
                cell.line.hidden = YES;
                cell.backgroundColor = RGB(242, 242, 242);
            }
        }
        return cell;
    } else {
        TCRightTableViewCell *cell_right = [[TCRightTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell_right"];
        cell_right.selectionStyle = UITableViewCellSelectionStyleNone;
        NSLog(@"------- %@",_shopMuArr);
        
        if (_shopMuArr.count != 0)
        {
            //赋值时，连带数据库数据也
            [cell_right create:_shopMuArr[indexPath.row] andSQLData:_sqlMuArr andNeedHidden:_isHinddenAddBtn];
            //点击加号按钮
            [cell_right getShopMes:^(NSString *shopID, NSString *shopName, NSString *shopPrice, NSString *shopCount, NSString *spec, NSString *headPic, NSString *stock) {
                
                //添加数据库
               [self joinData:shopID andname:shopName andprice:shopPrice andcount:shopCount andSpec:spec andpic:headPic andstock:stock];
                NSLog(@"添加按钮");
                
                //添加动画添加到购物车
                UIImageView *im = [[UIImageView alloc] init];
                NSInteger i = indexPath.row;
                
                im = [[UIImageView alloc]initWithFrame:CGRectMake( WIDHT * 0.28 + 10, 10 + 64  + i * 80, 40 , 40)];
                im.layer.cornerRadius = 20;
                im.clipsToBounds = YES;
                im.image = cell_right.im.image;
                [self.view addSubview: im];
                //设置旋转
                CABasicAnimation* rotationAnimation;
                rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
                rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
                rotationAnimation.duration = 0.4f;
                rotationAnimation.cumulative = YES;
                rotationAnimation.repeatCount = 99999;
                //添加商品到购物车动画
                [UIView animateWithDuration:0.3 animations:^{
                    im.frame = CGRectMake(im.frame.origin.x - 10, im.frame.origin.y - 10, 40 , 40 );
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.7 animations:^{
                        [im.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
                        im.center = _shopCarIm.center;
                        im.transform = CGAffineTransformMakeScale(0.1, 0.1);
                    }completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.2 animations:^{
                            im.alpha = 0;
                        }completion:^(BOOL finished) {
                            [im removeFromSuperview];
                        }];
                    }];
                }];
            }];
        }
        
        //减号
        [cell_right cutBtn:^(NSString *shopID, NSString *shopCount) {
            NSLog(@"减号");
            
        //从数据库减少
        [self joinData:shopID andcount:shopCount];

            
        }];
        
        return cell_right;
    }
    return nil;
}

#pragma  mark -- 点击+号 添加商品到数据库
- (void)joinData:(NSString *)shopID andname:(NSString *)shopName andprice:(NSString *)shopPrice andcount:(NSString *)shopCount andSpec:(NSString *)spec andpic:(NSString *)headPic andstock:(NSString *)stockcount
{
    //数字改变的动态效果
        [UIView animateWithDuration:0.3 animations:^{
            _numlb.transform = CGAffineTransformMakeScale(1.5, 1.5);
        } completion:^(BOOL finished) {
            _numlb.transform = CGAffineTransformIdentity;
        }];

    NSLog(@"-- --- %@",shopCount);
    //添加商品信息到数据库
    if ([_dataBase open])
    {
        //查看数据库，该店铺是否存在有该商品 //查询语句
        FMResultSet *result = [_dataBase executeQuery:@"select *from ShopCar where storeid = ? and shopid = ?", [_userdefaults valueForKey:@"shopid"], shopID];
        if ([result next])
        {
            //如果有，更新数据
            BOOL isSuccess = [_dataBase executeUpdate:@"update ShopCar set shopcount = ? where shopid = ? and storeid = ?", shopCount, shopID, [_userdefaults valueForKey:@"shopid"]];
            if (isSuccess)
            {
                NSLog(@"更新数据成功");
            }
        }
        else //如果没有就创建该商品信息
        {
            NSString *shopname = @"";
            if ([spec isEqualToString:@""])
            {
                shopname = shopName;
            }else{
                shopname = [shopName stringByAppendingString: [NSString stringWithFormat:@"(%@)", spec]];
            }
            BOOL isSuccess = [_dataBase executeUpdate:@"insert into ShopCar (storeid, shopid, shopprice, shopname, shopcount, shopPic, stockcount) values (?, ?, ?, ?, ?, ?, ?)", [_userdefaults valueForKey:@"shopid"], shopID, shopPrice, shopname, shopCount, headPic, stockcount];
            if (isSuccess) {
                NSLog(@"创建成功");
            }
        }
    }
    
    //遍历数据库
    [self bianliSQL];
}

#pragma  mark -- 点击减号事件
- (void)joinData:(NSString *)shopID andcount:(NSString *)shopCount
{
    NSLog(@"-- %@",shopCount);
    //添加商品到数据库
    if ([_dataBase open])
    {
        //查找数据库 是否有商品
        FMResultSet *re = [_dataBase executeQuery:@"select *from ShopCar where storeid = ? and shopid = ?", [_userdefaults valueForKey:@"shopid"], shopID];
        
        if ([re next]){
            //如果有，更新
            BOOL isSuccess = [_dataBase executeUpdate:@"update ShopCar set shopcount = ? where shopid = ? and storeid = ?", shopCount, shopID, [_userdefaults valueForKey:@"shopid"]];
            if (isSuccess) {
                NSLog(@"更新数据成功");
            }
        }else{
            //如果没有  创建该记录
            BOOL isSuccess = [_dataBase executeUpdate:@"insert into ShopCar (storeid, shopid, shopcount) values (?, ?, ?)", [_userdefaults valueForKey:@"shopid"], shopID, shopCount];
            if (isSuccess) {
                NSLog(@"记录创建成功");
            }
        }
    }
    [self bianliSQL];
    
    if ([shopCount intValue] == 0) {
        [_rightTableView reloadData];
    }

}
#pragma mark -- 遍历数据库
- (void)bianliSQL
{
    //把之前的数据清空
    [_sqlMuArr removeAllObjects];
    //遍历数据库，更改底层购物车的数据
    if ([_dataBase open]) {
        //通过ID找到
        FMResultSet *res = [_dataBase executeQuery:@"select *from ShopCar where storeid = ?", [_userdefaults valueForKey:@"shopid"]];
        NSLog(@" --- %@",[_userdefaults valueForKey:@"shopid"]);
        while ([res next]) {
            //把数据拿出来
            NSDictionary *dic = @{@"id":[res stringForColumn:@"shopid"], @"price":[res stringForColumn:@"shopprice"], @"amount":[res stringForColumn:@"shopcount"], @"name":[res stringForColumn:@"shopname"], @"pic":[res stringForColumn:@"shopPic"], @"stockcount":[res stringForColumn:@"stockcount"]};
            [_sqlMuArr addObject:dic];
            NSLog(@"数据库 ---%@",dic);
        }
    }
    
    //数字改变的动态效果
//    [UIView animateWithDuration:0.3 animations:^{
//        _numlb.transform = CGAffineTransformMakeScale(1.5, 1.5);
//    } completion:^(BOOL finished) {
//        _numlb.transform = CGAffineTransformIdentity;
//    }];
    
    //更新总价格 与 角标
    float x = 0;
    int y = 0;
    _numlb.hidden = NO;
    for (int i = 0; i < _sqlMuArr.count ; i++) {
        x += [_sqlMuArr[i][@"amount"] floatValue] * [_sqlMuArr[i][@"price"] floatValue];
        y += [_sqlMuArr[i][@"amount"] intValue];
    }
    NSLog(@" %d",y);
    _allPrice.text = [NSString stringWithFormat:@"¥%.2f", x];
    _numlb.text = [NSString stringWithFormat:@"%d", y];
    
    NSLog(@"-- %@",_numlb.text);
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
    float cha = [_shopMesDic[@"startPrice"] floatValue] - x;
    if (cha > 0) {
        if (x == 0) {
            [_jisuan setTitle:[NSString stringWithFormat:@"¥%.2f起送", [_shopMesDic[@"startPrice"] floatValue]] forState:UIControlStateNormal];
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
    
    [_rightTableView reloadData];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _leftTabelView) {
        return 48;
    } else {
        return 80 ;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   // _select = indexPath.row;
    // _isShow = YES;
   // [tableView reloadData];
    //点击后 刷新右侧collectionview
//    _sortID = _sortMuArr[indexPath.row][@"id"];
    //  [self createSecondSortView: _sortMuArr[indexPath.row][@"childs"]];
    //    [self setupRefresh: _sortID];
    
    TCShopDetailViewController *detileVC = [[TCShopDetailViewController alloc] init];
    detileVC.shopMesDic = _shopMesDic;
    detileVC.shopDetailDic = _shopMuArr[indexPath.row];
    detileVC.isHinddenAddBtn = _isHinddenAddBtn;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detileVC animated:YES];
    
}

#pragma mark -- 购物车点击事件
- (void)taps{
    NSLog(@"购物车点击事件");
    //先遍历
    [self bianliSQL];
    if (_sqlMuArr.count != 0) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDHT, HEIGHT)];
        _backView.backgroundColor = [[UIColor darkGrayColor]colorWithAlphaComponent:0.3];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hahha)];
        [_backView addGestureRecognizer:tap];
        [[UIApplication sharedApplication].keyWindow addSubview: _backView];

        TCShopCarView *shop = [[TCShopCarView alloc] initWithFrame:CGRectMake(0, HEIGHT - 350, WIDHT, 350) andData:_sqlMuArr andqisong:_shopMesDic[@"startPrice"] andPeisong:_shopMesDic[@"distributionPrice"]];
        
        [_backView addSubview: shop];
        
        //到达0
        [shop disBackView:^{
            [self bianliSQL];
            [_rightTableView reloadData];
            [_backView removeFromSuperview];
        }];
        
        //刷新 这个block每个都能顾及到（仿美团）
        [shop shuaxin:^{
            [self bianliSQL];
            [_rightTableView reloadData];
        }];
        
    }else{
        [TCDeliverView ShowHubViewWith:@"您还没有选择商品！"];
    }

}
- (void)hahha{
    [self bianliSQL];
    [_rightTableView reloadData];
    [_backView removeFromSuperview];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (![touch.view isKindOfClass: [TCShopCarView class]]) {
        return NO;
    }
    return YES;
}


//购物车红去结算
- (void)gogo{
    [_backView removeFromSuperview];
    [self bianliSQL];
    [_rightTableView reloadData];
    NSMutableArray *ar = [NSMutableArray array];
    [ar addObjectsFromArray: _sqlMuArr];
    if ([_userdefaults valueForKey:@"userID"]) {
//        TCCommitViewController *commit = [[TCCommitViewController alloc]init];
//        commit.shopMuArr = ar;
//        commit.shopsDic = _shopMesDic;
//        [self.navigationController pushViewController: commit animated:YES];
    }else{
//        TCLoginViewController *login = [[TCLoginViewController alloc]init];
//        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:login];
//        [self presentViewController:navi animated:YES completion:nil];
    }
}

#pragma mark -- 提交订单的点击事件
- (void)qujiesuan
{
    NSLog(@"提交订单");
    //[self bianliSQL];
//    [_rightTableView reloadData];
//    [_backView removeFromSuperview];
    
//    if ([[_userdefaults valueForKey:@"shopjuli"] intValue] > ShopDistance) {
//        //[self tipview];
//    }else{
//        if (_sqlMuArr.count != 0) {
            if ([_userdefaults valueForKey:@"userID"]) {
//                TCCommitViewController *commit = [[TCCommitViewController alloc]init];
//                commit.shopMuArr = _sqlMuArr;
//                commit.shopsDic = _shopMesDic;
//                [self.navigationController pushViewController: commit animated:YES];
            }else{
//                TCLoginViewController *login = [[TCLoginViewController alloc]init];
//                UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:login];
//                [self presentViewController:navi animated:YES completion:nil];
            }
            
//        }else{
//            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
//            [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
//            [SVProgressHUD setBackgroundColor:[[UIColor darkGrayColor]colorWithAlphaComponent:0.9]];
//            [SVProgressHUD showErrorWithStatus:@"您还没有选购商品！"];
//        }
   // }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
