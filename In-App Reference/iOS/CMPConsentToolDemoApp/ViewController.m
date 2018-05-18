//
//  ViewController.m
//  CMPConsentToolDemoApp
//
//  Copyright © 2018 Smaato. All rights reserved.
//

#import "ViewController.h"
//#import "CMPConsentToolAPI.h"
#import "CMPDataStorageUserDefaults.h"
#import "CMPConsentToolViewController.h"
#import <AppNexusSDK/ANBannerAdView.h>
#import <CoreLocation/CoreLocation.h>
#import <AppNexusSDK/ANLocation.h>
#import <AppNexusSDK/ANLogManager.h>

NSString * const  Consent_ConsentString = @"IABConsent_ConsentString";
NSString * const  Consent_SubjectToGDPR = @"IABConsent_SubjectToGDPR";

@interface ViewController () <CMPConsentToolViewControllerDelegate , ANBannerAdViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *GDPRConsentStringLabel;
@property (weak, nonatomic) IBOutlet ANBannerAdView *bannerAdView;
@property (nonatomic, readwrite, strong) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CMPDataStorageUserDefaults *consentStorageVC = [[CMPDataStorageUserDefaults alloc] init];
    if(consentStorageVC.cmpPresent  && consentStorageVC.consentString.length != 0){
        self.GDPRConsentStringLabel.text = consentStorageVC.consentString;
    }
}

- (IBAction)showGDPRConsentTool:(id)sender {
    CMPConsentToolViewController *consentToolVC = [[CMPConsentToolViewController alloc] init];
    consentToolVC.consentToolURL = [NSURL URLWithString: @"http://acdn.adnxs.com/mobile/democmp/docs/complete.html"];
    consentToolVC.consentToolAPI.subjectToGDPR = SubjectToGDPR_Yes;
    consentToolVC.consentToolAPI.cmpPresent = YES;
    consentToolVC.delegate = self;
    [self presentViewController:consentToolVC animated:YES completion:nil];
}

#pragma mark -
#pragma mark CMPConsentToolViewController delegate
-(void)consentToolViewController:(CMPConsentToolViewController *)consentToolViewController didReceiveConsentString:(NSString *)consentString {
    [consentToolViewController dismissViewControllerAnimated:YES completion:nil];
    
    self.GDPRConsentStringLabel.text = consentString;
    
    NSLog(@"CMPConsentToolViewControllerDelegate - didReceiveConsentString: %@", consentString);
    NSLog(@"IsSubjectToGDPR from CMPDataStorage: %ld", (long)consentToolViewController.consentToolAPI.subjectToGDPR);
    NSLog(@"ConsentString from CMPDataStorage: %@", consentToolViewController.consentToolAPI.consentString);
    NSLog(@"PurposeConsentBitString from CMPDataStorage: %@", consentToolViewController.consentToolAPI.parsedPurposeConsents);
    NSLog(@"VendorConsentBitString from CMPDataStorage: %@", consentToolViewController.consentToolAPI.parsedVendorConsents);
    
    int purposeId = 2;
    BOOL purposeConsent = [consentToolViewController.consentToolAPI isPurposeConsentGivenFor:purposeId];
    NSLog(@"Consent for purpose id %d= %@",purposeId, purposeConsent ? @"YES" : @"NO");
    
    int vendorId = 3;
    BOOL vendorConsent = [consentToolViewController.consentToolAPI isVendorConsentGivenFor:vendorId];
    NSLog(@"Consent for vendor id %d= %@",vendorId, vendorConsent ? @"YES" : @"NO");
}

- (void)consentToolViewController:(CMPConsentToolViewController *)consentToolViewController didReceiveURL:(NSURL *)url{
    
    UIApplication *application = [UIApplication sharedApplication];
    [application openURL:url options:@{} completionHandler:nil];
    
}


#pragma mark - Button's Action

- (IBAction)btLoanAppNexusAdAction:(id)sender {
    [self loadBannerAd];

}
- (IBAction)btLoadPrebidAdAction:(id)sender {

}


#pragma mark - Load Banner Ad Using AppNexus Ads

- (void)loadBannerAd
{
        int adWidth  = 300;
        int adHeight = 250;
        NSString *adID = @"1281482";
        
        // We want to center our ad on the screen.
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat originX = (screenRect.size.width / 2) - (adWidth / 2);
        CGFloat originY = (screenRect.size.height / 2) - (adHeight / 2);
        
        // Needed for when we create our ad view.
        CGRect rect = CGRectMake(originX, originY, adWidth, adHeight);
        CGSize size = CGSizeMake(adWidth, adHeight);
        
        // Make a banner ad view.
        ANBannerAdView *banner = [ANBannerAdView adViewWithFrame:rect placementId:adID adSize:size];
        banner.rootViewController = self;
        banner.delegate = self;
        [self.view addSubview:banner];
        
        // Since this example is for testing, we'll turn on PSAs and verbose logging.
        banner.shouldServePublicServiceAnnouncements = true;
        [ANLogManager setANLogLevel:ANLogLevelDebug];
        
        // Load an ad.
        [banner loadAd];
        
        [self locationSetup]; // If you want to pass location...
        self.bannerAdView = banner;
    }
    
    - (void)locationSetup {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
    }
    
    // We implement the delegate method from the `CLLocationManagerDelegate` protocol.  This allows
    // us to update the banner's location whenever the device's location is updated.
    - (void)locationManager:(CLLocationManager *)manager
didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    self.bannerAdView.location = [ANLocation getLocationWithLatitude:location.coordinate.latitude
                                                     longitude:location.coordinate.longitude
                                                     timestamp:location.timestamp
                                            horizontalAccuracy:location.horizontalAccuracy];
}
    
    - (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
        NSLog(@"Ad did receive ad");
        NSLog(@"Creative Id %@",ad.creativeId);
        
        
    }
    
    
    - (void)adDidClose:(id<ANAdProtocol>)ad {
        NSLog(@"Ad did close");
    }
    
    - (void)adWasClicked:(id<ANAdProtocol>)ad {
        NSLog(@"Ad was clicked");
    }
    
    - (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error {
        NSLog(@"Ad failed to load: %@", error);
    }
    
    - (void)didReceiveMemoryWarning
    {
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
    }
@end
