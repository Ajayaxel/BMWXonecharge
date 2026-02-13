# ⚡ OneCharge (Electro) - EV Service Platform

OneCharge (recently rebranded as **Electro**) is a premium, feature-rich mobile application built with Flutter, designed to provide a seamless service experience for Electric Vehicle (EV) users. Whether it's battery swapping, roadside assistance, or vehicle maintenance, OneCharge connects EV owners with real-time solutions and support.

---

## 📱 What is this App?

The OneCharge app serves as a comprehensive companion for EV owners. It addresses the critical needs of the EV ecosystem by providing:
- **Instant Service Booking**: Request battery swaps or repairs with a single tap.
- **Real-time Tracking**: Monitor the progress of your service request on a live map.
- **Vehicle Lifecycle Management**: Keep track of multiple EVs, their health, and service history.
- **Seamless Payments**: Manage subscriptions and pay for services through a secure, integrated wallet system.

---

## ✨ Key Features

### 🚀 Smart Onboarding & Authentication
- **User-friendly Onboarding**: Engaging visuals and animations to guide new users.
- **Secure Login**: Phone-based authentication for quick and secure access.

### 🗺️ Live Tracking & Maps
- **Interactive Station Map**: Find nearby charging and swapping stations effortlessly.
- **Live Service Tracking**: Watch your service provider reach your location in real-time.
- **Precise Geolocation**: Integrated Google Maps API for accurate picking and tracking of locations.

### 🚗 Vehicle Management
- **Digital Garage**: Add and manage multiple vehicles.
- **Detailed Specs**: View brand, model, and plate details at a glance.
- **Recent Services**: Access the history of all bookings related to a specific vehicle.

### 🛠️ Issue Reporting & Support
- **One-Tap Reporting**: Report vehicle issues or battery problems via an intuitive interface.
- **Chat Support**: Real-time communication with support teams for immediate help.
- **Issue Hierarchy**: Categorized issue reporting for faster resolution.

### 💳 Payments & Subscription
- **Digital Wallet**: Top up and pay for services instantly.
- **Subscription Models**: Manage monthly or yearly service plans.
- **Safe Transactions**: Secure webview-based payment gateways.

---

## 🛠️ Tech Stack

- **Core Framework**: Flutter (Dart)
- **State Management**: BLoC / Cubit (for scalable and predictable state)
- **Networking**: Dio (with interceptors for API management)
- **Real-time Updates**: Pusher Channels
- **Maps & Location**: Google Maps Flutter, Geolocator, Geocoding
- **UI & Experience**:
  - **Animations**: Lottie, Video Player
  - **Graphics**: Flutter SVG
  - **Feedback**: Custom Shimmer effects & Toast notifications
- **Persistence**: Shared Preferences & Secure Storage

---

## 📁 Project Structure

```text
lib/
├── logic/          # BLoC/Cubit state management
├── screen/         # UI Screens (Home, Login, Vehicle, etc.)
├── models/         # Data models and API responses
├── core/           # Core infrastructure (Storage, API clients)
├── data/           # Repositories and providers
├── utils/          # Helper functions and constants
└── widgets/        # Reusable UI components
```

---

## 🚀 Getting Started

1. **Clone the repository**
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the app**:
   ```bash
   flutter run
   ```

---

> **Note**: This project is actively evolving to improve the EV service experience. For any issues, please use the **Chat Support** feature within the app.

---
© 2024 OneCharge Tech. All rights reserved.
