import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Model/BuyOrder.dart';
import 'package:swapbuy/Model/SwapOrder.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:swapbuy/View/Delivery/Home/Controller/DeliveryOrderController.dart';
import 'package:swapbuy/Model/Address.dart';

class AvailableOrdersScreen extends StatefulWidget {
  const AvailableOrdersScreen({super.key});

  @override
  State<AvailableOrdersScreen> createState() => _AvailableOrdersScreenState();
}

class _AvailableOrdersScreenState extends State<AvailableOrdersScreen> {
  @override
  void initState() {
    super.initState();

    // Load available orders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAvailableOrders();
    });
  }

  Future<void> _loadAvailableOrders() async {
    final controller = Provider.of<DeliveryOrderController>(
      context,
      listen: false,
    );
    await controller.getAvailableSwapOrders(context);
    await controller.getAvailableBuyOrders(context);
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

        // Combine all available orders
        final allOrders = <Map<String, dynamic>>[];

        // Add swap orders
        for (var order in controller.availableSwapOrders) {
          allOrders.add({'type': 'swap', 'order': order});
        }

        // Add buy orders
        for (var order in controller.availableBuyOrders) {
          allOrders.add({'type': 'buy', 'order': order});
        }

        if (allOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64.sp, color: AppColors.grey),
                Gap(16.h),
                Text(
                  'No Available Orders',
                  style: TextStyles.title.copyWith(color: AppColors.grey),
                ),
                Gap(8.h),
                Text(
                  'All pending orders have been accepted or there are no orders requiring delivery.',
                  style: TextStyles.paraghraph.copyWith(color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadAvailableOrders,
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

  String formatAddress(Address? address) {
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

            // Pickup Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.store, color: AppColors.black, size: 20.sp),
                Gap(8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup Address',
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
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
            Gap(8.h),
            // Delivery Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: AppColors.black, size: 20.sp),
                Gap(8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Address',
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
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

            // Bottom Row with Time, Distance, and Accept Button
            Row(
              children: [
                // Time Estimate
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppColors.black,
                      size: 16.sp,
                    ),
                    Gap(4.w),
                    Text(
                      '15 min',
                      style: TextStyles.paraghraph.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
                Gap(16.w),
                // Distance
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      color: AppColors.black,
                      size: 16.sp,
                    ),
                    Gap(4.w),
                    Text(
                      '3.2 km',
                      style: TextStyles.paraghraph.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                // Accept Button
                GestureDetector(
                  onTap: () => _acceptSwapOrder(order, controller),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Accept',
                        style: TextStyles.paraghraph.copyWith(
                          color: AppColors.thirdy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap(4.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.thirdy,
                        size: 16.sp,
                      ),
                    ],
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

            // Pickup Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.store, color: AppColors.black, size: 20.sp),
                Gap(8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup Address',
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
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
            Gap(8.h),
            // Delivery Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: AppColors.black, size: 20.sp),
                Gap(8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Address',
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
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

            // Bottom Row with Time, Distance, and Accept Button
            Row(
              children: [
                // Time Estimate
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppColors.black,
                      size: 16.sp,
                    ),
                    Gap(4.w),
                    Text(
                      '12 min',
                      style: TextStyles.paraghraph.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
                Gap(16.w),
                // Distance
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      color: AppColors.black,
                      size: 16.sp,
                    ),
                    Gap(4.w),
                    Text(
                      '2.8 km',
                      style: TextStyles.paraghraph.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                // Accept Button
                GestureDetector(
                  onTap: () => _acceptBuyOrder(order, controller),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Accept',
                        style: TextStyles.paraghraph.copyWith(
                          color: AppColors.thirdy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap(4.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.thirdy,
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptSwapOrder(
    SwapOrder order,
    DeliveryOrderController controller,
  ) async {
    final deliveryId =
        Provider.of<ServicesProvider>(context, listen: false).deliveryId;
    if (deliveryId == null) {
      CustomDialog.DialogError(context, title: 'Delivery ID not found');
      return;
    }

    final result = await controller.acceptSwapOrder(
      context,
      order.orderId!,
      deliveryId,
      'accept',
    );

    result.fold(
      (failure) =>
          CustomDialog.DialogError(context, title: 'Failed to accept order'),
      (success) {
        if (success) {
          CustomDialog.DialogSuccess(
            context,
            title: 'Order accepted successfully!',
          );
        }
      },
    );
  }

  Future<void> _acceptBuyOrder(
    BuyOrder order,
    DeliveryOrderController controller,
  ) async {
    final deliveryId =
        Provider.of<ServicesProvider>(context, listen: false).deliveryId;
    if (deliveryId == null) {
      CustomDialog.DialogError(context, title: 'Delivery ID not found');
      return;
    }

    final result = await controller.acceptBuyOrder(
      context,
      order.orderId!,
      deliveryId,
      'accept',
    );

    result.fold(
      (failure) =>
          CustomDialog.DialogError(context, title: 'Failed to accept order'),
      (success) {
        if (success) {
          CustomDialog.DialogSuccess(
            context,
            title: 'Order accepted successfully!',
          );
        }
      },
    );
  }
}
