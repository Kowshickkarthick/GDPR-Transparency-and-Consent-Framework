package com.appnexus.opensdk.cmpdemo.cmpconsenttool.callbacks;

/**
 * Provides a listener that will be called when {@link com.appnexus.opensdk.cmpdemo.cmpconsenttool.CMPConsentToolActivity} is finished after interacting with the WebView
 */
public interface OnCloseCallback {

    /**
     * Listener called when {@link com.appnexus.opensdk.cmpdemo.cmpconsenttool.CMPConsentToolActivity} is finished after interacting with the WebView
     */
    void onWebViewClosed();

}