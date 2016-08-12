//
//  ViewController.m
//  CalendarDemo
//
//  Created by Jiayu_Zachary on 16/8/11.
//  Copyright © 2016年 Zachary. All rights reserved.
//

#import "ViewController.h"
#import "XXZCalendarPickerView.h"

@interface ViewController () <XXZCalendarPickerViewDelegate>

@end

@implementation ViewController {
    XXZCalendarPickerView *_calendarPicker;
    
    UIButton *_btn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = WHITE_COLOR;
    
    [self buildLayout];
}

#pragma mark - XXZCalendarPickerViewDelegate
- (void)xxzCalendarPickerViewWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    [_btn setTitle:[NSString stringWithFormat:@"%ld-%ld-%ld", year, month, day] forState:UIControlStateNormal];
}


#pragma mark - action
- (void)btnAction {
    [_calendarPicker show];
}

#pragma mark - build layout
- (void)buildLayout {
    [self loadButton];
    [self loadCalendarView];
}

#pragma mark - loading
- (void)loadButton {
    _btn = [UIButton buttonWithType:UIButtonTypeCustom];
    _btn.frame = CGRectMake(100, 100, 100, 50);
    _btn.backgroundColor = CYAN_COLOR;
    [_btn setTitleColor:BLACK_COLOR forState:UIControlStateNormal];
    [self.view addSubview:_btn];
    
    [_btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loadCalendarView {
    _calendarPicker = [[XXZCalendarPickerView alloc] initWithFrame:CGRectMake(0, XXZStatusAndNavHeight, SCREEN_WIDTH, SCREEN_HEIGHT-XXZStatusAndNavHeight)];
    _calendarPicker.delegate = self;
    [self.view addSubview:_calendarPicker];
    
    _calendarPicker.today = [NSDate date];
    [_calendarPicker setDate:_calendarPicker.today];
}

#pragma mark - getter


#pragma mark - setter


#pragma mark - dealloc
- (void)dealloc {
    _calendarPicker.delegate = nil;
}

#pragma mark - other
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
