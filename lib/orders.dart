import 'package:flutter/material.dart';
import 'classes.dart';
import 'global.dart';
import 'firebase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'state_update.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заказы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_outlined),
            onPressed: () {
              setState(() {
                appSettings['ordersSort'] == 'up' ? appSettings['ordersSort'] = 'down' : appSettings['ordersSort'] = 'up';
              });

              void saveSort() async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('ordersSort', appSettings['ordersSort']!);
              }

              saveSort();
            },
          ),
        ],
        centerTitle: true,
        elevation: 0,
      ),
      body: account.id != null
          ? RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
                setState(() {});
              },
              child: OrdersView(),
            )
          : const NotAccount(),
    );
  }
}

class NotAccount extends StatelessWidget {
  const NotAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: () => context.read<ChangeNavigation>().change(2),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline_rounded, size: 150),
              Text(
                'Войдите в аккаунт',
                style: TextStyle(fontSize: 20, fontFamily: 'BalsamiqSans'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderView extends StatelessWidget {
  const OrderView({super.key, required this.order});
  final OrderProducts order;

  String dateTime(DateTime dateTime) {
    final DateTime timeNow = DateTime.now();
    final Duration difference = timeNow.difference(dateTime);
    if (difference.inMinutes < 1) {
      return '${difference.inSeconds} сек. назад';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} мин. назад';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inDays < 2) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} д. назад';
    } else {
      return DateFormat('dd.MM.yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 0, right: 12, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Состав заказа:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'BalsamiqSans',
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd.MM.yyyy hh:mm').format(order.dateTime),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'BalsamiqSans',
                  ),
                ),
              ],
            ),
            Text(
              order.toString(),
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'BalsamiqSans',
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.stringPrice()} ₽',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(
                  order.status,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'BalsamiqSans'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersView extends StatelessWidget {
  OrdersView({super.key});

  final CloudStore _cloudStore = CloudStore();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _cloudStore.getOrders(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData && globalOrders.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Ошибка'));
        } else {
          return ListView.builder(
            key: const PageStorageKey('Orders'),
            padding: const EdgeInsets.symmetric(vertical: 5),
            itemCount: globalOrders.orders.length,
            itemBuilder: (context, int i) {
              if (appSettings['ordersSort'] == 'up') return OrderView(order: globalOrders.orders[i]);
              return OrderView(order: globalOrders.orders.reversed.elementAt(i));
            },
          );
        }
      },
    );
  }
}
