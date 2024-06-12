import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase.dart';
import 'global.dart';
import 'classes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:backdrop/backdrop.dart';
import 'state_update.dart';
import 'table.dart';
import 'package:intl/intl.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final CloudStore _cloudStore = CloudStore();

  @override
  Widget build(BuildContext context) {
    return BackdropScaffold(
      frontLayerBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      frontLayerScrim: Theme.of(context).cardColor.withOpacity(0.9),
      backLayerBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: BackdropAppBar(
        title: const Text('Бронирование столика'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          BackdropToggleButton(
            color: Theme.of(context).iconTheme.color!,
          ),
        ],
      ),
      frontLayer: RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {});
        },
        child: TablesView(),
      ),
      backLayer: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: const Text(
              'Схема ресторана',
              style: TextStyle(fontSize: 24, fontFamily: 'BalsamiqSans'),
            ),
          ),
          FutureBuilder(
              future: _cloudStore.getRestaurantLayout(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Ошибка'));
                } else {
                  return CachedNetworkImage(imageUrl: snapshot.data);
                }
              }),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: const Text(
              'Ваши бронирования',
              style: TextStyle(fontSize: 24, fontFamily: 'BalsamiqSans'),
            ),
          ),
          ReservationsView(),
        ],
      ),
    );
  }
}

class TableView extends StatelessWidget {
  const TableView({super.key, required this.table});

  final RestaurantTable table;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => TablePage(table: table)));
      },
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
                height: 120,
                margin: const EdgeInsets.fromLTRB(2, 2, 10, 2),
                child: ClipRRect(borderRadius: BorderRadius.circular(15), child: CachedNetworkImage(imageUrl: table.imageUrl)),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Стол № ${table.number}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'BalsamiqSans',
                      ),
                    ),
                    Text(
                      table.description,
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
        ),
      ),
    );
  }
}

class TablesView extends StatelessWidget {
  TablesView({super.key});

  final CloudStore _cloudStore = CloudStore();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _cloudStore.getTables(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData && globalTables.tables.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Ошибка'));
        } else {
          return ListView.builder(
            key: const PageStorageKey('Reservations'),
            padding: const EdgeInsets.symmetric(vertical: 5),
            itemCount: globalTables.tables.length,
            itemBuilder: (context, int i) {
              return TableView(table: globalTables.tables[i]);
            },
          );
        }
      },
    );
  }
}

class ReservationView extends StatelessWidget {
  const ReservationView({super.key, required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final RestaurantTable table = globalTables.getByNumber(reservation.tableNumber);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.fromLTRB(2, 2, 10, 2),
              child: ClipRRect(borderRadius: BorderRadius.circular(15), child: CachedNetworkImage(imageUrl: table.imageUrl)),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Стол № ${table.number}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'BalsamiqSans',
                    ),
                  ),
                  Text(
                    table.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'BalsamiqSans',
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
                  ),
                  Text(
                    '${DateFormat('dd.MM.yyyy').format(reservation.from)} ${DateFormat.Hm().format(reservation.from)} - ${DateFormat.Hm().format(reservation.to)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'BalsamiqSans',
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      showDialog<String>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Отмена бронирования'),
                          content: const Text('Уверены, что хотите отменить бронирование столика?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Нет'),
                            ),
                            TextButton(
                              onPressed: () {
                                final CloudStore cloudStore = CloudStore();
                                cloudStore.removeReservation(reservation.id);
                                Navigator.pop(context);
                                context.read<ChangeReservations>().change();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Бронирование отменено'),
                                  ),
                                );
                              },
                              child: const Text('Да'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'Отменить',
                      style: TextStyle(fontFamily: 'BalsamiqSans'),
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

class ReservationsView extends StatelessWidget {
  ReservationsView({super.key});

  final CloudStore _cloudStore = CloudStore();

  @override
  Widget build(BuildContext context) {
    context.watch<ChangeReservations>().get;

    return FutureBuilder(
      future: _cloudStore.getUserReservations(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData && userReservations.reservations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Ошибка'));
        } else {
          return Column(
            key: const PageStorageKey('UserReservations'),
            children: userReservations.reservations.map((reservation) => ReservationView(reservation: reservation)).toList(),
          );
        }
      },
    );
  }
}
