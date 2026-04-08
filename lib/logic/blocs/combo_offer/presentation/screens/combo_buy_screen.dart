import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/combo_offer/data/models/combo_offer_model.dart';
import 'package:onecharge/logic/blocs/combo_offer/data/models/combo_purchase_model.dart';
import 'package:onecharge/logic/blocs/combo_offer/data/repositories/combo_offer_repository.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/bloc/combo_purchase_bloc.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/bloc/combo_purchase_event.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/bloc/combo_purchase_state.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';
import 'package:onecharge/screen/settings/my_location_screen.dart';
import 'package:onecharge/models/location_model.dart';
import 'package:onecharge/core/storage/location_storage.dart';
import 'package:onecharge/screen/home/home_screen.dart';
import 'package:onecharge/logic/blocs/profile/profile_bloc.dart';
import 'package:onecharge/logic/blocs/profile/profile_event.dart';
import 'package:onecharge/logic/blocs/profile/profile_state.dart';
import 'package:onecharge/logic/blocs/location/location_bloc.dart';
import 'package:onecharge/logic/blocs/location/location_event.dart';
import 'package:onecharge/logic/blocs/location/location_state.dart';



class ComboBuyScreen extends StatefulWidget {
  final ComboOfferModel offer;
  final String? initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;

  const ComboBuyScreen({
    super.key,
    required this.offer,
    this.initialAddress,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<ComboBuyScreen> createState() => _ComboBuyScreenState();
}

class _ComboBuyScreenState extends State<ComboBuyScreen> {
  final _formKey = GlobalKey<FormState>();
  String _paymentMethod = 'paymob';
  
  // Product controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _buildingController = TextEditingController();
  final _notesController = TextEditingController();

  // Service controllers/state
  int? _selectedVehicleId = 105; // Default for demo
  final _locationController = TextEditingController();
  double? _latitude = 25.0719; // Default for demo
  double? _longitude = 55.1396; // Default for demo
  String _bookingType = 'instant';
  final _descriptionController = TextEditingController();
  DateTime? _scheduledAt;
  final _preferredTimeController = TextEditingController();
  String _selectedLocationType = "Inside";

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _locationController.text = widget.initialAddress!;
    }
    if (widget.initialLatitude != null) {
      _latitude = widget.initialLatitude;
    }
    if (widget.initialLongitude != null) {
      _longitude = widget.initialLongitude;
    }
    
    context.read<ProfileBloc>().add(FetchProfile());
    context.read<LocationBloc>().add(FetchLocations());
  }

  bool get hasProducts => widget.offer.products.isNotEmpty;
  bool get hasServices => widget.offer.services.isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _buildingController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _preferredTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ComboPurchaseBloc(
        repository: context.read<ComboOfferRepository>(),
      ),
      child: Builder(
        builder: (context) {
          return MultiBlocListener(
            listeners: [
              BlocListener<ComboPurchaseBloc, ComboPurchaseState>(
                listener: (context, state) {
                  if (state is ComboPurchaseSuccess) {
                    if (state.response.data?.paymentUrl != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentWebView(
                            url: state.response.data!.paymentUrl!,
                            title: 'Payment',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Purchase successful!')),
                      );
                      Navigator.pop(context);
                    }
                  } else if (state is ComboPurchaseFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error)),
                    );
                  }
                },
              ),
              BlocListener<ProfileBloc, ProfileState>(
                listener: (context, state) {
                  if (state is ProfileLoaded) {
                    if (_nameController.text.isEmpty) {
                      _nameController.text = state.customer.name;
                    }
                    if (_phoneController.text.isEmpty) {
                      _phoneController.text = state.customer.phone;
                    }
                    if (_emailController.text.isEmpty) {
                      _emailController.text = state.customer.email;
                    }
                  }
                },
              ),
              BlocListener<LocationBloc, LocationState>(
                listener: (context, state) {
                  if (state is LocationsLoaded) {
                    final location = state.selectedLocation ??
                        (state.locations.isNotEmpty ? state.locations.first : null);

                    if (location != null) {
                      if (_cityController.text.isEmpty) {
                        _cityController.text = location.roadArea ?? '';
                      }
                      if (_addressController.text.isEmpty) {
                        _addressController.text = location.address;
                      }
                      if (_buildingController.text.isEmpty) {
                        _buildingController.text = location.towerBuildingName ?? '';
                      }

                      if (_locationController.text.isEmpty) {
                        _locationController.text =
                            location.name.isNotEmpty ? location.name : location.address;
                        _latitude = location.latitude;
                        _longitude = location.longitude;
                      }
                    }
                  }
                },
              ),
            ],
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Buy ${widget.offer.name}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Lufga',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              body: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOfferSummary(),
                      const SizedBox(height: 24),
                      _buildComboItemsList(),
                      const SizedBox(height: 24),
                      if (hasProducts) ...[
                        _buildSectionTitle('Product Delivery Details'),
                        const SizedBox(height: 16),
                        _buildTextField(_nameController, 'Full Name', Icons.person_outline),
                        _buildTextField(_phoneController, 'Phone Number', Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                        _buildTextField(_emailController, 'Email Address', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                        _buildTextField(_addressController, 'Address', Icons.location_on_outlined),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_cityController, 'City', Icons.location_city_outlined)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(_buildingController, 'Building (Optional)', Icons.business_outlined, isRequired: false)),
                          ],
                        ),
                        _buildTextField(_notesController, 'Notes (Optional)', Icons.note_outlined, isRequired: false, maxLines: 3),
                        const SizedBox(height: 24),
                      ],
                      if (hasServices) ...[
                        _buildSectionTitle('Service Booking Details'),
                        const SizedBox(height: 16),
                        _buildLocationSelector(),
                        const SizedBox(height: 16),
                        _buildBookingTypeSelector(),
                        if (_bookingType == 'scheduled') ...[
                          const SizedBox(height: 12),
                          _buildDateTimePicker(),
                        ],
                        _buildTextField(_preferredTimeController, 'Preferred Time (Optional)', Icons.access_time, isRequired: false),
                        _buildTextField(_descriptionController, 'Description (Optional)', Icons.description_outlined, isRequired: false, maxLines: 3),
                        const SizedBox(height: 24),
                      ],
                      _buildSectionTitle('Payment Method'),
                      const SizedBox(height: 12),
                      _buildPaymentMethodSelector(),
                      const SizedBox(height: 40),
                      _buildSubmitButton(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOfferSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F1F1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: widget.offer.imageUrl.isNotEmpty
                ? Image.network(
                    widget.offer.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.contain,
                  )
                : const Icon(Icons.image, size: 70, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.offer.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Lufga',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'AED ${widget.offer.comboPrice}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Lufga',
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComboItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Included in this Combo'),
        const SizedBox(height: 12),
        ...widget.offer.products.map((product) => _buildItemTile(
          product.name, 
          'Product • ${product.comboPivot?.quantity ?? 1} unit', 
          Icons.inventory_2_outlined
        )),
        ...widget.offer.services.map((service) => _buildItemTile(
          service.name, 
          'Service • ${service.pivot.quantity} session', 
          Icons.build_circle_outlined
        )),
      ],
    );
  }

  Widget _buildItemTile(String name, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lufga',
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Lufga',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontFamily: 'Lufga',
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15, fontFamily: 'Lufga', fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, size: 22, color: Colors.black87),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFF1F1F1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFF1F1F1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.black, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildBookingTypeSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Type',
            style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildChoiceChip('Instant', 'instant', _bookingType == 'instant'),
              const SizedBox(width: 12),
              _buildChoiceChip('Scheduled', 'scheduled', _bookingType == 'scheduled'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, String value, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _bookingType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
          );
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (time != null) {
              setState(() {
                _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
              });
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.black87),
              const SizedBox(width: 12),
              Text(
                _scheduledAt == null 
                  ? 'Select Date & Time' 
                  : DateFormat('yyyy-MM-dd HH:mm').format(_scheduledAt!),
                style: TextStyle(
                  color: _scheduledAt == null ? Colors.grey[600] : Colors.black,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      children: [
        _buildPaymentOption('paymob', 'Pay with card (PaymNow)', Icons.credit_card_outlined),
        const SizedBox(height: 12),
        _buildPaymentOption('wallet', 'Pay with Wallet', Icons.account_balance_wallet_outlined),
      ],
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    bool isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black.withValues(alpha: 0.03) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.black : Colors.grey, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.black : Colors.black54,
              ),
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.black, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocBuilder<ComboPurchaseBloc, ComboPurchaseState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: state is ComboPurchaseLoading ? null : () => _submitOrder(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: state is ComboPurchaseLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Complete Purchase',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        );
      },
    );
  }

  void _submitOrder(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (hasServices && _locationController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a service location')),
        );
        return;
      }
      if (hasServices && _bookingType == 'scheduled' && _scheduledAt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a scheduled time')),
        );
        return;
      }

      final request = ComboPurchaseRequest(
        comboOfferId: widget.offer.id,
        paymentMethod: _paymentMethod,
        
        // Product fields
        name: hasProducts ? _nameController.text : null,
        phone: hasProducts ? _phoneController.text : null,
        email: hasProducts ? _emailController.text : null,
        address: hasProducts ? _addressController.text : null,
        city: hasProducts ? _cityController.text : null,
        building: (hasProducts && _buildingController.text.isNotEmpty) ? _buildingController.text : null,
        notes: (hasProducts && _notesController.text.isNotEmpty) ? _notesController.text : null,

        // Service fields
        customerVehicleId: hasServices ? _selectedVehicleId : null,
        location: hasServices ? _locationController.text : null,
        latitude: hasServices ? _latitude : null,
        longitude: hasServices ? _longitude : null,
        bookingType: hasServices ? _bookingType : null,
        description: (hasServices && _descriptionController.text.isNotEmpty) ? _descriptionController.text : null,
        scheduledAt: (hasServices && _bookingType == 'scheduled') 
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_scheduledAt!) 
            : null,
        preferredTime: (hasServices && _preferredTimeController.text.isNotEmpty) ? _preferredTimeController.text : null,
      );

      context.read<ComboPurchaseBloc>().add(PurchaseComboOfferRequested(request: request));
    }
  }

  Widget _buildLocationSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _openLocationPicker,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.black,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _locationController.text.isEmpty
                            ? "Select Service Location"
                            : _locationController.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: _locationController.text.isEmpty
                              ? Colors.grey[500]
                              : const Color(0xFF757575),
                          fontFamily: 'Lufga',
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedLocationType = value;
              });
            },
            color: Colors.white,
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<String>>[
                  _buildPopupMenuItem('Inside'),
                  _buildPopupMenuItem('Outside'),
                  _buildPopupMenuItem('Road'),
                ],
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedLocationType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Lufga',
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(
        value,
        style: const TextStyle(fontFamily: 'Lufga', fontSize: 14),
      ),
    );
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<LocationModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const MyLocationScreen(isPicker: true),
      ),
    );
    if (result != null) {
      setState(() {
        _locationController.text = result.name.isNotEmpty ? result.name : result.address;
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
      // Persist manual selection
      await LocationStorage.saveSelectedLocation(
        address: _locationController.text,
        lat: _latitude!,
        lng: _longitude!,
        isManual: true,
        id: result.id,
      );
      // Update HomeScreen if it's visible
      HomeScreenState.activeState?.updateLocation(
        _locationController.text,
        _latitude!,
        _longitude!,
        id: result.id,
      );
    }
  }
}

class PaymentWebView extends StatefulWidget {
  final String url;
  final String title;

  const PaymentWebView({super.key, required this.url, required this.title});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
