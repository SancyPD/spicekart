import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../model/user_address.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import 'add_edit_address_screen.dart';
import 'checkout_screen.dart';
import 'delivery_instructions_screen.dart';

class UserAddressListScreen extends StatefulWidget {
  final bool isFromCheckout;
  final bool isInitialFlow;
  const UserAddressListScreen({
    super.key,
    this.isFromCheckout = true,
    this.isInitialFlow = false,
  });

  @override
  State<UserAddressListScreen> createState() => _UserAddressListScreenState();
}

class _UserAddressListScreenState extends State<UserAddressListScreen> {
  List<UserAddress> _addresses = [];
  bool _isLoading = true;
  int? _selectedAddressId;
  // Removed _cartType

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  // Removed didChangeDependencies

  Future<void> _fetchAddresses() async {
    setState(() => _isLoading = true);
    final response = await ApiService.listUserAddresses();
    if (response != null && response.data != null) {
      setState(() {
        _addresses = response.data!;
        if (_addresses.isNotEmpty) {
           // pre-select default address if any, otherwise first one
          final defaultAddr = _addresses.where((a) => a.isDefault).toList();
          if (defaultAddr.isNotEmpty) {
            _selectedAddressId = defaultAddr.first.addressId;
          } else {
            _selectedAddressId = _addresses.first.addressId;
          }
        }
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _handleSaveAddress() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an address')),
      );
      return;
    }

    final address = _addresses.firstWhere((a) => a.addressId == _selectedAddressId);

    setState(() => _isLoading = true);
    final success = await ApiService.updateCheckoutAddress(
      addressId: address.addressId!,
    );
    
    if (success && mounted) {
      if (widget.isInitialFlow) {
        final instructions = await ApiService.getDeliveryInstructions();
        bool hasInstructions = false;
        if (instructions != null && instructions['status'] == 1) {
          final data = instructions['data'];
          if (data != null && data['property_type_id'] != null && data['property_type_id'] > 0) {
            hasInstructions = true;
          }
        }

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (hasInstructions) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CheckoutScreen(),
            // No RouteSettings with cartType
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DeliveryInstructionsScreen(
                isInitialFlow: true,
              ),
            // No RouteSettings with cartType
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        Navigator.pop(context, true);
      }
    } else if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update address')),
      );
    }
  }
  Future<void> _deleteAddress(int addressId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await ApiService.deleteUserAddress(addressId);
      if (success) {
        _fetchAddresses();
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete address')),
        );
      }
    }
  }


  void _navigateToAddEditAddress({UserAddress? address}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressScreen(
          addressToEdit: address,
          isFirstAddress: false,
        ),
      ),
    );

    if (result == true) {
      // Refresh list if address was successfully added or edited
      _fetchAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          'Select Address',
          style: TextStyle(
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? _buildEmptyState()
              : _buildAddressList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_on_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Addresses Found',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF4D555C),
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _navigateToAddEditAddress(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.instance.mutedColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Add New Address',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._addresses.map((address) => _buildAddressCard(address)),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _navigateToAddEditAddress(),
          icon: Icon(Icons.add, color: AppTheme.instance.mutedColor),
          label: Text(
            'ADD NEW ADDRESS',
            style: TextStyle(
              color: AppTheme.instance.mutedColor,
              fontFamily: 'ITC Avant Garde Gothic Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppTheme.instance.mutedColor, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleSaveAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.instance.secondaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              widget.isInitialFlow
                  ? 'PROCEED'
                  : (widget.isFromCheckout ? 'PROCEED TO CHECKOUT' : 'SAVE'),
              style: const TextStyle(
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
    );
  }

  Widget _buildAddressCard(UserAddress address) {
    final isSelected = _selectedAddressId == address.addressId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppTheme.instance.mutedColor : const Color(0xFFE0E0E0),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: AppTheme.instance.mutedColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedAddressId = address.addressId;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Radio<int>(
                value: address.addressId ?? 0,
                groupValue: _selectedAddressId ?? 0,
                onChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      _selectedAddressId = value;
                    });
                  }
                },
                activeColor: AppTheme.instance.mutedColor,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.addressType,
                          style: const TextStyle(
                            color: Color(0xFF4D555C),
                            fontSize: 16,
                            fontFamily: 'ITC Avant Garde Gothic Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.instance.mutedColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppTheme.instance.mutedColor),
                            ),
                            child: Text(
                              'Default',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.instance.mutedColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF4D555C)),
                          onPressed: () => _navigateToAddEditAddress(address: address),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          onPressed: () => _deleteAddress(address.addressId!),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      address.addressLine1,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF4D555C)),
                    ),
                    if (address.addressLine2 != null && address.addressLine2!.isNotEmpty)
                      Text(
                        address.addressLine2!,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF4D555C)),
                      ),
                    Text(
                      '${address.city}, ${address.state} ${address.postalCode}',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF4D555C)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
