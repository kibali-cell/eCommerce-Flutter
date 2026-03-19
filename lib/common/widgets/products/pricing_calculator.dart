class TPricingCalculator {
  /// Total Price including shipping and tax
  static double calculateTotalPrice(double subTotal, String location) {
    final shippingCost = getShippingCost(location);
    final taxAmount = calculateTax(subTotal, location);
    final totalPrice = subTotal + shippingCost + taxAmount;
    return totalPrice;
  }

  /// Calculate shipping cost
  static double calculateShippingCost(double subTotal, String location) {
    return getShippingCost(location);
  }

  /// Calculate tax amount
  static double calculateTax(double subTotal, String location) {
    final taxRate = getTaxRateForLocation(location);
    final taxAmount = subTotal * taxRate;
    return taxAmount;
  }

  /// Lookup tax rate for location
  static double getTaxRateForLocation(String location) {
    return 0.10; // Example: 10% tax
  }

  /// Lookup shipping cost for location
  static double getShippingCost(String location) {
    return 5.00; // Example: flat $5 shipping
  }
}