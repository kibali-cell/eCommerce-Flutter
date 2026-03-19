import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shopping/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:shopping/common/widgets/texts/product_price_text.dart';
import 'package:shopping/features/shop/controllers/product/order_controller.dart';
import 'package:shopping/features/shop/models/address_model.dart';
import 'package:shopping/features/shop/models/order_model.dart';
import 'package:shopping/utils/constants/colors.dart';
import 'package:shopping/utils/constants/enums.dart';
import 'package:shopping/utils/constants/sizes.dart';
import 'package:shopping/utils/helpers/helper_functions.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.find<OrderController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// -- Order Summary Section
            _SectionHeader(icon: Iconsax.bag, title: 'Order Summary', dark: dark),
            const SizedBox(height: TSizes.spaceBtwItems),
            TRoundedContainer(
              showBorder: true,
              padding: const EdgeInsets.all(TSizes.md),
              backgroundColor: dark ? TColors.dark : TColors.light,
              child: Column(
                children: [
                  _InfoRow(label: 'Order ID', value: '${order.id.substring(0, 6)}]'),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  _InfoRow(label: 'Placed on', value: order.formattedOrderDate),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  _InfoRow(
                    label: 'Grand Total',
                    valueWidget: TProductPriceText(price: order.totalAmount, isLarge: true),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order Status', style: Theme.of(context).textTheme.bodyMedium),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: TSizes.md, vertical: TSizes.xs),
                        decoration: BoxDecoration(
                          color: TColors.primary,
                          borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                        ),
                        child: Text(
                          order.orderStatusText,
                          style: Theme.of(context).textTheme.labelMedium!.apply(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),
            const Divider(),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// -- Items Section
            _SectionHeader(icon: Iconsax.shopping_cart, title: 'Items', dark: dark),
            const SizedBox(height: TSizes.spaceBtwItems),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
              itemBuilder: (_, index) {
                final item = order.items[index];
                return TRoundedContainer(
                  showBorder: true,
                  padding: const EdgeInsets.all(TSizes.md),
                  backgroundColor: dark ? TColors.dark : Colors.white,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Product Image
                          TRoundedContainer(
                            width: 60,
                            height: 60,
                            backgroundColor: dark ? TColors.darkerGrey : TColors.lightContainer,
                            child: item.image != null
                                ? Image.network(item.image!, fit: BoxFit.cover)
                                : const Icon(Iconsax.image, size: 30),
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),

                          // Product Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: Theme.of(context).textTheme.titleMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    Text('Unit Price: ', style: Theme.of(context).textTheme.labelMedium),
                                    TProductPriceText(price: item.price),
                                    Text('   Qty: ${item.quantity}', style: Theme.of(context).textTheme.labelMedium),
                                  ],
                                ),
                                const SizedBox(height: TSizes.spaceBtwItems,),
                                 // Item Total
                          TProductPriceText(price: item.price * item.quantity),
                              ],
                            ),
                          ),

                         
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Iconsax.star, size: TSizes.iconSm),
                          label: const Text('Review Product'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: TSizes.spaceBtwSections),
            const Divider(),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// -- Shipping & Billing Addresses
            TRoundedContainer(
              showBorder: false,
              padding: const EdgeInsets.all(TSizes.md),
              backgroundColor: dark ? TColors.darkerGrey : TColors.lightContainer,
              child: Column(
                children: [
                  _SectionHeader(icon: Iconsax.location_tick, title: 'Shipping Address', dark: dark),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  _InfoRow(label: 'Name', value: order.address?.name ?? '-'),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  _InfoRow(label: 'Phone Number', value: order.address?.phoneNumber ?? '-'),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  _InfoRow(label: 'Email', value: order.userEmail),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  _InfoRow(label: 'Address', value: order.address?.toString() ?? '-'),

                  const SizedBox(height: TSizes.spaceBtwSections),
                  const Divider(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  _SectionHeader(icon: Iconsax.location, title: 'Billing Address', dark: dark),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  _InfoRow(label: 'Name', value: order.address?.name ?? '-'),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  _InfoRow(label: 'Phone Number', value: order.address?.phoneNumber ?? '-'),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  _InfoRow(label: 'Email', value: order.userEmail),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  _InfoRow(label: 'Address', value: order.address?.toString() ?? '-'),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),
            const Divider(),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// -- Payment Details
            _SectionHeader(icon: Iconsax.card, title: 'Payment Details', dark: dark),
            const SizedBox(height: TSizes.spaceBtwItems),
            TRoundedContainer(
              showBorder: true,
              padding: const EdgeInsets.all(TSizes.md),
              backgroundColor: dark ? TColors.dark : TColors.light,
              child: Column(
                children: [
                  _InfoRow(label: 'Payment Method', value: order.paymentMethod),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  _InfoRow(
                    label: 'Subtotal',
                    valueWidget: TProductPriceText(price: order.totalAmount),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  _InfoRow(
                    label: 'Shipping Fee',
                    valueWidget: const TProductPriceText(price: 0),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  const Divider(),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Grand Total',
                          style: Theme.of(context).textTheme.titleMedium!.apply(fontWeightDelta: 2)),
                      TProductPriceText(price: order.totalAmount, isLarge: true),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),
            const Divider(),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// -- Delivery Status
            _SectionHeader(icon: Iconsax.ship, title: 'Delivery Status', dark: dark),
            const SizedBox(height: TSizes.spaceBtwItems),
            TRoundedContainer(
              showBorder: true,
              padding: const EdgeInsets.all(TSizes.md),
              backgroundColor: dark ? TColors.dark : TColors.light,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DeliveryStatusTimeline(order: order),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  _InfoRow(label: 'Expected Delivery', value: order.formattedDeliveryDate),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            /// -- Cancel Order Button
            if (order.status == OrderStatus.pending || order.status == OrderStatus.processing)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(context, controller),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                  ),
                  icon: const Icon(Iconsax.close_circle, color: Colors.red),
                  label: const Text('Cancel Order', style: TextStyle(color: Colors.red)),
                ),
              ),

            const SizedBox(height: TSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, OrderController controller) {
    Get.defaultDialog(
      title: 'Cancel Order',
      middleText: 'Are you sure you want to cancel this order? This action cannot be undone.',
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () {
          controller.cancelOrder(order.id);
          Get.back();
        },
        child: const Text('Yes, Cancel'),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        child: const Text('Keep Order'),
      ),
    );
  }
}

/// -- Reusable Section Header with Icon
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title, required this.dark});

  final IconData icon;
  final String title;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: TColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: TColors.primary, size: TSizes.iconMd),
        ),
        const SizedBox(width: TSizes.spaceBtwItems),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}

/// -- Reusable Label-Value Row (supports both plain text and widget values)
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: TSizes.spaceBtwItems),
        Flexible(
          child: valueWidget ??
              Text(
                value ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.end,
              ),
        ),
      ],
    );
  }
}

/// -- Delivery Status Timeline
class _DeliveryStatusTimeline extends StatelessWidget {
  const _DeliveryStatusTimeline({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StatusStep(label: 'Order Placed', icon: Iconsax.tick_circle, status: OrderStatus.pending),
      _StatusStep(label: 'Processing', icon: Iconsax.refresh_circle, status: OrderStatus.processing),
      _StatusStep(label: 'Shipped', icon: Iconsax.ship, status: OrderStatus.shipped),
      _StatusStep(label: 'Delivered', icon: Iconsax.bag_tick, status: OrderStatus.delivered),
    ];

    final currentIndex = steps.indexWhere((s) => s.status == order.status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (index) {
        final isDone = index <= currentIndex;
        final isActive = index == currentIndex;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index > 0)
                    Expanded(child: Container(height: 2, color: isDone ? TColors.primary : Colors.grey.shade600)),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? TColors.primary : Colors.grey.shade700,
                      border: isActive ? Border.all(color: TColors.primary, width: 2) : null,
                    ),
                    child: Icon(steps[index].icon, size: 14, color: isDone ? Colors.white : Colors.grey),
                  ),
                  if (index < steps.length - 1)
                    Expanded(child: Container(height: 2, color: index < currentIndex ? TColors.primary : Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                steps[index].label,
                style: Theme.of(context).textTheme.labelSmall!.apply(color: isDone ? TColors.primary : Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatusStep {
  final String label;
  final IconData icon;
  final OrderStatus status;
  _StatusStep({required this.label, required this.icon, required this.status});
}