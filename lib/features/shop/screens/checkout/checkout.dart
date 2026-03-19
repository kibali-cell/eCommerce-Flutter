import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping/common/widgets/appbar/appbar.dart';
import 'package:shopping/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:shopping/common/widgets/loaders/loaders.dart';
import 'package:shopping/common/widgets/products/cart/coupon_widget.dart';
import 'package:shopping/common/widgets/products/pricing_calculator.dart';
import 'package:shopping/common/widgets/texts/product_price_text.dart';
import 'package:shopping/features/shop/controllers/product/cart_controller.dart';
import 'package:shopping/features/shop/controllers/product/order_controller.dart';
import 'package:shopping/features/shop/screens/cart/widget/cart_items.dart';
import 'package:shopping/features/shop/screens/checkout/widgets/billing_address_section.dart';
import 'package:shopping/features/shop/screens/checkout/widgets/billing_amount_section.dart';
import 'package:shopping/features/shop/screens/checkout/widgets/billing_payment_section.dart';
import 'package:shopping/utils/constants/colors.dart';
import 'package:shopping/utils/constants/sizes.dart';
import 'package:shopping/utils/helpers/helper_functions.dart';

class CheckOutScreen extends StatelessWidget {
  const CheckOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    final subTotal = cartController.totalCartPrice.value;
    final orderController = Get.put(OrderController());
    final totalAmount = TPricingCalculator.calculateTotalPrice(subTotal, 'US');

    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: TAppBar(
          showBackArrow: true,
          title: Text('Order Review',
              style: Theme.of(context).textTheme.headlineSmall)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              //cart Items
              const TCartItems(
                showAddRemoveButton: false,
              ),
               
              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),

              //coupon TextField
              const TCouponCode(),
              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),

              //billing section
              TRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(TSizes.md),
                backgroundColor: dark ? TColors.black : TColors.white,
                child: const Column(children: [
                  //pricing
                  TBillingAmountSection(),
                  SizedBox(
                    height: TSizes.spaceBtwItems,
                  ),

                  //divider
                  Divider(),
                  SizedBox(
                    height: TSizes.spaceBtwItems,
                  ),

                  //payment methods
                  TBillingPaymentSection(),
                  SizedBox(
                    height: TSizes.spaceBtwItems,
                  ),
                  //address
                  TBillingAddressSection()
                ]),
              )
            ],
          ),
        ),
      ),

      //checkout button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: ElevatedButton(
            onPressed: subTotal > 0
                ? () => orderController.processOrder(totalAmount)
                : () => TLoaders.warningSnackBar(
                    title: 'Empty Cart',
                    message: ' To proceed Add Items in the cart.'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const Text('Checkout '),
              TProductPriceText(price: totalAmount)
            ],
            ),
            ),
      ),
    );
  }
}
