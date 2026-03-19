import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shopping/features/shop/controllers/product/all_products_controller.dart';
import 'package:shopping/utils/constants/sizes.dart';

class TFilterBottomSheet extends StatelessWidget {
  const TFilterBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const TFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AllProductsController.instance;
    final theme = Theme.of(context);

    // Local reactive copies so changes preview before Apply is tapped
    final tempBrand = controller.selectedBrand.value.obs;
    final tempCategory = controller.selectedCategory.value.obs;
    final tempMin = controller.minPrice.value.obs;
    final tempMax = controller.maxPrice.value.obs;

    final brands = controller.availableBrands;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.sm),
        child: ListView(
          controller: scrollController,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: TSizes.md),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter', style: theme.textTheme.headlineSmall),
                TextButton(
                  onPressed: () {
                    tempBrand.value = '';
                    tempCategory.value = '';
                    tempMin.value = 0;
                    tempMax.value = 100000;
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            // --- BRANDS ---
            if (brands.isNotEmpty) ...[
              Text('Brand', style: theme.textTheme.titleMedium),
              const SizedBox(height: TSizes.sm),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: brands.map((brand) {
                  final selected = tempBrand.value == brand;
                  return ChoiceChip(
                    label: Text(brand),
                    selected: selected,
                    onSelected: (_) =>
                        tempBrand.value = selected ? '' : brand,
                  );
                }).toList(),
              )),
              const SizedBox(height: TSizes.spaceBtwItems),
            ],

            // --- PRICE RANGE ---
            Text('Price Range', style: theme.textTheme.titleMedium),
            const SizedBox(height: TSizes.sm),
            Obx(() {
              final currentMin = tempMin.value;
              final currentMax = tempMax.value;
              return Column(
                children: [
                  RangeSlider(
                    min: 0,
                    max: 100000,
                    divisions: 200,
                    values: RangeValues(currentMin, currentMax),
                    labels: RangeLabels(
                      '\$${currentMin.toStringAsFixed(0)}',
                      '\$${currentMax.toStringAsFixed(0)}',
                    ),
                    onChanged: (values) {
                      tempMin.value = values.start;
                      tempMax.value = values.end;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${currentMin.toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall),
                      Text('\$${currentMax.toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              );
            }),

            const SizedBox(height: TSizes.spaceBtwSections),

            // --- APPLY ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Iconsax.filter),
                label: const Text('Apply Filters'),
                onPressed: () {
                  controller.selectedBrand.value = tempBrand.value;
                  controller.selectedCategory.value = tempCategory.value;
                  controller.minPrice.value = tempMin.value;
                  controller.maxPrice.value = tempMax.value;
                  controller.applyFilters();
                  Get.back();
                },
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwItems),
          ],
        ),
      ),
    );
  }
}