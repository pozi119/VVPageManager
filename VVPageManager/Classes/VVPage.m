//
//  VVPage.m
//  VVPageManagerDemo
//
//  Created by Valo on 16/2/24.
//  Copyright © 2016年 valo. All rights reserved.
//

#import "VVPage.h"

@implementation VVPage

//MARK: - 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        _alpha = 1.0;
        _soruceInNav = YES;
        _animated = YES;
    }
    return self;
}
//MARK: 链式编程,设置属性

- (VVPage *(^)(VVPageMethod method))vv_method{
    return ^(VVPageMethod method) {
        self.method = method;
        return self;
    };
}

- (VVPage *(^)(UIViewController *controller))vv_controller{
    return ^(UIViewController *controller) {
        self.controller = controller;
        return self;
    };
}

- (VVPage *(^)(NSString *aController))vv_aController{
    return ^(NSString *aController) {
        self.aController = aController;
        return self;
    };
}

- (VVPage *(^)(NSString *aStoryboard))vv_aStoryboard{
    return ^(NSString *aStoryboard) {
        self.aStoryboard = aStoryboard;
        return self;
    };
}

- (VVPage *(^)(NSDictionary *parameters))vv_parameters{
    return ^(NSDictionary *parameters) {
        self.parameters = parameters;
        return self;
    };
}

- (VVPage *(^)(void (^completion)(void)))vv_completion{
    return ^(void (^completion)(void)) {
        self.completion = completion;
        return self;
    };
}

- (VVPage *(^)(BOOL sourceInNavi))vv_sourceInNavi{
    return ^(BOOL sourceInNavi) {
        self.soruceInNav = sourceInNavi;
        return self;
    };
}

- (VVPage *(^)(BOOL destInNavi))vv_destInNavi{
    return ^(BOOL destInNavi) {
        self.destInNav = destInNavi;
        return self;
    };
}

- (VVPage *(^)(CGFloat alpha))vv_alpha{
    return ^(CGFloat alpha) {
        self.alpha = alpha;
        return self;
    };
}

- (VVPage *(^)(BOOL animated))vv_animated{
    return ^(BOOL animated) {
        self.animated = animated;
        return self;
    };
}

- (VVPage *(^)(NSArray *removeVCs))vv_removeVCs{
    return ^(NSArray *removeVCs) {
        self.removeVCs = removeVCs;
        return self;
    };
}

+ (instancetype)makePage:(void(^)(VVPage *page))block{
    VVPage *page = [[VVPage alloc] init];
    if (block) {
        block(page);
    }
    return page;
}

- (VVPage *(^)(BOOL))vv_showBottomBarWhenPushed{
    return ^(BOOL showBottomBarWhenPushed) {
        self.hidesBottomBarWhenPushed = showBottomBarWhenPushed;
        return self;
    };
}

//MARK: - 工厂方法
+ (instancetype)pageWithMethod:(VVPageMethod)method
                   controller:(UIViewController *)controller{
    return [[self class] pageWithMethod:method controller:controller parameters:nil];
}

+ (instancetype)pageWithMethod:(VVPageMethod)method
                   controller:(UIViewController *)controller
                   parameters:(NSDictionary *)parameters{
    VVPage *page = [[VVPage alloc] init];
    page.method = method;
    page.controller = controller;
    page.parameters = parameters;
    return page;
}

+ (instancetype)pageWithMethod:(VVPageMethod)method
                  aStoryboard:(NSString *)aStoryboard
                  aController:(NSString *)aController{
    return [[self class] pageWithMethod:method aStoryboard:aStoryboard aController:aController parameters:nil];
}

+ (instancetype)pageWithMethod:(VVPageMethod)method
                  aStoryboard:(NSString *)aStoryboard
                  aController:(NSString *)aController
                   parameters:(NSDictionary *)parameters{
    VVPage *page = [[VVPage alloc] init];
    page.method = method;
    page.aStoryboard = aStoryboard;
    page.aController = aController;
    page.parameters = parameters;
    return page;
}

//MARK: - 私有方法
- (UIViewController *)controller{
    if (!_controller) {
        _controller = [[self class] viewController:_aController storyboard:_aStoryboard params:_parameters];
    }
    return _controller;
}

+ (UIViewController *)viewController:(NSString *)aController storyboard:(NSString *)aStoryboard params:(NSDictionary *)aParams{
    // 1. 参数检查
    if(!aController || aController.length == 0){
        return nil;
    }
    
    Class clazz = NSClassFromString(aController);
    if(!clazz){
        return nil;
    }
    
    // 2. 创建VC
    UIViewController *viewController = nil;
    if(aStoryboard && aStoryboard.length > 0){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:aStoryboard bundle:nil];
        if (storyboard) {
            viewController = [storyboard instantiateViewControllerWithIdentifier:aController];
        }
    }
    else{
        viewController = [[clazz alloc] initWithNibName:nil bundle:nil];
        if(!viewController){
            viewController = [[clazz alloc] init];
        }
    }
    
    // 3. 设置ViewController参数
    [[self class] setParams:aParams forObject:viewController];
    
    return viewController;
}

+ (void)setParams:(NSDictionary *)params forObject:(NSObject *)obj{
    if (!params || ![params isKindOfClass:[NSDictionary class]]) {
        return;
    }
    for (NSString *key in params.allKeys) {
        id value = params[key];
        if (value && ![value isKindOfClass:[NSNull class]]) {
            NSString *capital = [[key substringToIndex:1] uppercaseString];
            NSString *capitalizedKey  = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:capital];
            SEL sel = NSSelectorFromString([NSString stringWithFormat:@"set%@:",capitalizedKey]);
            if ([obj respondsToSelector:sel]) {
                [obj setValue:value forKey:key];
            }
        }
    }
}


@end
