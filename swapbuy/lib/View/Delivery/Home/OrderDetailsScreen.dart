import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Model/Address.dart';
import 'package:swapbuy/Model/BuyOrder.dart';
import 'package:swapbuy/Model/SwapOrder.dart';

class OrderDetailsScreen extends StatefulWidget {
  final dynamic order;
  final String orderType; // 'swap' or 'buy'

  const OrderDetailsScreen({
    Key? key,
    required this.order,
    required this.orderType,
  }) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    // Debug logging

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Order #${_getOrderId()}',
          style: TextStyles.title.copyWith(color: AppColors.basic),
        ),
        backgroundColor: AppColors.thirdy,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.basic),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with order type and status
            _buildHeader(),

            // Main content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Order Summary Card
                  _buildOrderSummaryCard(),
                  SizedBox(height: 16.h),

                  // Customer Information Card
                  _buildCustomerInfoCard(),
                  SizedBox(height: 16.h),

                  // Delivery Information Card
                  _buildDeliveryInfoCard(),
                  SizedBox(height: 16.h),

                  // Products Card
                  _buildProductsCard(),
                  SizedBox(height: 16.h),

                  // Payment Information Card
                  _buildPaymentInfoCard(),
                  SizedBox(height: 16.h),

                  // Delivery Details Card
                  _buildDeliveryDetailsCard(),
                  SizedBox(height: 16.h),

                  // Rating Display Card (if order is delivered and has any rating)
                  if (_isOrderDelivered()) ...[
                    _buildRatingDisplayCard(),
                    SizedBox(height: 16.h),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isSwap = widget.orderType == 'swap';
    final status = _getOrderStatus();
    final statusColor = _getStatusColor(status);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.thirdy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Order Type Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.basic,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSwap ? Icons.swap_horiz : Icons.shopping_cart,
                    size: 20.sp,
                    color: AppColors.thirdy,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    isSwap ? 'SWAP ORDER' : 'BUY ORDER',
                    style: TextStyles.paraghraph.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.thirdy,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(color: statusColor, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getStatusIcon(status), size: 20.sp, color: statusColor),
                  SizedBox(width: 8.w),
                  Text(
                    status,
                    style: TextStyles.title.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return _buildCard(
      title: 'Order Summary',
      icon: Icons.receipt_long,
      child: Column(
        children: [
          _buildSummaryRow('Order ID', '#${_getOrderId()}'),
          _buildSummaryRow('Created Date', _formatDate(_getCreatedDate())),
          if (widget.orderType == 'buy' && _getTotalAmount() != null)
            _buildSummaryRow(
              'Total Amount',
              '\$${_getTotalAmount()!.toStringAsFixed(2)}',
              isAmount: true,
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return _buildCard(
      title: 'Customer Information',
      icon: Icons.people,
      child: Column(
        children: [
          _buildCustomerSection('Buyer', _getBuyerInfo()),
          SizedBox(height: 16.h),
          _buildCustomerSection('Seller', _getSellerInfo()),
        ],
      ),
    );
  }

  Widget _buildCustomerSection(
    String title,
    Map<String, String>? customerInfo,
  ) {
    if (customerInfo == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyles.paraghraph.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.thirdy,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildInfoRow('Name', customerInfo['name'] ?? 'N/A'),
              _buildInfoRow('Email', customerInfo['email'] ?? 'N/A'),
              _buildInfoRow('Phone', customerInfo['phone'] ?? 'N/A'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfoCard() {
    final address = _getDeliveryAddress();
    if (address == null) return SizedBox.shrink();

    return _buildCard(
      title: 'Delivery Information',
      icon: Icons.location_on,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Address',
                      style: TextStyles.paraghraph.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.thirdy,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${address.street ?? 'N/A'}',
                            style: TextStyles.paraghraph.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black,
                            ),
                          ),
                          if (address.neighborhood != null &&
                              address.neighborhood!.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              'Neighborhood: ${address.neighborhood}',
                              style: TextStyles.paraghraph.copyWith(
                                fontSize: 12.sp,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                          if (address.buildingNumber != null &&
                              address.buildingNumber!.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              'Building: ${address.buildingNumber}',
                              style: TextStyles.paraghraph.copyWith(
                                fontSize: 12.sp,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                          SizedBox(height: 4.h),
                          Text(
                            '${address.city ?? ''}, ${address.country ?? ''}',
                            style: TextStyles.paraghraph.copyWith(
                              fontSize: 12.sp,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Postal Code: ${address.postalCode ?? 'N/A'}',
                            style: TextStyles.paraghraph.copyWith(
                              fontSize: 12.sp,
                              color: AppColors.black,
                            ),
                          ),
                          if (address.description != null &&
                              address.description!.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Text(
                              'Additional Details:',
                              style: TextStyles.paraghraph.copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.thirdy,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              address.description!,
                              style: TextStyles.paraghraph.copyWith(
                                fontSize: 12.sp,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard() {
    return _buildCard(
      title: 'Products',
      icon: Icons.inventory,
      child: Column(
        children: [
          if (widget.orderType == 'swap') ...[
            _buildProductSection('Offered Product', _getOfferedProduct()),
            SizedBox(height: 16.h),
            _buildProductSection('Requested Product', _getRequestedProduct()),
          ] else ...[
            _buildProductSection('Product', _getProduct()),
          ],
        ],
      ),
    );
  }

  Widget _buildProductSection(String title, Map<String, dynamic>? productInfo) {
    if (productInfo == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyles.paraghraph.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildInfoRow('Name', productInfo['name'] ?? 'N/A'),
              _buildInfoRow(
                'Price',
                '\$${(productInfo['price'] ?? 0.0).toStringAsFixed(2)}',
              ),
              // Only show condition and status if they exist
              if (productInfo['condition'] != null &&
                  productInfo['condition'] != 'N/A')
                _buildInfoRow('Condition', productInfo['condition']),
              if (productInfo['status'] != null &&
                  productInfo['status'] != 'N/A')
                _buildInfoRow('Status', productInfo['status']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfoCard() {
    return _buildCard(
      title: 'Payment Information',
      icon: Icons.payment,
      child: Column(
        children: [
          _buildInfoRow('Payment Method', _getPaymentMethod()),
          _buildInfoRow('Payment Status', _getPaymentStatus()),
          if (widget.orderType == 'swap' && _getPayerOfDifference() != null)
            _buildInfoRow('Payer of Difference', _getPayerOfDifference()!),
          if (widget.orderType == 'swap' && _getTotalAmount() != null)
            _buildInfoRow(
              'Total Amount',
              '\$${_getTotalAmount()!.toStringAsFixed(2)}',
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetailsCard() {
    return _buildCard(
      title: 'Delivery Details',
      icon: Icons.local_shipping,
      child: Column(
        children: [
          _buildInfoRow('Delivery Type', _getDeliveryType()),
          if (_getDeliveryDescription() != null)
            _buildInfoRow('Description', _getDeliveryDescription()!),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.basic,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.thirdy, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyles.title.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyles.paraghraph.copyWith(
              fontSize: 14.sp,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyles.paraghraph.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyles.paraghraph.copyWith(
                fontSize: 12.sp,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              style: TextStyles.paraghraph.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods to extract data from orders
  String _getOrderStatus() {
    if (widget.orderType == 'swap') {
      return (widget.order as SwapOrder).status ?? 'Pending';
    } else {
      return (widget.order as BuyOrder).status ?? 'Pending';
    }
  }

  int _getOrderId() {
    if (widget.orderType == 'swap') {
      return (widget.order as SwapOrder).orderId ?? 0;
    } else {
      return (widget.order as BuyOrder).orderId ?? 0;
    }
  }

  String _getCreatedDate() {
    if (widget.orderType == 'swap') {
      return (widget.order as SwapOrder).createdAt ?? 'N/A';
    } else {
      return (widget.order as BuyOrder).createdAt ?? 'N/A';
    }
  }

  String _formatDate(String dateString) {
    if (dateString == 'N/A') return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  double? _getTotalAmount() {
    if (widget.orderType == 'swap') {
      return (widget.order as SwapOrder).totalAmount;
    } else {
      return (widget.order as BuyOrder).totalAmount;
    }
  }

  Map<String, String>? _getSellerInfo() {
    if (widget.orderType == 'swap') {
      final seller = (widget.order as SwapOrder).seller;
      if (seller == null) {
        return null;
      }
      return {
        'name': seller.name ?? 'N/A',
        'email': seller.email ?? 'N/A',
        'phone': seller.phone ?? 'N/A',
      };
    } else {
      final seller = (widget.order as BuyOrder).seller;
      if (seller == null) {
        return null;
      }
      return {
        'name': seller.name ?? 'N/A',
        'email': seller.email ?? 'N/A',
        'phone': seller.phone ?? 'N/A',
      };
    }
  }

  Map<String, String>? _getBuyerInfo() {
    if (widget.orderType == 'swap') {
      final buyer = (widget.order as SwapOrder).buyer;
      if (buyer == null) {
        return null;
      }
      return {
        'name': buyer.name ?? 'N/A',
        'email': buyer.email ?? 'N/A',
        'phone': buyer.phone ?? 'N/A',
      };
    } else {
      final buyer = (widget.order as BuyOrder).buyer;
      if (buyer == null) {
        return null;
      }
      return {
        'name': buyer.name ?? 'N/A',
        'email': buyer.email ?? 'N/A',
        'phone': buyer.phone ?? 'N/A',
      };
    }
  }

  Address? _getDeliveryAddress() {
    if (widget.orderType == 'swap') {
      return (widget.order as SwapOrder).deliveryAddress;
    } else {
      return (widget.order as BuyOrder).deliveryAddress;
    }
  }

  Map<String, dynamic>? _getOfferedProduct() {
    if (widget.orderType != 'swap') return null;
    final product = (widget.order as SwapOrder).productOffered;
    if (product == null) {
      return null;
    }
    return {
      'name': product.name,
      'price': product.price,
      'condition': product.condition,
      'status': product.status,
    };
  }

  Map<String, dynamic>? _getRequestedProduct() {
    if (widget.orderType != 'swap') return null;
    final product = (widget.order as SwapOrder).productRequested;
    if (product == null) {
      return null;
    }
    return {
      'name': product.name,
      'price': product.price,
      'condition': product.condition,
      'status': product.status,
    };
  }

  Map<String, dynamic>? _getProduct() {
    if (widget.orderType != 'buy') return null;
    final product = (widget.order as BuyOrder).product;
    if (product == null) return null;
    return {
      'name': product.name,
      'price': product.price,
      'condition': product.condition,
      'status': product.status,
    };
  }

  String _getPaymentMethod() {
    if (widget.orderType == 'swap') {
      return (widget.order as SwapOrder).paymentMethod ?? 'N/A';
    } else {
      return (widget.order as BuyOrder).paymentMethod ?? 'N/A';
    }
  }

  String _getPaymentStatus() {
    if (widget.orderType == 'swap') {
      return (widget.order as SwapOrder).paymentStatus ?? 'N/A';
    } else {
      return (widget.order as BuyOrder).paymentStatus ?? 'N/A';
    }
  }

  String? _getPayerOfDifference() {
    if (widget.orderType != 'swap') return null;
    final payer = (widget.order as SwapOrder).payerOfDifference;
    return payer?.name;
  }

  String _getDeliveryType() {
    if (widget.orderType == 'swap') {
      return (widget.order as SwapOrder).deliveryType ?? 'N/A';
    } else {
      return (widget.order as BuyOrder).deliveryType ?? 'N/A';
    }
  }

  String? _getDeliveryDescription() {
    final address = _getDeliveryAddress();
    return address?.description;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'out for delivery':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'accepted':
        return Icons.check_circle;
      case 'preparing':
        return Icons.build;
      case 'out for delivery':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  // ++++++ Ueful for rating system ++++++
  bool _isOrderDelivered() {
    return _getOrderStatus().toLowerCase() == 'delivered';
  }

  // ===== RATING SYSTEM (commented out) =====

  Widget _buildRatingDisplayCard() {
    int? buyerRating = _getBuyerDeliveryRating();
    String? buyerComment = _getBuyerDeliveryComment();
    int? sellerRating = _getSellerDeliveryRating();
    String? sellerComment = _getSellerDeliveryComment();
    final hasAny = (buyerRating > 0) || (sellerRating > 0);
    return _buildCard(
      title: 'Delivery Ratings',
      icon: Icons.star,
      child: Column(
        children: [
          if (buyerRating > 0) ...[
            _buildRatingSection('Buyer\'s Rating', buyerRating, buyerComment),
            SizedBox(height: 16.h),
          ],
          if (sellerRating > 0) ...[
            _buildRatingSection(
              'Seller\'s Rating',
              sellerRating,
              sellerComment,
            ),
            SizedBox(height: 16.h),
          ],
          if (hasAny) ...[
            Divider(),
            SizedBox(height: 8.h),
            _buildAverageDeliveryRatingCustom(buyerRating, sellerRating),
          ],
          if (!hasAny) ...[
            Text(
              'No delivery ratings received yet',
              style: TextStyles.paraghraph.copyWith(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAverageDeliveryRatingCustom(
    int? buyerRating,
    int? sellerRating,
  ) {
    int total = 0;
    int count = 0;
    if (buyerRating != null && buyerRating > 0) {
      total += buyerRating;
      count++;
    }
    if (sellerRating != null && sellerRating > 0) {
      total += sellerRating;
      count++;
    }
    final avg = count > 0 ? total / count : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average Delivery Rating',
          style: TextStyles.paraghraph.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            ...List.generate(5, (index) {
              return Icon(
                index < avg ? Icons.star : Icons.star_border,
                color: index < avg ? Colors.amber : Colors.grey,
                size: 16.sp,
              );
            }),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          '${avg.toStringAsFixed(1)}/5 ($count ratings)',
          style: TextStyles.paraghraph.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(String title, int rating, String? comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyles.paraghraph.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            ...List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: index < rating ? Colors.amber : Colors.grey,
                size: 20.sp,
              );
            }),
            SizedBox(width: 8.w),
            Text(
              '$rating/5',
              style: TextStyles.paraghraph.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        if (comment != null && comment.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            '"$comment"',
            style: TextStyles.paraghraph.copyWith(
              fontSize: 12.sp,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  int _getBuyerDeliveryRating() {
    if (widget.orderType == 'swap') {
      final order = widget.order as SwapOrder;
      return order.buyerDeliveryRating ?? 0;
    } else {
      final order = widget.order as BuyOrder;
      return order.buyerDeliveryRating ?? 0;
    }
  }

  int _getSellerDeliveryRating() {
    if (widget.orderType == 'swap') {
      final order = widget.order as SwapOrder;
      return order.sellerDeliveryRating ?? 0;
    } else {
      final order = widget.order as BuyOrder;
      return order.sellerDeliveryRating ?? 0;
    }
  }

  String? _getBuyerDeliveryComment() {
    if (widget.orderType == 'swap') {
      final order = widget.order as SwapOrder;
      return order.buyerDeliveryComment;
    } else {
      final order = widget.order as BuyOrder;
      return order.buyerDeliveryComment;
    }
  }

  String? _getSellerDeliveryComment() {
    if (widget.orderType == 'swap') {
      final order = widget.order as SwapOrder;
      return order.sellerDeliveryComment;
    } else {
      final order = widget.order as BuyOrder;
      return order.sellerDeliveryComment;
    }
  }

  // ===== END RATING SYSTEM =====
}
