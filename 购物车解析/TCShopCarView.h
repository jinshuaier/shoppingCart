//
//  TCShopCarView.h
//  购物车解析
//
//  Created by 胡高广 on 2017/9/5.
//  Copyright © 2017年 jinshuaier. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^dismiss)(void);
typedef void(^shuaxin)(void);


@interface TCShopCarView : UIView

@property (nonatomic, strong) dismiss block;

@property (nonatomic, strong) shuaxin shuaxinBlock;

- (id)initWithFrame:(CGRect)frame andData:(NSMutableArray *)arr andqisong:(NSString *)qisong andPeisong:(NSString *)peisong;

- (void)disBackView:(dismiss)blocks;
- (void)shuaxin:(shuaxin)shuaxinBlock;
@end
