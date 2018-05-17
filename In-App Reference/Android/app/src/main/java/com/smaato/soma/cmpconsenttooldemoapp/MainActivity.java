package com.smaato.soma.cmpconsenttooldemoapp;

import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
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
import com.appnexus.opensdk.utils.Clog;
import com.smaato.soma.cmpconsenttooldemoapp.cmpconsenttool.CMPConsentToolActivity;
import com.smaato.soma.cmpconsenttooldemoapp.cmpconsenttool.callbacks.OnCloseCallback;
import com.smaato.soma.cmpconsenttooldemoapp.cmpconsenttool.model.CMPSettings;
import com.smaato.soma.cmpconsenttooldemoapp.cmpconsenttool.model.SubjectToGdpr;
import com.smaato.soma.cmpconsenttooldemoapp.cmpconsenttool.storage.CMPStorage;

public class MainActivity extends AppCompatActivity {

    private TextView gdprInfoTextView;
    private FrameLayout adContainerLayout;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

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


        // @NOTE Since we are using a CMP no need to set the below two values in the SDK. The SDK will automatically read the values from Shared Preference stored by CMP.
        // If you set the values throgh the API's then this will override the CMP values.
        //ANGDPRSettings.setConsentRequired(this,true);
        //ANGDPRSettings.setConsentRequired(this,"CONSENT_STRING");

        // Just attaching Banner to an adview will automatically trigger loadAd()
        adContainerLayout.addView(bav);

    }


    public void showCMP(){
        CMPStorage.setCmpPresentValue(MainActivity.this, true);
        CMPSettings cmpSettings = new CMPSettings(SubjectToGdpr.CMPGDPREnabled, "http://mobile.devnxs.net/testgdpr/docs/complete.html", null);

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
}