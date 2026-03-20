import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/order_history_response.dart';
import '../utils/app_theme.dart';
import 'rating_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _isLoading = true;
  OrderHistoryResponse? _orderHistory;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    
    // Using dummy data as API is not available
    await Future.delayed(const Duration(seconds: 1));
    
    final dummyOrders = [
      Order(
        id: 1,
        orderNumber: "SK12345",
        orderDate: "27 Feb 2026, 04:30 PM",
        totalAmount: "440.00",
        status: "Delivered",
        itemCount: 6,
        deliveryBoyName: "Gilbert Fernandez Stancilas",
        items: [
          OrderItem(
            id: 101,
            productId: 1,
            productName: "Modern Multigrain Bread- 13 Grains & Seeds (Zero ...",
            productImage: "bread.png", // Use actual names from your local assets if possible
            varientSize: "400 g",
            productPrice: "60.00",
            quantity: 1,
          ),
          OrderItem(
            id: 102,
            productId: 2,
            productName: "Milky Mist Probiotic Curd",
            productImage: "curd.png",
            varientSize: "400 g",
            productPrice: "60.00",
            quantity: 1,
          ),
          OrderItem(
            id: 103,
            productId: 3,
            productName: "Carrot",
            productImage: "carrot.png",
            varientSize: "500 g",
            productPrice: "49.00",
            quantity: 1,
          ),
          OrderItem(
            id: 104,
            productId: 4,
            productName: "Pintola All Natural Peanut Butter Crunchy, Unsweet...",
            productImage: "peanut_butter.png",
            varientSize: "350 g",
            productPrice: "155.00",
            quantity: 1,
          ),
          OrderItem(
            id: 105,
            productId: 5,
            productName: "Indian Tomato (Thakkali)",
            productImage: "tomato.png",
            varientSize: "500 g",
            productPrice: "33.00",
            quantity: 1,
          ),
        ],
      ),
      Order(
        id: 2,
        orderNumber: "SK12344",
        orderDate: "25 Feb 2026, 11:20 AM",
        totalAmount: "120.00",
        status: "Completed",
        itemCount: 2,
        deliveryBoyName: "John Doe",
        items: [],
      ),
      Order(
        id: 3,
        orderNumber: "SK12343",
        orderDate: "20 Feb 2026, 02:15 PM",
        totalAmount: "85.50",
        status: "Cancelled",
        itemCount: 1,
        items: [],
      ),
    ];

    setState(() {
      _orderHistory = OrderHistoryResponse(
        status: 1,
        message: "Success",
        data: dummyOrders,
      );
      _isLoading = false;
    });
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
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4D555C),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'ITC Avant Garde Gothic Pro',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Order History',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4D555C),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ITC Avant Garde Gothic Pro',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _orderHistory == null || _orderHistory!.data.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _orderHistory!.data.length,
                            itemBuilder: (context, index) {
                              final order = _orderHistory!.data[index];
                              return _buildOrderCard(order);
                            },
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
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade400),
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

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.orderNumber}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374338),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(order.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.orderDate,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7A8D7C),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order.itemCount} Items',
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
              if (order.status.toLowerCase() == 'delivered' || order.status.toLowerCase() == 'completed')
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RatingScreen(order: order),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.instance.secondaryLightBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text(
                    'RATE ORDER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
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
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
