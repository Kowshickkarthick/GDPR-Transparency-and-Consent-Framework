//
//  AppDelegate.m
//  CMPConsentToolDemoApp
//
//  Copyright © 2018 Smaato. All rights reserved.
//

#import "AppDelegate.h"
#import <PrebidMobile/PrebidMobile.h>
#import <PrebidMobile/PBLogManager.h>
#import <PrebidMobile/PBBannerAdUnit.h>
#import <PrebidMobile/PBInterstitialAdUnit.h>
#import <PrebidMobile/PBTargetingParams.h>
#import <PrebidMobile/PBLogging.h>
#import <PrebidMobile/PBException.h>
#import <PrebidMobile/PBException.h>
#import <PrebidMobile/PBBannerAdUnit.h>
#import "MPAdView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self enablePrebidLogs];
    [self setupPrebidAndRegisterAdUnits];
    
    return YES;
}
- (void)enablePrebidLogs {
    [PBLogManager setPBLogLevel:PBLogLevelAll];
}

- (BOOL)setupPrebidAndRegisterAdUnits {
    @try {
        // Prebid Mobile setup!
        [self setupPrebidLocationManager];
        
        PBBannerAdUnit *__nullable adUnit1 = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"BannerScreen" andConfigId:@"625c6125-f19e-4d5b-95c5-55501526b2a4"];
        [adUnit1 addSize:CGSizeMake(320, 50)];
        [self setPrebidTargetingParams];
        [PrebidMobile registerAdUnits:@[adUnit1] withAccountId:@"bfa84af2-bd16-4d35-96ad-31c6bb888df0" withHost:PBServerHostAppNexus andPrimaryAdServer:PBPrimaryAdServerMoPub];
    } @catch (PBException *ex) {
        NSLog(@"%@",[ex reason]);
    } @finally {
        return YES;
    }
}

- (void)setupPrebidLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)setPrebidTargetingParams {
    [[PBTargetingParams sharedInstance] setAge:25];
    [[PBTargetingParams sharedInstance] setGender:PBTargetingParamsGenderFemale];
 }

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
