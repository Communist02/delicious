import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'classes.dart';
import 'global.dart';
import 'package:intl/intl.dart';
import 'firebase.dart';
import 'state_update.dart';
import 'package:provider/provider.dart';

int _indexDay = 0;

class TablePage extends StatefulWidget {
  const TablePage({Key? key, required this.table}) : super(key: key);
  final RestaurantTable table;

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  int _index = 0;

  _TablePageState() {
    for (int i = 0; i < globalTables.tables.length; i++) {
      if (globalTables.tables[i].number == widget.table.number) {
        _index = i;
        break;
      }
    }
  }

  List<Widget> viewTables() {
    List<Widget> tabs = [];
    for (final table in globalTables.tables) {
      tabs.add(TableView(table: table));
    }
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: _index,
      length: globalTables.tables.length,
      child: Builder(
        builder: (context) {
          return Scaffold(
            floatingActionButton: Container(
              margin: const EdgeInsets.only(top: 10),
              child: FloatingActionButton(
                mini: true,
                onPressed: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_rounded),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
            body: SafeArea(child: TabBarView(children: viewTables())),
          );
        },
      ),
    );
  }
}

class TableView extends StatefulWidget {
  const TableView({Key? key, required this.table}) : super(key: key);
  final RestaurantTable table;

  @override
  State<TableView> createState() => _TableViewState();
}

class _TableViewState extends State<TableView> {
  final CloudStore _cloudStore = CloudStore();

  final _colorFree = Colors.transparent;
  final _colorBooked = Colors.red;
  final _colorBound = Colors.blue;
  final _colorNear = Colors.green;

  int? _indexTime1;
  int? _indexTime2;
  int _countDay = 0;
  int _startTime = 0;
  int _endTime = 0;

  @override
  Widget build(BuildContext context) {
    final RestaurantTable table = widget.table;

    return Scaffold(
      body: ListView(
        key: const PageStorageKey('Tables'),
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(imageUrl: table.imageUrl),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Стол № ${table.number}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                fontFamily: 'BalsamiqSans',
              ),
            ),
          ),
          Text(
            table.description,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'BalsamiqSans',
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
          ),
          FutureBuilder(
              future: _cloudStore.getAllReservations(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Ошибка'));
                } else {
                  _countDay = snapshot.data['countDays'];
                  _startTime = snapshot.data['startTime'];
                  _endTime = snapshot.data['endTime'];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Дата: ${DateFormat('dd.MM.yyyy').format(table.dates(_countDay)[_indexDay])}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'BalsamiqSans',
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        key: const PageStorageKey('Days'),
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 2,
                          children: List.generate(_countDay, (index) => index)
                              .map(
                                (int index) => OutlinedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    backgroundColor: index == _indexDay
                                        ? MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.secondary)
                                        : MaterialStateProperty.all<Color>(Colors.transparent),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _indexTime1 = null;
                                      _indexTime2 = null;
                                      _indexDay = index;
                                    });
                                  },
                                  child: Text(
                                    DateFormat('dd.MM').format(table.dates(_countDay)[index]),
                                    style: TextStyle(
                                      color: index == _indexDay
                                          ? Theme.of(context).tabBarTheme.labelColor
                                          : Theme.of(context).tabBarTheme.unselectedLabelColor,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          _indexTime1 == _indexTime2
                              ? 'Временной диапазон не задан'
                              : 'Время: ${DateFormat.Hm().format(table.times(table.dates(_countDay)[_indexDay], _startTime, _endTime)[_indexTime1!])} - ${DateFormat.Hm().format(table.times(table.dates(_countDay)[_indexDay], _startTime, _endTime)[_indexTime2!])}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'BalsamiqSans',
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 20,
                        runSpacing: 5,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.radio_button_off),
                              Text(
                                ' Свободно',
                                style: TextStyle(fontFamily: 'BalsamiqSans'),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.radio_button_on, color: _colorBooked),
                              const Text(
                                ' Занято',
                                style: TextStyle(fontFamily: 'BalsamiqSans'),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.radio_button_on, color: _colorBound),
                              const Text(
                                ' Границы',
                                style: TextStyle(fontFamily: 'BalsamiqSans'),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.radio_button_on, color: _colorNear),
                              const Text(
                                ' Границы рядом',
                                style: TextStyle(fontFamily: 'BalsamiqSans'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 2,
                        alignment: WrapAlignment.spaceBetween,
                        children: List.generate(
                                table.times(table.dates(_countDay)[_indexDay], _startTime, _endTime).length, (index) => index)
                            .map((int index) {
                          final status = allReservations.isBooked(
                              table.times(table.dates(_countDay)[_indexDay], _startTime, _endTime)[index], table.number);
                          return OutlinedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              backgroundColor: _indexTime1 != null && index >= _indexTime1! && index <= _indexTime2!
                                  ? MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.secondary)
                                  : MaterialStateProperty.all<Color>(status == 0
                                      ? _colorFree
                                      : status == 1
                                          ? _colorBooked
                                          : status == 2
                                              ? _colorBound
                                              : _colorNear),
                            ),
                            onPressed: status == 1
                                ? null
                                : () {
                                    bool validationRange(int from, int to) {
                                      for (int i = from + 1; i < to; i++) {
                                        if (allReservations.isBooked(
                                                table.times(table.dates(_countDay)[_indexDay], _startTime, _endTime)[i],
                                                table.number) !=
                                            0) return false;
                                      }
                                      return true;
                                    }

                                    setState(() {
                                      if (_indexTime1 == null) {
                                        _indexTime1 = index;
                                        _indexTime2 = index;
                                      } else if (index < _indexTime1!) {
                                        _indexTime1 = index;
                                      } else if (index > _indexTime2!) {
                                        _indexTime2 = index;
                                      } else {
                                        _indexTime1 = index;
                                        _indexTime2 = index;
                                      }
                                      if (_indexTime1 != _indexTime2 &&
                                              allReservations.isBooked(
                                                      table.times(table.dates(_countDay)[_indexDay], _startTime,
                                                          _endTime)[_indexTime1!],
                                                      table.number) ==
                                                  3 &&
                                              allReservations.isBooked(
                                                      table.times(table.dates(_countDay)[_indexDay], _startTime,
                                                          _endTime)[_indexTime2!],
                                                      table.number) ==
                                                  3 ||
                                          !validationRange(_indexTime1!, _indexTime2!)) {
                                        _indexTime1 = null;
                                        _indexTime2 = null;
                                      }
                                    });
                                  },
                            child: Text(
                              DateFormat.Hm()
                                  .format(table.times(table.dates(_countDay)[_indexDay], _startTime, _endTime)[index]),
                              style: TextStyle(
                                color: _indexTime1 != null && index >= _indexTime1! && index <= _indexTime2!
                                    ? Theme.of(context).tabBarTheme.labelColor
                                    : Theme.of(context).tabBarTheme.unselectedLabelColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }
              }),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(19),
              ),
            ),
          ),
          onPressed: account.id == null
              ? () {
                  Navigator.pop(context);
                  context.read<ChangeNavigation>().change(2);
                }
              : _indexTime1 == _indexTime2
                  ? null
                  : () async {
                      final CloudStore cloudStore = CloudStore();
                      final reservation = table.createReservation(
                        account.id!,
                        table.times(table.dates(_countDay)[_indexDay], _startTime, _endTime)[_indexTime1!],
                        table.times(table.dates(_countDay)[_indexDay], _startTime, _endTime)[_indexTime2!],
                      );
                      //allReservations.reservations.add(reservation);
                      await cloudStore.addReservations(reservation);
                      setState(() {
                        _indexTime1 = null;
                        _indexTime2 = null;
                        context.read<ChangeReservations>().change();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Бронирование'),
                          duration: Duration(seconds: 1),
                        ));
                      });
                    },
          child: Text(
            account.id != null ? 'ЗАБРОНИРОВАТЬ' : 'ВОЙДИТЕ В АККАУНТ',
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }
}
