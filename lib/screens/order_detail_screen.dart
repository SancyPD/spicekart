import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/order_history_response.dart';
import '../utils/app_theme.dart';
import '../utils/date_formatter.dart';

class OrderDetailScreen extends StatelessWidget {
  final Datum order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4D555C)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Order Details',
            style: TextStyle(
              color: Color(0xFF4D555C),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'ITC Avant Garde Gothic Pro',
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Header
              _buildSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order ID: ${order.orderNumber}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374338),
                          ),
                        ),
                        _buildStatusBadge(order.orderStatus),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Placed on: ${DateFormatter.formatDateWithTime(order.placedAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9AA097),
                      ),
                    ),
                  ],
                ),
              ),

              // Delivery Address
              _buildSectionTitle('Delivery Address'),
              _buildSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.address.firstName} ${order.address.lastName}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374338),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.address.addressLine1}${order.address.addressLine2 != null ? ', ${order.address.addressLine2}' : ''}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF4D555C)),
                    ),
                    if (order.address.landmark.isNotEmpty)
                      Text(
                        'Landmark: ${order.address.landmark}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF4D555C)),
                      ),
                    Text(
                      '${order.address.city}, ${order.address.state} - ${order.address.postalCode}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF4D555C)),
                    ),
                  ],
                ),
              ),

              // Order Items
              _buildSectionTitle('Items (${order.items.length})'),
              _buildSection(
                padding: EdgeInsets.zero,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item.itemType == 'food'
                                    ? 'https://spicekart1.mockupz.in/storage/food_items/${item.item?.image}'
                                    : 'https://spicekart1.mockupz.in/storage/products/${item.item?.productImage}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.itemName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF374338),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${item.unitPrice} x ${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF7A8D7C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${item.totalPrice}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374338),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bill Details
              _buildSectionTitle('Bill Details'),
              _buildSection(
                child: Column(
                  children: [
                    _buildBillRow('Subtotal', '\$${order.subTotal}'),
                    _buildBillRow('Tax', '\$${order.taxAmount}'),
                    _buildBillRow('Delivery Fee', '\$${order.deliveryFee}'),
                    if (double.tryParse(order.tipAmount) != null && double.parse(order.tipAmount) > 0)
                      _buildBillRow('Tip', '\$${order.tipAmount}'),
                    if (double.tryParse(order.couponDiscount) != null && double.parse(order.couponDiscount) > 0)
                      _buildBillRow('Discount', '-\$${order.couponDiscount}', isDiscount: true),
                    if (double.tryParse(order.walletUsed.toString()) != null && double.parse(order.walletUsed.toString()) > 0)
                      _buildBillRow('Wallet Used', '-\$${order.walletUsed}', isDiscount: true),
                    const Divider(height: 24),
                    _buildBillRow(
                      'Total Amount',
                      '\$${order.totalAmount}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9AA097),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSection({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'packed':
        color = Colors.indigo;
        break;
      case 'failed':
      case 'cancelled':
        color = Colors.red;
        break;
      case 'out_for_delivery':
        color = Colors.brown;
        break;
      default:
        color = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String value,
      {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? const Color(0xFF374338) : const Color(0xFF4D555C),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isDiscount
                  ? Colors.red
                  : (isTotal ? const Color(0xFF374338) : const Color(0xFF374338)),
            ),
          ),
        ],
      ),
    );
  }

}
