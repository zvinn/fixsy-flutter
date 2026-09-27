# ============================================================
# Fixsy v1.0.0 GitHub Release Creator
# Run: .\create_release.ps1 -Token "ghp_YOUR_TOKEN_HERE"
# ============================================================
param(
    [string]$Token = ""
)

if ([string]::IsNullOrWhiteSpace($Token)) {
    $Token = Read-Host "🔑 Please enter your GitHub Token (ghp_...)"
}

$REPO = "zvinn/fixsy-flutter"
$TAG  = "v1.0.0"
$NAME = "v1.0.0 — Initial Production Release 🚀"
$APK_DIR = "build\app\outputs\flutter-apk"

$BODY = @"
## 🚀 Fixsy v1.0.0 — Initial Production Release

**منصة صيانة المنازل المتكاملة** — التطبيق الكامل لربط العملاء بالفنيين المحترفين.

> 🌐 **Live Web Demo:** https://zvinn.github.io/fixsy-flutter/

---

## ✨ What's Included

### 🔐 Authentication
- Email/password login & registration with form validation
- Google Sign-In & Apple Sign-In integration
- **Demo accounts** (Client / Technician / Admin) for instant access
- Remember me, forgot password, rate limiting & security utils

### 🏠 Client Experience
- Personalized home dashboard with service categories
- AI-powered service diagnosis (Gemini multi-modal vision)
- Floating Fixsy AI Assistant with voice input
- Real-time technician tracking on live map
- Interactive slot scheduling with date/time selection

### 🔧 Technician Experience
- Technician dashboard with job queue & stats
- Portfolio gallery & trust badges
- Onboarding & ID verification flow
- Job market with bidding system & custom proposals
- Daily stories with reactions & direct booking

### 💬 Communication
- Real-time private chat (Firebase Firestore)
- Voice notes, message read receipts (Sent/Delivered/Read)
- Live typing indicator & last-seen status

### 💳 Payments & Wallet
- Wallet with balance, top-up & withdrawal
- Multi-channel payment methods & voucher redemption
- Transaction history with filters

### ⭐ Ratings & Community
- Multi-criteria rating system with praise tags
- Community Q&A hub & referral program

### 🎮 Gamification & More
- Loyalty points & badges system
- Annual contract subscriptions & spare parts store
- Push notification center with swipe-to-delete
- Offline mode with auto-sync queue
- Admin panel for platform management
- Dark/Light theme · AR/EN language support

---

## 📱 Download

| Architecture | Recommended For | Size |
|---|---|---|
| **arm64-v8a** ⭐ | Most modern Android phones (2017+) | ~24.5 MB |
| **armeabi-v7a** | Older Android phones | ~22.7 MB |
| **x86_64** | Android Emulators | ~25.9 MB |

> **Not sure which to download?** Get ``arm64-v8a`` — works on 95%+ of modern devices.

---

## 🛠️ Tech Stack
Flutter 3.27 · Firebase (Auth, Firestore, Storage, Analytics) · Gemini AI · Google Maps · Provider

---

## 🐛 Bug Fixes in This Release
- **Web:** Demo accounts now correctly persist login state (fixed `_isDemoSession` race condition)
- **Web:** Toast notification colors now use branded theme colors (AppTheme.successColor/errorColor)
- **UI:** Fixed `ListTile` Material ancestor assertion errors (Flutter 3.27+)

---

*Built with ❤️ using Flutter*
"@

$headers = @{
    "Authorization"        = "Bearer $Token"
    "Accept"               = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

Write-Host "📦 Creating GitHub Release $TAG..." -ForegroundColor Cyan

# Step 1: Create the release
$releasePayload = @{
    tag_name         = $TAG
    target_commitish = "main"
    name             = $NAME
    body             = $BODY
    draft            = $false
    prerelease       = $false
} | ConvertTo-Json -Depth 5

try {
    $release = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/$REPO/releases" `
        -Method POST `
        -Headers $headers `
        -Body $releasePayload `
        -ContentType "application/json"
    
    Write-Host "✅ Release created! ID: $($release.id)" -ForegroundColor Green
    Write-Host "🔗 URL: $($release.html_url)" -ForegroundColor Green
    
    # Step 2: Upload APK files
    $apks = @(
        "app-arm64-v8a-release.apk",
        "app-armeabi-v7a-release.apk",
        "app-x86_64-release.apk"
    )
    
    foreach ($apk in $apks) {
        $apkPath = Join-Path $APK_DIR $apk
        if (Test-Path $apkPath) {
            Write-Host "📤 Uploading $apk..." -ForegroundColor Yellow
            $uploadUrl = "https://uploads.github.com/repos/$REPO/releases/$($release.id)/assets?name=$apk"
            $apkBytes = [System.IO.File]::ReadAllBytes($apkPath)
            
            try {
                $uploadResult = Invoke-RestMethod `
                    -Uri $uploadUrl `
                    -Method POST `
                    -Headers $headers `
                    -Body $apkBytes `
                    -ContentType "application/vnd.android.package-archive"
                Write-Host "  ✅ Uploaded: $($uploadResult.browser_download_url)" -ForegroundColor Green
            } catch {
                Write-Host "  ❌ Upload failed for $apk`: $_" -ForegroundColor Red
            }
        } else {
            Write-Host "  ⚠️ APK not found: $apkPath" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "🎉 DONE! GitHub Release v1.0.0 is live!" -ForegroundColor Magenta
    Write-Host "🔗 $($release.html_url)" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Failed to create release: $_" -ForegroundColor Red
    Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
}
