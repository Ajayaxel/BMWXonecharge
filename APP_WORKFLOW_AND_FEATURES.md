# ⚡ OneCharge (Electro) — App Workflow & Features Documentation

> **App Name**: OneCharge (also branded as **Electro**)
> **Platform**: Flutter (iOS & Android)
> **Purpose**: On-demand EV service platform — battery swaps, roadside assistance, and vehicle maintenance.
> **Last Updated**: March 2026

---

## 📋 Table of Contents

1. [App Overview](#1-app-overview)
2. [User Personas](#2-user-personas)
3. [Complete App Workflow](#3-complete-app-workflow)
4. [Screen-by-Screen Breakdown](#4-screen-by-screen-breakdown)
5. [Feature Catalogue](#5-feature-catalogue)
6. [Real-Time System Architecture](#6-real-time-system-architecture)
7. [Payment System](#7-payment-system)
8. [Data Models & State](#8-data-models--state)
9. [Tech Stack Summary](#9-tech-stack-summary)

---

## 1. App Overview

**OneCharge** is a specialized mobile platform that connects Electric Vehicle (EV) users with essential services. It operates on a **service-on-demand** model, using real-time tracking and location-based services to connect users with the nearest service centers or mobile service units.

The app handles the **complete lifecycle** of an EV service request — from user login all the way through booking, driver assignment, live tracking, payment, and post-service feedback.

---

## 2. User Personas

| Persona | Description |
|---|---|
| **Individual EV Owner** | Books battery swaps, roadside help, or maintenance for their personal vehicle. |
| **Fleet Operator** | Manages multiple EVs, tracks service history across vehicles. |

---

## 3. Complete App Workflow

The app has four major phases a user goes through:

```
[Onboarding] → [Authentication] → [Home / Service Flow] → [Post-Service]
```

### Phase 1 — Onboarding

```
App Launch
    │
    ▼
Splash / Onboarding Screens
    │   - Engaging visuals and animations (Lottie)
    │   - Guides first-time users through value proposition
    │
    ▼
Go to Login
```

### Phase 2 — Authentication

```
Phone Number Entry (phone_login.dart)
    │
    ▼
OTP Verification (otp_verification_screen.dart)
    │
    ▼
User Info Screen (user_info.dart)   ← Only for new users
    │   - Name, profile setup
    │
    ▼
Home Screen (Authenticated)
```

### Phase 3 — Core Service Flow (The Main Journey)

```
Home Screen
    │
    ├── User selects a service category (e.g. "Low Battery", "Breakdown")
    │
    ▼
Vehicle Selection Bottom Sheet
    │   - User picks which of their EVs needs service
    │   - Vehicle info (Brand, Model, Plate) saved to local storage
    │
    ▼
Issue Reporting Bottom Sheet
    │   ┌─────────────────────────────────────────────────────┐
    │   │  Step-by-step booking form:                         │
    │   │  1. Confirm / edit SERVICE LOCATION (with map pick) │
    │   │  2. Select booking type:                            │
    │   │     • Instant — proceed now                         │
    │   │     • Scheduled — pick date & time (3hr min gap)    │
    │   │  3. Choose issue sub-type / charging unit           │
    │   │  4. Add description (optional)                      │
    │   │  5. Attach photos / videos (optional)               │
    │   │  6. Apply REDEEM CODE (optional discount)           │
    │   │  7. Apply COMPANY CODE (optional corporate billing) │
    │   │  8. Select PAYMENT METHOD:                          │
    │   │     • Online (card / payment gateway)               │
    │   │     • Company (billed to employer)                  │
    │   └─────────────────────────────────────────────────────┘
    │
    ▼
Ticket Created via API (CreateTicketRequest)
    │
    ├─── If PAYMENT REQUIRED (online) ──────────────────────────────────┐
    │         ▼                                                          │
    │    Payment Bottom Sheet                                            │
    │         │  - Shows payment breakdown (base, VAT, discount, total) │
    │         │  - Opens secure WebView payment gateway                  │
    │         │  - On success → Service Flow begins                      │
    │         └───────────────────────────────────────────────────────── ┘
    │
    ├─── If FREE (company code / redeem applied) ─────────────────────── ┐
    │         ▼                                                           │
    │    Directly starts Service Flow                                     │
    │         └──────────────────────────────────────────────────────────┘
    │
    ▼
SERVICE TRACKING FLOW
    │
    ├── Stage 1: FINDING 🔍
    │       - Ticket submitted, waiting for driver assignment
    │       - Pusher/WebSocket listens for ticket.offered event
    │       - Progress bar shown on home screen & tracking map
    │
    ├── Stage 2: REACHING 🚗
    │       - Driver assigned (ticket.assigned event received)
    │       - Driver name, photo, and live GPS shown on map
    │       - Real-time polyline from driver → user location
    │       - Location freshness check (only show GPS < 30 mins old)
    │
    ├── Stage 3: SOLVING 🛠️
    │       - Driver reaches user location (status: at_location / in_progress)
    │       - Service in progress notification shown
    │
    ├── Stage 4: RESOLVED ✅
    │       - Service completed (status: completed / resolved)
    │       - "Submit Feedback" banner appears on home screen
    │
    └── CANCELLED / REJECTED ❌
            - Service flow resets to idle (stage: none)
            - WebSocket disconnected
```

### Phase 4 — Post-Service

```
Resolved State on Home Screen
    │
    ▼
Feedback Bottom Sheet
    │   - Star rating (1–5)
    │   - Optional written feedback
    │   - Submitted to API
    │
    ▼
Invoice Preview Screen (if invoice exists)
    │   - View invoice number, breakdown, total
    │   - Download / share invoice URL
    │
    ▼
Back to Idle Home Screen
```

---

## 4. Screen-by-Screen Breakdown

### 🏠 Home Screen (`home_screen.dart`)
The central hub of the app. It:
- Shows the user's current detected **GPS address** at the top
- Displays the user's **registered vehicles** as selectable cards
- Shows **service category buttons** (Low Battery, Breakdown, Charging Station, etc.)
- Houses the full **service progress tracker** (Finding → Reaching → Solving → Resolved) below when a booking is active
- Embeds `TrackingMapScreen` and `ServiceNotificationOverlay` to show live status
- Starts and manages the **WebSocket / Pusher real-time service**
- Supports **CarPlay integration** for hands-free booking

### 🔐 Login Screens (`screen/login/`)
| Screen | Purpose |
|---|---|
| `phone_login.dart` | Phone number input, country code selection |
| `otp_verification_screen.dart` | 4/6-digit OTP entry and verification |
| `user_info.dart` | Profile setup for new users (name, etc.) |

### 📋 Issue Reporting Bottom Sheet (`issue_reporting_bottom_sheet.dart`)
The most complex screen in the app (~2,000 lines). It handles:
- **Category selection** (fetched from API via `IssueCategoryBloc`)
- **Sub-type / issue detail selection** (e.g. specific charging type)
- **Location confirmation** with ability to open map picker
- **Instant vs. Scheduled** booking toggle with date/time picker (30-min intervals, 3-hour minimum gap)
- **File attachments** — photos and videos via camera or gallery
- **Redeem code** validation and application
- **Company code** validation and application (corporate billing)
- **Payment method** selection (online / company)
- Submission to API with full `CreateTicketRequest`

### 🗺️ Tracking Map Screen (`tracking_map_screen.dart`)
- Full-screen **Google Map** with real-time markers
- **Driver marker** (car icon) updates live via WebSocket
- **Destination marker** (black circle) at user location
- **Polyline** drawn between driver and customer
- **Driver location freshness guard** — ignores GPS coordinates older than 30 minutes to prevent showing stale database coordinates
- Falls back to Dubai coordinates if no location is available

### 📍 My Location Screen (`my_location_screen.dart`)
- Allows users to **save named locations** (Home, Work, etc.)
- Can act as a **location picker** returning coordinates to the booking form
- Integrated with Google Maps for visual selection

### 🚗 My Vehicle Screen (`my_vehicle_screen.dart`)
- Manage (add/view/delete) registered EVs
- Each vehicle stores: Brand, Model, Plate Number, Type, Image

### 👤 Profile Screen (`profile_screen.dart`)
- View and edit user profile details
- Profile photo, name, phone number

### 📜 Recent Bookings Screen (`recent_bookings_screen.dart`)
- Full history of all past service tickets
- Shows status, date, vehicle, and issue type per booking

### 💬 Chat Support Screen (`chat_support_screen.dart`)
- Real-time messaging with the support team
- Useful for escalations or custom service questions

### ⚙️ Settings Screen (`settings_screen.dart`)
| Setting | Description |
|---|---|
| Profile | Navigate to profile editing |
| Recent Bookings | View all past service requests |
| Notification | Toggle push notifications on/off |
| My Vehicle | Manage registered vehicles |
| Location | Manage saved addresses |
| Terms & Conditions | Legal information |
| Chat Support | In-app live chat |
| Log Out | Secure session logout with confirmation dialog |
| Delete Account | Permanent account deletion with warning |

### 🧾 Invoice Preview Screen (`invoice_preview_screen.dart`)
- Shows final invoice after service completion
- Invoice number, subtotal, VAT, discount, total, and currency
- Provides a shareable invoice URL

### 📬 Booking Detail Screen (`booking_detail_screen.dart`)
- Detailed view of a single booking/ticket
- Driver info, status, location, cost breakdown

### 💳 Payment Screens
| Screen | Description |
|---|---|
| `payment_bottom_sheet.dart` | Displays cost breakdown before payment |
| `select_payment_bottom_sheet.dart` | Lets user choose between payment methods |

---

## 5. Feature Catalogue

### 🔑 Authentication
- Phone number + OTP-based login (no passwords)
- Secure token storage via `flutter_secure_storage`
- Auto-login if token exists on launch
- Logout with token clearing

### 📍 Location & Maps
- **Auto-detect GPS** using `geolocator` + `geocoding`
- **Interactive map picker** for precise address selection
- **Saved locations** (Home, Work, custom) stored against the user account
- **Default location fallback** to Dubai coordinates (25.2048, 55.2708)
- Google Maps integration for all mapping features

### 🛵 Service Booking
- **Instant Booking** — service requested immediately
- **Scheduled Booking** — user picks a date & time (minimum 3 hours from now, in 30-minute slots)
- **Issue Categories** — dynamically loaded from API (e.g. Low Battery, Breakdown, Charging Station)
- **Issue Sub-types** — nested categories for more precise reporting
- **Attachment support** — photos and videos attached to tickets

### 📡 Real-Time Tracking (WebSocket / Pusher)
- WebSocket connection per authenticated user (customer channel)
- **Events handled:**

| Event | Action |
|---|---|
| `ticket.offered` | Stage → Finding |
| `ticket.assigned` | Stage → Reaching, driver details shown |
| `ticket.status_changed` | Stage → Solving / Resolved / Cancelled |
| `driver.location.updated` | Driver marker moves in real-time on map |

- **Location freshness guard**: GPS coordinates older than 30 minutes are discarded to prevent stale data from appearing on the map
- WebSocket disconnects automatically when service is complete or cancelled

### 💳 Payments
- **Online Payment** — secure WebView gateway (Stripe/payment intent flow)
- **Company Billing** — corporate code applied, billed to employer
- **Payment Breakdown** shown before confirmation: base amount, VAT, discount, total
- **Free Service** supported — if redeem/company code makes total = 0, payment screen is skipped
- **Invoice generation** after service completion

### 🎟️ Discount & Codes
- **Redeem Code** — promotional discount codes validated via API in real-time
- **Company Code** — corporate codes that route billing to the user's company

### 🚘 Vehicle Management
- **Digital Garage** — add and store multiple EVs
- Each vehicle: Brand, Model, Plate Number, Vehicle Type
- **Vehicle image** shown on cards
- Delete vehicle with confirmation dialog
- Vehicle info cached locally for fast booking

### ⭐ Post-Service Feedback
- **Star rating** (1–5 stars)
- **Written comment** (optional)
- Submitted to API linked to specific ticket

### 🔔 Notifications
- In-app **service status notifications** (overlay banners)
- Push notification toggle in Settings (on/off)
- Toast notifications for actions (success, errors)

### 📊 Service Status Stages

| Stage | Status Values from API | UI |
|---|---|---|
| `none` | — | Idle home screen |
| `finding` | `pending`, `offered` | Search animation, progress bar step 1 |
| `reaching` | `assigned`, `reaching` | Driver card + live map |
| `solving` | `at_location`, `in_progress`, `solving`, `reached` | In-progress message |
| `resolved` | `completed`, `resolved` | "Submit Feedback" banner |
| *(reset)* | `cancelled`, `rejected` | Flow resets to idle |

### 🚗 CarPlay Integration
- `CarPlayService` registers a handler for hands-free service booking
- Users can trigger a booking from their car's infotainment screen
- Uses locally cached vehicle info for instant submission

### 🎨 UI & UX Highlights
- **Custom font**: Lufga (premium look)
- **Shimmer skeleton** loading screens while data is fetched
- **Lottie animations** throughout onboarding and in-app
- **Toast notifications** with slide-in animations
- **Smooth transitions** between booking stages
- **Glassmorphism-style** bottom sheets
- Dark overlays and smooth progress indicators

---

## 6. Real-Time System Architecture

```
Flutter App
    │
    ├── RealtimeService (logic/services/realtime_service.dart)
    │       │
    │       │  Connects via WebSocket (Pusher Channels)
    │       │  Channel: customer.{customer_id}
    │       │
    │       ├── onTicketOffered    → HomeScreen → stage = 'finding'
    │       ├── onTicketAssigned   → HomeScreen → stage = 'reaching', driver info loaded
    │       ├── onTicketStatusChanged → HomeScreen → stage update (solving/resolved/cancelled)
    │       └── onDriverLocationUpdated → TicketBloc → UpdateDriverLocation → Map marker moves
    │
    └── TicketBloc (logic/blocs/ticket/)
            │
            ├── UpdateDriverLocation → TrackingMapScreen re-renders marker
            ├── UpdateTicketDetails  → Status synced across app
            └── FetchDriverLocationRequested → Polls API for fresh GPS on map open
```

---

## 7. Payment System

```
CreateTicketRequest submitted to API
    │
    ▼
API Response: CreateTicketResponse
    │
    ├── paymentRequired = false
    │       │
    │       └── → Start Service Flow immediately (free/company booking)
    │
    └── paymentRequired = true
            │
            ▼
        PaymentBreakdown shown (base, VAT, discount, total, currency)
            │
            ▼
        User confirms → WebView opens with paymentUrl
            │
            ▼
        Payment gateway processes (Stripe / online)
            │
            ▼
        Success → Service Flow begins (stage = finding)
```

**Payment Methods:**
| Method | API Value | Description |
|---|---|---|
| Online Payment | `"online"` | Default; opens WebView payment gateway |
| Company Billing | `"company"` | Billed to employer via company code |

---

## 8. Data Models & State

### Key Models (`lib/models/`)

| Model | Description |
|---|---|
| `Ticket` | Core service booking object with status, driver, location, cost |
| `TicketDriver` | Assigned driver details (name, photo, GPS, phone) |
| `TicketInvoice` | Invoice details after service completion |
| `PaymentBreakdown` | Full cost breakdown (base, VAT, discount, total) |
| `CreateTicketRequest` | All data needed to create a new booking |
| `VehicleListItem` | User's registered EV details |
| `IssueCategory` | Service category (e.g. Low Battery) with sub-types |
| `LocationModel` | Saved address with lat/lng coordinates |
| `LoginModel` | Auth token and user info from login API |
| `FeedbackModel` | Post-service rating and comment |
| `RedeemCodeModel` | Discount code validation result |
| `CompanyCodeModel` | Corporate billing code validation result |

### BLoC State Managers (`lib/logic/blocs/`)

| BLoC | Purpose |
|---|---|
| `AuthBloc` | Login, logout, session management |
| `TicketBloc` | Create ticket, track status, update driver location |
| `VehicleListBloc` | Fetch, add, delete user vehicles |
| `IssueCategoryBloc` | Load service categories from API |
| `ProfileBloc` | Fetch and update user profile |
| `LocationBloc` | Manage saved addresses |
| `RedeemCodeBloc` | Validate and apply redeem codes |
| `CompanyCodeBloc` | Validate and apply company codes |
| `BrandBloc` | EV brand list for vehicle registration |
| `VehicleModelBloc` | Vehicle model list per brand |
| `ChargingTypeBloc` | Charging connector types |
| `FeedbackBloc` | Post-service rating submission |
| `ChatBloc` | Real-time chat messages with support |
| `DeleteVehicleBloc` | Vehicle removal |

---

## 9. Tech Stack Summary

| Category | Technology |
|---|---|
| **Language** | Dart 3.x |
| **UI Framework** | Flutter |
| **Architecture** | BLoC / Cubit pattern |
| **API Client** | Dio (with interceptors) |
| **Real-Time** | Pusher Channels (WebSocket) |
| **Maps** | Google Maps Flutter |
| **Location** | Geolocator + Geocoding |
| **Animations** | Lottie, Video Player |
| **Graphics** | Flutter SVG |
| **Storage** | Shared Preferences + Flutter Secure Storage |
| **UI Effects** | Shimmer skeleton loading |
| **Font** | Lufga (custom) |
| **Backend Notifications** | Firebase (firebase_options.dart present) |
| **Platform** | iOS & Android (CarPlay on iOS) |

---

## 🗺️ App Navigation Map

```
App Start
  └── Onboarding Screens
        └── Login (Phone Number)
              └── OTP Verification
                    └── User Info (new users only)
                          └── HOME SCREEN
                                ├── Service Categories → Vehicle Select → Issue Report → Payment → Tracking Map
                                ├── Notification Screen
                                ├── Settings Screen
                                │     ├── Profile Screen
                                │     ├── Recent Bookings Screen
                                │     │     └── Booking Detail Screen
                                │     │           └── Invoice Preview Screen
                                │     ├── My Vehicle Screen
                                │     ├── My Location Screen
                                │     ├── Terms & Conditions
                                │     └── Chat Support Screen
                                └── Feedback Bottom Sheet (post-service)
```

---

*This document was auto-generated by analysing the full source code of the OneCharge (Electro) Flutter application.*
*For code-level details, refer to the source files under `lib/`.*
