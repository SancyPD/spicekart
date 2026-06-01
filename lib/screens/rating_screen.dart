import 'package:flutter/material.dart';
import '../model/order_history_response.dart';
import '../services/api_service.dart';

class RatingScreen extends StatefulWidget {
  final Datum order;

  const RatingScreen({super.key, required this.order});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  Map<int, double> _itemRatings = {};
  Set<int> _loadingItems = {};

  @override
  void initState() {
    super.initState();
    for (var item in widget.order.items) {
      _itemRatings[item.id] = 0;
    }
  }

  Future<void> _handleRateProduct(ItemElement item, double rating) async {
    setState(() {
      _loadingItems.add(item.id);
      _itemRatings[item.id] = rating;
    });

    final success = await ApiService.rateProduct(
      productId: item.id,
      rating: rating,
    );

    if (mounted) {
      setState(() {
        _loadingItems.remove(item.id);
      });

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to rate ${item.itemName}')),
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
              '${widget.order.items.length} Items • ${widget.order.totalAmount}',
              style: const TextStyle(
                color: Color(0xFF9AA097),
                fontSize: 12,
                fontFamily: 'ITC Avant Garde Gothic Pro',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'DONE',
              style: TextStyle(
                color: Color(0xFF374338),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Items Section
            _buildRatingCard(
              title: 'Rate the items in your order',
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.order.items.length,
                separatorBuilder: (context, index) => const Divider(
                    height: 32, thickness: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, index) {
                  final item = widget.order.items[index];
                  return _buildItemRatingRow(item);
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
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

  Widget _buildItemRatingRow(ItemElement item) {
    bool isLoading = _loadingItems.contains(item.id);

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
              'https://spicekart1.mockupz.in/storage/products/${item.item?.productImage}',
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
                '\$${item.unitPrice}${item.variant!.varientSize.isNotEmpty ? " • ${item.variant?.varientSize}" : ""}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7A8D7C),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStarRating(
                    onRatingChanged: (rating) => _handleRateProduct(item, rating),
                    currentRating: _itemRatings[item.id] ?? 0,
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF4D555C),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating(
      {required Function(double) onRatingChanged,
      required double currentRating}) {
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
                : const Icon(Icons.star_border,
                    color: Color(0xFFC8D3D9), size: 32),
          ),
        );
      }),
    );
  }
}
