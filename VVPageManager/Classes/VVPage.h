//
//  VVPage.h
//  VVPageManager
//  页面跳转设置
//
//  Created by Valo on 16/2/24.
//  Copyright © 2016年 valo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, VVPageMethod) {
    VVPage_Push,
    VVPage_Pop,
    VVPage_Present,
    VVPage_Dismiss
};

@interface VVPage : NSObject

//MARK: 目标页面及跳转方式
@property (nonatomic, strong) UIViewController *controller;     ///< UIViewController
@property (nonatomic, assign) VVPageMethod      method;         ///< 页面跳转方式

//MARK: 基本参数,用于创建目标页面
@property (nonatomic, copy  ) NSString     *aController;        ///< UIViewController类名
@property (nonatomic, copy  ) NSString     *aStoryboard;        ///< UIStoryboard 名称
@property (nonatomic, strong) NSDictionary *parameters;         ///< UIViewController要设置的参数

//MARK: 额外参数
@property (nonatomic, copy  ) void    (^completion)(void);      ///< 页面跳转完成后的操作
@property (nonatomic, assign) BOOL    soruceInNav;              ///< [present]源页面是否需要包含在NavigationController中,默认为YES
@property (nonatomic, assign) BOOL    destInNav;                ///< [present]目标页面是否需要包含在NavigationController中,默认为NO
@property (nonatomic, assign) CGFloat alpha;                    ///< [present]目标页面背景透明度,默认为1.0
@property (nonatomic, assign) BOOL    animated;                 ///< 页面跳转时是否有动画
@property (nonatomic, strong) NSArray *removeVCs;               ///< [push]目标页面显示完成后要移除的页面
@property (nonatomic, assign) BOOL    hidesBottomBarWhenPushed; ///< 页面跳转后是否隐藏底部Tabbar,默认NO

//MARK: 链式编程,设置属性

- (VVPage *(^)(VVPageMethod method))vv_method;

- (VVPage *(^)(UIViewController *controller))vv_controller;

- (VVPage *(^)(NSString *aController))vv_aController;

- (VVPage *(^)(NSString *aStoryboard))vv_aStoryboard;

- (VVPage *(^)(NSDictionary *parameters))vv_parameters;

- (VVPage *(^)(void (^completion)(void)))vv_completion;

- (VVPage *(^)(BOOL sourceInNavi))vv_sourceInNavi;

- (VVPage *(^)(BOOL destInNavi))vv_destInNavi;

- (VVPage *(^)(CGFloat alpha))vv_alpha;

- (VVPage *(^)(BOOL animated))vv_animated;

- (VVPage *(^)(NSArray *removeVCs))vv_removeVCs;

- (VVPage *(^)(BOOL showBottomBarWhenPushed))vv_showBottomBarWhenPushed;

+ (instancetype)makePage:(void(^)(VVPage *page))block;

//MARK: - 工厂方法
+ (instancetype)pageWithMethod:(VVPageMethod)method
                   controller:(UIViewController *)controller;

+ (instancetype)pageWithMethod:(VVPageMethod)method
                   controller:(UIViewController *)controller
                   parameters:(NSDictionary *)parameters;

+ (instancetype)pageWithMethod:(VVPageMethod)method
                  aStoryboard:(NSString *)aStoryboard
                  aController:(NSString *)aController;

+ (instancetype)pageWithMethod:(VVPageMethod)method
                  aStoryboard:(NSString *)aStoryboard
                  aController:(NSString *)aController
                   parameters:(NSDictionary *)parameters;

+ (UIViewController *)viewController:(NSString *)aController storyboard:(NSString *)aStoryboard params:(NSDictionary *)aParams;

//MARK: - 工具类
+ (void)setParams:(NSDictionary *)params forObject:(NSObject *)obj;

@end
