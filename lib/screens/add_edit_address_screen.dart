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
  // late TextEditingController _landmarkController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _postalCodeController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  String _addressType = 'Home';
  bool _isDefault = false;
  bool _isLoading = false;

  static const Set<String> _usStates = {
    'al', 'alabama', 'ak', 'alaska', 'az', 'arizona', 'ar', 'arkansas', 'ca', 'california',
    'co', 'colorado', 'ct', 'connecticut', 'de', 'delaware', 'fl', 'florida', 'ga', 'georgia',
    'hi', 'hawaii', 'id', 'idaho', 'il', 'illinois', 'in', 'indiana', 'ia', 'iowa',
    'ks', 'kansas', 'ky', 'kentucky', 'la', 'louisiana', 'me', 'maine', 'md', 'maryland',
    'ma', 'massachusetts', 'mi', 'michigan', 'mn', 'minnesota', 'ms', 'mississippi', 'mo', 'missouri',
    'mt', 'montana', 'ne', 'nebraska', 'nv', 'nevada', 'nh', 'new hampshire', 'nj', 'new jersey',
    'nm', 'new mexico', 'ny', 'new york', 'nc', 'north carolina', 'nd', 'north dakota', 'oh', 'ohio',
    'ok', 'oklahoma', 'or', 'oregon', 'pa', 'pennsylvania', 'ri', 'rhode island', 'sc', 'south carolina',
    'sd', 'south dakota', 'tn', 'tennessee', 'tx', 'texas', 'ut', 'utah', 'vt', 'vermont',
    'va', 'virginia', 'wa', 'washington', 'wv', 'west virginia', 'wi', 'wisconsin', 'wy', 'wyoming',
    'dc', 'district of columbia'
  };

  String? _validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    if (trimmed.length > 50) {
      return '$fieldName must not exceed 50 characters';
    }
    final RegExp nameRegExp = RegExp(r"^[\p{L}\s\-']+$", unicode: true);
    if (!nameRegExp.hasMatch(trimmed)) {
      return 'Enter a valid $fieldName (letters, spaces, hyphens, and apostrophes only)';
    }
    if (trimmed.contains('  ') || trimmed.contains('--') || trimmed.contains("''")) {
      return 'Enter a valid $fieldName (no consecutive spaces or symbols)';
    }
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'City is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'City name must be at least 2 characters';
    }
    if (trimmed.length > 50) {
      return 'City name must not exceed 50 characters';
    }
    final RegExp cityRegExp = RegExp(r"^[\p{L}\s\.\-']+$", unicode: true);
    if (!cityRegExp.hasMatch(trimmed)) {
      return 'Enter a valid city name (letters, spaces, dots, hyphens, and apostrophes only)';
    }
    if (trimmed.contains('  ') || trimmed.contains('--') || trimmed.contains("''")) {
      return 'Enter a valid city name (no consecutive spaces or symbols)';
    }
    return null;
  }

  String? _validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'State is required';
    }
    final trimmed = value.trim().toLowerCase();
    if (!_usStates.contains(trimmed)) {
      return 'Invalid US state (e.g. CA)';
    }
    return null;
  }

  String? _validateAddressLine1(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address Line 1 is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Address must be at least 3 characters';
    }
    if (trimmed.length > 150) {
      return 'Address must not exceed 150 characters';
    }
    
    // Check for P.O. Box
    final poBoxRegExp = RegExp(r"\b(p\.?\s*o\.?\s*box|post\s+office\s+box)\b", caseSensitive: false);
    if (poBoxRegExp.hasMatch(trimmed)) {
      return 'Deliveries to P.O. Boxes are not supported';
    }

    // Allowed characters: letters, numbers, spaces, common punctuation/symbols
    final RegExp addressRegExp = RegExp(r"^[\p{L}\p{N}\s\-\.,#/\(\)']+$", unicode: true);
    if (!addressRegExp.hasMatch(trimmed)) {
      return 'Enter a valid address (only letters, numbers, spaces, and common symbols like # , . / - ( ) allowed)';
    }

    return null;
  }

  String? _validateAddressLine2(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.length > 100) {
      return 'Address Line 2 must not exceed 100 characters';
    }
    final poBoxRegExp = RegExp(r"\b(p\.?\s*o\.?\s*box|post\s+office\s+box)\b", caseSensitive: false);
    if (poBoxRegExp.hasMatch(trimmed)) {
      return 'Deliveries to P.O. Boxes are not supported';
    }
    final RegExp addressRegExp = RegExp(r"^[\p{L}\p{N}\s\-\.,#/\(\)']+$", unicode: true);
    if (!addressRegExp.hasMatch(trimmed)) {
      return 'Enter a valid address (only letters, numbers, spaces, and common symbols like # , . / - ( ) allowed)';
    }
    return null;
  }

  bool _isLoadingZipCodes = true;
  List<String> _zipCodes = [];
  String? _selectedZipCode;

  @override
  void initState() {
    super.initState();
    _addressLine1Controller = TextEditingController(text: widget.addressToEdit?.addressLine1 ?? '');
    _addressLine2Controller = TextEditingController(text: widget.addressToEdit?.addressLine2 ?? '');
    // _landmarkController = TextEditingController(text: widget.addressToEdit?.landmark ?? '');
    _cityController = TextEditingController(text: widget.addressToEdit?.city ?? '');
    _stateController = TextEditingController(text: widget.addressToEdit?.state ?? '');
    _countryController = TextEditingController(text: widget.addressToEdit?.country ?? 'USA');
    _postalCodeController = TextEditingController(text: widget.addressToEdit?.postalCode ?? '');
    _firstNameController = TextEditingController(text: widget.addressToEdit?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.addressToEdit?.lastName ?? '');
    
    if (widget.addressToEdit != null) {
      _addressType = widget.addressToEdit!.addressType;
      if (_addressType.isEmpty) _addressType = 'Home'; // Fallback
      _isDefault = widget.addressToEdit!.isDefault;
    } else {
      _loadStoredPincode();
    }
    
    _loadZipCodes();
  }

  Future<void> _loadStoredPincode() async {
    final pincode = await ApiService.getPincode();
    if (pincode != null && mounted) {
      setState(() {
        _postalCodeController.text = pincode;
        if (_zipCodes.contains(pincode)) {
          _selectedZipCode = pincode;
        }
      });
    }
  }

  Future<void> _loadZipCodes() async {
    final response = await ApiService.listAllZipcodesWithZones();
    if (!mounted) return;
    if (response != null && response.data.isNotEmpty) {
      setState(() {
        _zipCodes = response.data.map((e) => e.zipCode).toList();
        _isLoadingZipCodes = false;
        
        final existingZip = _postalCodeController.text;
        if (existingZip.isNotEmpty && _zipCodes.contains(existingZip)) {
          _selectedZipCode = existingZip;
        }
      });
    } else {
      setState(() {
        _isLoadingZipCodes = false;
      });
    }
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    // _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (!_zipCodes.contains(_postalCodeController.text.trim())) {
      _showInvalidPincodePopup();
      return;
    }
    
    setState(() => _isLoading = true);

    final success = await ApiService.updateUserAddress(
      addressId: widget.addressToEdit?.addressId,
      addressLine1: _addressLine1Controller.text,
      addressLine2: _addressLine2Controller.text,
      // landmark: _landmarkController.text,
      city: _cityController.text,
      state: _stateController.text,
      country: _countryController.text,
      postalCode: _postalCodeController.text,
      addressType: _addressType.toLowerCase(),
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      isDefault: _isDefault,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      if (widget.isFirstAddress) {
        // Go to checkout directly
        try {
          final timezone = await FlutterTimezone.getLocalTimezone();
          print("timezone: $timezone");
          await ApiService.updateUserTimezone(timezone);
        } catch (e) {
          print("Error getting timezone: $e");
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CheckoutScreen()),
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

  void _showInvalidPincodePopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsupported Location'),
        content: const Text('We do not cater to this zip code as of now !!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'First Name *',
                      _firstNameController,
                      true,
                      validator: (v) => _validateName(v, 'First Name'),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Last Name *',
                      _lastNameController,
                      true,
                      validator: (v) => _validateName(v, 'Last Name'),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                'Address Line 1 *',
                _addressLine1Controller,
                true,
                validator: _validateAddressLine1,
                textCapitalization: TextCapitalization.words,
              ),
              _buildTextField(
                'Address Line 2',
                _addressLine2Controller,
                false,
                validator: _validateAddressLine2,
                textCapitalization: TextCapitalization.words,
              ),
              // _buildTextField('Landmark', _landmarkController, false),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'City *',
                      _cityController,
                      true,
                      validator: _validateCity,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'State *',
                      _stateController,
                      true,
                      validator: _validateState,
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildZipCodeDropdown()),
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
                    activeColor: AppTheme.instance.mutedColor,
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
                    backgroundColor: AppTheme.instance.secondaryColor ,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool isRequired, {
    bool enabled = true,
    bool hidden = false,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    if (hidden) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        textCapitalization: textCapitalization,
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'This field is required';
          }
          if (validator != null) {
            return validator(value);
          }
          return null;
        },
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
            borderSide: BorderSide(color: AppTheme.instance.mutedColor),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildZipCodeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _selectedZipCode,
        decoration: InputDecoration(
          labelText: 'Zipcode *',
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
            borderSide: BorderSide(color: AppTheme.instance.mutedColor),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: _zipCodes.map((zip) {
          return DropdownMenuItem(
            value: zip,
            child: Text(zip),
          );
        }).toList(),
        onChanged: _isLoadingZipCodes
            ? null
            : (value) {
                setState(() {
                  _selectedZipCode = value;
                  if (value != null) {
                    _postalCodeController.text = value;
                  }
                });
              },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        hint: _isLoadingZipCodes
            ? const Text('Loading...')
            : const Text('Select Zipcode'),
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
            color: isSelected ? AppTheme.instance.mutedColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.instance.mutedColor : const Color(0xFFBCC5CC),
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
