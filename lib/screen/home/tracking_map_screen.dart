import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onecharge/const/onebtn.dart';
import 'package:onecharge/screen/home/widgets/service_notification.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:math' as math;

class TrackingMapScreen extends StatefulWidget {
  final String stage;
  final double progress;

  const TrackingMapScreen({
    super.key,
    required this.stage,
    required this.progress,
  });

  @override
  State<TrackingMapScreen> createState() => _TrackingMapScreenState();
}

class _TrackingMapScreenState extends State<TrackingMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  late double _currentProgress;
  late String _currentStage;
  Timer? _animTimer;

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

  List<LatLng> _getRemainingPath(LatLng currentPos) {
    if (_currentProgress >= 1.0) return [_routePath.last];

    List<LatLng> points = [currentPos];

    double totalDist = 0;
    for (int i = 0; i < _routePath.length - 1; i++) {
      totalDist += _getDistance(_routePath[i], _routePath[i + 1]);
    }
    double targetDist = totalDist * _currentProgress;
    double currentDist = 0;
    int nextPointIndex = 1;

    for (int i = 0; i < _routePath.length - 1; i++) {
      double segmentDist = _getDistance(_routePath[i], _routePath[i + 1]);
      if (currentDist + segmentDist >= targetDist) {
        nextPointIndex = i + 1;
        break;
      }
      currentDist += segmentDist;
    }

    for (int i = nextPointIndex; i < _routePath.length; i++) {
      points.add(_routePath[i]);
    }
    return points;
  }

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.progress;
    _currentStage = widget.stage;
    _startFastTracking();
  }

  @override
  void dispose() {
    _animTimer?.cancel();
    super.dispose();
  }

  void _startFastTracking() {
    // 10 second reach = 1.0 / (10 seconds * 10 updates per second) = 0.01 per 100ms
    _animTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;

      setState(() {
        if (_currentProgress < 1.0) {
          _currentProgress += 0.01;
          if (_currentProgress >= 0.3 && _currentStage == 'assigned') {
            _currentStage = 'reaching';
          }
          if (_currentProgress >= 0.7 && _currentStage == 'reaching') {
            _currentStage = 'solving';
          }
        } else {
          _currentProgress = 1.0;
          timer.cancel();

          // Wait 2 seconds at 'solving' then show 'resolved'
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _currentStage = 'resolved';
              });
            }
          });
        }
        _addCustomMarkers();
        _addPolyline();
      });
    });
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

    // Current agent position interpolated by progress along the route
    final LatLng movingPos = _calculatePosition(_currentProgress);

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
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _center,
          icon: blackMarker,
          anchor: const Offset(0.5, 0.5),
        ),
      );
    });
  }

  void _addPolyline() {
    final LatLng currentPos = _calculatePosition(_currentProgress);
    final List<LatLng> pathPoints = _getRemainingPath(currentPos);

    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('path'),
        points: pathPoints,
        color: Colors.black,
        width: 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _center,
              zoom: 14,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: _markers,
            polylines: _polylines,
            zoomControlsEnabled: false,
            myLocationEnabled: false,
          ),

          // Custom header toast
          ServiceNotificationOverlay(
            stage: _currentStage,
            progress: _currentProgress,
            onDismiss: () => Navigator.pop(context),
            onSolved: () => Navigator.pop(context),
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
    );
  }
}
