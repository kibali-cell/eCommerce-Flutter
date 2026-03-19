import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shopping/common/widgets/appbar/appbar.dart';
import 'package:shopping/common/widgets/products/sortable/fillter_bottom_sheet.dart';
import 'package:shopping/common/widgets/texts/product_price_text.dart';
import 'package:shopping/data/repositories/product/product_repository.dart';
import 'package:shopping/features/shop/controllers/brand_controller.dart';
import 'package:shopping/features/shop/controllers/category_controller.dart';
import 'package:shopping/features/shop/controllers/product/all_products_controller.dart';
import 'package:shopping/features/shop/models/product_model.dart';
import 'package:shopping/features/shop/screens/product_details/product_detail.dart';
import 'package:shopping/utils/constants/colors.dart';
import 'package:shopping/utils/constants/sizes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final AllProductsController controller;
  late final BrandController brandController;
  late final CategoryController categoryController;

  final TextEditingController _searchController = TextEditingController();
  Worker? _debounceWorker;
  final RxString _query = ''.obs;
  final RxBool _hasSearched = false.obs;

  // Track which sections are expanded
  final RxBool _brandsExpanded = true.obs;
  final RxBool _categoriesExpanded = true.obs;

  // Track active quick-filters from discovery taps
  final RxString _activeBrandId = ''.obs;
  final RxString _activeBrandName = ''.obs;
  final RxString _activeCategoryId = ''.obs;
  final RxString _activeCategoryName = ''.obs;

  // Popular products loaded once on init
  final RxList popularProducts = [].obs;
  final RxBool _popularLoading = true.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AllProductsController());
    brandController = Get.put(BrandController());
    categoryController = Get.put(CategoryController());

    _loadPopularProducts();

    _debounceWorker = debounce(
      _query,
      (value) {
        if (value.trim().isNotEmpty) {
          _hasSearched.value = true;
          controller.searchProducts(value.trim());
        } else {
          _hasSearched.value = false;
          controller.products.clear();
        }
      },
      time: const Duration(milliseconds: 500),
    );
  }

  Future<void> _loadPopularProducts() async {
    try {
      _popularLoading.value = true;
      final products = await Get.find<ProductRepository>()
          .getAllFeaturedProducts()
          .catchError((_) async {
        return await Get.find<ProductRepository>().getFeaturedProducts();
      });
      popularProducts.assignAll(products);
    } catch (_) {
    } finally {
      _popularLoading.value = false;
    }
  }

  void _onBrandTap(String brandId, String brandName) {
    if (_activeBrandId.value == brandId) {
      // Deselect
      _activeBrandId.value = '';
      _activeBrandName.value = '';
      controller.selectedBrand.value = '';
    } else {
      _activeBrandId.value = brandId;
      _activeBrandName.value = brandName;
      controller.selectedBrand.value = brandName;
    }
    _runDiscoveryFilter();
  }

  void _onCategoryTap(String categoryId, String categoryName) {
    if (_activeCategoryId.value == categoryId) {
      _activeCategoryId.value = '';
      _activeCategoryName.value = '';
      controller.selectedCategory.value = '';
    } else {
      _activeCategoryId.value = categoryId;
      _activeCategoryName.value = categoryName;
      controller.selectedCategory.value = categoryId;
    }
    _runDiscoveryFilter();
  }

  void _runDiscoveryFilter() {
    // If actively searching, re-apply filters on search results
    if (_hasSearched.value) {
      controller.applyFilters();
      return;
    }
    // Otherwise filter popular products shown on discovery
    controller.assignProducts(popularProducts.cast());
  }

  void _clearDiscoveryFilters() {
    _activeBrandId.value = '';
    _activeBrandName.value = '';
    _activeCategoryId.value = '';
    _activeCategoryName.value = '';
    controller.selectedBrand.value = '';
    controller.selectedCategory.value = '';
    controller.minPrice.value = 0;
    controller.maxPrice.value = 100000;
    if (_hasSearched.value) {
      controller.applyFilters();
    } else {
      controller.assignProducts(popularProducts.cast());
    }
  }

  int _activeFilterCount(AllProductsController c) {
    int count = 0;
    if (c.selectedBrand.value.isNotEmpty) count++;
    if (c.selectedCategory.value.isNotEmpty) count++;
    if (c.minPrice.value > 0 || c.maxPrice.value < 100000) count++;
    return count;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Discover', style: theme.textTheme.headlineSmall),
        actions: [
          Obx(() {
            final count = _activeFilterCount(controller);
            return Padding(
              padding: const EdgeInsets.only(right: TSizes.sm),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: Icon(
                      count > 0 ? Iconsax.filter_tick : Iconsax.filter,
                    ),
                    tooltip: 'Filter',
                    onPressed: () => TFilterBottomSheet.show(context),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                TSizes.md, TSizes.sm, TSizes.md, TSizes.sm),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => _query.value = v,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Iconsax.search_normal),
                suffixIcon: Obx(
                  () => _query.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _query.value = '';
                            _hasSearched.value = false;
                            controller.products.clear();
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(TSizes.borderRadiusLg),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    dark ? TColors.darkerGrey : TColors.lightContainer,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: TSizes.sm,
                  horizontal: TSizes.md,
                ),
              ),
            ),
          ),

          // ── Active filter chips row ─────────────────────────────────────
          Obx(() {
            final brand = controller.selectedBrand.value;
            final category = _activeCategoryName.value;
            final hasPrice = controller.minPrice.value > 0 ||
                controller.maxPrice.value < 100000;
            if (brand.isEmpty && category.isEmpty && !hasPrice) {
              return const SizedBox.shrink();
            }
            return SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: TSizes.md),
                children: [
                  if (brand.isNotEmpty)
                    _FilterChip(
                      label: brand,
                      onRemove: () {
                        _activeBrandId.value = '';
                        _activeBrandName.value = '';
                        controller.selectedBrand.value = '';
                        _runDiscoveryFilter();
                      },
                    ),
                  if (category.isNotEmpty)
                    _FilterChip(
                      label: category,
                      onRemove: () {
                        _activeCategoryId.value = '';
                        _activeCategoryName.value = '';
                        controller.selectedCategory.value = '';
                        _runDiscoveryFilter();
                      },
                    ),
                  if (hasPrice)
                    _FilterChip(
                      label:
                          '\$${controller.minPrice.value.toStringAsFixed(0)} – \$${controller.maxPrice.value.toStringAsFixed(0)}',
                      onRemove: () {
                        controller.minPrice.value = 0;
                        controller.maxPrice.value = 100000;
                        _runDiscoveryFilter();
                      },
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: ActionChip(
                      label: const Text('Clear all'),
                      onPressed: _clearDiscoveryFilters,
                      backgroundColor: Colors.red.shade50,
                      labelStyle: const TextStyle(color: Colors.red),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                  ),
                ],
              ),
            );
          }),

          // ── Main scrollable body ────────────────────────────────────────
          Expanded(
            child: Obx(() {
              // ── SEARCH RESULTS MODE ──────────────────────────────────
              if (_hasSearched.value) {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final hasFilters =
                    controller.selectedBrand.value.isNotEmpty ||
                        controller.selectedCategory.value.isNotEmpty ||
                        controller.minPrice.value > 0 ||
                        controller.maxPrice.value < 100000;

                final displayList = hasFilters
                    ? controller.filteredProducts
                    : controller.products;

                if (displayList.isEmpty) {
                  return _EmptyState(
                    icon: Iconsax.box_remove,
                    title: 'No Products Found',
                    subtitle: hasFilters
                        ? 'No products match your filters.\nTry adjusting or clearing them.'
                        : 'Nothing for "${_query.value}".\nTry a different keyword.',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.md, vertical: TSizes.xs),
                      child: Text(
                        '${displayList.length} result${displayList.length == 1 ? '' : 's'} for "${_query.value}"',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: _ProductListView(
                        products: displayList
                            .cast<ProductModel>()
                            .toList(),
                        controller: controller,
                      ),
                    ),
                  ],
                );
              }

              // ── DISCOVERY MODE ───────────────────────────────────────
              return CustomScrollView(
                slivers: [
                  // ── Brands section ─────────────────────────────────
                  SliverToBoxAdapter(
                    child: _ExpandableSection(
                      title: 'Brands',
                      icon: Iconsax.shop,
                      expanded: _brandsExpanded,
                      onToggle: () => _brandsExpanded.toggle(),
                      child: Obx(() {
                        // if (brandController.isLoading.value) {
                        //   return const _SectionShimmer();
                        // }
                        if (brandController.allBrands.isEmpty) {
                          return const _SectionEmpty(
                              message: 'No brands available');
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(
                              TSizes.md, 0, TSizes.md, TSizes.sm),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: brandController.allBrands
                                .map((brand) {
                              final isActive =
                                  _activeBrandId.value == brand.id;
                              return GestureDetector(
                                onTap: () =>
                                    _onBrandTap(brand.id, brand.name),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? TColors.primary
                                        : dark
                                            ? TColors.darkerGrey
                                            : TColors.lightContainer,
                                    borderRadius: BorderRadius.circular(
                                        TSizes.borderRadiusMd),
                                    border: Border.all(
                                      color: isActive
                                          ? TColors.primary
                                          : dark
                                              ? TColors.darkGrey
                                              : TColors.borderSecondary,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (brand.image.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 6),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Image.network(
                                              brand.image,
                                              width: 20,
                                              height: 20,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) =>
                                                  Icon(
                                                      Iconsax.shop,
                                                      size: 16,
                                                      color: isActive
                                                          ? TColors.white
                                                          : TColors.darkGrey),
                                            ),
                                          ),
                                        ),
                                      Text(
                                        brand.name,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: isActive
                                              ? TColors.white
                                              : dark
                                                  ? TColors.white
                                                  : TColors.textPrimary,
                                          fontWeight: isActive
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (brand.productsCount != null &&
                                          brand.productsCount! > 0) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          '(${brand.productsCount})',
                                          style: theme
                                              .textTheme.labelSmall
                                              ?.copyWith(
                                            color: isActive
                                                ? TColors.white
                                                    .withOpacity(0.75)
                                                : TColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ── Categories section ──────────────────────────────
                  SliverToBoxAdapter(
                    child: _ExpandableSection(
                      title: 'Categories',
                      icon: Iconsax.category,
                      expanded: _categoriesExpanded,
                      onToggle: () => _categoriesExpanded.toggle(),
                      child: Obx(() {
                        if (categoryController.isLoading.value) {
                          return const _SectionShimmer();
                        }
                        if (categoryController.allCategories.isEmpty) {
                          return const _SectionEmpty(
                              message: 'No categories available');
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(
                              TSizes.md, 0, TSizes.md, TSizes.sm),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: categoryController.allCategories
                                .where((c) => c.parentId.isEmpty)
                                .map((category) {
                              final isActive =
                                  _activeCategoryId.value ==
                                      category.id;
                              return GestureDetector(
                                onTap: () => _onCategoryTap(
                                    category.id, category.name),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? theme.colorScheme.primary
                                        : dark
                                            ? TColors.darkerGrey
                                            : TColors.lightContainer,
                                    borderRadius: BorderRadius.circular(
                                        TSizes.borderRadiusMd),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (category.image.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 6),
                                          child: Image.network(
                                            category.image,
                                            width: 18,
                                            height: 18,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) =>
                                                Icon(
                                              Iconsax.category,
                                              size: 16,
                                              color: isActive
                                                  ? Colors.white
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      Text(
                                        category.name,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: isActive
                                              ? Colors.white
                                              : null,
                                          fontWeight: isActive
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ── Popular Products section ────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          TSizes.md, TSizes.sm, TSizes.md, TSizes.xs),
                      child: Row(
                        children: [
                          const Icon(Iconsax.star, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _activeBrandId.value.isNotEmpty ||
                                    _activeCategoryId.value.isNotEmpty
                                ? 'Filtered Products'
                                : 'Popular Products',
                            style: theme.textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Obx(() {
                            final count =
                                controller.filteredProducts.length;
                            final hasFilter =
                                _activeBrandId.value.isNotEmpty ||
                                    _activeCategoryId.value.isNotEmpty;
                            if (!hasFilter) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              '$count item${count == 1 ? '' : 's'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Popular products grid or filtered results
                  Obx(() {
                    if (_popularLoading.value) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(TSizes.xl),
                          child: Center(
                              child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    final hasFilter =
                        controller.selectedBrand.value.isNotEmpty ||
                            controller.selectedCategory.value.isNotEmpty;
                    final displayList = hasFilter
                        ? controller.filteredProducts
                            .cast<ProductModel>()
                            .toList()
                        : popularProducts.cast<ProductModel>().toList();

                    if (displayList.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _EmptyState(
                          icon: Iconsax.box_remove,
                          title: 'No Products Found',
                          subtitle: hasFilter
                              ? 'No products match the selected filters.\nTry a different combination.'
                              : 'No popular products yet.',
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.md, vertical: TSizes.sm),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index < displayList.length - 1) {
                              return Column(
                                children: [
                                  _ProductTile(
                                    product: displayList[index],
                                    controller: controller,
                                  ),
                                  const Divider(
                                      height: 1, thickness: 0.5),
                                ],
                              );
                            }
                            return _ProductTile(
                              product: displayList[index],
                              controller: controller,
                            );
                          },
                          childCount: displayList.length,
                        ),
                      ),
                    );
                  }),

                  const SliverToBoxAdapter(
                      child: SizedBox(height: TSizes.spaceBtwSections)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Reusable expandable section wrapper ────────────────────────────────────────
class _ExpandableSection extends StatelessWidget {
  const _ExpandableSection({
    required this.title,
    required this.icon,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final IconData icon;
  final RxBool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: TSizes.md, vertical: TSizes.sm),
            child: Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Obx(() => AnimatedRotation(
                      turns: expanded.value ? 0 : -0.25,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down,
                          size: 20),
                    )),
              ],
            ),
          ),
        ),
        Obx(() => AnimatedCrossFade(
              firstChild: child,
              secondChild: const SizedBox.shrink(),
              crossFadeState: expanded.value
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 250),
            )),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}

// ── Product list view used in search results ───────────────────────────────────
class _ProductListView extends StatelessWidget {
  const _ProductListView(
      {required this.products, required this.controller});

  final List<ProductModel> products;
  final AllProductsController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
          horizontal: TSizes.md, vertical: TSizes.sm),
      itemCount: products.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, thickness: 0.5),
      itemBuilder: (_, index) => _ProductTile(
        product: products[index],
        controller: controller,
      ),
    );
  }
}

// ── Single product row tile ────────────────────────────────────────────────────
class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.controller});

  final ProductModel product;
  final AllProductsController controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 0, vertical: TSizes.xs),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
        child: SizedBox(
          width: 60,
          height: 60,
          child: product.thumbnail.isNotEmpty
              ? Image.network(
                  product.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _PlaceholderImage(),
                )
              : const _PlaceholderImage(),
        ),
      ),
      title: Text(
        product.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: TProductPriceText(
            price: controller.getProductPrice(product)),
      ),
      trailing: const Icon(Iconsax.arrow_right_3, size: 16),
      onTap: () => Get.to(() => ProductDetailScreen(product: product)),
    );
  }
}

// ── Small helpers ──────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onRemove,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}

class _SectionShimmer extends StatelessWidget {
  const _SectionShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(TSizes.md, 0, TSizes.md, TSizes.sm),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          6,
          (_) => Container(
            width: 80,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(TSizes.md, 0, TSizes.md, TSizes.sm),
      child: Text(message,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState(
      {required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: TSizes.md),
            Text(title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: TSizes.sm),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(Iconsax.image, color: Colors.grey.shade400),
    );
  }
}