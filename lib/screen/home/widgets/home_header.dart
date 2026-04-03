import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:onecharge/features/auth/presentation/bloc/auth_state.dart';
import 'package:onecharge/logic/blocs/location/location_bloc.dart';
import 'package:onecharge/logic/blocs/location/location_event.dart';
import 'package:onecharge/logic/blocs/profile/profile_bloc.dart';
import 'package:onecharge/logic/blocs/profile/profile_state.dart';
import 'package:onecharge/models/location_model.dart';
import 'package:onecharge/screen/home/my_location_screen.dart';
import 'package:onecharge/screen/home/settings_screen.dart';
import 'package:onecharge/screen/notification/notification_screen.dart';
import 'package:onecharge/screen/wallet/wallet_screen.dart';
import 'package:onecharge/core/storage/location_storage.dart';
import 'package:onecharge/core/services/push_notification_service.dart';
import 'package:onecharge/utils/toast_utils.dart';

class HomeHeader extends StatelessWidget {
  final String currentAddress;
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final Function(LocationModel)? onLocationChanged;
  final String? hintText;

  const HomeHeader({
    super.key,
    required this.currentAddress,
    this.searchController,
    this.onSearchChanged,
    this.onLocationChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
                if (result is LocationModel && onLocationChanged != null) {
                  onLocationChanged!(result);
                }
              },
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  String? imageUrl;
                  if (state is ProfileLoaded) {
                    imageUrl = state.customer.profileImage;
                  } else if (state is ProfileUpdated) {
                    imageUrl = state.customer.profileImage;
                  } else if (state is ProfileUpdating) {
                    imageUrl = state.currentCustomer.profileImage;
                  }
                  return CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                      imageUrl ??
                          'https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D',
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      String name = "User";
                      if (state is Authenticated) {
                        name = state.user.name.split(' ')[0];
                      }
                      return Text(
                        'Hi $name',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lufga',
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push<LocationModel>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyLocationScreen(
                            isPicker: true,
                          ),
                        ),
                      );
                      if (result != null) {
                        context.read<LocationBloc>().add(SelectLocation(result));
                        if (onLocationChanged != null) {
                          onLocationChanged!(result);
                        }
                        await LocationStorage.saveSelectedLocation(
                          address: result.name.isNotEmpty ? result.name : result.address,
                          lat: result.latitude,
                          lng: result.longitude,
                          isManual: true,
                          id: result.id,
                        );
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color.fromARGB(255, 23, 23, 23),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            currentAddress,
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF1D1B20).withOpacity(0.6),
                              fontFamily: 'Lufga',
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WalletScreen(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.shade200,
                child: Image.asset(
                  "assets/home/mingcute_wallet-fill.png",
                  height: 25,
                  width: 25,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
              onLongPress: () {
                PushNotificationService().triggerTestNotification();
                ToastUtils.showToast(context, "Testing Notification... Check your tray!");
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xffF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_outlined,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (searchController != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xffF5F5F5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: hintText ?? 'Search for any services',
                hintStyle: TextStyle(
                  color: Color(0xffB8B9BD),
                  fontSize: 14,
                  fontFamily: 'Lufga',
                ),
                icon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
      ],
    );
  }
}
