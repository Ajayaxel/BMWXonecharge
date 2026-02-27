import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onecharge/const/onebtn.dart';
import 'package:onecharge/screen/home/widgets/service_notification.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/models/ticket_model.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_bloc.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_event.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_state.dart';

class TrackingMapScreen extends StatefulWidget {
  final String stage;
  final double progress;
  final Ticket? ticket;

  const TrackingMapScreen({
    super.key,
    required this.stage,
    required this.progress,
    this.ticket,
  });

  @override
  State<TrackingMapScreen> createState() => _TrackingMapScreenState();
}

class _TrackingMapScreenState extends State<TrackingMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  late double _currentProgress;
  late String _currentStage;
  Timer? _animTimer;
  Ticket? _currentTicket;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  /// Safely parses a nullable string to a double.
  /// Returns null if the string is null, empty, or not a valid number,
  /// or if it is exactly 0.0 (which indicates an unset location).
  double? _safeParseLatLng(String? value) {
    if (value == null || value.isEmpty || value == 'null') return null;
    final parsed = double.tryParse(value);
    if (parsed == null || parsed == 0.0) return null;
    return parsed;
  }

  /// Gets the driver's real LatLng from the current ticket driver info.
  /// Returns null if the driver location is not available.
  LatLng? get _driverLatLng {
    final lat = _safeParseLatLng(_currentTicket?.driver?.latitude);
    final lng = _safeParseLatLng(_currentTicket?.driver?.longitude);
    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }
    return null;
  }

  /// Gets the customer's ticket/destination LatLng.
  /// Returns null if the ticket location is not available.
  LatLng? get _destinationLatLng {
    final lat = _safeParseLatLng(_currentTicket?.latitude);
    final lng = _safeParseLatLng(_currentTicket?.longitude);
    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }
    return null;
  }

  /// Returns the best initial camera target: driver location > ticket location > null
  LatLng? get _bestInitialTarget {
    return _driverLatLng ?? _destinationLatLng;
  }

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.progress;
    _currentStage = widget.stage;
    _currentTicket = widget.ticket;
    _addCustomMarkers();
    _addPolyline();

    // Immediately fetch the latest driver location from the API when the map
    // opens. This ensures markers and polyline show up right away even before
    // the next driver.location.updated socket event fires.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _currentTicket != null) {
        print(
          '🗺️ [TrackingMap] Fetching latest driver location from API for ticket ${_currentTicket!.id}',
        );
        context.read<TicketBloc>().add(
          FetchDriverLocationRequested(_currentTicket!.id),
        );
      }
    });
  }

  @override
  void didUpdateWidget(TrackingMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stage != widget.stage) {
      setState(() {
        _currentStage = widget.stage;
      });
    }
    if (oldWidget.progress != widget.progress) {
      setState(() {
        _currentProgress = widget.progress;
      });
    }
    if (oldWidget.ticket != widget.ticket) {
      setState(() {
        _currentTicket = widget.ticket;
      });
      _addCustomMarkers();
      _addPolyline();
      _updateCameraBounds();
    }
  }

  @override
  void dispose() {
    _animTimer?.cancel();
    super.dispose();
  }

  /// Returns true if the driver's lastLocationUpdatedAt timestamp is within
  /// [maxAgeMinutes] minutes. Prevents stale DB coordinates (e.g. hardcoded
  /// San Francisco stored days ago) from being shown on the map.
  bool _isLocationFresh(String? lastUpdatedAt, {int maxAgeMinutes = 30}) {
    if (lastUpdatedAt == null || lastUpdatedAt.isEmpty) return false;
    try {
      final lastUpdated = DateTime.parse(lastUpdatedAt).toUtc();
      final ageMinutes = DateTime.now()
          .toUtc()
          .difference(lastUpdated)
          .inMinutes;
      print(
        '⏱️ [TrackingMap] Driver location age: $ageMinutes min (max: $maxAgeMinutes)',
      );
      return ageMinutes <= maxAgeMinutes;
    } catch (_) {
      return false;
    }
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
  }

  Future<BitmapDescriptor> _getBlackCircleMarker() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.black;
    const double radius = 15.0;

    // Draw white border
    canvas.drawCircle(
      const Offset(radius, radius),
      radius,
      Paint()..color = Colors.white,
    );
    // Draw black circle
    canvas.drawCircle(const Offset(radius, radius), radius - 2, paint);

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      radius.toInt() * 2,
      radius.toInt() * 2,
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<void> _addCustomMarkers() async {
    final Uint8List markerIconBytes = await _getBytesFromAsset(
      'assets/home/mapcars.png',
      100,
    );
    final BitmapDescriptor carIcon = BitmapDescriptor.fromBytes(
      markerIconBytes,
    );

    final BitmapDescriptor blackMarker = await _getBlackCircleMarker();

    // Get real driver position from ticket data
    final LatLng? movingPos = _driverLatLng;
    // Get real destination position from ticket data
    final LatLng? destination = _destinationLatLng;

    setState(() {
      _markers.clear();

      // Only add the driver marker if we have a real location
      if (movingPos != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('agent_car'),
            position: movingPos,
            icon: carIcon,
            anchor: const Offset(0.5, 0.5),
          ),
        );
      }

      // Only add the destination marker if we have a real location
      if (destination != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: destination,
            icon: blackMarker,
            anchor: const Offset(0.5, 0.5),
          ),
        );
      }
    });
  }

  void _updateCameraBounds() {
    final LatLng? movingPos = _driverLatLng;
    final LatLng? destination = _destinationLatLng;

    // If we only have one location, zoom to that
    if (movingPos != null && destination == null) {
      _controller.future.then((controller) {
        controller.animateCamera(CameraUpdate.newLatLngZoom(movingPos, 14));
      });
      return;
    }

    if (movingPos == null && destination != null) {
      _controller.future.then((controller) {
        controller.animateCamera(CameraUpdate.newLatLngZoom(destination, 14));
      });
      return;
    }

    // If we have both locations, fit bounds
    if (movingPos != null && destination != null) {
      if (movingPos.latitude == destination.latitude &&
          movingPos.longitude == destination.longitude) {
        _controller.future.then((controller) {
          controller.animateCamera(CameraUpdate.newLatLngZoom(movingPos, 14));
        });
        return;
      }

      double minLat = math.min(movingPos.latitude, destination.latitude);
      double maxLat = math.max(movingPos.latitude, destination.latitude);
      double minLng = math.min(movingPos.longitude, destination.longitude);
      double maxLng = math.max(movingPos.longitude, destination.longitude);

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      _controller.future.then((controller) {
        controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
      });
    }
    // If neither location is available, do nothing — keep the current view
  }

  void _addPolyline() {
    final LatLng? movingPos = _driverLatLng;
    final LatLng? destination = _destinationLatLng;

    _polylines.clear();

    // Only draw a polyline if we have both real locations
    if (movingPos != null && destination != null) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('path'),
          points: [movingPos, destination],
          color: Colors.black,
          width: 4,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TicketBloc, TicketState>(
      listener: (context, state) {
        if (state is TicketDetailSuccess) {
          setState(() {
            _currentTicket = state.ticket;
            final status = state.ticket.status?.toLowerCase() ?? '';

            if (state.ticket.driver != null ||
                status == 'assigned' ||
                status == 'reaching') {
              _currentStage = 'reaching';
              _currentProgress = 0.5;
            }
            if (status == 'solving' ||
                status == 'in_progress' ||
                status == 'at_location' ||
                status == 'reached') {
              _currentStage = 'solving';
              _currentProgress = 1.0;
            }
            if (status == 'completed' || status == 'resolved') {
              _currentStage = 'resolved';
            } else if (status == 'cancelled' || status == 'rejected') {
              _currentStage = 'none';
              if (Navigator.canPop(context)) {
                Navigator.pop(context); // Close map if cancelled
              }
            }
          });
          _addCustomMarkers();
          _addPolyline();
          _updateCameraBounds();
        } else if (state is DriverLocationLoaded) {
          if (state.driver != null) {
            final incomingDriver = state.driver!;

            // Check if the location timestamp is recent enough to trust.
            // If the driver location was stored days ago (e.g. hardcoded San
            // Francisco), we only take the driver identity (name/image) and
            // intentionally discard the stale coordinates.
            final bool fresh = _isLocationFresh(
              incomingDriver.lastLocationUpdatedAt,
            );

            final TicketDriver safeDriver;
            if (fresh) {
              print(
                '✅ [TrackingMap] Driver location is fresh — using coordinates: '
                'lat=${incomingDriver.latitude}, lng=${incomingDriver.longitude}',
              );
              safeDriver = incomingDriver;
            } else {
              print(
                '🚫 [TrackingMap] Driver location is STALE '
                '(${incomingDriver.lastLocationUpdatedAt}) — discarding coordinates.',
              );
              // Preserve any real GPS already in _currentTicket.driver
              final existing = _currentTicket?.driver;
              safeDriver = TicketDriver(
                id: incomingDriver.id,
                name: incomingDriver.name,
                image: incomingDriver.image,
                phone: incomingDriver.phone,
                latitude: existing?.latitude, // keep real GPS if we have it
                longitude: existing?.longitude, // keep real GPS if we have it
                lastLocationUpdatedAt: incomingDriver.lastLocationUpdatedAt,
              );
            }

            setState(() {
              if (_currentTicket != null) {
                _currentTicket = _currentTicket!.copyWith(driver: safeDriver);
              }
              if (_currentStage == 'finding' || _currentStage == 'none') {
                _currentStage = 'reaching';
              }
              final status = _currentTicket?.status?.toLowerCase() ?? '';
              if (status == 'completed' || status == 'resolved') {
                _currentStage = 'resolved';
              } else if (status == 'cancelled' || status == 'rejected') {
                _currentStage = 'none';
                if (Navigator.canPop(context)) Navigator.pop(context);
              } else if (status == 'at_location' ||
                  status == 'in_progress' ||
                  status == 'reached' ||
                  status == 'solving') {
                _currentStage = 'solving';
                _currentProgress = 1.0;
              } else if (status == 'assigned' || status == 'reaching') {
                _currentProgress = 0.5;
              }
            });
            _addCustomMarkers();
            _addPolyline();
            _updateCameraBounds();
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                // Use real driver location if available, else use ticket/customer
                // location, else default to a safe fallback (0,0 avoided).
                target: _bestInitialTarget ?? const LatLng(25.2048, 55.2708),
                zoom: 14,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                // After map is created, move camera to the real location
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) _updateCameraBounds();
                });
              },
              markers: _markers,
              polylines: _polylines,
              zoomControlsEnabled: false,
              myLocationEnabled: false,
            ),

            // Custom header toast
            if (_currentStage != 'none' && _currentStage != 'reached')
              ServiceNotificationOverlay(
                stage: _currentStage,
                progress: _currentProgress,
                ticket: _currentTicket,
                onDismiss: () => Navigator.pop(context),
                onSolved: () => Navigator.pop(context, true),
                onTap: () {}, // Already on map
              ),

            // Bottom Button
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: OneBtn(
                onPressed: () {
                  Navigator.pop(context);
                },
                text: "Back to home",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
