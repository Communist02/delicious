import 'dart:convert';
import 'package:flutter/material.dart';
import 'classes.dart';
import 'global.dart';
import 'payment.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'state_update.dart';
import 'product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasketPage extends StatefulWidget {
  const BasketPage({Key? key}) : super(key: key);

  @override
  State<BasketPage> createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${context.watch<ChangeBasket>().getCount} товаров на ${globalBasket.stringPrice(globalProducts)} ₽'),
        centerTitle: true,
      ),
      body: globalBasket.products.isNotEmpty ? const BasketView() : const BasketEmpty(),
      bottomNavigationBar: globalBasket.products.isNotEmpty
          ? Container(
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
                onPressed: account.id == null
                    ? () => context.read<ChangeNavigation>().change(2)
                    : () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentPage()));
                        setState(() {});
                      },
                child: Text(
                  account.id != null ? 'ОФОРМИТЬ ЗА ${globalBasket.stringPrice(globalProducts)} ₽' : 'ВОЙДИТЕ В АККАУНТ',
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}

class BasketEmpty extends StatelessWidget {
  const BasketEmpty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: () => context.read<ChangeNavigation>().change(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.shopping_cart_outlined, size: 150),
              Text(
                'Корзина пуста',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'BalsamiqSans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BasketProductView extends StatelessWidget {
  const BasketProductView({Key? key, required this.basketProduct}) : super(key: key);
  final BasketProduct basketProduct;

  Future<void> sharedBasket() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('basket', jsonEncode(globalBasket.toMap()));
  }

  @override
  Widget build(BuildContext context) {
    final menuProduct = globalProducts.byId(basketProduct.id);

    String price() {
      final total = menuProduct.price * basketProduct.count;
      return total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 1);
    }

    return Dismissible(
      key: Key(basketProduct.id),
      onDismissed: (DismissDirection dir) {
        globalBasket.delete(basketProduct);
        context.read<ChangeBasket>().change();
        sharedBasket();
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 30),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(21),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 30),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(21),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(product: menuProduct))),
        child: Card(
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
                            menuProduct.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'BalsamiqSans',
                            ),
                          ),
                          Text(
                            menuProduct.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'BalsamiqSans',
                              color: Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${price()} ₽',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[350]!),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                      height: 40,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              globalBasket.remove(basketProduct);
                              context.read<ChangeBasket>().change();
                              sharedBasket();
                            },
                          ),
                          Text(
                            basketProduct.count.toString(),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              globalBasket.add(basketProduct);
                              context.read<ChangeBasket>().change();
                              sharedBasket();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BasketView extends StatelessWidget {
  const BasketView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.watch<ChangeBasket>().getCount;
    return ListView.builder(
      key: const PageStorageKey('Basket'),
      padding: const EdgeInsets.symmetric(vertical: 5),
      itemCount: globalBasket.products.length,
      itemBuilder: (context, int i) {
        return BasketProductView(basketProduct: globalBasket.products[i]);
      },
    );
  }
}
