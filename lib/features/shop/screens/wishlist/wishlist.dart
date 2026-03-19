import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shopping/common/widgets/appbar/appbar.dart';
import 'package:shopping/common/widgets/icons/t_circular_icon.dart';
import 'package:shopping/common/widgets/layout/grid_layout.dart';
import 'package:shopping/common/widgets/loaders/animation_loader.dart';
import 'package:shopping/common/widgets/products/products_cards/product_card_vertical.dart';
import 'package:shopping/common/widgets/shimmers/vertical_product_shimmer.dart';
import 'package:shopping/features/shop/controllers/product/favourites_controller.dart';
import 'package:shopping/navigation_menu.dart';
import 'package:shopping/utils/constants/image_strings.dart';
import 'package:shopping/utils/constants/sizes.dart';
import 'package:shopping/utils/helpers/cloud_helper_function.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavouritesController());
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'Wishlist',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          TCircularIcon(
              icon: Iconsax.add, 
              onPressed: () {
                final navController = Get.find<NavigationController>();
                navController.selectedIndex.value = 1;     // 1 = StoreScreen
                Get.back();                                 // close FavoriteScreen
              },
              ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),

            //products grid
            child: Obx(
              () => FutureBuilder(
                  future: controller.favoriteProducts(),
                  builder: (context, snapshot) {
                    // Nothing found widget
                    final emptyWidget = TAnimationLoaderWidget(
                      text: 'Whoops! Wishlist is Empty...',
                      animation: TImages.loaderAnimation,
                      showAction: true,
                      actionText: 'Let\'s add some',
                      onActionPressed: () {
                      final navController = Get.find<NavigationController>();
                      navController.selectedIndex.value = 1;     // 1 = Store
                      Get.back();                                 // or just return to root nav
                    },
                    );

                    const loader = TVerticalProductShimmer(itemCount: 6);
                    final widget = TCloudHelperFunctions.checkMultiRecordState(
                        snapshot: snapshot,
                        loader: loader,
                        nothingFound: emptyWidget);
                    if (widget != null) return widget;

                    final products = snapshot.data!;

                    return TGridLayout(
                        itemCount: products.length,
                        itemBuilder: (_, index) => TProductCardVertical(
                              product: products[index],
                            ));
                  }),
            )),
      ),
    );
  }
}
