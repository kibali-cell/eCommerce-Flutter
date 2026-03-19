import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping/common/widgets/appbar/appbar.dart';
import 'package:shopping/common/widgets/loaders/animation_loader.dart';
import 'package:shopping/common/widgets/texts/product_price_text.dart';
import 'package:shopping/features/shop/controllers/product/cart_controller.dart';
import 'package:shopping/features/shop/screens/cart/widget/cart_items.dart';
import 'package:shopping/features/shop/screens/checkout/checkout.dart';
import 'package:shopping/features/shop/screens/store/store.dart';
import 'package:shopping/navigation_menu.dart';
import 'package:shopping/utils/constants/image_strings.dart';
import 'package:shopping/utils/constants/sizes.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Cart', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Obx(() {
        final emptyWidget = TAnimationLoaderWidget(
          text: 'Whoops! Cart is EMPTY.',
          animation: TImages.cartAnimation,
          showAction: true,
          actionText: 'Let\'s fill it',
          onActionPressed: () => Get.off(() => const StoreScreen()),
        );

        if (controller.cartItems.isEmpty) {
          return emptyWidget;
        } else {
          return const SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(TSizes.defaultSpace),

              //items in cart
              child: TCartItems(),
            ),
          );
        }
      }),

      //checkout button
      bottomNavigationBar: controller.cartItems.isEmpty
          ? const SizedBox()
          : Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: ElevatedButton(
                  onPressed: () => Get.to(() => const CheckOutScreen()),
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Checkout '),
                        TProductPriceText(price: controller.totalCartPrice.value,)
                      ],
                    ),
                      ),),
            ),
    );
  }
}
