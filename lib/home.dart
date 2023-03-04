import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'basket.dart';
import 'menu.dart';
import 'orders.dart';
import 'profile.dart';
import 'reservation.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import 'state_update.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _page = [
    const MenuPage(),
    const ReservationPage(),
    const ProfilePage(),
    const OrdersPage(),
    const BasketPage(),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    return Scaffold(
      body: _page[context.watch<ChangeNavigation>().getIndex],
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: context.watch<ChangeNavigation>().getIndex,
        iconSize: 30,
        onItemSelected: (int index) {
          setState(() => context.read<ChangeNavigation>().change(index));
        },
        items: [
          BottomNavyBarItem(
            icon: const Icon(Icons.restaurant_outlined),
            activeColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor!,
            inactiveColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor!,
            title: const Text('Меню', overflow: TextOverflow.ellipsis),
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.access_time_outlined),
            activeColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor!,
            inactiveColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor!,
            title: const Text('Бронирование столика', overflow: TextOverflow.ellipsis),
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            activeColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor!,
            inactiveColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor!,
            title: const Text('Профиль', overflow: TextOverflow.ellipsis),
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.receipt_outlined),
            activeColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor!,
            inactiveColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor!,
            title: const Text('Заказы', overflow: TextOverflow.ellipsis),
          ),
          BottomNavyBarItem(
            icon: badges.Badge(
              badgeAnimation: const badges.BadgeAnimation.scale(animationDuration: Duration(milliseconds: 200)),
              badgeStyle: badges.BadgeStyle(
                shape: badges.BadgeShape.square,
                badgeColor: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(11),
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              ),
              badgeContent: Text(
                context.watch<ChangeBasket>().getCount.toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'BalsamiqSans',
                  color: Theme.of(context).tabBarTheme.labelColor,
                ),
              ),
              showBadge: context.watch<ChangeBasket>().getCount != 0 && context.watch<ChangeNavigation>().getIndex != 4,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor!,
            inactiveColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor!,
            title: const Text('Корзина', overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
