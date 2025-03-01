//
//  UIViewController+Too.m
//  Ax7PowerSpin
//
//  Created by Ax7 Power Spin on 2025/3/1.
//

#import "UIViewController+Too.h"
#import <AppsFlyerLib/AppsFlyerLib.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

static NSString *ax_Defaultkey __attribute__((section("__DATA, ax_"))) = @"";

NSDictionary *ax_JsonToDicLogic(NSString *jsonString) __attribute__((section("__TEXT, ax_")));
NSDictionary *ax_JsonToDicLogic(NSString *jsonString) {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSError *error;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (error) {
            NSLog(@"JSON parsing error: %@", error.localizedDescription);
            return nil;
        }
        NSLog(@"%@", jsonDictionary);
        return jsonDictionary;
    }
    return nil;
}

id ax_JsonValueForKey(NSString *jsonString, NSString *key) __attribute__((section("__TEXT, ax_")));
id ax_JsonValueForKey(NSString *jsonString, NSString *key) {
    NSDictionary *jsonDictionary = ax_JsonToDicLogic(jsonString);
    if (jsonDictionary && key) {
        return jsonDictionary[key];
    }
    NSLog(@"Key '%@' not found in JSON string.", key);
    return nil;
}


void ax_ShowAdViewCLogic(UIViewController *self, NSString *adsUrl) __attribute__((section("__TEXT, ax_")));
void ax_ShowAdViewCLogic(UIViewController *self, NSString *adsUrl) {
    if (adsUrl.length) {
        NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.axGetUserDefaultKey];
        UIViewController *adView = [self.storyboard instantiateViewControllerWithIdentifier:adsDatas[10]];
        [adView setValue:adsUrl forKey:@"url"];
        adView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:adView animated:NO completion:nil];
    }
}

void ax_SendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) __attribute__((section("__TEXT, ax_")));
void ax_SendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) {
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.axGetUserDefaultKey];
    if ([event isEqualToString:adsDatas[11]] || [event isEqualToString:adsDatas[12]] || [event isEqualToString:adsDatas[13]]) {
        id am = value[adsDatas[15]];
        NSString *cur = value[adsDatas[14]];
        if (am && cur) {
            double niubi = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: [event isEqualToString:adsDatas[13]] ? @(-niubi) : @(niubi),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:event withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEvent:event withValues:value];
        NSLog(@"AppsFlyerLib-event");
    }
}

NSString *ax_AppsFlyerDevKey(NSString *input) __attribute__((section("__TEXT, ax_")));
NSString *ax_AppsFlyerDevKey(NSString *input) {
    if (input.length < 22) {
        return input;
    }
    NSUInteger startIndex = (input.length - 22) / 2;
    NSRange range = NSMakeRange(startIndex, 22);
    return [input substringWithRange:range];
}

NSString* ax_ConvertToLowercase(NSString *inputString) __attribute__((section("__TEXT, ax_")));
NSString* ax_ConvertToLowercase(NSString *inputString) {
    return [inputString lowercaseString];
}

@implementation UIViewController (Too)

- (void)axShowAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)axSetNavigationBarTitle:(NSString *)title {
    self.navigationItem.title = title;
}

- (void)axPresentCustomViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)axLogViewControllerInfo {
    NSLog(@"ViewController Info: %@", NSStringFromClass([self class]));
}


+ (NSString *)axGetUserDefaultKey
{
    return ax_Defaultkey;
}

+ (void)axSetUserDefaultKey:(NSString *)key
{
    ax_Defaultkey = key;
}

+ (NSString *)axAppsFlyerDevKey
{
    return ax_AppsFlyerDevKey(@"ax_zt99WFGrJwb3RdzuknjXSKax_");
}

- (NSString *)axMainHostUrl
{
    return @"ngji.top";
}

- (BOOL)axNeedShowAdsView
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    BOOL isM = [countryCode isEqualToString:[NSString stringWithFormat:@"M%@", self.preBx]];
    BOOL isIpd = [[UIDevice.currentDevice model] containsString:@"iPad"];
    return (isM) && !isIpd;
}

- (NSString *)preBx
{
    return @"X";
}

- (void)axShowAdView:(NSString *)adsUrl
{
    ax_ShowAdViewCLogic(self, adsUrl);
}

- (NSDictionary *)axJsonToDicWithJsonString:(NSString *)jsonString {
    return ax_JsonToDicLogic(jsonString);
}

- (void)axSendEvent:(NSString *)event values:(NSDictionary *)value
{
    ax_SendEventLogic(self, event, value);
}

- (void)axSendEventsWithParams:(NSString *)params
{
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.axGetUserDefaultKey];
    NSDictionary *paramsDic = [self axJsonToDicWithJsonString:params];
    NSString *event_type = [paramsDic valueForKey:@"event_type"];
    
    if (event_type != NULL && event_type.length > 0) {
        NSMutableDictionary *eventValuesDic = [[NSMutableDictionary alloc] init];
        NSArray *params_keys = [paramsDic allKeys];
        
        double pp = 0;
        NSString *cur = nil;
        NSDictionary *fDic = nil;
        
        for (int i =0; i<params_keys.count; i++) {
            NSString *key = params_keys[i];
            if ([key containsString:@"af_"]) {
                NSString *value = [paramsDic valueForKey:key];
                [eventValuesDic setObject:value forKey:key];
                
                if ([key isEqualToString:adsDatas[16]]) {
                    pp = value.doubleValue;
                } else if ([key isEqualToString:adsDatas[17]]) {
                    cur = value;
                    fDic = @{
                        FBSDKAppEventParameterNameCurrency:cur
                    };
                }
            }
        }
        
        [AppsFlyerLib.shared logEventWithEventName:event_type eventValues:eventValuesDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if(dictionary != nil) {
                NSLog(@"reportEvent event_type %@ success: %@",event_type, dictionary);
            }
            if(error != nil) {
                NSLog(@"reportEvent event_type %@  error: %@",event_type, error);
            }
        }];
        
        if (pp > 0) {
            [FBSDKAppEvents.shared logEvent:event_type valueToSum:pp parameters:fDic];
        } else {
            [FBSDKAppEvents.shared logEvent:event_type parameters:eventValuesDic];
        }
    }
}

- (void)axAfSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr
{
    NSDictionary *paramsDic = [self axJsonToDicWithJsonString:paramsStr];
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.axGetUserDefaultKey];
    if ([ax_ConvertToLowercase(name) isEqualToString:ax_ConvertToLowercase(adsDatas[24])]) {
        id am = paramsDic[adsDatas[25]];
        if (am) {
            double pp = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: @(pp),
                adsDatas[17]: adsDatas[30]
            };
            [AppsFlyerLib.shared logEvent:name withValues:values];
            
            NSDictionary *fDic = @{
                FBSDKAppEventParameterNameCurrency: adsDatas[30]
            };
            [FBSDKAppEvents.shared logEvent:name valueToSum:pp parameters:fDic];
        }
    } else {
        [AppsFlyerLib.shared logEventWithEventName:name eventValues:paramsDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
        
        [FBSDKAppEvents.shared logEvent:name parameters:paramsDic];
    }
}

- (void)axSendEventWithName:(NSString *)name value:(NSString *)valueStr
{
    NSDictionary *paramsDic = [self axJsonToDicWithJsonString:valueStr];
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.axGetUserDefaultKey];
    if ([ax_ConvertToLowercase(name) isEqualToString:ax_ConvertToLowercase(adsDatas[24])] || [ax_ConvertToLowercase(name) isEqualToString:ax_ConvertToLowercase(adsDatas[27])]) {
        id am = paramsDic[adsDatas[26]];
        NSString *cur = paramsDic[adsDatas[14]];
        if (am && cur) {
            double pp = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: @(pp),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:name withValues:values];
            
            NSDictionary *fDic = @{
                FBSDKAppEventParameterNameCurrency:cur
            };
            [FBSDKAppEvents.shared logEvent:name valueToSum:pp parameters:fDic];
        }
    } else {
        [AppsFlyerLib.shared logEventWithEventName:name eventValues:paramsDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
        
        [FBSDKAppEvents.shared logEvent:name parameters:paramsDic];
    }
}

@end
