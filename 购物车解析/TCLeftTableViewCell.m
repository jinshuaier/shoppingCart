//
//  TCLeftTableViewCell.m
//  顺道嘉(新)
//
//  Created by 某某 on 16/9/27.
//  Copyright © 2016年 Macx. All rights reserved.
//

#import "TCLeftTableViewCell.h"
#define WIDHT [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define backGgray [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1]//背景颜色  淡灰色
#define RGB(r, g, b)    [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
@implementation TCLeftTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self create];
    }
    return self;
}

- (void)create{
    _line = [[UILabel alloc]initWithFrame:CGRectMake(0, 8, 4 , 32 )];
    _line.hidden =  YES;
    _line.backgroundColor = RGB(255, 219, 77);
    [self addSubview: _line];

    _title = [[UILabel alloc]initWithFrame:CGRectMake(_line.frame.origin.x + _line.frame.size.width, 0, WIDHT * 0.28 - _line.frame.origin.x - _line.frame.size.width, 47 )];
    _title.font = [UIFont systemFontOfSize:14];
    _title.textColor = [UIColor redColor];
    _title.textAlignment = NSTextAlignmentCenter;
    [self addSubview: _title];
    
    UILabel *line2 = [[UILabel alloc]initWithFrame:CGRectMake(0, _title.frame.origin.y + _title.frame.size.height, WIDHT * 0.28 - _line.frame.origin.x - _line.frame.size.width, 1 )];
    line2.backgroundColor = RGB(225,225,225);
    [self addSubview: line2];
}

@end
