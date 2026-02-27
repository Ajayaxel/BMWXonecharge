# 🔴 Laravel Reverb WebSocket — Server Fix Required

**Reported By:** Flutter Mobile App Team  
**Date:** 2026-02-23  
**Error:** `WebSocketException: Connection to 'wss://app.onecharge.io/app/5csvb4sew88zqnmcxuqg' was not upgraded to websocket, HTTP status code: 404`

---

## 📋 Problem Summary

The Flutter app is trying to connect to Laravel Reverb for real-time driver location updates via WebSocket. The connection **always fails with HTTP 404** because **Reverb is not running as a publicly accessible service** on the production server.

### Proof (run this curl command from any terminal):
```bash
curl -si --http1.1 \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
  "https://app.onecharge.io/app/5csvb4sew88zqnmcxuqg"
```

**Current response (broken):**
```
HTTP/1.1 404 Not Found
X-Powered-By: PHP/8.2.30   ← Laravel is answering, NOT Reverb
```

**Expected response (when Reverb is running):**
```
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
```

---

## 🔍 Root Cause

Laravel Reverb is a **separate long-running process** that must be started alongside the regular Laravel HTTP server. It listens on its own port (default: `8080`) for WebSocket connections.

On your Railway deployment, **only the Laravel HTTP server** (port 443/80) is running. The Reverb WebSocket server process is **not running** or **not publicly exposed**.

The request flow that needs to work:
```
Flutter App
    │
    └──► wss://app.onecharge.io/app/{key}  ← WebSocket request
              │
              ▼
         Railway (Public URL Port 443)
              │
              ▼
         Reverb Process (Internal Port 8080)  ← This is missing!
```

---

## ✅ Fix: How to Set Up Reverb on Railway

### Option A — Add Reverb as a Separate Railway Service (Recommended)

1. **Go to your Railway project dashboard.**

2. **Add a new Service** in the same project (using the same GitHub repo/source).

3. **Set the Start Command** for the new Reverb service:
   ```bash
   php artisan reverb:start --host=0.0.0.0 --port=8080
   ```

4. **Add the same Environment Variables** as your main Laravel service, especially:
   ```env
   REVERB_APP_ID=632317
   REVERB_APP_KEY=5csvb4sew88zqnmcxuqg
   REVERB_APP_SECRET=nzvg0ngobyn8ghqtkapo
   REVERB_HOST=0.0.0.0
   REVERB_PORT=8080
   REVERB_SCHEME=https
   APP_KEY=<your Laravel APP_KEY>
   ```

5. **Railway will auto-assign a public URL** to this new service, e.g.:
   ```
   reverb-production-xxxx.up.railway.app
   ```

6. **Share that URL with the Flutter team.** We will update one line:
   ```dart
   // lib/core/config/app_config.dart
   static const String reverbHost = 'reverb-production-xxxx.up.railway.app';
   static const int reverbPort = 443;
   static const bool reverbUseTls = true;
   ```

---

### Option B — Run Reverb on the Same Railway Service (Supervisor/Procfile)

If you want both Laravel HTTP and Reverb on the same Railway service, use a `Procfile`:

Create a file called `Procfile` in your Laravel project root:
```
web: php artisan serve --host=0.0.0.0 --port=$PORT
reverb: php artisan reverb:start --host=0.0.0.0 --port=8080
```

> ⚠️ **Note:** Railway only exposes ONE port per service publicly. For this to work, you need to put Nginx or a reverse proxy in front to route WebSocket traffic. **Option A is simpler and recommended.**

---

### Option C — Use Pusher.com (Simplest, Fully Managed)

If setting up Reverb on Railway is complex, switch to **Pusher.com** (free tier available):

1. Sign up at [https://pusher.com](https://pusher.com) → Create a new **Channels** app.
2. Update Laravel `.env`:
   ```env
   BROADCAST_DRIVER=pusher
   PUSHER_APP_ID=your_pusher_app_id
   PUSHER_APP_KEY=your_pusher_key
   PUSHER_APP_SECRET=your_pusher_secret
   PUSHER_APP_CLUSTER=ap2
   ```
3. Share the Pusher credentials with the Flutter team.

---

## 🧪 How to Verify the Fix

After setting up, run this command — it should respond with `101 Switching Protocols`:
```bash
curl -si --http1.1 \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
  "https://<REVERB_HOST>/app/5csvb4sew88zqnmcxuqg"
```

Expected output:
```
HTTP/1.1 101 Switching Protocols ✅
```

---

## 📱 Flutter App Status

The Flutter app code is **100% correct** and ready. Once the Reverb server is accessible:
- WebSocket will connect automatically
- Real-time driver location updates will work
- No further Flutter code changes are needed (only `reverbHost` may need updating)

**Flutter App Key Config (`lib/core/config/app_config.dart`):**
```dart
static const String reverbHost = 'app.onecharge.io'; // ← update if Reverb gets its own URL
static const int reverbPort = 443;
static const String reverbAppKey = '5csvb4sew88zqnmcxuqg';
static const bool reverbUseTls = true;
```

---

*Document prepared by: Flutter App Team*  
*For questions, refer to: [Laravel Reverb Docs](https://laravel.com/docs/11.x/reverb)*
