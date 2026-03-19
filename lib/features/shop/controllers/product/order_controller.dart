import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shopping/common/widgets/loaders/loaders.dart';
import 'package:shopping/common/widgets/success_screen/success_screen.dart';
import 'package:shopping/data/repositories/authentication/authentication_repository.dart';
import 'package:shopping/data/repositories/orders/order_repository.dart';
import 'package:shopping/features/personalization/controllers/address_controller.dart';
import 'package:shopping/features/shop/controllers/product/cart_controller.dart';
import 'package:shopping/features/shop/controllers/product/checkout_controller.dart';
import 'package:shopping/features/shop/models/order_model.dart';
import 'package:shopping/navigation_menu.dart';
import 'package:shopping/utils/constants/enums.dart';
import 'package:shopping/utils/constants/image_strings.dart';
import 'package:shopping/utils/popups/full_screen_loader.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  //variables
  final cartController = CartController.instance;
  final addressController = AddressController.instance;
  final checkoutController = CheckoutController.instance;
  final orderRepository = Get.put(OrderRepository());
  final userEmail = AuthenticationRepository.instance.authUser.email ?? '';

  //fetch user's order history
  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final userOrders = await orderRepository.fetchUserOrders();
      return userOrders;
    } catch (e) {
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  //Add methods for order processing
  void processOrder(double totalAmount) async {
    try {
      //start loader
      TFullScreenLoader.openLoadingDialog(
          'Processing your Order', TImages.loadingJuggleAnimation);

      //get user auth
      final userId = AuthenticationRepository.instance.authUser.uid;
      if (userId.isEmpty) return;

      //Add details
      final order = OrderModel(
        id: UniqueKey().toString(),
        userId: userId,
        userEmail: userEmail,
        status: OrderStatus.pending,
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        paymentMethod: checkoutController.selectedPaymentMethod.value.name,
        address: addressController.selectedAddress.value,
        deliveryDate: DateTime.now(),
        items: cartController.cartItems.toList(),
      );

      //save the order
      await orderRepository.saveOrder(order, userId);

      //update the cart
      cartController.clearCart();

      //show Success Screen
      Get.off(() => SuccessScreen(
            image: TImages.onBoardingImage3,
            title: 'Payment Success!',
            subTitle: 'Your Item will be shipped soon!',
            onPressed: () => Get.offAll(() => const NavigationMenu()),
          ));
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  // Cancel an order by ID
  Future<void> cancelOrder(String orderId) async {
    try {
      // Starting loader
      TFullScreenLoader.openLoadingDialog(
        "Cancelling your Order...", TImages.loadingJuggleAnimation);

        //Get User Auth
        final userId = AuthenticationRepository.instance.authUser.uid;
        if (userId.isEmpty) return;
        // Update order status to cancelled in the repository
      await orderRepository.updateOrderStatus(
          orderId, userId, OrderStatus.cancelled);

      // Stop loader
      TFullScreenLoader.stopLoading();

      // Show success feedback
      TLoaders.successSnackBar(
        title: 'Order Cancelled',
        message: 'Your order has been successfully cancelled.',
      );

      // Navigate back to orders list
      Get.offAll(() => const NavigationMenu());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}