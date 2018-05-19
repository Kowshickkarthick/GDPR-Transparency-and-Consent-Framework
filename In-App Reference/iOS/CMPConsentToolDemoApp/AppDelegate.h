//
//  AppDelegate.h
//  CMPConsentToolDemoApp
//
//  Copyright © 2018 Smaato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate , CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readwrite) CLLocationManager *locationManager;


@end

