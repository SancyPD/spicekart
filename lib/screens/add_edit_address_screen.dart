import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../model/user_address.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import 'checkout_screen.dart';

class AddEditAddressScreen extends StatefulWidget {
  final UserAddress? addressToEdit;
  final bool isFirstAddress; // If true, on save go directly to checkout

  const AddEditAddressScreen({
    super.key,
    this.addressToEdit,
    this.isFirstAddress = false,
  });

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _landmarkController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _postalCodeController;

  String _addressType = 'Home';
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addressLine1Controller = TextEditingController(text: widget.addressToEdit?.addressLine1 ?? '');
    _addressLine2Controller = TextEditingController(text: widget.addressToEdit?.addressLine2 ?? '');
    _landmarkController = TextEditingController(text: widget.addressToEdit?.landmark ?? '');
    _cityController = TextEditingController(text: widget.addressToEdit?.city ?? '');
    _stateController = TextEditingController(text: widget.addressToEdit?.state ?? '');
    _countryController = TextEditingController(text: widget.addressToEdit?.country ?? '');
    _postalCodeController = TextEditingController(text: widget.addressToEdit?.postalCode ?? '');
    
    if (widget.addressToEdit != null) {
      _addressType = widget.addressToEdit!.addressType;
      if (_addressType.isEmpty) _addressType = 'Home'; // Fallback
      _isDefault = widget.addressToEdit!.isDefault;
    }
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final success = await ApiService.updateUserAddress(
      addressId: widget.addressToEdit?.addressId,
      addressLine1: _addressLine1Controller.text,
      addressLine2: _addressLine2Controller.text,
      landmark: _landmarkController.text,
      city: _cityController.text,
      state: _stateController.text,
      country: _countryController.text,
      postalCode: _postalCodeController.text,
      addressType: _addressType.toLowerCase(),
      isDefault: _isDefault,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      if (widget.isFirstAddress) {
        // Go to checkout directly
        try {
          final timezone = await FlutterTimezone.getLocalTimezone();
          print("timezone: ${timezone.identifier}");
          await ApiService.updateUserTimezone(timezone.identifier);
        } catch (e) {
          print("Error getting timezone: $e");
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CheckoutScreen()),
        );
      } else {
        // Pop back to the address list
        Navigator.pop(context, true); // true indicates saving was successful
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save address. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.addressToEdit == null ? 'Add Address' : 'Edit Address',
          style: const TextStyle(
            color: Color(0xFF4D555C),
            fontSize: 18,
            fontFamily: 'ITC Avant Garde Gothic Pro',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4D555C)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Address Line 1 *', _addressLine1Controller, true),
              _buildTextField('Address Line 2', _addressLine2Controller, false),
              _buildTextField('Landmark', _landmarkController, false),
              Row(
                children: [
                  Expanded(child: _buildTextField('City *', _cityController, true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('State *', _stateController, true)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildTextField('Country *', _countryController, true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Postal Code *', _postalCodeController, true)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Address Type',
                style: TextStyle(
                  color: Color(0xFF4D555C),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'ITC Avant Garde Gothic Pro',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                   _buildAddressTypeOption('Home'),
                   const SizedBox(width: 8),
                   _buildAddressTypeOption('Work'),
                   const SizedBox(width: 8),
                   _buildAddressTypeOption('Other'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    onChanged: (val) {
                      setState(() {
                        _isDefault = val ?? false;
                      });
                    },
                    activeColor: AppTheme.instance.mutedBlue,
                  ),
                  const Text(
                    'Set as Default Address',
                    style: TextStyle(
                      color: Color(0xFF4D555C),
                      fontSize: 16,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38B547),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'SAVE ADDRESS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'ITC Avant Garde Gothic Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        validator: isRequired ? (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
          return null;
        } : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF4D555C),
            fontSize: 14,
            fontFamily: 'ITC Avant Garde Gothic Pro',
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFBCC5CC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFBCC5CC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppTheme.instance.mutedBlue),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildAddressTypeOption(String type) {
    final isSelected = _addressType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _addressType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.instance.mutedBlue : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.instance.mutedBlue : const Color(0xFFBCC5CC),
            ),
          ),
          child: Text(
            type,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF4D555C),
              fontSize: 14,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
