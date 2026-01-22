import 'package:flutter/material.dart';
import 'package:onecharge/screen/home/location_map_screen.dart';

class SavedLocation {
  final String title;
  final String address;
  final IconData icon;
  final bool isDefault;

  SavedLocation({
    required this.title,
    required this.address,
    required this.icon,
    this.isDefault = false,
  });
}

class MyLocationScreen extends StatefulWidget {
  const MyLocationScreen({super.key});

  @override
  State<MyLocationScreen> createState() => _MyLocationScreenState();
}

class _MyLocationScreenState extends State<MyLocationScreen> {
  String selectedLocation = 'Home';
  final List<SavedLocation> _locations = [
    SavedLocation(
      title: 'Home',
      address: '1901 Thornridge Cir. Shiloh, Hawaii 81063',
      icon: Icons.home_outlined,
      isDefault: true,
    ),
    SavedLocation(
      title: 'Work',
      address: '4517 Washington Ave. Manchester, Kentucky 39495',
      icon: Icons.work_outline,
    ),
    SavedLocation(
      title: 'Other',
      address: '2464 Royal Ln. Mesa, New Jersey 45463',
      icon: Icons.location_on_outlined,
    ),
  ];

  Future<void> _navigateAndAddLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationMapScreen(initialAddress: ''),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        _locations.add(
          SavedLocation(
            title: 'New Location ${_locations.length + 1}',
            address: result,
            icon: Icons.location_on_outlined,
          ),
        );
      });
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
      body: SingleChildScrollView(
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _locations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final location = _locations[index];
                return _buildLocationItem(
                  icon: location.icon,
                  title: location.title,
                  address: location.address,
                  isDefault: location.isDefault,
                  onDelete: () {
                    setState(() {
                      _locations.removeAt(index);
                    });
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
      ),
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required String title,
    required String address,
    bool isDefault = false,
    required VoidCallback onDelete,
  }) {
    bool isSelected = selectedLocation == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLocation = title;
        });
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
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lufga',
                          color: Colors.black,
                        ),
                      ),
                      if (isDefault) ...[
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
                    address,
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
