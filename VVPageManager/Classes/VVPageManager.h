//
//  VVManager.h
//  VVPageManager
//
//  Created by Valo on 16/2/24.
//  Copyright © 2016年 valo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VVPage.h"

UIKIT_EXTERN NSNotificationName const VVPageManagerViewDidAppearNotification;
UIKIT_EXTERN NSNotificationName const VVPageManagerViewDidDisappearNotification;

@interface VVPageManager : NSObject

//MARK: 调试信息打印开关
/**
 是否打印调试信息

 @param verbose 是否打印
 */
+ (void)setVerbose:(BOOL)verbose;

//MARK: 设置页面跳转时的额外操作
/**
 *  在viewDidAppear要处理的通用额外操作,比如统计页面是否显示
 *
 *  通常在-application:didFinishLaunchingWithOptions:中设置
 *
 *  @param appearExtraHandler 额外操作
 */

/**
 在viewDidAppear要处理的通用额外操作,例如:统计页面是否显示
 
 通常在-application:didFinishLaunchingWithOptions:中设置

 @param appearExtraHandler 额外操作
 */
+ (void)setAppearExtraHandler:(void (^)(UIViewController *))appearExtraHandler;

/**
 在viewDidDisappear要处理的通用额外操作,例如:统计页面停留时间

 @param disappearExtraHandler 额外操作
 */
+ (void)setDisappearExtraHandler:(void (^)(UIViewController *))disappearExtraHandler;

/**
 重置,清除所有保存的UIViewController,UINavigationController,UITabBarController.
 @attention 仅在某些特殊场景使用,比如重新设置了UIApplication的KeyWindow
 */
+ (void)reset;

//MARK: 获取页面
@property (nonatomic, strong, class, readonly) UIViewController *currentVC;             ///< 当前页面
@property (nonatomic, strong, class, readonly) UIViewController *rootVC;                ///< 第一个页面
@property (nonatomic, strong, class, readonly) UINavigationController *currentNaviVC;   ///< 当前NavigationController
@property (nonatomic, strong, class, readonly) UINavigationController *rootNaviVC;      ///< 第一个NavigationController
@property (nonatomic, strong, class, readonly) UITabBarController *currentTabBarVC;     ///< 当前TabBarController
@property (nonatomic, strong, class, readonly) UITabBarController *rootTabBarVC;        ///< 第一个TabBarController

//MARK: - 页面显示
/**
 根据page设置,进行页面跳转

 @param page 要显示的页面
 @attention 使用此方法显示页面,默认使用当前viewController或当前navigationController
 */
+ (void)showPage:(VVPage *)page;

//MARK: - 其他操作
/**
 不记录某些页面
 
 @param ignoreVCs 不记录的页面列表
 */
+ (void)addIgnoreVCs:(NSArray<NSString *> *)ignoreVCs;

/**
 移除某些VC
 
 在某些场景,移除VC并不会调用`-viewDidDisappear:`,因此需要手动移除缓存中的VC
 
 @param cachedVCs 要移除的VC
 */
+ (void)removeCachedVCs:(NSArray<UIViewController *> *)cachedVCs;

@end
