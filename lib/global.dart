import 'classes.dart';

MenuProducts globalProducts = MenuProducts([]);
BasketProducts globalBasket = BasketProducts([]);
Map<String, String> appSettings = {'theme': 'system', 'ordersSort': 'up'};
SearchHistory searchHistory = SearchHistory([]);
Orders globalOrders = Orders([]);
Account account = Account();
RestaurantTables globalTables = RestaurantTables([]);
Reservations allReservations = Reservations();
Reservations userReservations = Reservations();