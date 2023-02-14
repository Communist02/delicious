import 'package:flutter/material.dart';
import 'classes.dart';
import 'global.dart';
import 'firebase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'state_update.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Оформление заказа'),
      ),
      body: const ProductsView(),
      bottomNavigationBar: Container(
        height: 40,
        width: double.infinity,
        margin: const EdgeInsets.all(10),
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          child: const Text('ЗАВЕРШИТЬ ОФОРМЛЕНИЕ'),
          onPressed: () async {
            final CloudStore cloudStore = CloudStore();
            await cloudStore.addOrder(OrderProducts.fromBasket(globalBasket, globalProducts));
            globalBasket.clear();
            if (!mounted) return;
            context.read<ChangeBasket>().change();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Оформление'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProductView extends StatelessWidget {
  const ProductView({Key? key, required this.basketProduct}) : super(key: key);
  final BasketProduct basketProduct;


  @override
  Widget build(BuildContext context) {
    final menuProduct = globalProducts.byId(basketProduct.id);

    String price() {
      final total = menuProduct.price * basketProduct.count;
      return total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 1);
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 10, 10),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  child: CachedNetworkImage(imageUrl: menuProduct.imageUrl),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menuProduct.name + (basketProduct.count > 1 ? ' ${basketProduct.count.toString()} шт.' : ''),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'BalsamiqSans',
                        ),
                      ),
                      Text(
                        '${price()} ₽',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductsView extends StatelessWidget {
  const ProductsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 5),
      itemCount: globalBasket.products.length,
      itemBuilder: (context, int i) {
        return ProductView(basketProduct: globalBasket.products[i]);
      },
    );
  }
}
