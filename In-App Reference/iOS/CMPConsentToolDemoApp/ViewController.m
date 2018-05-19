//
//  ViewController.m
//  CMPConsentToolDemoApp
//
//  Copyright © 2018 Smaato. All rights reserved.
//

#import "ViewController.h"
#import "CMPDataStorageUserDefaults.h"
#import "CMPConsentToolViewController.h"
#import <AppNexusSDK/ANBannerAdView.h>
#import <CoreLocation/CoreLocation.h>
#import <AppNexusSDK/ANLocation.h>
#import <AppNexusSDK/ANLogManager.h>
#import "CMPConsentGlobal.h"
#import <PrebidMobile/PrebidMobile.h>
#import "MPAdView.h"
#import <MoPub.h>
#import <GoogleMobileAds/DFPBannerView.h>



NSString * const  Consent_ConsentString = @"IABConsent_ConsentString";
NSString * const  Consent_SubjectToGDPR = @"IABConsent_SubjectToGDPR";

@interface ViewController () <CMPConsentToolViewControllerDelegate , ANBannerAdViewDelegate, CLLocationManagerDelegate , GADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *GDPRConsentStringLabel;
@property (weak, nonatomic) IBOutlet UIView *adView;
@property (nonatomic, readwrite, strong) CLLocationManager *locationManager;

// AppNexus SDK
@property (weak, nonatomic) IBOutlet ANBannerAdView *bannerAdView;
// PreBidSDK
@property (strong, nonatomic) UIView *adContainerView;
@property (strong, nonatomic) MPAdView *mopubAdView;
@property (strong, nonatomic) DFPBannerView *dfpAdView;


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
    consentToolVC.consentToolURL = [NSURL URLWithString:CMP_URL];
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
    if (@available(iOS 10.0, *)) {
        [application openURL:url options:@{} completionHandler:nil];
    } else {
        // Fallback on earlier versions
        [[UIApplication sharedApplication] openURL:url];
        
    }
}


#pragma mark - Button's Action

- (IBAction)btLoanAppNexusAdAction:(id)sender {
    [self loadAppNexusBannerAd];
    
}
- (IBAction)btLoadPrebidAdAction:(id)sender {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select Ad" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"DFP" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // DFP button tapped.
        [self loadPreBidDFPBannerAd];

    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"MoPub" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // MoPub button tapped.
        [self loadPreBidMoPubBannerAd];

        
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
    
}


#pragma mark - Load Banner Ad Using AppNexus Ads

- (void)loadAppNexusBannerAd
{
    
    [self clearAdView];
    int adWidth  = 300;
    int adHeight = 250;
    NSString *adID = @"1281482";
    
    // We want to center our ad on the screen.
    CGFloat originX = (self.adView.frame.size.width / 2) - (adWidth / 2);
    
    // Needed for when we create our ad view.
    CGRect rect = CGRectMake(originX, 0, adWidth, adHeight);
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
    [self.adView addSubview:self.bannerAdView];

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

#pragma mark - Load Banner Ad Using PreBid Ads
- (void)loadPreBidDFPBannerAd
{
    [self clearAdView];
    int adWidth  = 300;
    int adHeight = 250;

    _dfpAdView = [[DFPBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(adWidth, adHeight))];
    _dfpAdView.adUnitID = @"/19968336/PriceCheck_300x250";
    _dfpAdView.rootViewController = self;
    _dfpAdView.delegate = self;
    
    [_adContainerView addSubview:_dfpAdView];
    [self.adView addSubview:_adContainerView];

    [PrebidMobile setBidKeywordsOnAdObject:self.dfpAdView withAdUnitId:@"BannerScreen" withTimeout:600 completionHandler:^{
        [_dfpAdView loadRequest:[DFPRequest request]];
        
    }];
    
    
    
}

- (void)loadPreBidMoPubBannerAd
{
    
    [self clearAdView];
    int adWidth  = 300;
    int adHeight = 250;
    
    // We want to center our ad on the screen.
    CGFloat originX = (self.adView.frame.size.width / 2) - (adWidth / 2);
    
    // Needed for when we create our ad view.
    CGRect rect = CGRectMake(originX, 0, adWidth, adHeight);
    
    
    _adContainerView = [[UIView alloc] initWithFrame:rect];
    [self.adView addSubview:_adContainerView];
    
    
    _mopubAdView = [[MPAdView alloc] initWithAdUnitId:@"bd0a2cd5dd2241aaac18d7823d8e3a6f"
                                                 size:CGSizeMake(adWidth, adHeight)];
    [_adContainerView addSubview:_mopubAdView];
    
    
    [PrebidMobile setBidKeywordsOnAdObject:self.mopubAdView withAdUnitId:@"BannerScreen" withTimeout:600 completionHandler:^{
        [self.mopubAdView loadAd];
    }];
    
    
}

#pragma mark - Clear Ads

- (void)clearAdView{
    [self.bannerAdView removeFromSuperview];
    [self.adContainerView removeFromSuperview];
}

#pragma mark - GADBannerViewDelegate methods

- (void)adViewDidReceiveAd:(DFPBannerView *)view {
    NSLog(@"DFP: %@", NSStringFromSelector(_cmd));
}

- (void)adView:(DFPBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"DFP: %@", NSStringFromSelector(_cmd));
}

@end
