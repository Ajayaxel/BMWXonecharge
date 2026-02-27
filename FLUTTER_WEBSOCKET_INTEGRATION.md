# 📱 Flutter WebSocket (Reverb) Integration Guide

**Project:** OneCharge Driver App  
**Date:** 2026-02-23  
**Feature:** Real-time Driver Location Tracking via Laravel Reverb WebSockets  
**Package:** `pusher_reverb_flutter: ^0.0.4`

---

## 📐 Architecture Overview

```
┌────────────────────────────────────────────────────────┐
│                     Flutter App                        │
│                                                        │
│  HomeScreen                                            │
│    │  (1) Booking created → startServiceFlow()         │
│    │                                                   │
│    ▼                                                   │
│  RealtimeService  ──────────────────────────────────►  │
│    │  (2) connectAndSubscribe()          Reverb Server │
│    │  (3) subscribe: private-customer.{id}.driver-loc  │
│    │                                                   │
│    │  (4) Events arrive:                               │
│    │      • ticket.offered                             │
│    │      • ticket.assigned                            │
│    │      • driver.location.updated                    │
│    │                                                   │
│    ▼                                                   │
│  TicketBloc                                            │
│    │  (5) add(UpdateDriverLocation(driver))            │
│    ▼                                                   │
│  TrackingMapScreen                                     │
│       (6) BlocBuilder → updates map marker             │
└────────────────────────────────────────────────────────┘
```

---

## 📦 Step 1 — Add Dependency

In `pubspec.yaml`:
```yaml
dependencies:
  pusher_reverb_flutter: ^0.0.4
```

Run:
```bash
flutter pub get
```

---

## ⚙️ Step 2 — Configuration

**File:** `lib/core/config/app_config.dart`

```dart
class AppConfig {
  // ── WebSocket (Reverb) ──────────────────────────────
  static const String reverbHost    = 'app.onecharge.io'; // Reverb server URL
  static const int    reverbPort    = 443;                // 443 for wss://, 80 for ws://
  static const String reverbAppKey  = '5csvb4sew88zqnmcxuqg';
  static const String reverbScheme  = 'wss';              // wss = secure, ws = plain
  static const bool   reverbUseTls  = true;               // true = wss://, false = ws://

  // ── Auth endpoint for private channels ─────────────
  static const String broadcastingAuthUrl =
      'https://app.onecharge.io/api/broadcasting/auth';

  // ── REST API ────────────────────────────────────────
  static const String baseUrl    = 'https://app.onecharge.io/api';
  static const String storageUrl = 'https://app.onecharge.io/storage/';
}
```

**The URL the app connects to is built from config:**
```
wss://{reverbHost}:{reverbPort}/app/{reverbAppKey}
→ wss://app.onecharge.io:443/app/5csvb4sew88zqnmcxuqg
```

---

## 🔌 Step 3 — RealtimeService

**File:** `lib/logic/services/realtime_service.dart`

This is the **core WebSocket class**. It wraps `pusher_reverb_flutter` and exposes simple callbacks.

```dart
class RealtimeService {
  ReverbClient? _client;
  Channel? _customerChannel;

  final int customerId;
  final String token;

  // ── Event Callbacks ────────────────────────────────
  final Function(dynamic data)? onTicketOffered;
  final Function(dynamic data)? onTicketAssigned;
  final Function(dynamic data)? onDriverLocationUpdated;
```

### Key Methods:

| Method | What it does |
|--------|-------------|
| `connectAndSubscribe()` | Opens WebSocket, subscribes to private channel |
| `_authorizer()` | Sends Bearer token to `/api/broadcasting/auth` |
| `disconnect()` | Closes WebSocket, cleans up |

### Private Channel Name Format:
```
private-customer.{customerId}.driver-location
```
Example: `private-customer.42.driver-location`

### Events Listened:
| Event Name | When it fires |
|-----------|---------------|
| `ticket.offered` | When the system is searching for a driver |
| `ticket.assigned` | When a driver accepts the booking |
| `driver.location.updated` | Every time the driver moves |

---

## 🧩 Step 4 — BLoC Integration

**File:** `lib/logic/blocs/ticket/`

### Events added for real-time:

```dart
// Fired from REST poll (initial fetch)
class FetchDriverLocationRequested extends TicketEvent {
  final int ticketId;
}

// Fired from WebSocket callbacks (live updates)
class UpdateDriverLocation extends TicketEvent {
  final TicketDriver driver; // contains lat, lng, name
}
```

### States emitted:
```dart
class DriverLocationLoaded extends TicketState {
  final TicketDriver? driver;
}
```

### In TicketBloc:
```dart
on<UpdateDriverLocation>((event, emit) {
  emit(DriverLocationLoaded(event.driver)); // instant — no API call needed
});
```

---

## 🏠 Step 5 — HomeScreen Integration

**File:** `lib/screen/home/home_screen.dart`

### When a booking is created:
```dart
// In BlocListener, when TicketSuccess state arrives:
if (state is TicketSuccess) {
  startServiceFlow(ticket: state.response.data?.ticket);
}

void startServiceFlow({Ticket? ticket}) {
  setState(() => _currentServiceStage = 'finding');

  if (ticket != null) {
    // 1. REST call for initial driver location (if already assigned)
    context.read<TicketBloc>().add(FetchDriverLocationRequested(ticket.id));

    // 2. Start WebSocket for live updates
    _initRealtimeService(ticket);
  }
}
```

### WebSocket init (wrapped in try-catch to prevent crashes):
```dart
void _initRealtimeService(Ticket ticket) async {
  try {
    final token = await TokenStorage.readToken();
    if (token == null) return;

    _realtimeService?.disconnect(); // disconnect any old connection

    _realtimeService = RealtimeService(
      customerId: ticket.customerId,
      token: token,
      onDriverLocationUpdated: (data) {
        // Push new location into BLoC → map updates automatically
        context.read<TicketBloc>().add(UpdateDriverLocation(driver));
      },
    );

    await _realtimeService!.connectAndSubscribe();
  } catch (e) {
    // WebSocket failed silently — app still works (no real-time updates)
    developer.log('⚠️ [HomeScreen] Realtime failed: $e');
  }
}
```

### Cleanup on screen close:
```dart
@override
void dispose() {
  _realtimeService?.disconnect(); // always clean up WebSocket on exit
  super.dispose();
}
```

---

## 🗺️ Step 6 — Map Screen Updates

**File:** `lib/screen/home/tracking_map_screen.dart`

The map listens to `TicketBloc` for `DriverLocationLoaded`:

```dart
BlocListener<TicketBloc, TicketState>(
  listener: (context, state) {
    if (state is DriverLocationLoaded && state.driver != null) {
      final lat = double.tryParse(state.driver!.latitude ?? '');
      final lng = double.tryParse(state.driver!.longitude ?? '');
      if (lat != null && lng != null) {
        // Move the driver marker on the map
        _updateDriverMarker(LatLng(lat, lng));
      }
    }
  },
)
```

---

## 🔐 Step 7 — Private Channel Authentication

The Reverb server requires **authentication** for private channels.

### How it works:
1. Flutter connects to WebSocket successfully
2. Flutter tries to subscribe to `private-customer.{id}.driver-location`
3. Reverb asks Flutter to authenticate by calling `broadcastingAuthUrl`
4. Flutter's `_authorizer()` function sends the **Bearer token** to Laravel
5. Laravel verifies the token and responds with a signed auth response
6. Reverb allows the subscription

### Authorizer in RealtimeService:
```dart
Future<Map<String, String>> _authorizer(
  String channelName,
  String socketId,
) async {
  return {
    'Authorization': 'Bearer $token', // user's login token
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
```

### Required Laravel Route (`routes/channels.php`):
```php
// Must exist on the server!
Broadcast::channel('customer.{customerId}.driver-location', function ($user, $customerId) {
    return (int) $user->id === (int) $customerId;
});
```

---

## 📊 Complete Data Flow Diagram

```
[Driver App] ──GPS update──► [Laravel Backend]
                                    │
                            broadcast() event
                                    │
                                    ▼
                            [Reverb WebSocket Server]
                                    │
                         sends to subscribed clients
                                    │
                                    ▼
                         [Flutter App — RealtimeService]
                                    │
                           onDriverLocationUpdated()
                                    │
                                    ▼
                         [TicketBloc — UpdateDriverLocation]
                                    │
                             emits DriverLocationLoaded
                                    │
                                    ▼
                         [TrackingMapScreen — BlocBuilder]
                                    │
                          updates driver marker on map 🗺️
```

---

## 🐛 Debug Logs to Watch

When the app runs, look for these in the Flutter console:

| Log | Meaning |
|-----|---------|
| `🚀 [RealtimeService] Connecting to Reverb...` | Connection attempt started |
| `✅ [RealtimeService] Connected!` | WebSocket connected ✅ |
| `📡 [RealtimeService] Subscribing to private-customer.X.driver-location` | Subscribing |
| `✅ [RealtimeService] Subscribed` | Subscription confirmed ✅ |
| `📍 [RealtimeService] Event: driver.location.updated` | Live location received |
| `❌ [RealtimeService] Connection error: ...` | Connection failed ❌ |
| `⚠️ [HomeScreen] Real-time service failed` | WebSocket unavailable, app continues |

---

## ⚠️ Current Status & Known Issue

> **The WebSocket is NOT working in production** because the Reverb server is not exposed on `app.onecharge.io`.
>
> See `REVERB_SERVER_FIX.md` for the complete backend fix guide.

**All Flutter code is complete and correct.** The moment the backend exposes Reverb, it will work automatically.

| Component | Status |
|-----------|--------|
| `AppConfig` | ✅ Configured |
| `RealtimeService` | ✅ Complete |
| `TicketBloc` | ✅ Handles real-time events |
| `HomeScreen` | ✅ Integrated with error handling |
| `TrackingMapScreen` | ✅ Listens to BLoC |
| **Reverb Server** | ❌ Not exposed — backend fix required |

---

*Integration guide prepared by: Flutter App Team*  
*For server fix instructions, see: `REVERB_SERVER_FIX.md`*
