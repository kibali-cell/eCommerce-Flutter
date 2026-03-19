import 'package:flutter/material.dart';
import 'package:shopping/common/widgets/products/pricing_calculator.dart';
import 'package:shopping/common/widgets/texts/product_price_text.dart';
import 'package:shopping/features/shop/controllers/product/cart_controller.dart';

import 'package:shopping/utils/constants/sizes.dart';

class TBillingAmountSection extends StatelessWidget {
  const TBillingAmountSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;

    final subTotal = cartController.totalCartPrice.value;
    final shipping = TPricingCalculator.calculateShippingCost(subTotal, 'TZ');
    final tax = TPricingCalculator.calculateTax(subTotal, 'TZ');
    final total = TPricingCalculator.calculateTotalPrice(subTotal, 'TZ');

    TProductPriceText(price: subTotal);
    TProductPriceText(price: shipping);
    TProductPriceText(price: tax);
    TProductPriceText(price: total, isLarge: true);

    return Column(
      children: [

        /// Subtotal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('SubTotal', style: Theme.of(context).textTheme.bodyMedium),

            TProductPriceText(price: subTotal),
          ],
        ),

        const SizedBox(height: TSizes.spaceBtwItems / 2),

        /// Shipping
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Shipping Fee', style: Theme.of(context).textTheme.bodyMedium),

            TProductPriceText(price: shipping),
          ],
        ),

        const SizedBox(height: TSizes.spaceBtwItems / 2),

        /// Tax
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tax Fee', style: Theme.of(context).textTheme.bodyMedium),

            TProductPriceText(price: tax),
          ],
        ),

        const SizedBox(height: TSizes.spaceBtwItems / 2),

        /// Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order Total', style: Theme.of(context).textTheme.bodyMedium),

            TProductPriceText(
              price: total,
              isLarge: true,
            ),
          ],
        ),
      ],
    );
  }
}
