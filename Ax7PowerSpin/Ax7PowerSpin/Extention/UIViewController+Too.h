//
//  UIViewController+Too.h
//  Ax7PowerSpin
//
//  Created by Ax7 Power Spin on 2025/3/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Too)

+ (NSString *)axGetUserDefaultKey;

+ (void)axSetUserDefaultKey:(NSString *)key;

- (void)axSendEvent:(NSString *)event values:(NSDictionary *)value;

+ (NSString *)axAppsFlyerDevKey;

- (NSString *)axMainHostUrl;

- (BOOL)axNeedShowAdsView;

- (void)axShowAdView:(NSString *)adsUrl;

- (NSDictionary *)axJsonToDicWithJsonString:(NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
