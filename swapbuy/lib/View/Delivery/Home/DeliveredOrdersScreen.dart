import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Model/BuyOrder.dart';
import 'package:swapbuy/Model/SwapOrder.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:swapbuy/View/Delivery/Home/Controller/DeliveryOrderController.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';

class DeliveredOrdersScreen extends StatefulWidget {
  const DeliveredOrdersScreen({super.key});

  @override
  State<DeliveredOrdersScreen> createState() => _DeliveredOrdersScreenState();
}

class _DeliveredOrdersScreenState extends State<DeliveredOrdersScreen> {
  String formatAddress(address) {
    if (address == null) return 'Not available';
    final parts = [
      if ((address.buildingNumber ?? '').isNotEmpty) address.buildingNumber,
      if ((address.street ?? '').isNotEmpty) address.street,
      if ((address.neighborhood ?? '').isNotEmpty) address.neighborhood,
      if ((address.city ?? '').isNotEmpty) address.city,
      if ((address.postalCode ?? '').isNotEmpty) address.postalCode,
      if ((address.country ?? '').isNotEmpty) address.country,
    ];
    return parts.join(', ');
  }

  @override
  void initState() {
    super.initState();

    // Load delivered orders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDeliveredOrders();
    });
  }

  Future<void> _loadDeliveredOrders() async {
    final controller = Provider.of<DeliveryOrderController>(
      context,
      listen: false,
    );

    final servicesProvider = Provider.of<ServicesProvider>(
      context,
      listen: false,
    );
    final deliveryId = servicesProvider.deliveryId;

    if (deliveryId != null) {
      await controller.getDeliveredOrders(context, deliveryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryOrderController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.thirdy),
          );
        }

        // Combine all delivered orders
        final allOrders = <Map<String, dynamic>>[];

        // Add swap orders
        for (var order in controller.deliveredSwapOrders) {
          allOrders.add({'type': 'swap', 'order': order});
        }

        // Add buy orders
        for (var order in controller.deliveredBuyOrders) {
          allOrders.add({'type': 'buy', 'order': order});
        }

        if (allOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64.sp,
                  color: AppColors.grey,
                ),
                Gap(16.h),
                Text(
                  'No Delivered Orders',
                  style: TextStyles.title.copyWith(color: AppColors.grey),
                ),
                Gap(8.h),
                Text(
                  'You haven\'t delivered any orders yet.\nComplete some deliveries to see them here.',
                  style: TextStyles.paraghraph.copyWith(color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadDeliveredOrders,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: allOrders.length,
            itemBuilder: (context, index) {
              final orderData = allOrders[index];
              final type = orderData['type'] as String;
              final order = orderData['order'];

              if (type == 'swap') {
                return _buildSwapOrderCard(order as SwapOrder, controller);
              } else {
                return _buildBuyOrderCard(order as BuyOrder, controller);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildSwapOrderCard(
    SwapOrder order,
    DeliveryOrderController controller,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.basic,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price and Type Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.thirdy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        size: 16.sp,
                        color: AppColors.thirdy,
                      ),
                      Gap(4.w),
                      Text(
                        'SWAP',
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.thirdy,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${order.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyles.title.copyWith(
                    fontSize: 18.sp,
                    color: AppColors.thirdy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Gap(16.h),

            // Order Status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.done_all, size: 16.sp, color: Colors.green),
                  Gap(8.w),
                  Text(
                    'Delivered',
                    style: TextStyles.paraghraph.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            Gap(16.h),

            // Pickup Location (Seller's Address)
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.black, size: 20.sp),
                Gap(8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup',
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        // Using seller's address for pickup
                        formatAddress(order.seller?.address),
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(12.h),

            // Delivery Location (Buyer's Address)
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.black, size: 20.sp),
                Gap(8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery',
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        // Using delivery address for delivery
                        formatAddress(order.deliveryAddress),
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(16.h),

            // Separator
            Divider(color: Colors.grey.shade200, height: 1),
            Gap(12.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ButtonCustom(
                    title: 'View Details',
                    color: AppColors.thirdy,
                    onTap: () => _handleViewDetails(order, controller, 'swap'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyOrderCard(
    BuyOrder order,
    DeliveryOrderController controller,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.basic,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price and Type Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.thirdy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 16.sp,
                        color: AppColors.thirdy,
                      ),
                      Gap(4.w),
                      Text(
                        'BUY',
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.thirdy,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${order.product?.price?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyles.title.copyWith(
                    fontSize: 18.sp,
                    color: AppColors.thirdy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Gap(16.h),

            // Order Status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.done_all, size: 16.sp, color: Colors.green),
                  Gap(8.w),
                  Text(
                    'Delivered',
                    style: TextStyles.paraghraph.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            Gap(16.h),

            // Pickup Location (Seller's Address)
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.black, size: 20.sp),
                Gap(8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup',
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        // Using seller's address for pickup
                        formatAddress(order.seller?.address),
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                      // Show seller's name if available
                      if (order.seller != null)
                        Text(
                          '${order.seller!.name}',
                          style: TextStyles.paraghraph.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(12.h),

            // Delivery Location (Buyer's Address)
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.black, size: 20.sp),
                Gap(8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery',
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        // Using delivery address for delivery
                        formatAddress(order.deliveryAddress),
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                      // Show buyer's name if available
                      if (order.buyer != null)
                        Text(
                          '${order.buyer!.name}',
                          style: TextStyles.paraghraph.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(16.h),

            // Separator
            Divider(color: Colors.grey.shade200, height: 1),
            Gap(12.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ButtonCustom(
                    title: 'View Details',
                    color: AppColors.thirdy,
                    onTap: () => _handleViewDetails(order, controller, 'buy'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Handle view details
  void _handleViewDetails(
    dynamic order,
    DeliveryOrderController controller,
    String type,
  ) {
    controller.viewOrderDetails(context, order, type);
  }
}
