import 'package:flutter/material.dart';
import '../model/order_history_response.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class RatingScreen extends StatefulWidget {
  final Order order;

  const RatingScreen({super.key, required this.order});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _deliveryRating = 0;
  Map<int, double> _itemRatings = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (var item in widget.order.items) {
      _itemRatings[item.id] = 0;
    }
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);

    List<Map<String, dynamic>> itemRatingsList = _itemRatings.entries.map((e) {
      return {
        'item_id': e.key,
        'rating': e.value,
      };
    }).toList();

    final success = await ApiService.rateOrder(
      orderId: widget.order.id,
      deliveryRating: _deliveryRating,
      itemRatings: itemRatingsList,
    );

    setState(() => _isSubmitting = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted successfully!')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit rating. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF323C42)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate your order',
              style: TextStyle(
                color: Color(0xFF171717),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'ITC Avant Garde Gothic Pro',
              ),
            ),
            Text(
              '${widget.order.itemCount} Items • \$${widget.order.totalAmount}',
              style: const TextStyle(
                color: Color(0xFF9AA097),
                fontSize: 12,
                fontFamily: 'ITC Avant Garde Gothic Pro',
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*// Delivery Experience Card
            _buildRatingCard(
              title: 'Rate your delivery experience',
              child: Row(
                children: [
                   Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delivery_dining, color: AppTheme.instance.secondaryLightBlue, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivered by ${widget.order.deliveryBoyName ?? "Gilbert Fernandez Stancilas"}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374338),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStarRating(
                          onRatingChanged: (rating) => setState(() => _deliveryRating = rating),
                          currentRating: _deliveryRating,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),*/
            const SizedBox(height: 16),
            // Items Section
            _buildRatingCard(
              title: 'Rate the items in your order',
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.order.items.length,
                separatorBuilder: (context, index) => const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, index) {
                  final item = widget.order.items[index];
                  return _buildItemRatingRow(item);
                },
              ),
            ),
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
     /* bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitRating,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5E5E5),
              foregroundColor: const Color(0xFF4D555C),
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4D555C)),
                  )
                : const Text(
                    'Submit Rating',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'ITC Avant Garde Gothic Pro',
                    ),
                  ),
          ),
        ),
      ),*/
    );
  }

  Widget _buildRatingCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374338),
              fontFamily: 'ITC Avant Garde Gothic Pro',
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildItemRatingRow(OrderItem item) {
    return Row(
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
              'https://spicekart.mockupz.in/storage/products/${item.productImage}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
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
                '₹${item.productPrice} • ${item.varientSize}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7A8D7C),
                ),
              ),
              const SizedBox(height: 8),
              _buildStarRating(
                onRatingChanged: (rating) => setState(() => _itemRatings[item.id] = rating),
                currentRating: _itemRatings[item.id] ?? 0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating({required Function(double) onRatingChanged, required double currentRating}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        int starIndex = index + 1;
        bool isSelected = currentRating >= starIndex;
        return GestureDetector(
          onTap: () => onRatingChanged(starIndex.toDouble()),
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: isSelected 
              ? Image.asset('assets/images/star.png', width: 28, height: 28)
              : const Icon(Icons.star_border, color: Color(0xFFC8D3D9), size: 32),
          ),
        );
      }),
    );
  }
}
