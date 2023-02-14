import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'global.dart';
import 'classes.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signEmailPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (_) {}
    if (_auth.currentUser == null) return false;
    account.id = _auth.currentUser?.uid;
    account.email = _auth.currentUser?.email;
    return true;
  }

  Future<bool> registerEmailPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (_) {}
    if (_auth.currentUser == null) return false;
    account.id = _auth.currentUser?.uid;
    account.email = _auth.currentUser?.email;
    return true;
  }

  Future<bool> resetPassword(String email) async {
    _auth.sendPasswordResetEmail(email: email);
    return true;
  }

  void sign() {
    if (_auth.currentUser != null) {
      account.id = _auth.currentUser!.uid;
      account.email = _auth.currentUser!.email;
    }
  }

  Future signOut() async {
    await _auth.signOut();
  }

  bool checkSign() {
    return _auth.currentUser != null;
  }

  String? getId() {
    return _auth.currentUser?.uid;
  }
}

class CloudStore {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> getProducts() async {
    final CollectionReference products = firestore.collection('products');
    final result = await products.get();
    List<MenuProduct> menuProducts = [];
    for (var product in result.docs) {
      menuProducts.add(MenuProduct.withBase(product.id, product.data()));
    }
    globalProducts.products = menuProducts;
    return true;
  }

  Future<bool> getOrders() async {
    final CollectionReference orders = firestore.collection('orders');
    final result = await orders.where('user', isEqualTo: account.id.toString()).get();
    List<OrderProducts> orderProducts = [];
    for (var order in result.docs) {
      orderProducts.add(OrderProducts.withBase(order.id, order.data()));
    }
    orderProducts.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    globalOrders.orders = orderProducts;
    return true;
  }

  Future<bool> addOrder(OrderProducts order) async {
    final CollectionReference orders = firestore.collection('orders');
    orders.add(order.toMap(account.id!));
    return true;
  }

  Future<bool> getTables() async {
    final CollectionReference tables = firestore.collection('tables');
    final result = await tables.orderBy('number').get();
    List<RestaurantTable> restaurantTable = [];
    for (var table in result.docs) {
      restaurantTable.add(RestaurantTable.withBase(table.data()));
    }
    globalTables.tables = restaurantTable;
    return true;
  }

  Future<bool> getUserReservations() async {
    final CollectionReference reservations = firestore.collection('reservations');
    final result = await reservations.where('user', isEqualTo: account.id).get();
    List<Reservation> userReservation = [];
    for (var reservation in result.docs) {
      userReservation.add(Reservation.withBase(reservation.id, reservation.data()));
    }
    userReservations.reservations = userReservation;
    return true;
  }

  Future<Map<String, int>> getAllReservations() async {
    final CollectionReference reservations = firestore.collection('reservations');
    final result = await reservations.get();
    List<Reservation> allReservation = [];
    for (var reservation in result.docs) {
      allReservation.add(Reservation.withBase(reservation.id, reservation.data()));
    }
    allReservations.reservations = allReservation;
    final settings = await firestore.collection('settings').doc('app').get();
    return {
      'countDays': settings['countDaysReservation'],
      'startTime': settings['startTime'],
      'endTime': settings['endTime'],
    };
  }

  Future<bool> addReservations(Map<String, dynamic> reservation) async {
    final CollectionReference reservations = firestore.collection('reservations');
    reservations.add(reservation);
    return true;
  }

  Future<bool> removeReservation(String id) async {
    final CollectionReference reservations = firestore.collection('reservations');
    reservations.doc(id).delete();
    return true;
  }

  Future<String> getRestaurantLayout() async {
    final settings = await firestore.collection('settings').doc('app').get();
    return settings['restaurantLayout'];
  }
}
