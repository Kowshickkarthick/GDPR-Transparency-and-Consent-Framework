package com.appnexus.opensdk.cmpdemo;

import android.content.DialogInterface;
import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.appnexus.opensdk.ANGDPRSettings;
import com.appnexus.opensdk.AdListener;
import com.appnexus.opensdk.AdView;
import com.appnexus.opensdk.BannerAdView;
import com.appnexus.opensdk.ResultCode;
import com.appnexus.opensdk.cmpdemo.cmpconsenttool.CMPConsentToolActivity;
import com.appnexus.opensdk.cmpdemo.cmpconsenttool.callbacks.OnCloseCallback;
import com.appnexus.opensdk.cmpdemo.cmpconsenttool.model.CMPSettings;
import com.appnexus.opensdk.cmpdemo.cmpconsenttool.model.SubjectToGdpr;
import com.appnexus.opensdk.cmpdemo.cmpconsenttool.storage.CMPStorage;
import com.appnexus.opensdk.utils.Clog;
import com.google.android.gms.ads.doubleclick.PublisherAdRequest;
import com.google.android.gms.ads.doubleclick.PublisherAdView;

import org.prebid.mobile.core.AdUnit;
import org.prebid.mobile.core.BannerAdUnit;
import org.prebid.mobile.core.Prebid;
import org.prebid.mobile.core.PrebidException;
import com.google.android.gms.ads.AdSize;
import com.mopub.mobileads.MoPubErrorCode;
import com.mopub.mobileads.MoPubView;


import java.util.ArrayList;

public class MainActivity extends AppCompatActivity implements Prebid.OnAttachCompleteListener , MoPubView.BannerAdListener {

    private TextView gdprInfoTextView;
    private FrameLayout adContainerLayout;
    PublisherAdView dfpAdView;
    private MoPubView moPubAdView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ArrayList<AdUnit> adUnits = new ArrayList<AdUnit>();

        // Configure a Banner Ad Unit with size 320x50
        BannerAdUnit adUnit1 = new BannerAdUnit("BannerScreen", "625c6125-f19e-4d5b-95c5-55501526b2a4");
        adUnit1.addSize(320, 50);

        // Configure an Interstitial Ad Unit

        // Add them to the list
        adUnits.add(adUnit1);

        // Register ad units for prebid.
        try {
            Prebid.init(getApplicationContext(), adUnits, "bfa84af2-bd16-4d35-96ad-31c6bb888df0", Prebid.AdServer.MOPUB, Prebid.Host.APPNEXUS);
        } catch (PrebidException e) {
            e.printStackTrace();
        }



        Button gdprButton = findViewById(R.id.gdpr_button);
        Button appnexusButton = findViewById(R.id.loadAppnexusAd_button);
        Button prebidButton = findViewById(R.id.loadPrebid_button);
        gdprInfoTextView = findViewById(R.id.consentStringTV);
        adContainerLayout = findViewById(R.id.adContainer);


        gdprButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                adContainerLayout.removeAllViews();
                showCMP();
            }
        });


        appnexusButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                loadAppNexusAd();
            }
        });


        prebidButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                loadPrebidAd();
            }
        });

    }

    private void loadPrebidAd() {
        adContainerLayout.removeAllViews();

        AlertDialog.Builder builder1 = new AlertDialog.Builder(this);
        builder1.setMessage("Select Ad.");
        builder1.setCancelable(true);

        builder1.setNegativeButton(
                "DFP",
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        loadPreBidDFPBannerAd();
                        dialog.cancel();
                    }
                });

        builder1.setPositiveButton(
                "MoPub",
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        loadPreBidMoPubBannerAd();
                        dialog.cancel();

                    }
                });

        AlertDialog alert11 = builder1.create();
        alert11.show();
    }

    private void loadPreBidDFPBannerAd() {
            setupBannerWithWait(500);

    }

    private void setupBannerWithWait(final int waitTime) {

        dfpAdView = new PublisherAdView(this);
        dfpAdView.setAdUnitId("/19968336/PriceCheck_300x250");
        dfpAdView.setAdSizes(new AdSize(300, 250));
//        dfpAdView2.setAdListener(adListener);
        adContainerLayout.addView(dfpAdView);
        //region PriceCheckForDFP API usage
        PublisherAdRequest.Builder builder = new PublisherAdRequest.Builder();
        PublisherAdRequest request = builder.build();
        Prebid.attachBidsWhenReady(request, "BannerScreen", this, waitTime, this);
        //endregion

    }

    private void loadPreBidMoPubBannerAd() {
         setupMoPubBannerWithWait(500);
    }


    private void setupMoPubBannerWithWait(final int waitTime) {
        moPubAdView = new MoPubView(this);
        moPubAdView.setAdUnitId("a9cb8ff85fef4b50b457e3b11119aabf");
        moPubAdView.setBannerAdListener(this);
        moPubAdView.setAutorefreshEnabled(true);
        moPubAdView.setMinimumWidth(300);
        moPubAdView.setMinimumHeight(50);
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.gravity = Gravity.CENTER;
        moPubAdView.setLayoutParams(lp);
        adContainerLayout.addView(moPubAdView);
        //region Prebid API usage
        Prebid.attachBidsWhenReady(moPubAdView, "BannerScreen", this, waitTime, this);
        //endregion

    }

    private void loadAppNexusAd() {

        adContainerLayout.removeAllViews();

        final BannerAdView bav = new BannerAdView(this);

        // This is your AppNexus placement ID.
        bav.setPlacementID("1281482");

        // Turning this on so we always get an ad during testing.
        bav.setShouldServePSAs(true);

        // By default ad clicks open in an in-app WebView.
        bav.setOpensNativeBrowser(true);

        // Get a 300x50 ad.
        bav.setAdSize(300, 250);

        // Resizes the container size to fit the banner ad
        bav.setResizeAdToFitContainer(true);

        // Set up a listener on this ad view that logs events.
        AdListener adListener = new AdListener() {
            @Override
            public void onAdRequestFailed(AdView bav, ResultCode errorCode) {
                if (errorCode == null) {
                    Clog.v("SIMPLEBANNER", "Call to loadAd failed");
                } else {
                    Clog.v("SIMPLEBANNER", "Ad request failed: " + errorCode);
                }
            }

            @Override
            public void onAdLoaded(AdView bav) {
                Clog.v("SIMPLEBANNER", "The Ad Loaded!");
            }

            @Override
            public void onAdExpanded(AdView bav) {
                Clog.v("SIMPLEBANNER", "Ad expanded");
            }

            @Override
            public void onAdCollapsed(AdView bav) {
                Clog.v("SIMPLEBANNER", "Ad collapsed");
            }

            @Override
            public void onAdClicked(AdView bav) {
                Clog.v("SIMPLEBANNER", "Ad clicked; opening browser");
            }
        };

        bav.setAdListener(adListener);


        // NOTE even if this is not set AppNexus SDK will automatically read the values from the Shared Preferences.
        ANGDPRSettings.setConsentRequired(this,CMPStorage.getSubjectToGdpr(this)==SubjectToGdpr.CMPGDPREnabled?true:false);
        ANGDPRSettings.setConsentString(this,CMPStorage.getConsentString(this));

        // Just attaching Banner to an adview will automatically trigger loadAd()
        adContainerLayout.addView(bav);

    }


    public void showCMP(){
        CMPStorage.setCmpPresentValue(MainActivity.this, true);
        CMPSettings cmpSettings = new CMPSettings(SubjectToGdpr.CMPGDPREnabled, "https://acdn.adnxs.com/mobile/democmp/docs/complete.html", null);

        CMPConsentToolActivity.openCmpConsentToolView(cmpSettings, MainActivity.this, new OnCloseCallback() {
            @Override
            public void onWebViewClosed() {
                Toast.makeText(MainActivity.this, "Got consent", Toast.LENGTH_LONG).show();

                gdprInfoTextView.setText(getGdprInfo());
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        gdprInfoTextView.setText(getGdprInfo());
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            WebView.setWebContentsDebuggingEnabled(true);
        }
    }

    private String getGdprInfo() {
        return String.format("consentString: %s\nvendors: %s\npurposes: %s\nsubjectToGDPR: %s",
                CMPStorage.getConsentString(this),
                CMPStorage.getVendorsString(this),
                CMPStorage.getPurposesString(this),
                CMPStorage.getSubjectToGdpr(this));
    }

    @Override
    public void onAttachComplete(Object adObj) {
        if (adObj != null && adObj instanceof MoPubView) {
            ((MoPubView) adObj).loadAd();
        }else if (dfpAdView != null && adObj != null && adObj instanceof PublisherAdRequest) {
            dfpAdView.loadAd((PublisherAdRequest) adObj);
            Prebid.detachUsedBid(adObj);
        }
    }

    // MoPub Banner Listeners
    @Override
    public void onBannerLoaded(MoPubView banner) {
    }

    @Override
    public void onBannerFailed(MoPubView banner, MoPubErrorCode errorCode) {
    }

    @Override
    public void onBannerClicked(MoPubView banner) {
    }

    @Override
    public void onBannerExpanded(MoPubView banner) {
    }

    @Override
    public void onBannerCollapsed(MoPubView banner) {
    }
}