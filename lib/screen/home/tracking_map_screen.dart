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

  static const LatLng _center = LatLng(25.2048, 55.2708); // User Location

  static const List<LatLng> _routePath = [
    LatLng(25.2158, 55.2858), // Start
    LatLng(25.2145, 55.2840),
    LatLng(25.2132, 55.2818),
    LatLng(25.2115, 55.2795),
    LatLng(25.2098, 55.2770),
    LatLng(25.2082, 55.2748),
    LatLng(25.2065, 55.2725),
    LatLng(25.2048, 55.2708), // End
  ];

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  double _getDistance(LatLng p1, LatLng p2) {
    return math.sqrt(
      math.pow(p1.latitude - p2.latitude, 2) +
          math.pow(p1.longitude - p2.longitude, 2),
    );
  }

  LatLng _calculatePosition(double progress) {
    if (progress <= 0) return _routePath.first;
    if (progress >= 1) return _routePath.last;

    double totalDist = 0;
    for (int i = 0; i < _routePath.length - 1; i++) {
      totalDist += _getDistance(_routePath[i], _routePath[i + 1]);
    }

    double targetDist = totalDist * progress;
    double currentDist = 0;

    for (int i = 0; i < _routePath.length - 1; i++) {
      double segmentDist = _getDistance(_routePath[i], _routePath[i + 1]);
      if (currentDist + segmentDist >= targetDist) {
        double segmentProgress = (targetDist - currentDist) / segmentDist;
        return LatLng(
          _routePath[i].latitude +
              (_routePath[i + 1].latitude - _routePath[i].latitude) *
                  segmentProgress,
          _routePath[i].longitude +
              (_routePath[i + 1].longitude - _routePath[i].longitude) *
                  segmentProgress,
        );
      }
      currentDist += segmentDist;
    }
    return _routePath.last;
  }

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.progress;
    _currentStage = widget.stage;
    _currentTicket = widget.ticket;
    _addCustomMarkers();
    _addPolyline();
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
      100, // Set to 40 for a balanced look
    );
    final BitmapDescriptor carIcon = BitmapDescriptor.fromBytes(
      markerIconBytes,
    );

    final BitmapDescriptor blackMarker = await _getBlackCircleMarker();

    // Current agent position: use real location if available, else interpolate
    LatLng movingPos;
    if (_currentTicket?.driver?.latitude != null &&
        _currentTicket?.driver?.longitude != null) {
      movingPos = LatLng(
        double.parse(_currentTicket!.driver!.latitude!),
        double.parse(_currentTicket!.driver!.longitude!),
      );
    } else {
      movingPos = _calculatePosition(_currentProgress);
    }

    // Add ambient cars
    final carPositions = [
      const LatLng(25.2028, 55.2668),
      const LatLng(25.1988, 55.2788),
      const LatLng(25.2128, 55.2828),
    ];

    setState(() {
      _markers.clear();

      // Moving Agent
      _markers.add(
        Marker(
          markerId: const MarkerId('agent_car'),
          position: movingPos,
          icon: carIcon,
          anchor: const Offset(0.5, 0.5),
        ),
      );

      for (int i = 0; i < carPositions.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId('car_$i'),
            position: carPositions[i],
            icon: carIcon,
            anchor: const Offset(0.5, 0.5),
          ),
        );
      }

      // Add user marker
      LatLng destination = _center;
      if (_currentTicket?.latitude != null &&
          _currentTicket?.longitude != null) {
        destination = LatLng(
          double.parse(_currentTicket!.latitude!),
          double.parse(_currentTicket!.longitude!),
        );
      }

      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          icon: blackMarker,
          anchor: const Offset(0.5, 0.5),
        ),
      );
    });
  }

  void _updateCameraBounds() {
    LatLng movingPos;
    if (_currentTicket?.driver?.latitude != null &&
        _currentTicket?.driver?.longitude != null) {
      movingPos = LatLng(
        double.parse(_currentTicket!.driver!.latitude!),
        double.parse(_currentTicket!.driver!.longitude!),
      );
    } else {
      movingPos = _calculatePosition(_currentProgress);
    }

    LatLng destination = _center;
    if (_currentTicket?.latitude != null && _currentTicket?.longitude != null) {
      destination = LatLng(
        double.parse(_currentTicket!.latitude!),
        double.parse(_currentTicket!.longitude!),
      );
    }

    double minLat = math.min(movingPos.latitude, destination.latitude);
    double maxLat = math.max(movingPos.latitude, destination.latitude);
    double minLng = math.min(movingPos.longitude, destination.longitude);
    double maxLng = math.max(movingPos.longitude, destination.longitude);

    if (minLat == maxLat && minLng == maxLng) {
      _controller.future.then((controller) {
        controller.animateCamera(CameraUpdate.newLatLngZoom(movingPos, 14));
      });
      return;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _controller.future.then((controller) {
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    });
  }

  void _addPolyline() {
    LatLng movingPos;
    if (_currentTicket?.driver?.latitude != null &&
        _currentTicket?.driver?.longitude != null) {
      movingPos = LatLng(
        double.parse(_currentTicket!.driver!.latitude!),
        double.parse(_currentTicket!.driver!.longitude!),
      );
    } else {
      movingPos = _calculatePosition(_currentProgress);
    }

    LatLng destination = _center;
    if (_currentTicket?.latitude != null && _currentTicket?.longitude != null) {
      destination = LatLng(
        double.parse(_currentTicket!.latitude!),
        double.parse(_currentTicket!.longitude!),
      );
    }

    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('path'),
        points: [movingPos, destination],
        color: Colors.black,
        width: 4,
      ),
    );
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
            setState(() {
              // Update local ticket with new driver info
              if (_currentTicket != null) {
                _currentTicket = _currentTicket!.copyWith(driver: state.driver);
              }

              // Priority 1: If we have a driver, we are no longer "finding"
              if (_currentStage == 'finding' || _currentStage == 'none') {
                _currentStage = 'reaching';
              }

              // Priority 2: Check for arrival
              final status = _currentTicket?.status?.toLowerCase() ?? '';

              if (status == 'completed' || status == 'resolved') {
                _currentStage = 'resolved';
              } else if (status == 'cancelled' || status == 'rejected') {
                _currentStage = 'none';
                if (Navigator.canPop(context)) {
                  Navigator.pop(context); // Close map if cancelled
                }
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
                target: (_currentTicket?.driver?.latitude != null)
                    ? LatLng(
                        double.parse(_currentTicket!.driver!.latitude!),
                        double.parse(_currentTicket!.driver!.longitude!),
                      )
                    : _center,
                zoom: 14,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
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
