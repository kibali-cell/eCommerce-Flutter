import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shopping/common/widgets/loaders/loaders.dart';

class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  // FIX: connectivity_plus v5+ emits List<ConnectivityResult>, not a single ConnectivityResult.
  // Updated StreamSubscription type accordingly.
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Rx<ConnectivityResult> _connectionStatus = ConnectivityResult.none.obs;

  @override
  void onInit() {
    super.onInit();
    // FIX: _updateConnectionStatus now accepts List<ConnectivityResult> to match
    // the new stream type from connectivity_plus v5+.
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // FIX: Parameter changed from ConnectivityResult to List<ConnectivityResult>.
  // We take the first result from the list (or default to none if the list is empty).
  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final result =
        results.isNotEmpty ? results.first : ConnectivityResult.none;
    _connectionStatus.value = result;
    if (_connectionStatus.value == ConnectivityResult.none) {
      TLoaders.warningSnackBar(title: 'No Internet Connection');
    }
  }

  Future<bool> isConnected() async {
    try {
      // FIX: checkConnectivity() also returns List<ConnectivityResult> in v5+.
      // We check if the list contains none, or if it's empty.
      final results = await _connectivity.checkConnectivity();
      if (results.isEmpty || results.contains(ConnectivityResult.none) && results.length == 1) {
        return false;
      } else {
        return true;
      }
    } on PlatformException catch (_) {
      return false;
    }
  }

  //dispose
  @override
  void onClose() {
    super.onClose();
    _connectivitySubscription.cancel();
  }
}