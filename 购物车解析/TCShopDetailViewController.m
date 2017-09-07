//
//  TCShopDetailViewController.m
//  顺道嘉(新)
//
//  Created by 某某 on 16/9/30.
//  Copyright © 2016年 Macx. All rights reserved.
//

#import "TCShopDetailViewController.h"
#import "TCShopCarView.h"
#import "FMDB.h"
#import "TCDeliverView.h"
#import "UIImageView+WebCache.h"

//数据库路径
#define SqlPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"ShopCar.sqlite"]
// 屏幕适配时需要的宏
#define WIDHT [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
//比例
#define WIDHTSCALE  [UIScreen mainScreen].bounds.size.width/375.0
#define HEIGHTSCALE  [UIScreen mainScreen].bounds.size.height/667.0
#define RGB(r, g, b)    [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define backGgray [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1]//背景颜色  淡灰色

@interface TCShopDetailViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *numlb;
@property (nonatomic, strong) UIButton *jisuan;
@property (nonatomic, strong) UILabel *allPrice;
@property (nonatomic, strong) NSMutableArray *sqlMuArr;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) NSUserDefaults *userdefaults;
@property (nonatomic, strong) UILabel *countlb;
@property (nonatomic, strong) UIButton *cutsbtn;
@end

@implementation TCShopDetailViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self peizhi];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gogo) name:@"shopcarpush" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(relo) name:@"needreload" object:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    _database = [FMDatabase databaseWithPath: SqlPath];
    _userdefaults = [NSUserDefaults standardUserDefaults];
    [_userdefaults setObject:@"122" forKey:@"shopid"];
    _sqlMuArr = [NSMutableArray array];
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, WIDHT, HEIGHT - 50 * HEIGHTSCALE)];
    _mainScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: _mainScrollView];
    
    UIImageView *shopim = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDHT, 280 * HEIGHTSCALE)];
    shopim.contentMode = UIViewContentModeScaleAspectFit;
    [shopim sd_setImageWithURL:[NSURL URLWithString:_shopDetailDic[@"headPic"]] placeholderImage:[UIImage imageNamed:@"1.jpg"]];
    shopim.autoresizesSubviews = YES;
    
    //这个方法是适应图片的大小
    shopim.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UIView *viewImage = [[UIView alloc]init];
    viewImage.frame = CGRectMake(0, 0, WIDHT, 280 * HEIGHTSCALE);
    viewImage.backgroundColor = [UIColor whiteColor];
    [_mainScrollView addSubview:viewImage];
    [viewImage addSubview:shopim];
    
    UIButton *backbtn = [[UIButton alloc]initWithFrame:CGRectMake(12 * WIDHTSCALE - (35 * WIDHTSCALE / 2), 10 * HEIGHTSCALE - 5 * WIDHTSCALE, 70 * WIDHTSCALE, 70 * WIDHTSCALE)];
    [backbtn setImage:[UIImage imageNamed:@"返回图标-带背景.png"] forState: UIControlStateNormal];
    [backbtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    //    backbtn.backgroundColor = [UIColor redColor];
    [_mainScrollView addSubview: backbtn];
    
    UILabel *line1 = [[UILabel alloc]initWithFrame:CGRectMake(0, viewImage.frame.origin.y + viewImage.frame.size.height, WIDHT, 1)];
    line1.backgroundColor = backGgray;
    [_mainScrollView addSubview: line1];
    
    //商品名view
    UIView *nameView = [[UIView alloc]initWithFrame:CGRectMake(0, line1.frame.origin.y + 1, WIDHT, 128 * HEIGHTSCALE)];
    nameView.backgroundColor = [UIColor whiteColor];
    [_mainScrollView addSubview: nameView];
    //商品民
    UILabel *namelb = [[UILabel alloc]initWithFrame:CGRectMake(10 * WIDHTSCALE, 20 * HEIGHTSCALE, WIDHT - 20 * WIDHTSCALE, 16 * HEIGHTSCALE)];
    namelb.text = _shopDetailDic[@"name"];
    namelb.font = [UIFont systemFontOfSize:16 * HEIGHTSCALE];
    namelb.textColor = RGB(51, 51, 51);
    [nameView addSubview: namelb];
    //规格
    UILabel *guige = [[UILabel alloc]initWithFrame:CGRectMake(10 * WIDHTSCALE, namelb.frame.origin.y + namelb.frame.size.height, 20, 14 * HEIGHTSCALE)];
    if ([_shopDetailDic[@"spec"] isEqualToString:@""]) {
        guige.text = @"规格:暂无";
    }else{
        guige.text = [NSString stringWithFormat:@"规格:%@", _shopDetailDic[@"spec"]];
    }
    CGSize size1 = [guige sizeThatFits:CGSizeMake(WIDHT / 2, 14 * HEIGHTSCALE)];
    guige.frame = CGRectMake(10 * WIDHTSCALE, namelb.frame.origin.y + namelb.frame.size.height + 12 * HEIGHTSCALE, size1.width, 14 * HEIGHTSCALE);
    guige.font = [UIFont systemFontOfSize:14 * HEIGHTSCALE];
    guige.textColor = RGB(77, 77, 77);
    [nameView addSubview: guige];
    
    //库存量
    UILabel *kuncun = [[UILabel alloc]initWithFrame:CGRectMake(guige.frame.origin.x, guige.frame.size.height + guige.frame.origin.y + 8, WIDHT / 2, 16 * HEIGHTSCALE)];
    kuncun.text = [NSString stringWithFormat:@"库存：%@", _shopDetailDic[@"stockCount"]];
    kuncun.font = [UIFont systemFontOfSize:14 * HEIGHTSCALE];
    kuncun.textColor = RGB(77, 77, 77);
    kuncun.textAlignment = NSTextAlignmentLeft;
    [nameView addSubview: kuncun];
    
    
    //口味
    UILabel *kouwei = [[UILabel alloc]initWithFrame:CGRectMake(guige.frame.origin.x + 32 * WIDHTSCALE, guige.frame.origin.y, 20, guige.frame.size.height)];
    NSArray *arr = _shopDetailDic[@"natures"];
    if (arr.count == 0 ) {
        kouwei.text = @"口味:暂无";
    }else{
        NSString *str = arr[0];
        for (int i = 1; i < arr.count; i++) {
            str = [str stringByAppendingString: arr[i]];
        }
        kouwei.text = [NSString stringWithFormat:@"口味:%@", str];
    }
    CGSize size2 = [kouwei sizeThatFits:CGSizeMake(WIDHT / 2, 14 * HEIGHTSCALE)];
    kouwei.frame = CGRectMake(guige.frame.origin.x + 32 * WIDHTSCALE + guige.frame.size.width, guige.frame.origin.y, size2.width, guige.frame.size.height);
    kouwei.font = [UIFont systemFontOfSize:14 * HEIGHTSCALE];
    kouwei.textColor = RGB(77, 77, 77);
    [nameView addSubview: kouwei];
    //价格
    UILabel *jiage = [[UILabel alloc]initWithFrame:CGRectMake(10 * WIDHTSCALE, kuncun.frame.origin.y + kuncun.frame.size.height + 10 * HEIGHTSCALE, WIDHT / 2, 20 * HEIGHTSCALE)];
    jiage.text = [NSString stringWithFormat:@"¥%@", _shopDetailDic[@"price"]];
    jiage.font = [UIFont boldSystemFontOfSize: 18 * HEIGHTSCALE];
    jiage.textColor = [UIColor redColor];
    [nameView addSubview: jiage];
    //添加按钮
    UIButton *addbtn = [[UIButton alloc]initWithFrame:CGRectMake(WIDHT - 10 * WIDHTSCALE - 25 * WIDHTSCALE, jiage.frame.origin.y, 25 * WIDHTSCALE, 25 * WIDHTSCALE)];
    [addbtn setImage:[UIImage imageNamed:@"商品加号图标.png"] forState: UIControlStateNormal];
    [addbtn addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    [nameView addSubview: addbtn];
    //个数
    UILabel *numlb = [[UILabel alloc]initWithFrame:CGRectMake(addbtn.frame.origin.x - 32 * WIDHTSCALE, addbtn.frame.origin.y, 32 * WIDHTSCALE, addbtn.frame.size.height)];
    numlb.text = @"";
    numlb.font = [UIFont systemFontOfSize:15 * HEIGHTSCALE];
    numlb.textAlignment = NSTextAlignmentCenter;
    [nameView addSubview: numlb];
    _countlb = numlb;
    //减号
    UIButton *cutbtn = [[UIButton alloc]initWithFrame:CGRectMake(numlb.frame.origin.x - 25 * WIDHTSCALE, numlb.frame.origin.y, 25 * WIDHTSCALE, 25 * WIDHTSCALE)];
    [cutbtn setImage:[UIImage imageNamed:@"商品减号.png"] forState:UIControlStateNormal];
    [cutbtn addTarget:self action:@selector(cut) forControlEvents:UIControlEventTouchUpInside];
    [nameView addSubview: cutbtn];
    cutbtn.hidden = YES;
    _cutsbtn = cutbtn;
    //商品描述
    UILabel *miaoshu = [[UILabel alloc]initWithFrame:CGRectMake(0, nameView.frame.size.height + nameView.frame.origin.y, WIDHT, 40 * HEIGHTSCALE)];
    miaoshu.text = @"  商品描述";
    miaoshu.backgroundColor = RGB(242, 242, 242);
    miaoshu.textColor = RGB(51, 51, 51);
    miaoshu.font = [UIFont systemFontOfSize: 14 * HEIGHTSCALE];
    [_mainScrollView addSubview: miaoshu];
    //描述view
    UIView *mview = [[UIView alloc]initWithFrame:CGRectMake(0, miaoshu.frame.origin.y + miaoshu.frame.size.height, WIDHT, HEIGHT - 50 * HEIGHTSCALE  - miaoshu.frame.origin.y - miaoshu.frame.size.height - 30 * HEIGHTSCALE)];
    mview.backgroundColor = [UIColor whiteColor];
    [_mainScrollView addSubview: mview];
    UILabel *miaolb = [[UILabel alloc]initWithFrame:CGRectMake(10 * WIDHTSCALE, 10 * HEIGHTSCALE, WIDHT - 20 * WIDHTSCALE, mview.frame.size.height - 20 * HEIGHTSCALE)];
    miaolb.textColor = RGB(77, 77, 77);
    miaolb.font = [UIFont systemFontOfSize:14 * HEIGHTSCALE];
    miaolb.numberOfLines = 0;
    if ([_shopDetailDic[@"description"] isEqualToString:@""]) {
        miaolb.text = @"暂无描述";
    }else{
        miaolb.text = _shopDetailDic[@"description"];
    }
    CGSize size3 = [miaolb sizeThatFits: CGSizeMake(WIDHT - 20 * WIDHTSCALE, mview.frame.size.height - 20 * HEIGHTSCALE)];
    miaolb.frame = CGRectMake(10 * WIDHTSCALE, 10 * HEIGHTSCALE, size3.width, size3.height);
    [mview addSubview: miaolb];
    
    //购物车
    //底部view
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, HEIGHT - 50 * HEIGHTSCALE, WIDHT, 50 * HEIGHTSCALE)];
    _bottomView.backgroundColor = backGgray;
    [self.view addSubview: _bottomView];
    UILabel *linew = [[UILabel alloc]initWithFrame:CGRectMake(0, _bottomView.frame.origin.y - 0.5, WIDHT, 0.5)];
    linew.backgroundColor = RGB(102, 102, 102);
    [self.view addSubview: linew];
    UIImageView *im1 = [[UIImageView alloc]initWithFrame:CGRectMake(12 * WIDHTSCALE, _bottomView.frame.origin.y + _bottomView.frame.size.height - 6.5 * HEIGHTSCALE - 60 * HEIGHTSCALE, 60 * HEIGHTSCALE, 60 * HEIGHTSCALE)];
    im1.image = [UIImage imageNamed:@"顺道嘉标志购物车.png"];
    im1.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(taps)];
    [im1 addGestureRecognizer: tap];
    [self.view addSubview: im1];
    _numlb = [[UILabel alloc]initWithFrame:CGRectMake(im1.frame.size.width + im1.frame.origin.x - 19 * HEIGHTSCALE, im1.frame.origin.y, 18 * HEIGHTSCALE, 18 * HEIGHTSCALE)];
    _numlb.layer.cornerRadius = 9 * HEIGHTSCALE;
    _numlb.layer.masksToBounds = YES;
    _numlb.backgroundColor = [UIColor redColor];
    _numlb.text = @"";
    _numlb.hidden = YES;
    _numlb.textAlignment = NSTextAlignmentCenter;
    _numlb.font = [UIFont systemFontOfSize:12 * HEIGHTSCALE];
    _numlb.textColor = [UIColor whiteColor];
    [self.view addSubview: _numlb];
    
    //结算按钮
    _jisuan = [UIButton buttonWithType:UIButtonTypeCustom];
    _jisuan.frame = CGRectMake(WIDHT - 120 * WIDHTSCALE, 0, 120 * WIDHTSCALE, _bottomView.frame.size.height);
    _jisuan.backgroundColor = RGB(204, 204, 204);
    [_jisuan setTitle:[NSString stringWithFormat:@"¥%@起送", _shopMesDic[@"startPrice"]] forState:UIControlStateNormal];
    [_jisuan addTarget:self action:@selector(qujiesuan) forControlEvents:UIControlEventTouchUpInside];
    [_jisuan setTitleColor:RGB(51, 51, 51) forState:UIControlStateNormal];
    _jisuan.titleLabel.font = [UIFont systemFontOfSize:15 * HEIGHTSCALE];
    [_bottomView addSubview: _jisuan];
    //总计
    UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(im1.frame.origin.x + im1.frame.size.width + 8 * WIDHTSCALE, 12 * HEIGHTSCALE, 20, 20 * HEIGHTSCALE)];
    lb.text = @"总计:";
    lb.font = [UIFont boldSystemFontOfSize:15 * HEIGHTSCALE];
    CGSize size = [lb sizeThatFits:CGSizeMake(50, 30 * HEIGHTSCALE)];
    lb.frame = CGRectMake(im1.frame.origin.x + im1.frame.size.width + 8 * WIDHTSCALE, 12 * HEIGHTSCALE, size.width, 15 * HEIGHTSCALE);
    [_bottomView addSubview: lb];
    //价格
    _allPrice = [[UILabel alloc]initWithFrame:CGRectMake(lb.frame.origin.x + lb.frame.size.width + 5 * WIDHTSCALE, lb.frame.origin.y, _jisuan.frame.origin.x - lb.frame.origin.x - lb.frame.size.width - 5 * WIDHTSCALE - 12 * WIDHTSCALE, lb.frame.size.height)];
    _allPrice.text = @"¥0.00";
    _allPrice.textColor = [UIColor redColor];
    _allPrice.font = [UIFont boldSystemFontOfSize:15 * HEIGHTSCALE];
    [_bottomView addSubview: _allPrice];
    //配送费
    UILabel *lb2 = [[UILabel alloc]initWithFrame:CGRectMake(lb.frame.origin.x, lb.frame.origin.y + lb.frame.size.height + 4 * HEIGHTSCALE, 10, 15 * HEIGHTSCALE)];
    lb2.text = @"配送费:";
    lb2.font = [UIFont systemFontOfSize:11 * HEIGHTSCALE];
    lb2.textColor = RGB(102, 102, 102);
    CGSize sizes = [lb2 sizeThatFits:CGSizeMake(50, 15 * HEIGHTSCALE)];
    lb2.frame = CGRectMake(lb.frame.origin.x, lb.frame.origin.y + lb.frame.size.height + 4 * HEIGHTSCALE, sizes.width, 15 * HEIGHTSCALE);
    [_bottomView addSubview: lb2];
    //配送费
    UILabel *lb3 = [[UILabel alloc]initWithFrame:CGRectMake(lb2.frame.origin.x + lb2.frame.size.width + 5 * WIDHTSCALE, lb2.frame.origin.y, _jisuan.frame.origin.x - lb2.frame.origin.x - lb2.frame.size.width - 5 * WIDHTSCALE - 12 * WIDHTSCALE, lb2.frame.size.height)];
    lb3.text = [NSString stringWithFormat:@"¥%@", _shopMesDic[@"distributionPrice"]];
    lb3.font = [UIFont systemFontOfSize:11 * HEIGHTSCALE];
    lb3.textColor = RGB(102, 102, 102);
    [_bottomView addSubview: lb3];
    
    if (_isHinddenAddBtn) {
        addbtn.hidden = YES;
    }else{
        addbtn.hidden = NO;
    }
    
    [self peizhi];
}

- (void)relo{
    [self peizhi];
}

//配置页面上的数量与减号状态
- (void)peizhi{
    //遍历数据库
    [self bianliSQL];
    //遍历记录  如果有 就显示对应个数
    if (_sqlMuArr.count == 0) {
        //主要用于  购物车减到0后 该数组中无数据  就不执行下方循环 则数量与减号状态不改变
        _cutsbtn.hidden = YES;
        _countlb.text = @"";
    }else{
        for (int i = 0; i < _sqlMuArr.count; i++) {
            if ([_shopDetailDic[@"id"] isEqualToString: _sqlMuArr[i][@"id"]]) {
                _countlb.text = _sqlMuArr[i][@"amount"];
                _cutsbtn.hidden = NO;
                return;
            }else{
                _cutsbtn.hidden = YES;
            }
        }
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (![touch.view isKindOfClass: [TCShopCarView class]]) {
        return NO;
    }
    return YES;
}

//添加
- (void)add{
    if ([_countlb.text intValue] + 1 > [_shopDetailDic[@"stockCount"] intValue]) {
        [TCDeliverView ShowHubViewWith:@"超出库存啦!"];
    }else{
        _countlb.text = [NSString stringWithFormat:@"%d", [_countlb.text intValue] + 1];
        //添加商品信息到数据库
        if ([_database open]) {
            //查找数据库 该店铺下是否有该商品
            FMResultSet *re = [_database executeQuery:@"select *from ShopCar where storeid = ? and shopid = ?", [_userdefaults valueForKey:@"shopid"], _shopDetailDic[@"id"]];
            if ([re next]) {
                //如果有  更新个数
                BOOL isSuccess = [_database executeUpdate:@"update ShopCar set shopcount = ? where shopid = ? and storeid = ?", _countlb.text, _shopDetailDic[@"id"], [_userdefaults valueForKey:@"shopid"]];
                if (isSuccess) {
                    NSLog(@"更新数据成功");
                }
            }else{
                //如果没有  创建该记录
                NSString *shopname = @"";
                if ([_shopDetailDic[@"spec"] isEqualToString:@""]) {
                    shopname = _shopDetailDic[@"name"];
                }else{
                    shopname = [_shopDetailDic[@"name"] stringByAppendingString: [NSString stringWithFormat:@"(%@)", _shopDetailDic[@"spec"]]];
                }
                BOOL isSuccess = [_database executeUpdate:@"insert into ShopCar (storeid, shopid, shopprice, shopname, shopcount, shopPic, stockcount) values (?, ?, ?, ?, ?, ?, ?)", [_userdefaults valueForKey:@"shopid"], _shopDetailDic[@"id"], _shopDetailDic[@"price"], shopname, _countlb.text, _shopDetailDic[@"headPic"], _shopDetailDic[@"stockCount"]];
                if (isSuccess) {
                    NSLog(@"记录创建成功");
                }
            }
        }
        _cutsbtn.hidden = NO;
        [self bianliSQL];
    }
}

//减少
- (void)cut{
    _countlb.text = [NSString stringWithFormat:@"%d", [_countlb.text intValue] - 1];
    //添加商品信息到数据库
    if ([_database open]) {
        //查找数据库 该店铺下是否有该商品
        FMResultSet *re = [_database executeQuery:@"select *from ShopCar where storeid = ? and shopid = ?", [_userdefaults valueForKey:@"shopid"], _shopDetailDic[@"id"]];
        if ([re next]) {
            //如果有  更新个数
            BOOL isSuccess = [_database executeUpdate:@"update ShopCar set shopcount = ? where shopid = ? and storeid = ?", _countlb.text, _shopDetailDic[@"id"], [_userdefaults valueForKey:@"shopid"]];
            if (isSuccess) {
                NSLog(@"更新数据成功");
            }
        }else{
            //如果没有  创建该记录
            BOOL isSuccess = [_database executeUpdate:@"insert into ShopCar (storeid, shopid, shopprice, shopname, shopcount, shopPic, stockcount) values (?, ?, ?, ?, ?, ?, ?)", [_userdefaults valueForKey:@"shopid"], _shopDetailDic[@"id"], _shopDetailDic[@"price"], _shopDetailDic[@"name"], _countlb.text, _shopDetailDic[@"headPic"], _shopDetailDic[@"stockCount"]];
            if (isSuccess) {
                NSLog(@"记录创建成功");
            }
        }
    }
    [self bianliSQL];
    //当减到0 的时候  tableview中移除刚数据
    if ([_countlb.text intValue] == 0) {
        _cutsbtn.hidden = YES;
        _countlb.text = @"";
    }
}

//购物车点击事件
- (void)taps{
    //先遍历
    [self bianliSQL];
    if (_sqlMuArr.count != 0) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDHT, HEIGHT)];
        _backView.backgroundColor = [[UIColor darkGrayColor]colorWithAlphaComponent:0.3];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(haha)];
        tap.delegate = self;
        [_backView addGestureRecognizer: tap];
        [[UIApplication sharedApplication].keyWindow addSubview: _backView];
        //创建是  将起送跟配送传过去
        
        TCShopCarView *shop = [[TCShopCarView alloc] initWithFrame:CGRectMake(0, HEIGHT - 350 * HEIGHTSCALE, WIDHT, 350 * HEIGHTSCALE) andData:_sqlMuArr andqisong:_shopMesDic[@"startPrice"] andPeisong:_shopMesDic[@"distributionPrice"]];
        
        [_backView addSubview: shop];
        //点击购物车按钮  移除view后的回调方法  在此处要重新配置主页面上的减号状态与数量
        [shop disBackView:^{
            [self bianliSQL];
            [self peizhi];
            [_backView removeFromSuperview];
        }];
        //到达0 这里是同步上面的数据
        [shop shuaxin:^{
            [self bianliSQL];
            [self peizhi];
            //[_backView removeFromSuperview];
        }];
    

    }else{
       
        [TCDeliverView ShowHubViewWith:@"您还没有选购商品！"];
    }
    
}

- (void)haha{
    [self bianliSQL];
    [self peizhi];
    [_backView removeFromSuperview];
}

//遍历数据库
- (void)bianliSQL{
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
    _numlb.hidden = NO;
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
}

- (void)gogo{
    [_backView removeFromSuperview];
    [self peizhi];
}

- (void)qujiesuan{
    NSLog(@"去结算");
 
//    if ([[_userdefaults valueForKey:@"shopjuli"] intValue] > ShopDistance) {
//       // [SVProgressHUD showErrorWithStatus:@"距离过远，无法为您提供配送服务！"];
//    }else{
//        [self bianliSQL];
//        if (_sqlMuArr.count != 0) {
//            if ([_userdefaults valueForKey:@"userID"]) {
//               
//            }else{
//              //  [SVProgressHUD showErrorWithStatus:@"请先登录后在结算"];
//            }
//        }else{
//           // [SVProgressHUD showErrorWithStatus:@"您还没有选购商品！"];
//        }
//    }
    
}

- (void)back{
    //要求前一个页面刷新数据
    [[NSNotificationCenter defaultCenter]postNotificationName:@"detailBack" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}
@end
