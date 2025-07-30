import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'ReviewDetailsScreen.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({Key? key}) : super(key: key);

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> deliveryRatings = [];
  List<dynamic> userRatings = [];
  bool isLoadingDelivery = true;
  bool isLoadingUser = true;
  String? deliveryError;
  String? userError;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchDeliveryRatings();
    fetchUserRatings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchDeliveryRatings() async {
    setState(() {
      isLoadingDelivery = true;
      deliveryError = null;
    });
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      final response = await client.request(
        path: '/Service/delivery/ratings-summary/',
        requestType: RequestType.GET,
      );
      if (response.statusCode == 200) {
        setState(() {
          deliveryRatings = jsonDecode(response.body);
          isLoadingDelivery = false;
        });
      } else {
        setState(() {
          deliveryError = 'Failed to fetch delivery ratings.';
          isLoadingDelivery = false;
        });
      }
    } catch (e) {
      setState(() {
        deliveryError = 'Error: $e';
        isLoadingDelivery = false;
      });
    }
  }

  Future<void> fetchUserRatings() async {
    setState(() {
      isLoadingUser = true;
      userError = null;
    });
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      final response = await client.request(
        path: '/Service/user/ratings-summary/',
        requestType: RequestType.GET,
      );
      if (response.statusCode == 200) {
        setState(() {
          userRatings = jsonDecode(response.body);
          isLoadingUser = false;
        });
      } else {
        setState(() {
          userError = 'Failed to fetch user ratings.';
          isLoadingUser = false;
        });
      }
    } catch (e) {
      setState(() {
        userError = 'Error: $e';
        isLoadingUser = false;
      });
    }
  }

  Widget _buildDeliveryRatingsTab() {
    if (isLoadingDelivery) {
      return const Center(child: CircularProgressIndicator());
    }

    if (deliveryError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(deliveryError!, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchDeliveryRatings,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (deliveryRatings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No delivery ratings found.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchDeliveryRatings,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: deliveryRatings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final item = deliveryRatings[i];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ReviewDetailsScreen(
                        deliveryName: item['delivery_name'],
                        buyerAvg:
                            (item['buyer_avg'] is int)
                                ? (item['buyer_avg'] as int).toDouble()
                                : (item['buyer_avg'] ?? 0.0),
                        buyerCount: item['buyer_count'] ?? 0,
                        buyerComments: List<String>.from(
                          item['buyer_comments'] ?? [],
                        ),
                        sellerAvg:
                            (item['seller_avg'] is int)
                                ? (item['seller_avg'] as int).toDouble()
                                : (item['seller_avg'] ?? 0.0),
                        sellerCount: item['seller_count'] ?? 0,
                        sellerComments: List<String>.from(
                          item['seller_comments'] ?? [],
                        ),
                        overallAvg:
                            (item['overall_avg'] is int)
                                ? (item['overall_avg'] as int).toDouble()
                                : (item['overall_avg'] ?? 0.0),
                        overallCount: item['overall_count'] ?? 0,
                      ),
                ),
              );
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.local_shipping,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['delivery_name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              RatingBarIndicator(
                                rating: (item['overall_avg'] ?? 0).toDouble(),
                                itemBuilder:
                                    (context, _) =>
                                        Icon(Icons.star, color: Colors.amber),
                                itemCount: 5,
                                itemSize: 22.0,
                                direction: Axis.horizontal,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item['overall_avg'] != null
                                    ? item['overall_avg'].toStringAsFixed(2)
                                    : '0.00',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${item['overall_count']} ratings)',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserRatingsTab() {
    if (isLoadingUser) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(userError!, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: fetchUserRatings, child: Text('Retry')),
          ],
        ),
      );
    }

    if (userRatings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No user ratings found.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchUserRatings,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: userRatings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final item = userRatings[i];
          return GestureDetector(
            onTap: () {
              // Navigate to user details screen
              // You can create a UserDetailsScreen similar to ReviewDetailsScreen
              // For now, using the same ReviewDetailsScreen with user data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ReviewDetailsScreen(
                        deliveryName: item['user_name'],
                        buyerAvg:
                            (item['buyer_avg'] is int)
                                ? (item['buyer_avg'] as int).toDouble()
                                : (item['buyer_avg'] ?? 0.0),
                        buyerCount: item['buyer_count'] ?? 0,
                        buyerComments: List<String>.from(
                          item['buyer_comments'] ?? [],
                        ),
                        sellerAvg:
                            (item['seller_avg'] is int)
                                ? (item['seller_avg'] as int).toDouble()
                                : (item['seller_avg'] ?? 0.0),
                        sellerCount: item['seller_count'] ?? 0,
                        sellerComments: List<String>.from(
                          item['seller_comments'] ?? [],
                        ),
                        overallAvg:
                            (item['total_avg'] is int)
                                ? (item['total_avg'] as int).toDouble()
                                : (item['total_avg'] ?? 0.0),
                        overallCount: item['total_count'] ?? 0,
                      ),
                ),
              );
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['user_name'] ?? 'Unknown User',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              RatingBarIndicator(
                                rating: (item['total_avg'] ?? 0).toDouble(),
                                itemBuilder:
                                    (context, _) =>
                                        Icon(Icons.star, color: Colors.amber),
                                itemCount: 5,
                                itemSize: 22.0,
                                direction: Axis.horizontal,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item['total_avg'] != null
                                    ? item['total_avg'].toStringAsFixed(2)
                                    : '0.00',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${item['total_count']} ratings)',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildRatingChip(
                                'Buyer',
                                item['buyer_avg'],
                                item['buyer_count'],
                                Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              _buildRatingChip(
                                'Seller',
                                item['seller_avg'],
                                item['seller_count'],
                                Colors.green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingChip(
    String label,
    dynamic avg,
    dynamic count,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: ${(avg ?? 0).toStringAsFixed(1)} (${count ?? 0})',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.local_shipping), text: 'Delivery Ratings'),
            Tab(icon: Icon(Icons.people), text: 'User Ratings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDeliveryRatingsTab(), _buildUserRatingsTab()],
      ),
    );
  }
}
