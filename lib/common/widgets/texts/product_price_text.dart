import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TProductPriceText extends StatelessWidget {
  const TProductPriceText(
      {super.key,
      this.currencySign = '/=',
      required this.price,
      this.maxLine = 1,
      this.isLarge = false,
      this.lineThrough = false}
      );

  final String currencySign;
  final double price;
  final int maxLine;
  final bool isLarge;
  final bool lineThrough;

  @override
  Widget build(BuildContext context) {

    final formattedPrice = NumberFormat.currency(
      locale: 'en_TZ',
      symbol: '',
      decimalDigits: price % 1 == 0 ? 0 : 2, 
    ).format(price);


    return Text(
      '$formattedPrice$currencySign',
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
      style: isLarge
          ? Theme.of(context).textTheme.headlineMedium!.apply(
              decoration: lineThrough ? TextDecoration.lineThrough : null)
          : Theme.of(context).textTheme.titleLarge!.apply(
              decoration: lineThrough ? TextDecoration.lineThrough : null),
    );
  }
}
