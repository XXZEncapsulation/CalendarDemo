//
//  XXZCalendarPickerView.m
//  CalendarDemo
//
//  Created by Jiayu_Zachary on 16/8/11.
//  Copyright © 2016年 Zachary. All rights reserved.
//

#import "XXZCalendarPickerView.h"
#import "CalendarCell.h"

NSString *const XXZCalendarCellIdentifier = @"CalendarCell";
NSString *const headerViewIdentifier = @"headerViewIdentifier";
NSString *const footerViewIdentifier = @"footerViewIdentifier";


@interface XXZCalendarPickerView () <UICollectionViewDelegate , UICollectionViewDataSource> {
    NSInteger _startMonth; //开始的月份
    UIView *_contentMaskView; //内容的蒙版
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UILabel *monthLabel;
@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) NSArray *weekDayArray;
@property (nonatomic, strong) UIView *mask; //底部阴影

@end

@implementation XXZCalendarPickerView {
    CGRect _originalRect;
    CGFloat _topHeight;
    CGFloat _cellHeight;
    
    NSMutableDictionary *_dateDict;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _startMonth = 6; //默认功能开启的月份
        
        _originalRect = frame;
        _topHeight = 44*RATIO_WIDTH;
        _cellHeight = _topHeight;
        
        _dateDict = [NSMutableDictionary dictionary];
        
        NSMutableArray *augustArr = [NSMutableArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"0", @"0", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", nil];
        [_dateDict setObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:augustArr, @"8", nil] forKey:@"2016"];
        
        self.alpha = 0.0;
        self.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        [self buildLayout];
    }
    
    return self;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return _weekDayArray.count;
    }
    else {
        return 42;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:XXZCalendarCellIdentifier forIndexPath:indexPath];
    [cell.dateLabel setBackgroundColor:[UIColor clearColor]]; //默认无底色
    
    if (indexPath.section == 0) { //星期
        cell.dateLabel.frame = CGRectMake(0, 0, _cellHeight, _cellHeight-10*RATIO_WIDTH);
        
        [cell.dateLabel setText:_weekDayArray[indexPath.row]];
        
        if (indexPath.row == 0 || indexPath.row == 6) { //周日周六
            [cell.dateLabel setTextColor:UICOLOR_DARK];
        }
        else {
            [cell.dateLabel setTextColor:UICOLOR_FROM_YELLOW];
        }
        
    }
    else { //天
        cell.dateLabel.frame = CGRectMake(0, 0, _cellHeight, _cellHeight);
        
        NSInteger daysInThisMonth = [XXZDateModel totaldaysInMonth:_date];
        NSInteger firstWeekday = [XXZDateModel firstWeekdayInThisMonth:_date];
        
        NSInteger day = 0;
        NSInteger i = indexPath.row;
        
        if (i < firstWeekday) { //每月第一天之前没有内容
            [cell.dateLabel setText:@""];
        }
        else if (i > firstWeekday + daysInThisMonth - 1){ //每月最后一天之后没有内容
            [cell.dateLabel setText:@""];
        }
        else{ //每个月的日期
            day = i - firstWeekday + 1;
            [cell.dateLabel setText:[NSString stringWithFormat:@"%ld", day]]; //显示具体日期
            
            //是否开启
            if ([self isOpenDateStatusWithDay:day]) { //开启
                [cell.dateLabel setTextColor:UICOLOR_FROM(@"#2D3841")]; //默认正常
            }
            else { //未开启
                [cell.dateLabel setTextColor:UICOLOR_FROM(@"#A1A1A1")];
            }
            
            //本月特殊情况处理
            if ([_today isEqualToDate:_date]) {
                if (day == [XXZDateModel returnDayWithDate:_date]) { //今日日期
                    ViewRadius(cell.dateLabel, cell.dateLabel.frame.size.height/2);
                    [cell.dateLabel setTextColor:WHITE_COLOR];
                    [cell.dateLabel setBackgroundColor:UICOLOR_FROM(@"#FF5A60")]; //背景色
                }
                else if (day > [XXZDateModel returnDayWithDate:_date]) {
                    [cell.dateLabel setTextColor:UICOLOR_FROM(@"#E5E5E5")]; //本月未到的日期
                }
            }
            else if ([_today compare:_date] == NSOrderedAscending) { //下个月日期
                [cell.dateLabel setTextColor:UICOLOR_FROM(@"#E5E5E5")];
            }
            
        }
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
//每个cell的宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(_cellHeight, _cellHeight-10*RATIO_WIDTH);
    }
    else {
        return CGSizeMake(_cellHeight, _topHeight);
    }
}

//设置每组的cell的上下左右边界
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    //上, 左, 下, 右
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//cell的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

//cell的最小列间距
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {}

#pragma mark - UICollectionViewDelegateFlowLayout
#if 1
//定义并返回每个headerView或footerView
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *headerView = nil;
    
    if ([kind isEqualToString: UICollectionElementKindSectionHeader]) { //头视图
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerViewIdentifier forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor magentaColor];
        
        UILabel *title = [headerView viewWithTag:100];
        if (title == nil) {
            UILabel *title = [[UILabel alloc] init];
            title.frame = CGRectMake(15, 5, headerView.frame.size.width-15*2, headerView.frame.size.height-10);
            title.backgroundColor = [UIColor clearColor];
            title.textColor = [UIColor blackColor];
            title.tag = 100;
            title.text = @"headerView";
            title.textAlignment = NSTextAlignmentCenter;
//            [headerView addSubview:title];
        }
        
        UIView *topLine = [headerView viewWithTag:101];
        if (!topLine) {
            topLine = [[UIView alloc] init];
            topLine.frame = CGRectMake(0, 0, self.frame.size.width, 1);
            topLine.backgroundColor = UICOLOR_FROM(@"#E5E5E5");
            [headerView addSubview:topLine];
        }
        
        //coding..
        
        
    }
    else if ([kind isEqualToString: UICollectionElementKindSectionFooter]) { //脚视图
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footerViewIdentifier forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor magentaColor];
        
        UILabel *title = [headerView viewWithTag:100];
        if (title == nil) {
            UILabel *title = [[UILabel alloc] init];
            title.frame = CGRectMake(15, 5, headerView.frame.size.width-15*2, headerView.frame.size.height-10);
            title.backgroundColor = [UIColor clearColor];
            title.textColor = [UIColor blackColor];
            title.tag = 100;
            title.text = @"footerView";
            title.textAlignment = NSTextAlignmentCenter;
            [headerView addSubview:title];
        }
        
        //coding..
        
    }
    
    return headerView;
}

//头视图宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(0, 1);
}

//脚视图宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
//    return CGSizeMake(0, 30);
    return CGSizeZero;
}
#endif

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSInteger daysInThisMonth = [XXZDateModel totaldaysInMonth:_date];
        NSInteger firstWeekday = [XXZDateModel firstWeekdayInThisMonth:_date];
        
        NSInteger day = 0;
        NSInteger i = indexPath.row;
        
        //每月第一天~每月最后一天
        if (i >= firstWeekday && i <= firstWeekday + daysInThisMonth - 1) {
            day = i - firstWeekday + 1;
            
            //this month
            if ([_today isEqualToDate:_date]) {
                if (day <= [XXZDateModel returnDayWithDate:_date]) {
                    if ([self isOpenDateStatusWithDay:day]) { //可选
                        return YES;
                    }

                    [MBProgressHUD showMsg:@"没有相关的路线数据" toView:self];
                    return NO;
                }
            }
            else if ([_today compare:_date] == NSOrderedDescending) {
                if ([self isOpenDateStatusWithDay:day]) { //可选
                    return YES;
                }
                
                [MBProgressHUD showMsg:@"没有相关的路线数据" toView:self];
                return NO;
            }
            
        }
        else {
            XXZLog(@"没有日期部分");
            return NO;
        }
        
        [MBProgressHUD showMsg:@"没有相关的路线数据" toView:self];
    }
    
    return NO; //不可选
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:_date];
    NSInteger firstWeekday = [XXZDateModel firstWeekdayInThisMonth:_date];
    
    NSInteger day = 0;
    NSInteger i = indexPath.row;
    day = i - firstWeekday + 1;
    
    if ([_delegate respondsToSelector:@selector(xxzCalendarPickerViewWithYear:month:day:)]) {
        [_delegate xxzCalendarPickerViewWithYear:[comp year] month:[comp month] day:day];
    }
    
    [self hide];
}

#pragma mark - action
- (void)previouseAction {
    NSInteger month = [XXZDateModel returnMonthWithDate:_date];
    if (month == _startMonth) {
        //不能查看过去月份
        NSString *msg = [NSString stringWithFormat:@"路线图数据从%ld月份开始", month];
        [MBProgressHUD showMsg:msg toView:self];
        return;
    }
    else {
        [_nextButton setImage:[UIImage imageNamed:@"rightArrow_canClick"] forState:UIControlStateNormal];
        
        if (month-1 == _startMonth) {
            [_previousButton setImage:[UIImage imageNamed:@"leftArrow_noClick"] forState:UIControlStateNormal];
        }
    }
    
    [UIView transitionWithView:_contentMaskView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
        self.date = [XXZDateModel lastMonth:_date];
    } completion:nil];
}

- (void)nextAction {
    NSInteger month = [XXZDateModel returnMonthWithDate:_date];
    if (month == [XXZDateModel returnCurrentMonth]) {
        //不能查看未来月份
        [MBProgressHUD showMsg:@"不能查看未来月份" toView:self];
        return;
    }
    else {
        [_previousButton setImage:[UIImage imageNamed:@"leftArrow_canClick"] forState:UIControlStateNormal];
        
        if (month+1 == [XXZDateModel returnCurrentMonth]) {
            [_nextButton setImage:[UIImage imageNamed:@"rightArrow_noClick"] forState:UIControlStateNormal];
        }
    }
    
    [UIView transitionWithView:_contentMaskView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
        self.date = [XXZDateModel nextMonth:_date];
    } completion:nil];
}

#pragma mark - build layout
- (void)buildLayout {
    [self addSubview:self.mask];
    [self loadContentMaskView];
}

#pragma mark - loading
//装载主内容视图
- (void)loadContentMaskView {
    _contentMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _originalRect.size.width, (_cellHeight*7+_topHeight))];
    _contentMaskView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentMaskView];
    
    [self loadTopViewWithView:_contentMaskView];
    
    [_contentMaskView addSubview:self.collectionView];
    [self registerClass:_collectionView]; //注册
    
    [self addTap];
    [self addSwipe];
}

//装载日期切换视图
- (void)loadTopViewWithView:(UIView *)view {
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _originalRect.size.width, _topHeight)];
    topView.backgroundColor = WHITE_COLOR;
    [view addSubview:topView];
    
    [topView addSubview:self.monthLabel];
    [topView addSubview:self.previousButton];
    [topView addSubview:self.nextButton];
}

//注册
- (void)registerClass:(UICollectionView *)collectionView {
    //注册Cell
    [collectionView registerClass:[CalendarCell class] forCellWithReuseIdentifier:XXZCalendarCellIdentifier];
    //注册头视图
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerViewIdentifier];
    //注册脚视图
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerViewIdentifier];
    
    _weekDayArray = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
}

#pragma mark - getter
- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.frame = CGRectMake(CGRectGetMaxX(_monthLabel.frame)+1, 0, _topHeight, _topHeight);
//        _nextButton.backgroundColor = CYAN_COLOR;
        [_nextButton setImage:[UIImage imageNamed:@"rightArrow_noClick"] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _nextButton;
}

- (UIButton *)previousButton {
    if (!_previousButton) {
        _previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _previousButton.frame = CGRectMake(CGRectGetMinX(_monthLabel.frame)-(1+_topHeight), 0, _topHeight, _topHeight);
//        _previousButton.backgroundColor = CYAN_COLOR;
        
        if (_startMonth < [XXZDateModel returnCurrentMonth]) {
            [_previousButton setImage:[UIImage imageNamed:@"leftArrow_canClick"] forState:UIControlStateNormal];
        }
        else {
            [_previousButton setImage:[UIImage imageNamed:@"leftArrow_noClick"] forState:UIControlStateNormal];
        }
        [_previousButton addTarget:self action:@selector(previouseAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _previousButton;
}

- (UILabel *)monthLabel {
    if (!_monthLabel) {
        _monthLabel = [[UILabel alloc] init];
        _monthLabel.frame = CGRectMake((self.frame.size.width-80*RATIO_WIDTH)/2, 0, 80*RATIO_WIDTH, _topHeight);
        _monthLabel.font = BOLD_l7;
        _monthLabel.textColor = UICOLOR_FROM(@"#2D3841");
        _monthLabel.textAlignment = NSTextAlignmentCenter;
//        _monthLabel.backgroundColor = CYAN_COLOR;
    }
    
    return _monthLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, _topHeight+1, self.frame.size.width, _cellHeight*7) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        _collectionView.backgroundColor = WHITE_COLOR;
    }
    
    return _collectionView;
}

- (UIView *)mask {
    if (!_mask) {
        _mask = [[UIView alloc] init];
        _mask.frame = CGRectMake(0, 0, _originalRect.size.width, _originalRect.size.height);
        _mask.backgroundColor = [BLACK_COLOR colorWithAlphaComponent:0.5];
        _mask.alpha = 0;
    }
    
    return _mask;
}

#pragma mark - setter
- (void)setDate:(NSDate *)date {
    _date = date;
    [_monthLabel setText:[NSString stringWithFormat:@"%ld/%02ld", [XXZDateModel returnYearWithDate:_date], [XXZDateModel returnMonthWithDate:_date]]];
    
    [_collectionView reloadData];
}

#pragma mark - method
//动画转场
- (void)show {
    self.hidden = NO;
    _contentMaskView.transform = CGAffineTransformTranslate(_contentMaskView.transform, 0, - _contentMaskView.frame.size.height);
    
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.alpha = 1.0;
        
        _mask.alpha = 1.0;
        _contentMaskView.transform = CGAffineTransformIdentity;
        
    } completion:nil];
}

- (void)hide {
    [UIView animateWithDuration:0.5 animations:^(void) {
        
        _contentMaskView.transform = CGAffineTransformTranslate(_contentMaskView.transform, 0, - _contentMaskView.frame.size.height);
        
        _mask.alpha = 0.0;
        self.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void)addSwipe {
    UISwipeGestureRecognizer *swipLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextAction)];
    swipLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [_contentMaskView addGestureRecognizer:swipLeft];
    
    UISwipeGestureRecognizer *swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previouseAction)];
    swipRight.direction = UISwipeGestureRecognizerDirectionRight;
    [_contentMaskView addGestureRecognizer:swipRight];
}

- (void)addTap {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [_mask addGestureRecognizer:tap];
}

#pragma mark - dealloc
- (void)dealloc {
    
}

#pragma mark - other
//YES 有路线图, NO 没有路线图
- (BOOL)isOpenDateStatusWithDay:(NSInteger)day {
#if 0
    NSInteger year = [XXZDateModel returnYearWithDate:_date];
    NSInteger month = [XXZDateModel returnMonthWithDate:_date];
    
    if (month == 8) {
        return [self returnDateTestDataWithYear:year month:month day:day];
    }
    
    return NO;
    
#else
    
    return YES;
    
#endif
}

- (BOOL)returnDateTestDataWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
//    XXZLog(@"year = %ld, month = %ld, day = %ld", year, month, day);
    
    NSString *yearStr = [NSString stringWithFormat:@"%ld", year];
    NSString *monthStr = [NSString stringWithFormat:@"%ld", month];
    
    NSInteger saveDay = [[_dateDict[yearStr][monthStr] objectAtIndex:(day-1)] integerValue];
    if (saveDay == day) {
        return YES;
    }
    
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
