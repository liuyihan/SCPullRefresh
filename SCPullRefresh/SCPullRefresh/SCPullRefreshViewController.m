//
//  SCPullRefreshViewController.m
//  v2ex-iOS
//
//  Created by Singro on 4/4/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCPullRefreshViewController.h"

#import "SCBubbleRefreshView.h"
#import "SCCircularRefreshView.h"

#import "KSActivityIndicatorBallPulseAnimation.h"
#import "KSActivityIndicatorTriplePulseAnimation.h"
#import "KSActivityIndicatorCookieTerminatorAnimation.h"

//#define kBubbleAnimation
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)


static CGFloat const kRefreshHeight = 44.0f;

@interface SCPullRefreshViewController ()

@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UIView *tableFooterView;

#ifdef kBubbleAnimation
@property (nonatomic, strong) SCBubbleRefreshView *refreshView;
@property (nonatomic, strong) SCBubbleRefreshView *loadMoreView;
#else
@property (nonatomic, strong) KSActivityIndicatorCookieTerminatorAnimation *refreshView;
@property (nonatomic, strong) KSActivityIndicatorCookieTerminatorAnimation *loadMoreView;
#endif

@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) BOOL hadLoadMore;
@property (nonatomic, assign) CGFloat dragOffsetY;

@end

@implementation SCPullRefreshViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.isLoadingMore = NO;
        self.isRefreshing = NO;
        self.hadLoadMore = NO;
        
        self.tableViewInsertTop = 64;
        self.tableViewInsertBottom = 0;
        
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
#ifdef kBubbleAnimation
    
    // bubble animation
    self.tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0}];
    self.refreshView = [[SCBubbleRefreshView alloc] initWithFrame:(CGRect){0, -44, kScreenWidth, 44}];
    self.refreshView.timeOffset = 0.0;
    [self.tableHeaderView addSubview:self.refreshView];
    
    self.tableFooterView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0}];
    self.loadMoreView = [[SCBubbleRefreshView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 44}];
    self.loadMoreView.timeOffset = 0.0;
    [self.tableFooterView addSubview:self.loadMoreView];
    
#else
    
    // circular aniamtion
    self.tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0}];
    self.refreshView = [[KSActivityIndicatorCookieTerminatorAnimation alloc] initWithFrame:(CGRect){0, -44, kScreenWidth, 44}];
    self.refreshView.timeOffset = 0.0;
    [self.tableHeaderView addSubview:self.refreshView];
    
    self.tableFooterView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0}];
    self.loadMoreView = [[KSActivityIndicatorCookieTerminatorAnimation alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 44}];
    self.loadMoreView.timeOffset = 0.0;
    [self.tableFooterView addSubview:self.loadMoreView];
    
#endif
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)dealloc {
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableViewInsertTop, 0, self.tableViewInsertBottom, 0);
    
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // Refresh
    CGFloat offsetY = -scrollView.contentOffsetY - self.tableViewInsertTop  - 25;
    
    self.refreshView.timeOffset = MAX(offsetY / 60.0, 0);
    
    // LoadMore
    if ((self.loadMoreBlock && scrollView.contentSizeHeight > 300) || !self.hadLoadMore) {
        self.loadMoreView.hidden = NO;
    } else {
        self.loadMoreView.hidden = YES;
    }
    
    if (scrollView.contentSizeHeight + scrollView.contentInsetTop < [UIScreen mainScreen].bounds.size.height) {
        return;
    }
    
    CGFloat loadMoreOffset = - (scrollView.contentSizeHeight - self.view.height - scrollView.contentOffsetY + scrollView.contentInsetBottom);
    
    if (loadMoreOffset > 0) {
        self.loadMoreView.timeOffset = MAX(loadMoreOffset / 60.0, 0);
    } else {
        self.loadMoreView.timeOffset = 0;
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.dragOffsetY = scrollView.contentOffsetY;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    // Refresh
    CGFloat refreshOffset = -scrollView.contentOffsetY - scrollView.contentInsetTop;
    if (refreshOffset > 60 && self.refreshBlock && !self.isRefreshing) {
        [self beginRefresh];
    }
    
    // loadMore
    CGFloat loadMoreOffset = scrollView.contentSizeHeight - self.view.height - scrollView.contentOffsetY + scrollView.contentInsetBottom;
    if (loadMoreOffset < -60 && self.loadMoreBlock && !self.isLoadingMore && scrollView.contentSizeHeight > [UIScreen mainScreen].bounds.size.height) {
        [self beginLoadMore];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
}

#pragma mark - Public Methods

- (void)setRefreshBlock:(void (^)())refreshBlock {
    _refreshBlock = refreshBlock;
    
    if (self.tableView) {
        self.tableView.tableHeaderView = self.tableHeaderView;
    }
    
}

- (void)beginRefresh {
    
    if (self.isRefreshing) {
        return;
    }
    
    self.isRefreshing = YES;
    
    [self.refreshView beginRefreshing];
    
    if (self.refreshBlock) {
        self.refreshBlock();
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            self.tableView.contentInsetTop = kRefreshHeight + self.tableViewInsertTop;
            
        } completion:^(BOOL finished){
            
        }];
    });
    
}

- (void)endRefresh {
    
    [self.refreshView endRefreshing];
    
    self.isRefreshing = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.contentInsetTop = self.tableViewInsertTop;
    }];
    
}

- (void)beginLoadMore {
    
    [self.loadMoreView beginRefreshing];
    
    self.isLoadingMore = YES;
    self.hadLoadMore = YES;
    
    if (self.loadMoreBlock) {
        self.loadMoreBlock();
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            self.tableView.contentInsetBottom = kRefreshHeight + self.tableViewInsertBottom;

        } completion:^(BOOL finished){
            
        }];
    });
    
    
}

- (void)endLoadMore {
    
    [self.loadMoreView endRefreshing];
    
    self.isLoadingMore = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.contentInsetBottom =  + self.tableViewInsertBottom;
    }];
    
}

- (void)setLoadMoreBlock:(void (^)())loadMoreBlock {
    _loadMoreBlock = loadMoreBlock;
    
    if (self.loadMoreBlock && self.tableView) {
        self.tableView.tableFooterView = self.tableFooterView;
    }
    
}

@end
