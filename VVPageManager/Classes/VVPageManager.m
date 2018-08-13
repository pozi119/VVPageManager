//
//  VVManager.m
//  VVPageManagerDemo
//
//  Created by Valo on 16/2/24.
//  Copyright © 2016年 valo. All rights reserved.
//

#import "VVPageManager.h"
#import <objc/runtime.h>

NSNotificationName const VVPageManagerViewDidAppearNotification = @"VVPageManagerViewDidAppearNotification";
NSNotificationName const VVPageManagerViewDidDisappearNotification = @"VVPageManagerViewDidDisappearNotification";

BOOL method_swizzle(Class cls, SEL origSel, SEL altSel){
    if (!cls) return NO;
    Method origMethod = class_getInstanceMethod(cls, origSel);
    Method altMethod = class_getInstanceMethod(cls, altSel);
    if (!origMethod || !altMethod)  return NO;
    method_exchangeImplementations(origMethod, altMethod);
    return YES;
}

@interface UIViewController (VVPageManager)
// 开始记录ViewController的跳转
+ (void)record;

// 停止记录ViewController的跳转
+ (void)undoRecord;

@end

@interface VVPageManager ()
@property (nonatomic, assign) BOOL  verbose;             ///< 打印页面切换信息
@property (nonatomic, strong) NSMutableSet *ignoreVCs;   ///< 要忽略的页面类型
@property (nonatomic, strong) NSMutableArray *vcs;       ///< 已加载的UIViewController.不包含ignoreVCs,UINavigationController,UITabBarController
@property (nonatomic, strong) NSMutableArray *naviVCs;   ///< 已加载的UINavigationController
@property (nonatomic, strong) NSMutableArray *tabbarVCs; ///< 已加载的UITabBarController
@property (nonatomic, copy  ) void (^appearExtraHandler)(UIViewController *);
@property (nonatomic, copy  ) void (^disappearExtraHandler)(UIViewController *);
@end

@implementation VVPageManager

//MARK: - 管理器,单例
+ (instancetype)shared{
    static VVPageManager *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[VVPageManager alloc] init];
    });
    return _shared;
}

//MARK: - 初始化
+ (void)load{
    [[VVPageManager shared] begin];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _vcs = [NSMutableArray arrayWithCapacity:0];
        _naviVCs = [NSMutableArray arrayWithCapacity:0];
        _tabbarVCs = [NSMutableArray arrayWithCapacity:0];
        _ignoreVCs = [NSMutableSet setWithArray:@[@"UIInputWindowController",
                                                  @"UICompatibilityInputViewController",
                                                  @"UIKeyboardCandidateGridCollectionViewController",
                                                  @"UIInputViewController",
                                                  @"UIApplicationRotationFollowingControllerNoTouches",
                                                  @"_UIRemoteInputViewController",
                                                  @"PLUICameraViewController"]];
    }
    return self;
}

- (void)begin{
    [UIViewController record];
}

//MARK: - 获取页面
+ (UIViewController *)currentVC {
    return [VVPageManager shared].vcs.count > 0 ? [VVPageManager shared].vcs.lastObject : nil;
}

+ (UIViewController *)rootVC {
    return [VVPageManager shared].vcs.count > 0 ? [VVPageManager shared].vcs.firstObject : nil;
}

+ (UINavigationController *)currentNaviVC {
    return [VVPageManager shared].naviVCs.count > 0 ? [VVPageManager shared].naviVCs.lastObject : nil;
}

+ (UINavigationController *)rootNaviVC {
    return [VVPageManager shared].naviVCs.count > 0 ? [VVPageManager shared].naviVCs.firstObject : nil;
}

+ (UITabBarController *)currentTabBarVC {
    return [VVPageManager shared].tabbarVCs.count > 0 ? [VVPageManager shared].tabbarVCs.lastObject : nil;
}

+ (UITabBarController *)rootTabBarVC {
    return [VVPageManager shared].tabbarVCs.count > 0 ? [VVPageManager shared].tabbarVCs.firstObject : nil;
}

+ (void)addIgnoreVCs:(NSArray<NSString *> *)ignoreVCs{
    [[VVPageManager shared].ignoreVCs addObjectsFromArray:ignoreVCs];
}

+ (void)removeCachedVCs:(NSArray<UIViewController *> *)cachedVCs{
    [[VVPageManager shared].vcs removeObjectsInArray:cachedVCs];
    [[VVPageManager shared].naviVCs removeObjectsInArray:cachedVCs];
    [[VVPageManager shared].tabbarVCs removeObjectsInArray:cachedVCs];
}

//MARK: - UIViewController+VVRecord使用
- (void)didAppearViewController:(UIViewController *)viewController{
    NSString *vcStr = NSStringFromClass([viewController class]);
    if ([_ignoreVCs containsObject:vcStr]) { return;}
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        [_naviVCs addObject:viewController];
    }
    else if ([viewController isKindOfClass:[UITabBarController class]]) {
        [_tabbarVCs addObject:viewController];
    }
    else if ([viewController isKindOfClass:[UIViewController class]]) {
        [_vcs addObject:viewController];
    }
    
    [self printPathWithTag:@"Appear   " controller:viewController];
    !_appearExtraHandler ? : _appearExtraHandler(viewController);
    [[NSNotificationCenter defaultCenter] postNotificationName:VVPageManagerViewDidAppearNotification object:viewController];
}

- (void)didDisappearViewController:(UIViewController *)viewController{
    NSString *vcStr = NSStringFromClass([viewController class]);
    if ([_ignoreVCs containsObject:vcStr]) { return;}
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        [_naviVCs removeObject:viewController];
    }
    else if ([viewController isKindOfClass:[UITabBarController class]]) {
        [_tabbarVCs removeObject:viewController];
    }
    else if ([viewController isKindOfClass:[UIViewController class]]) {
        [_vcs removeObject:viewController];
    }

    [self printPathWithTag:@"Disappear" controller:viewController];
    !_disappearExtraHandler ? : _disappearExtraHandler(viewController);
    [[NSNotificationCenter defaultCenter] postNotificationName:VVPageManagerViewDidDisappearNotification object:viewController];
}

//MARK: - 打印信息
+ (void)setVerbose:(BOOL)verbose{
    [VVPageManager shared].verbose = verbose;
}

- (void)printPathWithTag:(NSString *)tag controller:(UIViewController *)controller{
    if(_verbose){
        NSLog(@"%@:-->(Tab<%@>|Nav<%@>|Vc<%@>) %@", tag,@(_tabbarVCs.count),@(_naviVCs.count), @(_vcs.count), controller.description);
    }
}

//MARK: - 设置页面跳转时的额外操作
+ (void)setAppearExtraHandler:(void (^)(UIViewController *))appearExtraHandler{
    [VVPageManager shared].appearExtraHandler = appearExtraHandler;
}

+ (void)setDisappearExtraHandler:(void (^)(UIViewController *))disappearExtraHandler{
    [VVPageManager shared].disappearExtraHandler = disappearExtraHandler;
}

+ (void)reset{
    [[VVPageManager shared].vcs removeAllObjects];
    [[VVPageManager shared].naviVCs removeAllObjects];
    [[VVPageManager shared].tabbarVCs removeAllObjects];
}

//MARK: - 页面跳转
+ (void)pushPage:(VVPage *)page{
    if (!page.controller) {
        return;
    }
    page.controller.hidesBottomBarWhenPushed = page.hidesBottomBarWhenPushed;
    UINavigationController *nav = VVPageManager.currentNaviVC;
    [nav pushViewController:page.controller animated:page.animated];
    if (page.removeVCs.count > 0) {
        // 1. 延迟1s之后再移除指定页面,防止连续快速push时,移除了要显示的页面.
        //FIXME: 若页面跳转动画时间过长,请单独处理移除页面的操作.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSMutableArray *existVCs = nav.viewControllers.mutableCopy;
            __block NSMutableArray *willRemoveVCs = @[].mutableCopy;
            [existVCs enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
                NSString *vcName = NSStringFromClass([vc class]);
                for (NSString *rvc in page.removeVCs) {
                    if ([rvc isEqualToString:vcName]) {
                        [willRemoveVCs addObject:vc];
                        break;
                    }
                }
            }];
            [existVCs removeObjectsInArray:willRemoveVCs];
            [nav setViewControllers:existVCs animated:YES];
            [self removeCachedVCs:willRemoveVCs];
        });
    }
}

+ (void)popPage:(VVPage *)page{
    if (!page.controller) {
        [VVPageManager.currentNaviVC popViewControllerAnimated:page.animated];
    }
    else{
        UINavigationController *nav = VVPageManager.currentNaviVC;
        NSArray *existVCs = nav.viewControllers;
        UIViewController *destVC = nil;
        for (UIViewController *vc in existVCs) {
            NSString *vcName = NSStringFromClass([vc class]);
            NSString *pageName = NSStringFromClass([page.controller class]);
            if ([vcName isEqualToString:pageName]) {
                destVC = vc;
            }
        }
        if (destVC) {
            [VVPage setParams:page.parameters forObject:destVC];
            [nav popToViewController:destVC animated:page.animated];
        }
        else{
            [VVPageManager pushPage:page];
        }
    }
}

+ (void)presentPage:(VVPage *)page{
    if (!page.controller) {
        return;
    }
    UIViewController *sourceVC = VVPageManager.currentVC;
    UINavigationController *nav = VVPageManager.currentNaviVC;
    if (page.soruceInNav && nav != nil) {
        sourceVC = nav;
    }
    UIViewController *destVC = page.controller;
    if (page.destInNav) {
        if (destVC.navigationController) {
            destVC = destVC.navigationController;
        }
        else{
            destVC = [[UINavigationController alloc] initWithRootViewController:destVC];
        }
    }
    if (page.alpha < 1.0 && page.alpha >= 0.0) {
        destVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        UIColor *color = page.controller.view.backgroundColor;
        color = [color colorWithAlphaComponent:page.alpha];
        page.controller.view.backgroundColor = color;
    }
    [VVPage setParams:page.parameters forObject:destVC];
    [sourceVC presentViewController:destVC animated:page.animated completion:page.completion];
}

+ (void)dismissPage:(VVPage *)page{
    [VVPageManager.currentVC dismissViewControllerAnimated:page.animated completion:page.completion];
}

+ (void)showPage:(VVPage *)page{
    switch (page.method) {
        case VVPage_Push:{
            [self pushPage:page];
            break;
        }
        case VVPage_Pop:{
            [self popPage:page];
            break;
        }
        case VVPage_Present:{
            [self presentPage:page];
            break;
        }
        case VVPage_Dismiss: {
            [self dismissPage:page];
            break;
        }
    }
}

@end


@implementation UIViewController (VVPageManager)

static BOOL _isRecording;

//MARK: - 替代方法

-(void)recordViewDidAppear:(BOOL)animated{
    [[VVPageManager shared] didAppearViewController:self];
    [self recordViewDidAppear:animated];
}

-(void)recordViewDidDisappear:(BOOL)animated{
    [[VVPageManager shared] didDisappearViewController:self];
    [self recordViewDidDisappear:animated];
}

//MARK: - 方法替代
+ (void)record{
    if (_isRecording) return;
    method_swizzle(self, @selector(viewDidAppear:), @selector(recordViewDidAppear:));
    method_swizzle(self, @selector(viewDidDisappear:), @selector(recordViewDidDisappear:));
    _isRecording = YES;
}

+ (void)undoRecord{
    if (!_isRecording) return;
    method_swizzle(self, @selector(recordViewDidAppear:), @selector(viewDidAppear:));
    method_swizzle(self, @selector(recordViewDidDisappear:), @selector(viewDidDisappear:));
    _isRecording = NO;
}

@end
