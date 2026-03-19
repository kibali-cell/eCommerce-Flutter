import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shopping/data/repositories/authentication/authentication_repository.dart';
import 'package:shopping/features/shop/models/order_model.dart';
import 'package:shopping/utils/constants/enums.dart';

class OrderRepository extends GetxController {
  static OrderRepository get instance => Get.find();

  /// Variables
  final _db = FirebaseFirestore.instance;

  /// Get all order related to current User
  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final userId = AuthenticationRepository.instance.authUser.uid;
      if (userId.isEmpty) {
        throw 'Unable to find user information. Try again in few minutes.';
      }
      final result =
          await _db.collection('Users').doc(userId).collection('Orders').get();
      return result.docs
          .map((documentSnapshot) => OrderModel.fromSnapshot(documentSnapshot))
          .toList();
    } catch (e) {
      throw 'Something went wrong while fetching Order Information. Try again later';
    }
  }

  /// Store new usen order
  Future<void> saveOrder(OrderModel order, String userId) async {
    try {
      await _db
          .collection('Users')
          .doc(userId)
          .collection('Orders')
          .add(order.toJson());
    } catch (e) {
      throw 'Something went wrong white saving Order Information. Try again later';
    }
  }



/// Update the status of an existing order in Firestore
Future<void> updateOrderStatus(
    String orderId, String userId, OrderStatus status) async {
  try {
    await _db
        .collection('Users')
        .doc(userId)
        .collection('Orders')
        .doc(orderId)
        .update({'Status': status.toString()});
  } catch (e) {
    throw 'Failed to update order status. Please try again.';
  }
}
}
