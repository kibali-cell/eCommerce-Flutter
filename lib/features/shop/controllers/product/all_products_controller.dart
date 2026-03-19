import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shopping/common/widgets/loaders/loaders.dart';
import 'package:shopping/data/repositories/product/product_repository.dart';
import 'package:shopping/features/shop/models/product_model.dart';
import 'package:shopping/utils/constants/enums.dart';
import 'package:shopping/utils/constants/sort_constants.dart';

class AllProductsController extends GetxController {
  static AllProductsController get instance => Get.find();

  final isLoading = false.obs;
  final repository = ProductRepository.instance;
  final RxString selectedSortOption = SortOptions.name.obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  final selectedBrand = ''.obs;
  final selectedCategory = ''.obs;

  final minPrice = 0.0.obs;
  final maxPrice = 100000.0.obs;

  List<String> get availableBrands {
  return allProducts
      .map((p) => p.brand?.name ?? '')
      .where((name) => name.isNotEmpty)
      .toSet()
      .toList();
}

  Future<List<ProductModel>> fetchProductsByQuery(Query? query) async {
    try {
      if (query == null) return [];

      final products = await repository.fetchProductsByQuery(query);

      return products;
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  void sortProducts(String sortOption) {
    selectedSortOption.value = sortOption;

    var tempList = filteredProducts.toList();
    switch (sortOption) {
      case 'Name':
        tempList.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Higher Price':
        tempList.sort((a, b) =>
            getEffectivePrice(b).compareTo(getEffectivePrice(a)));
        break;

      case 'Lower Price':
        tempList.sort((a, b) =>
            getEffectivePrice(a).compareTo(getEffectivePrice(b)));
        break;
      case 'Newest':
        tempList.sort((a, b) => a.date!.compareTo(b.date!));
        break;
      case 'Sale':
        tempList.sort((a, b) {
          if (b.salePrice > 0) {
            return b.salePrice.compareTo(a.salePrice);
          } else if (a.salePrice > 0) {
            return -1;
          } else {
            return 1;
          }
        });
        break;
      default:
        //Default sorting option: Name
        tempList.sort((a, b) => a.title.compareTo(b.title));
    }
    filteredProducts.assignAll(tempList);
  }

  double getEffectivePrice(ProductModel product) {
  return product.salePrice > 0 ? product.salePrice : product.price;
}


  // void assignProducts(List<ProductModel> products) {
  //   this.products.assignAll(products);
  //   sortProducts('name');
  // }

  void assignProducts(List<ProductModel> products) {
    allProducts.assignAll(products);
    applyFilters();
  }

void applyFilters() {
  var tempList = allProducts.toList();

  /// BRAND
  if (selectedBrand.value.isNotEmpty) {
    tempList = tempList.where(
      (p) => p.brand?.name == selectedBrand.value,
    ).toList();
  }

  /// CATEGORY
  if (selectedCategory.value.isNotEmpty) {
    tempList = tempList.where(
      (p) => p.categoryId == selectedCategory.value,
    ).toList();
  }

  /// PRICE
  tempList = tempList.where((p) {
    final price = getEffectivePrice(p);
    return price >= minPrice.value && price <= maxPrice.value;
  }).toList();

  filteredProducts.assignAll(tempList);

  sortProducts(selectedSortOption.value);
}

  double getProductPriceValue(ProductModel product) {
  return product.salePrice > 0 ? product.salePrice : product.price;
}

  // Future<void> searchProducts(String query) async {
  //   try {
  //     final searchQuery = _buildSearchQuery(query);
  //     final searchResults = await fetchProductsByQuery(searchQuery);
  //     assignProducts(searchResults);
  //   } catch (e) {
  //     TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
  //   }
  // }

  void searchProducts(String query) async {
    isLoading.value = true;
    try {
      final searchResults = await repository.searchProducts(query);
      products.assignAll(searchResults);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  double getProductPrice(ProductModel product) {
    double smallestPrice = double.infinity;
    double largestPrice = 0.0;

    // Single Product
    if (product.productType == ProductType.single.toString()) {
      return product.salePrice > 0 ? product.salePrice : product.price;
    } 
    // Variable Product
    else {
      for (var variation in product.productVariations!) {

        final priceToConsider =
            variation.salePrice > 0.0 ? variation.salePrice : variation.price;

        if (priceToConsider < smallestPrice) {
          smallestPrice = priceToConsider;
        }

        if (priceToConsider > largestPrice) {
          largestPrice = priceToConsider;
        }
      }

      // If all variations same price
      if (smallestPrice == largestPrice) {
        return largestPrice;
      }

      // Return smallest price (UI decides range display)
      return smallestPrice;
    }
  }


  // Query _buildSearchQuery(String query) {
  //   return FirebaseFirestore.instance
  //       .collection('products')
  //       .where('title', isGreaterThanOrEqualTo: query)
  //       .where('title', isLessThanOrEqualTo: '$query\uf8ff');
  // }
}
