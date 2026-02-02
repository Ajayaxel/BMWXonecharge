import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/location/location_bloc.dart';
import 'package:onecharge/logic/blocs/location/location_event.dart';
import 'package:onecharge/logic/blocs/location/location_state.dart';
import 'package:onecharge/models/location_model.dart';
import 'package:onecharge/screen/home/location_map_screen.dart';

class MyLocationScreen extends StatefulWidget {
  final bool isPicker;
  const MyLocationScreen({super.key, this.isPicker = false});

  @override
  State<MyLocationScreen> createState() => _MyLocationScreenState();
}

class _MyLocationScreenState extends State<MyLocationScreen> {
  int? selectedLocationId;
  OverlayEntry? _toastEntry;

  @override
  void initState() {
    super.initState();
    // Fetch locations when the screen is initialized
    context.read<LocationBloc>().add(FetchLocations());
  }

  @override
  void dispose() {
    _toastEntry?.remove();
    super.dispose();
  }

  void _showToast(String message, {bool isError = false}) {
    _toastEntry?.remove();
    _toastEntry = null;

    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, -20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: isError ? Colors.red : Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lufga',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    _toastEntry = entry;
    overlayState.insert(entry);

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      if (_toastEntry == entry) {
        _toastEntry?.remove();
        _toastEntry = null;
      }
    });
  }

  Future<void> _navigateAndAddLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationMapScreen(initialAddress: ''),
      ),
    );

    if (result != null && result is LocationModel) {
      if (mounted) {
        context.read<LocationBloc>().add(AddLocation(result));
      }
      if (widget.isPicker) {
        // If we are in picker mode and just added a new location,
        // return it immediately
        if (mounted) Navigator.pop(context, result);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Location',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Lufga',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _navigateAndAddLocation,
            icon: const Icon(
              Icons.add_location_alt_outlined,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: BlocConsumer<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationAdded) {
            _showToast('Location added successfully');
          } else if (state is LocationDeleted) {
            _showToast('Location deleted successfully');
          } else if (state is LocationError) {
            _showToast(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is LocationLoading && state is! LocationsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          List<LocationModel> locations = [];
          if (state is LocationsLoaded) {
            locations = state.locations;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saved Locations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lufga',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                if (locations.isEmpty && state is! LocationLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        'No saved locations found',
                        style: TextStyle(
                          fontFamily: 'Lufga',
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: locations.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final location = locations[index];
                      return _buildLocationItem(
                        icon: _getIconForName(location.name),
                        location: location,
                        onDelete: () {
                          if (location.id != null) {
                            context.read<LocationBloc>().add(
                              DeleteLocation(location.id!),
                            );
                          }
                        },
                      );
                    },
                  ),
                const SizedBox(height: 30),
                Center(
                  child: TextButton.icon(
                    onPressed: _navigateAndAddLocation,
                    icon: const Icon(Icons.add, color: Colors.blue),
                    label: const Text(
                      'Add New Location',
                      style: TextStyle(
                        color: Colors.blue,
                        fontFamily: 'Lufga',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForName(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('home')) return Icons.home_outlined;
    if (lowerName.contains('work') || lowerName.contains('office')) {
      return Icons.work_outline;
    }
    return Icons.location_on_outlined;
  }

  Widget _buildLocationItem({
    required IconData icon,
    required LocationModel location,
    required VoidCallback onDelete,
  }) {
    bool isSelected = selectedLocationId == location.id;

    return GestureDetector(
      onTap: () {
        if (widget.isPicker) {
          Navigator.pop(context, location);
        } else {
          setState(() {
            selectedLocationId = location.id;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.black, width: 1) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF7F7F7) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          location.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Lufga',
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (location.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'DEFAULT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location.address,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontFamily: 'Lufga',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
