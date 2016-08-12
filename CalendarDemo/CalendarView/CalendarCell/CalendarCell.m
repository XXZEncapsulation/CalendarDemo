//
//  CalendarCell.m
//  CalendarDemo
//
//  Created by Jiayu_Zachary on 16/8/11.
//  Copyright © 2016年 Zachary. All rights reserved.
//

#import "CalendarCell.h"

@interface CalendarCell ()

@end

@implementation CalendarCell


#pragma mark - action


#pragma mark - build layout
- (void)buildLayout {
    
}

#pragma mark - loading


#pragma mark - getter
- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [_dateLabel setTextAlignment:NSTextAlignmentCenter];
        [_dateLabel setFont:FONT_l7];
//        ViewRadius(_dateLabel, _dateLabel.frame.size.height/2);
        //_dateLabel.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:_dateLabel];
    }
    
    return _dateLabel;
}

#pragma mark - setter


#pragma mark - dealloc
- (void)dealloc {
    
}

#pragma mark - other


@end
