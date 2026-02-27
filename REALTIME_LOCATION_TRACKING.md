# Real-time Driver Location Tracking Documentation

This document outlines the implementation of real-time driver location tracking using WebSockets (Laravel Reverb / Pusher) in the OneCharge application.

## 1. Overview
Previously, the application used HTTP polling to fetch the driver's location every 5 seconds. This has been replaced with a WebSocket-based approach for:
- Reduced server load.
- Real-time updates with lower latency.
- Better user experience (smooth marker movement).

## 2. Technical Stack
- **Server**: Laravel Reverb (WebSocket Server).
- **Client**: `pusher_reverb_flutter` package.
- **Protocol**: Pusher Protocol (WSS).
- **Authentication**: Bearer Token via `POST /api/broadcasting/auth`.

## 3. Configuration (`AppConfig`)
Configuration values are stored in `lib/core/config/app_config.dart`:
- `reverbHost`: `app.onecharge.io`
- `reverbPort`: `8080`
- `reverbAppKey`: `5csvb4sew88zqnmcxuqg`
- `broadcastingAuthUrl`: `https://app.onecharge.io/api/broadcasting/auth`

## 4. Implementation Details

### A. RealtimeService (`lib/logic/services/realtime_service.dart`)
A dedicated service class handles the connection lifecycle and event binding.
- **Connect**: `connectAndSubscribe()` initializes the `ReverbClient` and subscribes to the private channel.
- **Authorize**: Uses a custom authorizer to inject the Bearer token for private channels.
- **Events**:
  - `ticket.offered`: Triggered when an agent is being searched.
  - `ticket.assigned`: Triggered when an agent accepts the ticket.
  - `driver.location.updated`: Triggered for live GPS updates.

### B. UI Integration (`lib/screen/home/home_screen.dart`)
The `HomeScreen` manages the `RealtimeService` instance when a service flow is active.
- When a booking is successful, `_initRealtimeService(ticket)` is called.
- Event callbacks update the `TicketBloc` via `UpdateDriverLocation` events.
- Stage transitions (Finding -> Reaching) are handled in real-time.

### C. Map Updates (`lib/screen/home/tracking_map_screen.dart`)
The map screen listens to the `TicketBloc` for `DriverLocationLoaded` states.
- When a new location arrives via WebSocket, the Bloc emits a state.
- The map listener updates the driver marker position smoothly.
- The camera follows the driver if significant movement is detected.

## 5. Usage Flow
1. **User creates a ticket**: `startServiceFlow` is called.
2. **Initial Fetch**: A REST call is made to get the current driver position (if assigned).
3. **WebSocket Connect**: The app subscribes to `private-customer.{customerId}.driver-location`.
4. **Live Updates**: GPS coordinates flow over the socket and update the UI instantly.
5. **Completion**: When the ticket status reaches `at_location` or `reached`, the socket is disconnected.

## 6. Maintenance
To add new events:
1. Bind the event in `RealtimeService.connectAndSubscribe()`.
2. Add a corresponding event to `TicketEvent`.
3. Handle the event in `TicketBloc`.
4. Update the UI listener in the relevant screens.
