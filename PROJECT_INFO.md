# PROJECT DOCUMENTATION: OneCharge (Electro)

**Date**: February 9, 2026  
**Subject**: Application Overview and Feature Specification  

---

## 1. Executive Summary
**OneCharge** (also known as **Electro**) is a specialized mobile platform designed to bridge the gap between Electric Vehicle (EV) users and essential services. The application focuses on high-availability services like battery swapping, breakdown assistance, and maintenance tracking, ensuring that EV users never face downtime.

---

## 2. Core Application Logic
The application is built on a service-on-demand model. It utilizes real-time tracking and location-based services to connect users with the nearest service centers or mobile service units.

### Primary User Personas:
- **Individual EV Owners**: Looking for quick battery swaps and maintenance.
- **Fleet Operators**: Managing multiple vehicles and tracking swap history.

---

## 3. Product Features

### A. Real-time Service Ecosystem
- **Instant Booking**: Users can select their vehicle and report an issue in seconds.
- **Dynamic Progress Tracking**: A visual progression system (Finding -> Assigned -> Reaching -> Solving -> Resolved) keeps users informed.
- **Pusher Integration**: Real-time events ensure the UI is always in sync with the backend status updates.

### B. Fleet & Vehicle Management
- **Vehicle Profiles**: Stores specific details about the EV model, battery type, and registration.
- **Service History**: A detailed log of all past battery swaps and repairs for auditability.

### C. Financial Integration
- **Subscription Management**: Users can subscribe to monthly battery swap plans.
- **In-App Wallet**: A digital wallet for one-off payments and service charges.
- **Transaction Security**: Fully encrypted payment gateway integration.

### D. Advanced User Interface
- **Premium Aesthetics**: Uses the "Lufga" custom font and a refined color palette for a premium feel.
- **Skeleton Loading**: Implements shimmer effects to provide a smooth experience during data fetching.
- **Responsive Animations**: Uses Lottie for lightweight yet high-quality animations throughout the app.

---

## 4. Technical Architecture
- **Language**: Dart 3.x
- **UI Framework**: Flutter
- **Architecture Pattern**: BLoC (Business Logic Component)
- **Data Layer**: Repository pattern with Dio for clean API abstraction.
- **Static Assets**: SVG-based iconography for infinite scalability.

---

## 5. Roadmap & Future Scope
- **Expansion of Service Network**: Integration with more third-party service providers.
- **AI-Driven Diagnostics**: Predicting vehicle health issues before they occur.
- **Multi-language Support**: Localizing the app for broader geographic reach.

---

*This document serves as the official project overview for OneCharge / Electro.*

**Export Instructions**: To save this as a PDF, open this file in your editor (like VS Code) and use the "Print to PDF" or "Export to PDF" functionality.
