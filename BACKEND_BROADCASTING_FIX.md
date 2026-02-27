# 1Charge – Backend Broadcasting Fix (Implementation Plan)

## Problem

The Flutter customer app successfully connects to the Reverb WebSocket server and subscribes to the private channel `private-customer.{id}.driver-location`. However, **no events are received** when:

- A driver is offered a ticket (`ticket.offered`)
- A driver accepts/is assigned to a ticket (`ticket.assigned`)
- A driver's location changes (`driver.location.updated`)

The Flutter app is confirmed working — the issue is that the **Laravel backend is not broadcasting events to Reverb**.

---

## Architecture Reminder

```
┌──────────────┐     HTTP (REST API)      ┌──────────────────────┐
│  Flutter App  │ ◄─────────────────────► │  app.onecharge.io    │
│  (Customer)   │                         │  (Laravel Main App)  │
│               │     WebSocket (wss)     │                      │
│               │ ◄──────────────────┐    │  MUST broadcast      │
└──────────────┘                     │    │  events to Reverb ──►│
                                     │    └──────────────────────┘
                                     │              │
                                     │              │ Internal connection
                                     │              ▼
                                     │    ┌──────────────────────────────────┐
                                     └────│  one-charge-1-charge.up.railway  │
                                          │  (Laravel Reverb Server)         │
                                          │  Port 443, wss                   │
                                          └──────────────────────────────────┘
```

**Flow:**
1. Laravel Main App broadcasts an event → Reverb receives it
2. Reverb pushes the event → Flutter app receives it via WebSocket
3. If step 1 is broken, step 2 never happens

---

## Step 1: Verify Environment Variables

Open the Railway dashboard for the **Main App** (`app.onecharge.io`) and check these environment variables:

| Variable | Required Value | Why |
|----------|---------------|-----|
| `BROADCAST_CONNECTION` | `reverb` | If set to `log`, events go to the log file instead of Reverb |
| `REVERB_APP_ID` | (must match Reverb service) | Identifies this app to Reverb |
| `REVERB_APP_KEY` | `5csvb4sew88zqnmcxuqg` | Must be exactly the same on both Main App and Reverb |
| `REVERB_APP_SECRET` | (must match Reverb service) | Used for server-to-server auth |
| `REVERB_HOST` | Internal Railway hostname of Reverb service | How the Main App connects to Reverb internally |
| `REVERB_PORT` | `443` or `8080` (depends on Railway config) | Port Reverb listens on |
| `REVERB_SCHEME` | `https` or `http` (depends on internal vs external) | Protocol for server-to-server connection |

### Common Mistakes:
- ❌ `BROADCAST_CONNECTION=log` → Events are logged, not broadcast
- ❌ `BROADCAST_CONNECTION` not set at all → Defaults to `log`
- ❌ `REVERB_APP_KEY` mismatch between Main App and Reverb service
- ❌ `REVERB_HOST` pointing to `localhost` instead of the Railway internal URL

### How to verify:
```bash
# SSH into your Railway Main App or use Railway CLI
php artisan tinker
>>> config('broadcasting.default')
# Should return: "reverb"

>>> config('broadcasting.connections.reverb')
# Should show the correct host, port, key, secret
```

---

## Step 2: Create the Broadcast Events

You need **3 event classes** in Laravel. Check if they exist. If not, create them.

### Event 1: `TicketOffered`

- **When to fire:** When a ticket is created and offered to drivers
- **Channel:** `private-customer.{customer_id}.driver-location`
- **Event name:** `ticket.offered`
- **Data to include:**
  - `ticket_id` (integer)
  - `status` (string: "offered")
  - `driver_id` (integer, nullable)
  - `driver_name` (string, nullable)
  - `message` (string, e.g., "Looking for a driver...")

### Event 2: `TicketAssigned`

- **When to fire:** When a driver accepts/is assigned to a ticket
- **Channel:** `private-customer.{customer_id}.driver-location`
- **Event name:** `ticket.assigned`
- **Data to include:**
  - `ticket_id` (integer)
  - `status` (string: "assigned")
  - `driver_id` (integer)
  - `driver_name` (string)
  - `latitude` (float)
  - `longitude` (float)
  - `last_location_updated_at` (datetime string)

### Event 3: `DriverLocationUpdated`

- **When to fire:** When the driver's GPS location changes (from the driver app)
- **Channel:** `private-customer.{customer_id}.driver-location`
- **Event name:** `driver.location.updated`
- **Data to include:**
  - `ticket_id` (integer)
  - `driver_id` (integer)
  - `driver_name` (string)
  - `latitude` (float)
  - `longitude` (float)
  - `last_location_updated_at` (datetime string)

### Key Requirements for Each Event Class:
1. Must implement `ShouldBroadcast` interface
2. Must define `broadcastOn()` returning the private channel
3. Must define `broadcastAs()` returning the exact event name
4. Must define `broadcastWith()` returning the data array

---

## Step 3: Fire Events in the Correct Places

### 3a. When a ticket is offered to drivers

Find the controller/service method that creates a ticket or offers it to drivers. After the ticket is saved, fire the event:

- **File to look in:** `TicketController` or `TicketService`
- **Method:** The one that handles `POST /api/customer/tickets` or the job that offers tickets
- **Action:** After the ticket status becomes `offered`, broadcast `TicketOffered`

### 3b. When a driver accepts/is assigned

Find the controller/service method where a driver accepts a ticket.

- **File to look in:** `DriverTicketController` or similar
- **Method:** The one that handles driver accepting a ticket (e.g., `acceptTicket`, `assignDriver`)
- **Action:** After the ticket status becomes `assigned` and the driver is linked, broadcast `TicketAssigned`

### 3c. When the driver's location updates

Find the controller/service method where the driver app sends GPS coordinates.

- **File to look in:** `DriverLocationController` or similar
- **Method:** The one that handles `POST /api/driver/location` or similar
- **Action:** After saving the new location, find the driver's active ticket(s) and broadcast `DriverLocationUpdated` for each

---

## Step 4: Authorize the Private Channel

The Flutter app subscribes to `private-customer.{id}.driver-location`. Laravel must authorize this channel.

Check `routes/channels.php` for a channel authorization rule:

- **Channel pattern:** `customer.{customerId}.driver-location`
- **Authorization:** The authenticated user's ID must match `{customerId}`
- **Auth endpoint:** `POST /api/broadcasting/auth` (already configured at `app.onecharge.io`)

### How to verify:
- The Flutter app already shows `🔐 Authorizing channel...` and succeeds, so this step is likely already done.
- If you see `401` errors in Flutter logs during authorization, this step needs fixing.

---

## Step 5: Quick Test with Tinker

Before writing any code, test if Reverb is receiving events at all:

```bash
# SSH into Railway Main App
php artisan tinker

# Manually broadcast a test event to see if Flutter receives it
>>> use Illuminate\Support\Facades\Broadcast;
>>> Broadcast::channel('customer.100.driver-location', function () { return true; });

# Or dispatch a test event manually:
>>> event(new App\Events\TicketAssigned(App\Models\Ticket::find(317)));
```

**What to look for:**
- If the Flutter app shows `🚗 [RealtimeService] Event: ticket.assigned`, Reverb is working and the issue was just that the event wasn't being fired in the business logic.
- If nothing appears in Flutter, check the Reverb service logs on Railway for errors.

---

## Step 6: Check Reverb Service Logs

Go to Railway dashboard → Reverb service → Logs

**Healthy logs look like:**
```
Starting server on 0.0.0.0:8080...
New connection: socket_id=445586219.485184023
Channel subscribed: private-customer.100.driver-location
```

**Unhealthy signs:**
- No "Channel subscribed" log → The Main App isn't connected to Reverb
- Errors about authentication → `REVERB_APP_KEY` or `REVERB_APP_SECRET` mismatch
- No logs at all → Reverb service is not running

---

## Step 7: Verify the Full Flow

After implementing the fixes, test the complete flow:

1. **Customer books a ticket** (Flutter app)
   - Flutter should show: `🎫 Event: ticket.offered`
   
2. **Driver accepts the ticket** (Driver app or admin panel)
   - Flutter should show: `🚗 Event: ticket.assigned`
   - UI should switch from "Finding driver..." to "Driver Ajay is on the way"
   
3. **Driver moves** (Driver app sends location updates)
   - Flutter should show: `📍 Event: driver.location.updated`
   - Map marker should move in real-time

---

## Summary Checklist

| # | Task | Status |
|---|------|--------|
| 1 | `BROADCAST_CONNECTION=reverb` in .env | ⬜ Check |
| 2 | `REVERB_APP_KEY` matches on both services | ⬜ Check |
| 3 | `REVERB_HOST` points to Reverb internal URL | ⬜ Check |
| 4 | `TicketOffered` event class exists and implements `ShouldBroadcast` | ⬜ Check/Create |
| 5 | `TicketAssigned` event class exists and implements `ShouldBroadcast` | ⬜ Check/Create |
| 6 | `DriverLocationUpdated` event class exists and implements `ShouldBroadcast` | ⬜ Check/Create |
| 7 | Events are fired in the correct controller methods | ⬜ Check/Add |
| 8 | Channel authorization exists in `routes/channels.php` | ⬜ Check (likely done) |
| 9 | Test with Tinker to confirm Reverb receives events | ⬜ Test |
| 10 | End-to-end test: book → assign → location update | ⬜ Test |

---

## Flutter Side (Already Complete ✅)

The Flutter customer app is fully implemented and verified:
- ✅ WebSocket connects to `one-charge-1-charge.up.railway.app:443`
- ✅ Subscribes to `private-customer.{id}.driver-location`
- ✅ Listens for `ticket.offered`, `ticket.assigned`, `driver.location.updated`
- ✅ Channel authorization works (Bearer token sent to `app.onecharge.io/api/broadcasting/auth`)
- ✅ UI updates when events are received
- ✅ No aggressive polling (backend-friendly)

**No changes needed on the Flutter side.** The backend just needs to start broadcasting the events.
