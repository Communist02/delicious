import 'dart:convert';
import 'package:flutter/material.dart';
import 'classes.dart';
import 'global.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'state_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key, required this.product});
  final MenuProduct product;

  @override
  Widget build(BuildContext context) {
    List<MenuProduct> products = globalProducts.byCategory(product.category);

    int index = 0;
    for (int i = 0; i < products.length; i++) {
      if (products[i].name == product.name) {
        index = i;
        break;
      }
    }

    List<Widget> viewProducts(List<MenuProduct> products) {
      List<Widget> tabs = [];
      for (final product in products) {
        tabs.add(ProductView(product: product));
      }
      return tabs;
    }

    return DefaultTabController(
      initialIndex: index,
      length: products.length,
      child: Builder(
        builder: (context) {
          return Stack(
            children: [
              Container(color: Theme.of(context).cardColor),
              Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amber.shade600,
                        image: DecorationImage(
                          alignment: Alignment.topCenter,
                          image: const AssetImage('assets/images/food_outlined.png'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.amber.shade800, BlendMode.srcATop),
                        ),
                      ),
                    ),
                  ),
                  Flexible(flex: 1, child: Container()),
                ],
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: Stack(
                    children: [
                      TabBarView(children: viewProducts(products)),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: const EdgeInsets.only(left: 10, top: 10),
                          child: FloatingActionButton(
                            mini: true,
                            heroTag: null,
                            onPressed: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back_ios_rounded),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: const EdgeInsets.only(right: 10, top: 10),
                          child: FloatingActionButton(
                            mini: true,
                            heroTag: null,
                            onPressed: () {
                              Navigator.popUntil(context, ModalRoute.withName('/'));
                              context.read<ChangeNavigation>().change(4);
                            },
                            child: const Icon(Icons.shopping_cart_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProductView extends StatelessWidget {
  ProductView({super.key, required this.product});
  final MenuProduct product;
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<void> sharedBasket() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('basket', jsonEncode(globalBasket.toMap()));
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          children: [
            Stack(
              children: [
                Card(
                  margin: const EdgeInsets.only(top: 170),
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 300),
                    margin: const EdgeInsets.fromLTRB(30, 120, 30, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                          title: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'BalsamiqSans',
                            ),
                          ),
                          trailing: Text(
                            '${product.stringPrice()} ₽',
                            style: TextStyle(
                              color: Colors.amber.shade600,
                              fontSize: 40,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (product.description.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                              'Описание',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'BalsamiqSans',
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            product.description,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'BalsamiqSans',
                              color: Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  margin: const EdgeInsets.fromLTRB(50, 10, 50, 0),
                  child: CachedNetworkImage(imageUrl: product.imageUrl),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: Container(
          height: 70,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          color: Theme.of(context).cardColor,
          child: ElevatedButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: const Text(
              'ДОБАВИТЬ В КОРЗИНУ',
              style: TextStyle(fontSize: 15),
            ),
            onPressed: () {
              globalBasket.add(product.toBasketProduct());
              context.read<ChangeBasket>().change();
              sharedBasket();
              _messengerKey.currentState!.removeCurrentSnackBar();
              _messengerKey.currentState!.showSnackBar(
                const SnackBar(
                  content: Text('Добавлено в корзину'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
