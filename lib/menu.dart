import 'dart:convert';
import 'package:flutter/material.dart';
import 'global.dart';
import 'classes.dart';
import 'product.dart';
import 'settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:provider/provider.dart';
import 'state_update.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final CloudStore _cloudStore = CloudStore();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _cloudStore.getProducts(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData && globalProducts.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Ошибка'));
        } else {
          List<Tab> menuTabs() {
            List<Tab> menuTabs = [];
            for (final category in globalProducts.categories()) {
              menuTabs.add(Tab(text: category));
            }
            return menuTabs;
          }

          List<Widget> menuPages() {
            List<Widget> menuPages = [];
            for (final category in globalProducts.categories()) {
              menuPages.add(ProductsView(category: category));
            }
            return menuPages;
          }

          final menuTabs0 = menuTabs();
          final menuPages0 = menuPages();

          return DefaultTabController(
            length: menuTabs0.length,
            child: Scaffold(
              body: NestedScrollView(
                floatHeaderSlivers: true,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      sliver: SliverAppBar(
                        pinned: true,
                        floating: true,
                        snap: true,
                        elevation: 1,
                        title: GestureDetector(
                          onTap: () {
                            showSearch(context: context, delegate: MenuSearch());
                          },
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                            ),
                            child: Container(
                              height: 46,
                              padding: const EdgeInsets.only(left: 12, right: 1),
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Icon(
                                      Icons.search,
                                      color: Theme.of(context).textTheme.bodySmall!.color,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Поиск',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodySmall!.color,
                                        fontSize: 17,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.settings_outlined,
                                      color: Theme.of(context).textTheme.bodySmall!.color,
                                    ),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        bottom: TabBar(
                          tabs: menuTabs0,
                          isScrollable: true,
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'BalsamiqSans',
                          ),
                          indicator: BubbleTabIndicator(
                            indicatorColor: Theme.of(context).colorScheme.secondary,
                            indicatorHeight: 34,
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: TabBarView(children: menuPages0),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class ProductView extends StatelessWidget {
  final MenuProduct product;

  const ProductView(this.product, {super.key});

  Future<void> sharedBasket() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('basket', jsonEncode(globalBasket.toMap()));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(product: product))),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                margin: const EdgeInsets.only(right: 8),
                child: CachedNetworkImage(imageUrl: product.imageUrl),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'BalsamiqSans',
                      ),
                    ),
                    Text(
                      product.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'BalsamiqSans',
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: OutlinedButton(
                        child: Text(
                          '${product.stringPrice()} ₽',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        onPressed: () {
                          globalBasket.add(product.toBasketProduct());
                          context.read<ChangeBasket>().change();
                          sharedBasket();
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Добавлено в корзину'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductsView extends StatelessWidget {
  const ProductsView({Key? key, required this.category}) : super(key: key);
  final String category;

  @override
  Widget build(BuildContext context) {
    final List<MenuProduct> products = globalProducts.byCategory(category);
    return ListView.builder(
      key: PageStorageKey(category),
      padding: const EdgeInsets.symmetric(vertical: 5),
      itemCount: products.length,
      itemBuilder: (context, int i) {
        return ProductView(products[i]);
      },
    );
  }
}

class MenuSearch extends SearchDelegate<MenuSearch> {
  @override
  String get searchFieldLabel => 'Поиск';

  @override
  TextStyle get searchFieldStyle {
    return TextStyle(
      fontWeight: FontWeight.normal,
      color: Colors.grey[600],
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return super.appBarTheme(context).copyWith(
            appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 1,
        ));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(
            Icons.clear_rounded,
            color: Theme.of(context).textTheme.bodySmall!.color,
          ),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
        color: Theme.of(context).textTheme.bodySmall!.color,
      ),
      onPressed: () => close(context, MenuSearch()),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    searchHistory.add(query);
    void saveHistory() async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('searchHistory', searchHistory.history);
    }

    saveHistory();
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    MenuProducts products = query.isNotEmpty ? globalProducts : MenuProducts([]);

    ListView viewProducts() {
      List<Widget> menu = [];
      for (final product in products.products) {
        if (product.name.toLowerCase().contains(query.toLowerCase())) {
          menu.add(ProductView(product));
        }
      }
      return ListView(
        key: const PageStorageKey('Search'),
        padding: const EdgeInsets.symmetric(vertical: 5),
        children: menu,
      );
    }

    if (query.isNotEmpty) {
      return viewProducts();
    } else {
      return HistoryView(
        (value) => query = value,
        onSelected: (String value) {},
      );
    }
  }
}

class HistoryView extends StatefulWidget {
  const HistoryView(Function(dynamic value) param0, {Key? key, required this.onSelected}) : super(key: key);
  final ValueChanged<String> onSelected;

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  void saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('searchHistory', searchHistory.history);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: searchHistory.history.length,
      itemBuilder: (context, int i) {
        String text = searchHistory.history[i];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(text),
          trailing: IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: () {
              setState(() {
                searchHistory.delete(text);
                saveHistory();
              });
            },
          ),
          onTap: () {
            searchHistory.add(text);
            saveHistory();
            widget.onSelected(text);
          },
        );
      },
    );
  }
}
