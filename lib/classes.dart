class MenuProduct {
  String id;
  String name = '';
  String category = '';
  double price = 0;
  String imageUrl = '';
  String description = '';

  MenuProduct({
    this.id = '',
    this.name = '',
    this.category = '',
    this.price = 0,
    this.imageUrl = '',
    this.description = '',
  });

  MenuProduct.withBase(this.id, product) {
    name = product['name'];
    category = product['category'];
    price = double.parse(product['price'].toString());
    imageUrl = product['image'];
    description = product['description'];
  }

  BasketProduct toBasketProduct() {
    return BasketProduct(
      id: id,
    );
  }

  String stringPrice() {
    return price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 1);
  }
}

class MenuProducts {
  List<MenuProduct> products = [];

  MenuProducts(this.products);

  List<MenuProduct> byCategory(String category) {
    List<MenuProduct> products = [];
    for (final product in this.products) {
      if (product.category == category) products.add(product);
    }
    return products;
  }

  MenuProduct byId(String id) {
    return products.where((product) => product.id == id).single;
  }

  Set<String> categories() {
    Set<String> categories = {};
    for (final product in products) {
      categories.add(product.category);
    }
    return categories;
  }

  void add(MenuProduct product) {
    products.add(product);
  }

  void clear() {
    products.clear();
  }
}

class BasketProduct {
  String id;
  int count;

  BasketProduct({this.id = '', this.count = 1});

  MenuProduct toMenuProduct(MenuProducts products) {
    return products.byId(id);
  }
}

class BasketProducts {
  List<BasketProduct> products = [];

  BasketProducts(this.products);

  void add(BasketProduct product) {
    bool add = true;
    for (final element in products) {
      if (element.id == product.id) {
        element.count++;
        add = false;
        break;
      }
    }
    if (add) products.add(product);
  }

  void remove(BasketProduct product) {
    for (int i = 0; i < products.length; i++) {
      if (product.id == products[i].id) {
        products[i].count--;
        if (products[i].count <= 0) products.removeAt(i);
        break;
      }
    }
  }

  void delete(BasketProduct product) {
    for (int i = 0; i < products.length; i++) {
      if (product.id == products[i].id) {
        products.removeAt(i);
        break;
      }
    }
  }

  void clear() {
    products.clear();
  }

  int count() {
    int count = 0;
    for (final product in products) {
      count += product.count;
    }
    return count;
  }

  double price(MenuProducts menuProducts) {
    double price = 0;
    for (final product in products) {
      price += product.toMenuProduct(menuProducts).price * product.count;
    }
    return price;
  }

  String stringPrice(MenuProducts menuProducts) {
    final double value = price(menuProducts);
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
  }

  List<Map<String, dynamic>> toMap() {
    List<Map<String, dynamic>> products = [];
    for (final product in this.products) {
      products.add({'id': product.id, 'count': product.count});
    }
    return products;
  }

  List<BasketProduct> fromMap(List products) {
    List<BasketProduct> basketProducts = [];
    for (final product in products) {
      basketProducts.add(BasketProduct(id: product['id'], count: product['count']));
    }
    return basketProducts;
  }
}

class Account {
  String? id;
  String? email;

  void clear() {
    id = null;
    email = null;
  }
}

class SearchHistory {
  List<String> history = [];

  SearchHistory(this.history);

  void clear() {
    history.clear();
  }

  void add(String value) {
    if (value.isEmpty) return;
    for (int i = 0; i < history.length; i++) {
      if (history[i] == value) {
        history.removeAt(i);
        history.insert(0, value);
        return;
      }
    }
    history.insert(0, value);
    if (history.length > 10) {
      history.removeAt(history.length - 1);
    }
  }

  void delete(String value) {
    for (int i = 0; i < history.length; i++) {
      if (history[i] == value) {
        history.removeAt(i);
      }
    }
  }
}

class OrderProduct {
  String name;
  double price;
  int count;

  OrderProduct({this.name = '', this.price = 0, this.count = 1});

  String stringPrice() {
    double price = this.price * count;
    return price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 1);
  }
}

class OrderProducts {
  String id = '';
  List<OrderProduct> products = [];
  DateTime dateTime = DateTime.now();
  String status = '';

  OrderProducts(this.id, this.products, this.dateTime, this.status);

  OrderProducts.withBase(this.id, order) {
    List<OrderProduct> products = [];
    dateTime = DateTime.fromMillisecondsSinceEpoch(order['dateTime'].seconds * 1000);
    status = order['status'];
    order['products'].forEach((product) {
      products.add(OrderProduct(
        name: product['name'],
        price: double.parse(product['price'].toString()),
        count: int.parse(product['count'].toString()),
      ));
    });
    this.products = products;
  }

  OrderProducts.fromBasket(BasketProducts basketProducts, MenuProducts menuProducts) {
    List<OrderProduct> order = [];
    MenuProduct product;
    for (final basketProduct in basketProducts.products) {
      product = basketProduct.toMenuProduct(menuProducts);
      order.add(OrderProduct(
        name: product.name,
        price: product.price,
        count: basketProduct.count,
      ));
    }
    products = order;
    dateTime = DateTime.now();
    status = 'Выполняется';
  }

  double price() {
    double price = 0;
    for (final product in products) {
      price += product.price * product.count;
    }
    return price;
  }

  String stringPrice() {
    double price = 0;
    for (final product in products) {
      price += product.price * product.count;
    }
    return price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 1);
  }

  @override
  String toString() {
    String order = '';
    for (int i = 0; i < products.length; i++) {
      if (i != 0) order += '\n';
      order += products[i].name;
      if (products[i].count > 1) order += ' x ${products[i].count} шт.';
      order += ' = ${products[i].stringPrice()} руб.';
    }
    return order;
  }

  Map<String, dynamic> toMap(String accountId) {
    List<Map<String, dynamic>> products = [];
    for (var product in this.products) {
      products.add({
        'name': product.name,
        'price': product.price,
        'count': product.count,
      });
    }

    return {
      'user': accountId,
      'dateTime': dateTime,
      'status': status,
      'products': products,
    };
  }
}

class Orders {
  List<OrderProducts> orders;

  Orders(this.orders);

  void add(OrderProducts order) {
    orders.insert(0, order);
  }

  void clear() {
    orders.clear();
  }
}

class RestaurantTable {
  int number = 1;
  String imageUrl = '';
  String description = '';

  RestaurantTable({this.number = 1, this.imageUrl = '', this.description = ''});

  RestaurantTable.withBase(table) {
    number = int.parse(table['number'].toString());
    imageUrl = table['image'];
    description = table['description'];
  }

  Map<String, dynamic> createReservation(String accountId, DateTime from, DateTime to) {
    final reservation = {
      'user': accountId,
      'tableNumber': number,
      'from': from,
      'to': to,
    };
    return reservation;
  }

  List<DateTime> dates(int count) {
    List<DateTime> dates = [];
    DateTime date = DateTime.now();
    for (int i = 0; i < count; i++) {
      dates.add(date.add(Duration(days: i)));
    }
    return dates;
  }

  List<DateTime> times(DateTime date, int startTime, int endTime) {
    List<DateTime> times = [];
    DateTime time = date.subtract(Duration(hours: date.hour - startTime, minutes: date.minute, seconds: date.second));
    while (time.hour < endTime || time.minute == 0) {
      times.add(time);
      time = time.add(const Duration(minutes: 30));
    }
    return times;
  }
}

class RestaurantTables {
  List<RestaurantTable> tables;

  RestaurantTables(this.tables);

  RestaurantTable getByNumber(int number) {
    return tables.where((table) => table.number == number).single;
  }
}

class Reservations {
  List<Reservation> reservations = [];

  List<Reservation> date(DateTime date, {int? numberTable}) {
    List<Reservation> reservations = [];
    for (final reservation in this.reservations) {
      if (reservation.from.day == date.day &&
          reservation.from.month == date.month &&
          (numberTable == null || reservation.tableNumber == numberTable)) {
        reservations.add(reservation);
      }
    }
    return reservations;
  }

  int isBooked(DateTime dateTime, int numberTable) {
    int status = 0;
    List<Reservation> reservations = date(dateTime, numberTable: numberTable);
    for (final reservation in reservations) {
      if (dateTime.hour * 60 + dateTime.minute > reservation.from.hour * 60 + reservation.from.minute &&
          dateTime.hour * 60 + dateTime.minute < reservation.to.hour * 60 + reservation.to.minute) {
        return 1; // Занят - середина
      } else if (dateTime.hour * 60 + dateTime.minute == reservation.from.hour * 60 + reservation.from.minute ||
          dateTime.hour * 60 + dateTime.minute == reservation.to.hour * 60 + reservation.to.minute) {
        if (reservation.from.hour * 60 + reservation.from.minute + 30 != reservation.to.hour * 60 + reservation.to.minute) {
          status = 2; // Занят - граница
        } else {
          return 3; // Занят - границы рядом
        }
      }
    }
    return status; // Свободен
  }

  List<Reservation> table(int number) {
    List<Reservation> reservations = [];
    for (final reservation in this.reservations) {
      if (reservation.tableNumber == number) {
        reservations.add(reservation);
      }
    }
    return reservations;
  }
}

class Reservation {
  String id;
  String user = '';
  int tableNumber = 0;
  DateTime from = DateTime.now();
  DateTime to = DateTime.now();

  Reservation.withBase(this.id, reservation) {
    user = reservation['user'];
    tableNumber = reservation['tableNumber'];
    from = DateTime.fromMillisecondsSinceEpoch(reservation['from'].seconds * 1000);
    to = DateTime.fromMillisecondsSinceEpoch(reservation['to'].seconds * 1000);
  }
}
