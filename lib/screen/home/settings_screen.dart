import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onecharge/screen/home/chat_support_screen.dart';
import 'package:onecharge/screen/home/my_location_screen.dart';
import 'package:onecharge/screen/home/my_vehicle_screen.dart';
import 'package:onecharge/screen/home/profile_screen.dart';
import 'package:onecharge/screen/home/recent_bookings_screen.dart';
import 'package:onecharge/screen/home/terms_conditions_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/auth/auth_bloc.dart';
import 'package:onecharge/logic/blocs/auth/auth_event.dart';
import 'package:onecharge/logic/blocs/auth/auth_state.dart';
import 'package:onecharge/screen/login/phone_login.dart';
import 'package:onecharge/test/testlogin.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_bloc.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_state.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_event.dart';
import 'package:onecharge/models/vehicle_list_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:onecharge/logic/blocs/delete_vehicle/delete_vehicle_bloc.dart';
import 'package:onecharge/logic/blocs/delete_vehicle/delete_vehicle_event.dart';
import 'package:onecharge/logic/blocs/delete_vehicle/delete_vehicle_state.dart';
import 'package:onecharge/core/storage/token_storage.dart';
import 'package:onecharge/logic/blocs/profile/profile_bloc.dart';
import 'package:onecharge/logic/blocs/profile/profile_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  OverlayEntry? _toastEntry;
  String _userName = 'Saleh Al Sabah';
  bool _notificationsEnabled = true;
  bool _isDeleteLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final name = await TokenStorage.readUserName();
    final notifications = await TokenStorage.readNotificationStatus();
    if (mounted) {
      setState(() {
        if (name != null) _userName = name;
        _notificationsEnabled = notifications;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DeleteVehicleBloc, DeleteVehicleState>(
          listener: (context, state) {
            if (state is DeleteVehicleLoading) {
              _isDeleteLoading = true;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 15,
                      ),
                    ),
                  );
                },
              );
            } else if (state is DeleteVehicleSuccess) {
              if (_isDeleteLoading) {
                Navigator.of(context).pop();
                _isDeleteLoading = false;
              }
              _showToast('Vehicle removed successfully');
              context.read<VehicleListBloc>().add(FetchVehicles());
            } else if (state is DeleteVehicleError) {
              if (_isDeleteLoading) {
                Navigator.of(context).pop();
                _isDeleteLoading = false;
              }
              _showToast(state.message, isError: true);
            }
          },
        ),
        BlocListener<VehicleListBloc, VehicleListState>(
          listener: (context, state) {
            if (state is VehicleListError) {
              _showToast(state.message, isError: true);
            }
          },
        ),
      ],
      child: Scaffold(
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
            'Settings',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Profile Section
              Center(
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    String name = _userName;
                    String? profileImage;

                    if (state is ProfileLoaded) {
                      name = state.customer.name;
                      profileImage = state.customer.profileImage;
                    }

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: profileImage != null
                                ? NetworkImage(profileImage)
                                : const NetworkImage(
                                        'https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D',
                                      )
                                      as ImageProvider,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Lufga',
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          'Individual',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontFamily: 'Lufga',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Vehicle Cards
              BlocBuilder<VehicleListBloc, VehicleListState>(
                builder: (context, state) {
                  if (state is VehicleListLoading) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Row(
                          children: List.generate(
                            2,
                            (index) => Container(
                              width: MediaQuery.of(context).size.width * 0.44,
                              height: 210,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F7F7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Shimmer.fromColors(
                                baseColor: const Color(0xffE0E0E0),
                                highlightColor: Colors.white,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        color: Colors.white,
                                        margin: const EdgeInsets.all(16),
                                      ),
                                    ),
                                    Container(
                                      width: 100,
                                      height: 16,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 12,
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final vehicles = (state is VehicleListLoaded)
                      ? state.vehicles
                      : <VehicleListItem>[];

                  if (vehicles.isEmpty) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: vehicles.map((vehicle) {
                          final title =
                              '${vehicle.brand?.name ?? ''} ${vehicle.model?.name ?? ''}'
                                  .trim();
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.44,
                            margin: const EdgeInsets.only(right: 10),
                            child: _buildVehicleCard(
                              title.isEmpty ? 'Unknown Vehicle' : title,
                              vehicle.vehicleNumber,
                              'assets/home/profilecar.png',
                              const Color(0xFFF7F7F7),
                              onDelete: () => _showDeleteConfirmationDialog(
                                context,
                                vehicle,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Menu Items
              _buildMenuItem(
                Icons.person_outline,
                'Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),

              _buildMenuItem(
                Icons.history,
                'Recent Bookings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecentBookingsScreen(),
                    ),
                  );
                },
              ),

              _buildMenuItem(
                Icons.notifications_none_outlined,
                'Notification',
                onTap: () {
                  setState(() {
                    _notificationsEnabled = !_notificationsEnabled;
                  });
                  TokenStorage.saveNotificationStatus(_notificationsEnabled);
                },
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (val) async {
                    setState(() {
                      _notificationsEnabled = val;
                    });
                    await TokenStorage.saveNotificationStatus(val);
                  },
                  activeColor: Colors.green,
                ),
              ),
              _buildMenuItem(
                Icons.directions_car_filled_outlined,
                'My Vehicle',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyVehicleScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                Icons.location_on_outlined,
                'Location',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyLocationScreen(),
                    ),
                  );
                },
              ),

              _buildMenuItem(
                Icons.info_outline,
                'Terms & Conditions',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsConditionsScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                Icons.chat_bubble_outline,
                'Chat Support',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatSupportScreen(),
                    ),
                  );
                },
              ),

              _buildMenuItem(
                Icons.logout,
                'Log out',
                showArrow: false,
                onTap: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthLoggedOut) {
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Testlogin(),
                            ),
                            (route) => false,
                          );
                        } else if (state is AuthError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                      },
                      child: CupertinoAlertDialog(
                        title: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontFamily: 'Lufga',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        content: const Text(
                          'Are you sure you want to log out from\nthe application?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Lufga',
                            color: Color(0xff636363),
                          ),
                        ),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Lufga',
                              ),
                            ),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              context.read<AuthBloc>().add(LogoutRequested());
                            },
                            child: BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                if (state is AuthLoading) {
                                  return const CupertinoActivityIndicator();
                                }
                                return const Text(
                                  'Log Out',
                                  style: TextStyle(
                                    color: Color(0xffFF0000),
                                    fontFamily: 'Lufga',
                                    fontWeight: FontWeight.w700,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              _buildMenuItem(
                Icons.delete_outline,
                'Delete Account',
                showArrow: false,
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text(
                        'Are You Sure?',
                        style: TextStyle(
                          fontFamily: 'Lufga',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      content: const Text(
                        'You will permanently lose your account. This action cannot be undone',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Lufga',
                          color: Color(0xff636363),
                        ),
                      ),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Lufga',
                            ),
                          ),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              color: Color(0xffFF0000),
                              fontFamily: 'Lufga',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    VehicleListItem vehicle,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          'Remove Vehicle',
          style: TextStyle(fontFamily: 'Lufga', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to remove ${vehicle.brand?.name ?? ''} ${vehicle.model?.name ?? ''} (${vehicle.vehicleNumber}) from your account?',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Lufga', color: Color(0xff636363)),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontFamily: 'Lufga'),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              context.read<DeleteVehicleBloc>().add(
                DeleteVehicleRequested(vehicle.id),
              );
            },
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: Color(0xffFF0000),
                fontFamily: 'Lufga',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(
    String title,
    String subtitle,
    String imagePath,
    Color bgColor, {
    VoidCallback? onDelete,
  }) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Image.asset(imagePath, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lufga',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB8B9BD),
                    fontFamily: 'Lufga',
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    Widget? trailing,
    bool showArrow = true,
    Color textColor = Colors.black,
    Color iconColor = Colors.grey,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontFamily: 'Lufga',
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          trailing ??
          (showArrow
              ? const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                )
              : null),
      onTap: onTap,
    );
  }
}
