import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CartSummaryCard extends StatelessWidget {
  final List<dynamic> filteredItems;
  const CartSummaryCard({super.key, required this.filteredItems});

  @override
  Widget build(BuildContext context) {
    double itemHeight = 40;
    double calculatedHeight = (filteredItems.length * itemHeight);
    double modalHeight = calculatedHeight > 250 ? 250 : calculatedHeight;

    final totalPrice = filteredItems.fold<double>(
      0.0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 21),
      padding: EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(11),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(maxHeight: 270),
              height: modalHeight,
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 130,
                              child: Text(
                                filteredItems[index]['itemName'],
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '   x   ${filteredItems[index]['quantity']}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "₹ ${filteredItems[index]['price'] * filteredItems[index]['quantity']}",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Gap(11),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "₹ $totalPrice",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
