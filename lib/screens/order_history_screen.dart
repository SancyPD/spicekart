import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/order_history_response.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../utils/date_formatter.dart';
import 'order_detail_screen.dart';
import 'rating_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _isLoading = true;
  OrderHistoryResponse? _orderHistory;
  final Set<int> _expandedOrders = {};

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);

    final response = await ApiService.listOrders();

    if (mounted) {
      setState(() {
        _orderHistory = response;
        _isLoading = false;
      });
    }
  }

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
        body: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8, right: 20),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4D555C),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'ITC Avant Garde Gothic Pro',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                     Text(
                      'Order History',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.instance.secondaryColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchOrders,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : (_orderHistory == null ||
                            _orderHistory!.data.data.isEmpty)
                      ? Stack(
                          children: [
                            ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                            ),
                            _buildEmptyState(),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _orderHistory!.data.data.length,
                          itemBuilder: (context, index) {
                            final order = _orderHistory!.data.data[index];
                            return _buildOrderCard(order);
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF4D555C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Datum order) {
    bool isExpanded = _expandedOrders.contains(order.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Order Card (Clickable to go to Details)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(order: order),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${order.orderNumber}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374338),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            order.orderStatus,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order.orderStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _getStatusColor(order.orderStatus),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormatter.formatDateWithTime(order.placedAt),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A8D7C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.items.length == 1
                                ? '${order.items.length} Item'
                                : '${order.items.length} Items',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4D555C),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${order.totalAmount}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374338),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedOrders.remove(order.id);
                            } else {
                              _expandedOrders.add(order.id);
                            }
                          });
                        },
                        child: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xFF4D555C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expanded Items Section
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6F7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.itemType == 'food'
                                    ? 'https://spicekart1.mockupz.in/storage/food_items/${item.item?.image}'
                                    : 'https://spicekart1.mockupz.in/storage/products/${item.item?.productImage}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.image,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.itemName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF4D555C),
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'x${item.quantity}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374338),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (order.orderStatus.toLowerCase() == 'delivered' ||
                      order.orderStatus.toLowerCase() == 'completed')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RatingScreen(order: order),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.instance.secondaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'RATE ORDER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'placed':
        return Colors.blue;
      case 'assigned':
        return Colors.cyan;
      case 'picking':
        return Colors.deepPurple;
      case 'packed':
        return Colors.indigo;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      case 'out_for_delivery':
        return Colors.brown;
      default:
        return Colors.blueGrey;
    }
  }

}
