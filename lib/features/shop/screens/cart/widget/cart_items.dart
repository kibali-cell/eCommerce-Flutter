import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping/common/widgets/products/cart/add_remove_button.dart';
import 'package:shopping/common/widgets/products/cart/cart_item.dart';
import 'package:shopping/common/widgets/texts/product_price_text.dart';
import 'package:shopping/features/shop/controllers/product/cart_controller.dart';
import 'package:shopping/utils/constants/sizes.dart';

class TCartItems extends StatelessWidget {
  const TCartItems({super.key, this.showAddRemoveButton = true});

  final bool showAddRemoveButton;

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;

    return Obx(
      () => ListView.separated(
        shrinkWrap: true,
        itemCount: cartController.cartItems.length,
        separatorBuilder: (_, __) => const SizedBox(
          height: TSizes.spaceBtwSections,
        ),
        itemBuilder: (_, index) => Obx(
          () {
            final item = cartController.cartItems[index];
            return Column(
              children: [
                //cart items
                TCartItem(cartItem: item),
                if (showAddRemoveButton)
                  const SizedBox(
                    height: TSizes.spaceBtwItems,
                  ),

                //add remove btn with total price
                if (showAddRemoveButton)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 70),

                          //add remove buttons
                          TProductQuantityWithAddRemoveButton(
                            quantity: item.quantity,
                            add: () => cartController.addOneToCart(item),
                            remove: () =>
                                cartController.removeOneFromCart(item),
                          ),
                        ],
                      ),
                      TProductPriceText(
                         price: item.price * item.quantity,
                         ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
