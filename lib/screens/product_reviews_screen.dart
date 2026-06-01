import 'package:flutter/material.dart';
import '../model/product_detail_response.dart' as pd;
import '../utils/app_theme.dart';

class ProductReviewsScreen extends StatelessWidget {
  final List<pd.Rating> ratings;
  final String productName;

  const ProductReviewsScreen({
    super.key,
    required this.ratings,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF323C42)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ratings & Reviews',
              style: TextStyle(
                color: Color(0xFF171717),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'ITC Avant Garde Gothic Pro',
              ),
            ),
            Text(
              productName,
              style: const TextStyle(
                color: Color(0xFF9AA097),
                fontSize: 12,
                fontFamily: 'ITC Avant Garde Gothic Pro',
              ),
            ),
          ],
        ),
      ),
      body: ratings.isEmpty
          ? const Center(
              child: Text(
                'No reviews yet',
                style: TextStyle(
                  color: Color(0xFF7A8D7C),
                  fontSize: 16,
                  fontFamily: 'ITC Avant Garde Gothic Pro',
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                final rating = ratings[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              rating.userName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374338),
                                fontFamily: 'ITC Avant Garde Gothic Pro',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < rating.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: const Color(0xFF3EA334),
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (rating.reviewText.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          rating.reviewText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4D555C),
                            height: 1.5,
                            fontFamily: 'ITC Avant Garde Gothic Pro',
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
