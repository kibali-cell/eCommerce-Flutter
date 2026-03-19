import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shopping/common/widgets/layout/grid_layout.dart';
import 'package:shopping/common/widgets/products/products_cards/product_card_vertical.dart';
import 'package:shopping/common/widgets/products/sortable/fillter_bottom_sheet.dart';
import 'package:shopping/features/shop/controllers/product/all_products_controller.dart';
import 'package:shopping/features/shop/models/product_model.dart'; 
import 'package:shopping/utils/constants/sizes.dart';
import 'package:shopping/utils/constants/sort_constants.dart';

class TSortableProducts extends StatelessWidget {
  const TSortableProducts({super.key, required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllProductsController());
    controller.assignProducts(products);

    return Column(
      children: [
        Row(
          children: [
            // Sort dropdown
            Expanded(
              child: Obx(() => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.sort),
                ),
                value: controller.selectedSortOption.value,
                items: SortOptions.values
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
                onChanged: (value) => controller.sortProducts(value!),
              )),
            ),

            const SizedBox(width: TSizes.sm),

            // // Filter button
            // Obx(() {
            //   final hasFilters = controller.selectedBrand.value.isNotEmpty ||
            //       controller.selectedCategory.value.isNotEmpty ||
            //       controller.minPrice.value > 0 ||
            //       controller.maxPrice.value < 100000;

            //   return Badge(
            //     isLabelVisible: hasFilters,
            //     child: IconButton(
            //       icon: const Icon(Iconsax.filter),
            //       style: IconButton.styleFrom(
            //         side: BorderSide(color: Theme.of(context).dividerColor),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
            //         ),
            //       ),
            //       onPressed: () => TFilterBottomSheet.show(context),
            //     ),
            //   );
            // }),
          
          ],
        ),

        const SizedBox(height: TSizes.spaceBtwSections),

        Obx(() => TGridLayout(
          itemCount: controller.filteredProducts.length,
          itemBuilder: (_, index) => TProductCardVertical(
            product: controller.filteredProducts[index],
          ),
        )),
      ],
    );
  }
}