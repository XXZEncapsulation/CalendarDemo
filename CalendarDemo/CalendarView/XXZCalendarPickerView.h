//
//  XXZCalendarPickerView.h
//  CalendarDemo
//
//  Created by Jiayu_Zachary on 16/8/11.
//  Copyright © 2016年 Zachary. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XXZCalendarPickerViewDelegate <NSObject>

- (void)xxzCalendarPickerViewWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

@end

@interface XXZCalendarPickerView : UIView

@property (nonatomic, weak) id<XXZCalendarPickerViewDelegate>delegate;

@property (nonatomic , strong) NSDate *date;
@property (nonatomic , strong) NSDate *today;

- (void)show;
- (void)hide;

@end
