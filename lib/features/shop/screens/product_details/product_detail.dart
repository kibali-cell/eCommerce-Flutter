import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:shopping/common/widgets/texts/section_heading.dart';
import 'package:shopping/features/shop/models/product_model.dart';
import 'package:shopping/features/shop/screens/product_details/widget/bottom_add_to_cart.dart';
import 'package:shopping/features/shop/screens/product_details/widget/product_attributes.dart';
import 'package:shopping/features/shop/screens/product_details/widget/product_detail_image_slider.dart';
import 'package:shopping/features/shop/screens/product_details/widget/product_meta_data.dart';
import 'package:shopping/features/shop/screens/product_details/widget/rating_share_widget.dart';
import 'package:shopping/features/shop/screens/product_reviews/product_reviews.dart';
import 'package:shopping/features/shop/screens/checkout/checkout.dart';
import 'package:shopping/utils/constants/enums.dart';

import 'package:shopping/utils/constants/sizes.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    // final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      bottomNavigationBar: TBottomAddToCart(product: product),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //product image slider
            TProductImageSlider(product: product),

            //product details
            Padding(
              padding: const EdgeInsets.only(
                  right: TSizes.defaultSpace,
                  left: TSizes.defaultSpace,
                  bottom: TSizes.defaultSpace),
              child: Column(
                children: [
                  const TRatingAndShare(),

                  //price, title, stock & brand
                  TProductMetaData(product: product),

                  //attributes
                  if (product.productType == ProductType.variable.toString())
                    TProductAttributes(
                      product: product,
                    ),
                  if (product.productType == ProductType.variable.toString())
                    const SizedBox(
                      height: TSizes.spaceBtwSections,
                    ),

                  //description
                  const TSectionHeading(
                    title: 'Description',
                    showActionButton: false,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  ReadMoreText(
                    product.description ?? '',
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: 'Show more',
                    trimExpandedText: ' Less',
                    moreStyle:
                        const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    lessStyle:
                        const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),

                  //reviews
                  const Divider(),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TSectionHeading(
                    title: 'Reviews(199)',
                    onPressed: () =>
                        Get.to((() => const ProductReviewScreen())),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            )
          ],

          //product detail
        ),
      ),
    );
  }
}
