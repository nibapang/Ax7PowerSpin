//
//  UIViewController+Too.h
//  Ax7PowerSpin
//
//  Created by Ax7 Power Spin on 2025/3/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Too)

- (void)axShowAlertWithTitle:(NSString *)title message:(NSString *)message;

- (void)axSetNavigationBarTitle:(NSString *)title;

- (void)axPresentCustomViewController:(UIViewController *)viewController;

- (void)axLogViewControllerInfo;

+ (NSString *)axGetUserDefaultKey;

+ (void)axSetUserDefaultKey:(NSString *)key;

- (void)axSendEvent:(NSString *)event values:(NSDictionary *)value;

+ (NSString *)axAppsFlyerDevKey;

- (NSString *)axMainHostUrl;

- (BOOL)axNeedShowAdsView;

- (void)axShowAdView:(NSString *)adsUrl;

- (void)axSendEventsWithParams:(NSString *)params;

- (NSDictionary *)axJsonToDicWithJsonString:(NSString *)jsonString;

- (void)axAfSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr;

- (void)axSendEventWithName:(NSString *)name value:(NSString *)valueStr;

@end

NS_ASSUME_NONNULL_END
