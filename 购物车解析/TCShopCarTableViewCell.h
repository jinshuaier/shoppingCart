//
//  TCShopCarTableViewCell.h
//  顺道嘉(新)
//
//  Created by 某某 on 16/9/29.
//  Copyright © 2016年 Macx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDB.h"
typedef void(^SQLBlock)(void);
typedef void(^reloadBlock)(void);
@interface TCShopCarTableViewCell : UITableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andData:(NSDictionary *)dic;
@property (nonatomic, strong) NSDictionary *dics;
@property (nonatomic, strong) UILabel *lb2;
@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) NSUserDefaults *userdefaults;
@property (nonatomic, copy) SQLBlock sqlBlock;
@property (nonatomic, copy) reloadBlock block;
- (void)bianliSQL:(SQLBlock)sql;
- (void)reloadTableview:(reloadBlock)reload;
@end
