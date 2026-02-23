import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/models/order_details_model.dart';
import 'package:neeknots/models/order_model.dart';
import 'package:neeknots/service/gloable_status_code.dart';
import 'package:neeknots/service/network_repository.dart';

import '../core/firebase/auth_service.dart';
import '../models/order_details_model.dart' as order show OrderDetailsModel;
import '../service/api_config.dart';

class OrdersProvider with ChangeNotifier {
  Color getPaymentStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.amber;
      case "Failed":
        return Colors.red;
      case "Paid":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _selectedStatus = "All";

  String get selectedStatus => _selectedStatus;

  /// 🏷️ Filter by status (Pending, Shipped, Delivered, or All)

  /*  void filterByStatus(String status) {
    String apiStatus = status.toLowerCase().replaceAll(' ', '_');
    if (status == "all") {
      getOrderList(financialStatus: null);
    } else {
      getOrderList(financialStatus: apiStatus);
    }

    _selectedStatus = status;
    notifyListeners();
    //_applyFilters();
  }*/

  bool _isFetching = false;

  bool get isFetching => _isFetching;

  String _searchQuery = "";

  String get searchQuery => _searchQuery;

  //for filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  final int _limit = 100; // items per page

  // Store totals
  int totalPaid = 0;
  int totalPending = 0;
  int totalRefunded = 0;
  int totalShipping = 0;
  int totalCancel = 0;
  String selectedTab = "Paid";
  List<Order> filterTotalOrderList = [];

  void setSelectedTab(String tab) {
    selectedTab = tab;
    notifyListeners();
  }

  void resetData1() {
    orderStatusCounts.updateAll((key, value) => 0);
    _ordersByStatus.clear();
    notifyListeners();
  }

  void resetData() {
    filterOrderList.clear();
    _searchQuery = "";

    totalPaid = totalPending = totalRefunded = totalShipping = totalCancel = 0;
    notifyListeners();
  }

  final Map<String, List<Order>> _ordersByStatus = {};

  Map<String, List<Order>> get ordersByStatus => _ordersByStatus;

  // selected tab orders
  /*List<Order> get selectedOrders =>
      _ordersByStatus[selectedTab.toLowerCase()] ?? [];*/
  int todaysOrderCount = 0;
  int openOrderCount = 0;
  var closedOrderCount = 0;
  int pendingToChargeCount = 0;
  int pendingShipmentCount = 0;
  int shippedCount = 0;
  int awaitingReturnCount = 0;
  int completedCount = 0;

  Future<void> orderCountStatusValue1({
    int? limit,
    String? financialStatus,
  }) async {
    _isFetching = true;
    notifyListeners();
    final effectiveLimit = limit ?? _limit;

    try {
      String url =
          '${await ApiConfig.ordersUrl}?status=any&limit=$effectiveLimit&order=id+asc';
      if (financialStatus != null && financialStatus.isNotEmpty) {
        final encodedTitle = "&financial_status=$financialStatus";
        url += encodedTitle;
      }

      final response = await callGETMethod(url: url);
      if (globalStatusCode == 200) {
        final data = json.decode(response); // ✅ now .body works

        final fetchedOrders = OrderModel.fromJson(data).orders ?? [];

        final todayStart = DateTime.now().toUtc().subtract(
          Duration(
            hours: DateTime.now().hour,
            minutes: DateTime.now().minute,
            seconds: DateTime.now().second,
          ),
        );
        final todayEnd = todayStart.add(const Duration(days: 1));

        for (var order in fetchedOrders) {
          final status = order.financialStatus?.toLowerCase() ?? 'unknown';
          final createdAt = DateTime.parse(
            order.createdAt ?? DateTime.now().toString(),
          );

          // Total counts by financial status
          if (status == 'paid') totalPaid++;
          if (status == 'pending') totalPending++;
          if (status == 'refunded') totalRefunded++;
          if (status == 'shipping') totalShipping++;
          if (status == 'cancelled') totalCancel++;

          // Custom status counts
          if (createdAt.isAfter(todayStart) && createdAt.isBefore(todayEnd)) {
            todaysOrderCount++;
          }
          if (status == 'pending') pendingToChargeCount++; // example mapping
          if (status == 'shipping') pendingShipmentCount++;
          if (status == 'shipped') shippedCount++;
          if (status == 'completed') completedCount++;
          // Map awaiting return depending on your data, example:
          if (status == 'awaiting_return') awaitingReturnCount++;
          // Closed Orders example: maybe cancelled + refunded
          if (status == 'cancelled' || status == 'refunded') closedOrderCount++;
          // Open Orders: all others that are not closed
          if (!(status == 'cancelled' ||
              status == 'refunded' ||
              status == 'completed')) {
            openOrderCount++;
          }
        }

        totalPaid = fetchedOrders
            .where((e) => e.financialStatus?.toLowerCase() == 'paid')
            .length;
        totalPending = fetchedOrders
            .where((e) => e.financialStatus?.toLowerCase() == 'pending')
            .length;
        totalRefunded = fetchedOrders
            .where((e) => e.financialStatus?.toLowerCase() == 'refunded')
            .length;
        totalShipping = fetchedOrders
            .where((e) => e.financialStatus?.toLowerCase() == 'shipping')
            .length;
        totalCancel = fetchedOrders
            .where((e) => e.financialStatus?.toLowerCase() == 'cancelled')
            .length;
        _ordersByStatus.clear(); // ✅ naya fetch hote hi purana clear karo
        for (var order in fetchedOrders) {
          final status = order.financialStatus?.toLowerCase() ?? 'unknown';
          _ordersByStatus.putIfAbsent(status, () => []);
          _ordersByStatus[status]!.add(order);
        }

        _isFetching = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  Map<String, int> orderStatusCounts = {
    "Today’s Order": 0,
    "Open Order": 0,
    "Closed Orders": 0,
    "Pending To Charge": 0,
    "Pending Shipment": 0,
    "Shipped": 0,
    "Awaiting Return": 0,
    "Completed": 0,
  };

  Future<void> orderCountStatusValue() async {
    _isFetching = true;
    notifyListeners();

    try {
      String url =
          '${await ApiConfig.ordersUrl}?status=any&limit=$_limit&order=id+asc';
      final response = await callGETMethod(url: url);

      if (response != null) {
        final data = json.decode(response);
        final fetchedOrders = OrderModel.fromJson(data).orders ?? [];

        // Initialize counts dynamically from filter list
        Map<String, int> tempCounts = {
          for (var filter in allOrderFilterList) filter['title']!: 0,
        };
        _ordersByStatus.clear();

        final todayStart = DateTime.now().subtract(
          Duration(
            hours: DateTime.now().hour,
            minutes: DateTime.now().minute,
            seconds: DateTime.now().second,
          ),
        );
        final todayEnd = todayStart.add(const Duration(days: 1));

        for (var order in fetchedOrders) {
          final status = order.financialStatus?.toLowerCase() ?? 'unknown';
          final createdAt = DateTime.parse(
            order.createdAt ?? DateTime.now().toString(),
          );

          for (var filter in allOrderFilterList) {
            final title = filter['title']!;

            bool match = false;
            switch (title) {
              case "Today’s Order":
                match =
                    createdAt.isAfter(todayStart) &&
                    createdAt.isBefore(todayEnd);
                break;
              case "Open Order":
                match =
                    !(status == 'cancelled' ||
                        status == 'refunded' ||
                        status == 'completed');
                break;
              case "Closed Orders":
                match = status == 'cancelled' || status == 'refunded';
                break;
              case "Pending To Charge":
                match = status == 'pending' || status == 'paid';
                break;
              case "Pending Shipment":
                match = status == 'shipping';
                break;
              case "Shipped":
                match = status == 'shipped';
                break;
              case "Awaiting Return":
                match = status == 'awaiting_return';
                break;
              case "Completed":
                match = status == 'completed';
                break;
              default:
                match = status == title.toLowerCase();
            }

            if (match) {
              tempCounts[title] = tempCounts[title]! + 1;
              _ordersByStatus.putIfAbsent(title.toLowerCase(), () => []);
              _ordersByStatus[title.toLowerCase()]!.add(order);
            }
          }
        }

        orderStatusCounts = tempCounts;

        // Logs
        // debugPrint("===== ORDER COUNTS =====");
        orderStatusCounts.forEach((key, value) {
          // debugPrint("$key : $value");
        });

        _isFetching = false;
        notifyListeners();
      }
    } catch (e) {
      _isFetching = false;
      notifyListeners();
      debugPrint("Error calculating order counts: $e");
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  List<Order> get selectedOrders {
    if (selectedTab.isEmpty || _ordersByStatus.isEmpty) return [];
    return _ordersByStatus[selectedTab.toLowerCase()] ?? [];
  }

  int _totalOrderCount = 0;

  int get totalOrderCount => _totalOrderCount;

  /* Future<void> getTotalOrderCount({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isFetching = true;
    notifyListeners();

    final response =  callGETMethod(
      url: '${ApiConfig.totalOrderUrl}?status=any',
    );

    if (globalStatusCode == 200) {
      final data = json.decode(await response);

      _totalOrderCount = data["count"] ?? 0;
      _isFetching = false;
      notifyListeners();
    }

    _isFetching = false;
    notifyListeners();
  }*/

  Future<void> getTotalOrderCount({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isFetching = true;
    notifyListeners();

    try {
      final url = "${await ApiConfig.totalOrderUrl}?status=any";

      final response = await callGETMethod(url: url);

      if (globalStatusCode == 200) {
        final data = json.decode(await response);
        _totalOrderCount = data["count"] ?? 0;
      }
    } catch (e) {
      _totalOrderCount = 0;
      _isFetching = false;
      notifyListeners();
    }
    _isFetching = false;
    notifyListeners();
  }

  int _totalOrderSaleCount = 0;

  int get totalOrderSaleCount => _totalOrderSaleCount;

  Future<void> getTotalSaleOrder({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isFetching = true;
    notifyListeners();

    try {
      final utcStart = startDate.toUtc();
      final utcEnd = endDate.toUtc();

      // Format as ISO 8601
      final createdAtMin = Uri.encodeComponent(utcStart.toIso8601String());
      final createdAtMax = Uri.encodeComponent(utcEnd.toIso8601String());
      final url =
          "${await ApiConfig.totalOrderUrl}?created_at_min=$createdAtMin&created_at_max=$createdAtMax&status=any";
      final response = await callGETMethod(url: url);

      if (globalStatusCode == 200) {
        final data = json.decode(response);

        _totalOrderSaleCount = data["count"] ?? 0;
        _isFetching = false;
        notifyListeners();
      }
    } catch (e) {
      _totalOrderSaleCount = 0;
      _isFetching = false;
      notifyListeners();
    }

    _isFetching = false;
    notifyListeners();
  }

  OrderDetailsModel? _orderDetailsModel;

  OrderDetailsModel? get orderDetailsModel => _orderDetailsModel;

  Future<void> clearOrderDetailsData() async {
    _orderDetailsModel?.orderData = null;
    notifyListeners();
  }

  Future<void> getOrderById({int? orderID}) async {
    _isFetching = true;
    notifyListeners();

    try {
      final url = '${await ApiConfig.getOrderById}/$orderID.json';

      final response = await callGETMethod(url: url);

      _orderDetailsModel = order.OrderDetailsModel.fromJson(
        json.decode(response),
      );

      final orderData = _orderDetailsModel?.orderData;
      if (orderData != null && orderData.lineItems != null) {
        fetchImagesForProduct(product: orderData);
      }

      _isFetching = false;
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      _orderDetailsModel = OrderDetailsModel(); // fallback empty list
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  //Girish 25-Sep
  final List<Order> _customerOrders = [];

  List<Order> get customerOrders => _customerOrders;

  List<Order> get filterCustomerOrderList {
    return _customerOrders.where((p) {
      final matchesSearch = p.name.toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      //return matchesSearch && matchesCategory && matchesStatus;
      return matchesSearch;
    }).toList();
  }

  Future<void> getOrdersByCustomerId({required String customerId}) async {
    _customerOrders.clear();
    _isFetching = true;
    notifyListeners();

    try {
      final url =
          '${await ApiConfig.getCustomerImage}/$customerId/orders.json?status=any';
      final response = await callGETMethod(url: url);
      if (globalStatusCode == 200) {
        final data = json.decode(response);
        final fetchedOrders = OrderModel.fromJson(data).orders ?? [];
        if (fetchedOrders.isNotEmpty) {
          _customerOrders.addAll(fetchedOrders);
        } else {
          _customerOrders.clear();
        }
      }
    } catch (e) {
      _isFetching = false;
      notifyListeners();
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<void> fetchImagesForProduct({required OrderData product}) async {
    if (product.lineItems == null) return;

    _isFetching = true;
    notifyListeners();

    await Future.wait(
      product.lineItems!.map((item) async {
        item.imageUrl = await fetchProductImage(
          productId: item.productId ?? 0,
          variantId: item.id ?? 0,
        );
      }),
    );

    _isFetching = false;
    notifyListeners();
  }

  OrderModel? _orderModelByDate;

  OrderModel? get orderModelByDate => _orderModelByDate;
  double _totalOrderPrice = 0.0;

  double get totalOrderPrice => _totalOrderPrice;

  Future<void> getOrderByDate({
    required DateTime startDate,
    required DateTime endDate,
    required bool isDashboard,
  }) async {
    _isFetching = true;
    _orderModelByDate = null;

    notifyListeners();
    try {
      final utcStart = startDate.toUtc();
      final utcEnd = endDate.toUtc();

      // Format as ISO 8601
      final createdAtMin = Uri.encodeComponent(utcStart.toIso8601String());
      final createdAtMax = Uri.encodeComponent(utcEnd.toIso8601String());
      final url =
          "${await ApiConfig.ordersUrl}?created_at_min=$createdAtMin&created_at_max=$createdAtMax&status=any";

      final response = await callGETMethod(url: url);

      if (globalStatusCode == 200) {
        _orderModelByDate = OrderModel.fromJson(json.decode(response));

        if (isDashboard) {
          _totalOrderPrice = getTotalOrderPrice(
            _orderModelByDate ?? OrderModel(),
          );
        }

        _isFetching = false;
        notifyListeners();
      }
    } catch (e) {
      _orderModelByDate?.orders?.clear();
      _isFetching = false;
      notifyListeners();
    }

    _isFetching = false;
    notifyListeners();
  }

  double getTotalOrderPrice(OrderModel orderModel) {
    double total = 0;

    if (orderModel.orders != null) {
      for (var order in orderModel.orders!) {
        // totalPrice String hai, so double me convert karo
        final price = double.tryParse(order.totalPrice ?? "0") ?? 0;
        total += price;
      }
    }

    return total;
  }

  //===============================================Graph
  String _selectedRange = "Today";

  String get selectedRange => _selectedRange;

  void setRange(String range) {
    _selectedRange = range;
    notifyListeners();
  }

  void fetchTodayOrders() {
    final today = DateTime.now();

    getOrderByDate(
      isDashboard: false,
      startDate: DateTime(today.year, today.month, today.day),
      endDate: DateTime(today.year, today.month, today.day, 23, 59, 59),
    );
  }

  void fetchByRange(String range) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    if (range == "This Week") {
      startDate = now.subtract(
        Duration(days: now.weekday - 1),
      ); // start of week
    } else if (range == "This Month") {
      startDate = DateTime(now.year, now.month, 1); // start of month
    } else {
      DateTime now = DateTime.now();

      // Aaj ka start (00:00:00)
      startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);

      // Aaj ka end (23:59:59)
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      //startDate = now; // default today
    }

    getOrderByDate(isDashboard: false, startDate: startDate, endDate: endDate);
  }

  Future<Map<String, dynamic>> getOrderPagination({
    String? pageInfo,
    String? financialStatus,
    String? status,
    String? limit,
    String? fulfillmentStatus,
    String? createdMinDate,
    String? createdMaxDate,
  }) async {
    try {
      _isFetching = true;
      notifyListeners();

      final queryParams = {
        'limit': limit?.toString() ?? '10',
        'status': 'any',

        if (pageInfo != null) 'page_info': pageInfo,
        if (financialStatus != null) 'financial_status': financialStatus,
        if (status != null) 'status': status,
        if (createdMinDate != null) 'created_at_min': createdMinDate,
        if (fulfillmentStatus != null) 'fulfillment_status': fulfillmentStatus,
        if (createdMaxDate != null) 'created_at_max': createdMaxDate,
      };

      final baseUrl = await ApiConfig.baseUrl;

      final uri = Uri.parse(
        "$baseUrl/orders.json",
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: await ApiConfig.getCommonHeaders(),
      );

      final data = json.decode(response.body);
      final ordersJson = data['orders'] as List? ?? [];

      final orders = ordersJson.map((e) => Order.fromJson(e)).toList();

      String? nextPageInfo;
      final linkHeader = response.headers['link'];

      if (linkHeader != null) {
        final parts = linkHeader.split(',');
        for (var part in parts) {
          if (part.contains('rel="next"')) {
            final match = RegExp(r'page_info=([^&>]+)').firstMatch(part);
            if (match != null) {
              nextPageInfo = match.group(1);
            }
          }
        }
      }

      return {"orders": orders, "nextPageInfo": nextPageInfo};
    } catch (e, stackTrace) {
      debugPrint("Order Pagination Error: $e");
      debugPrint("StackTrace: $stackTrace");

      rethrow; // agar upar handle karna ho
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  void filterByStatus({
    String? status,
    String? value,
    String? financialStatus,
    String? fulfillmentStatus,
    String? createdMinDate,
    String? createdMaxDate,
  }) {
    String apiStatus = status.toString().toLowerCase().replaceAll(' ', '_');
    if (status == "all") {
      getOrderList(
        loadMore: false,
        financialStatus: null,
        status: null,
        createdMaxDate: null,
        createdMinDate: null,
        fulfillmentStatus: null,
      );
    } else {
      getOrderList(
        loadMore: false,
        status: apiStatus,
        createdMinDate: createdMinDate,
        createdMaxDate: createdMaxDate,
        financialStatus: financialStatus,
        fulfillmentStatus: fulfillmentStatus,
      );
    }

    _selectedStatus = value ?? 'all';
    notifyListeners();
    //_applyFilters();
  }

  String? _nextPageInfo;

  bool get hasMore => _nextPageInfo != null;

  List<Order> get ordersList => _ordersList;
  List<Order> _ordersList = [];

  Future<void> getOrderList({
    bool loadMore = false,
    String? financialStatus,
    String? fulfillmentStatus,
    String? status,
    String? limit,
    String? createdMinDate,
    String? createdMaxDate,
  }) async {
    if (_isFetching) return;
    if (!loadMore) _ordersList.clear(); // clear only on initial load

    _isFetching = true;
    notifyListeners();

    try {
      final result = await getOrderPagination(
        financialStatus: financialStatus,
        limit: limit,
        status: status,
        fulfillmentStatus: fulfillmentStatus,
        createdMaxDate: createdMaxDate,
        createdMinDate: createdMinDate,
        pageInfo: loadMore ? _nextPageInfo : null,
      );

      if (loadMore) {
        _ordersList.addAll(result["orders"]);
      } else {
        _ordersList = result["orders"];
      }

      _nextPageInfo = result["nextPageInfo"];
    } catch (e) {
      debugPrint("Order List Error: $e");

      // 🔥 Error aaye to clear karo
      //      _ordersList.clear();

      notifyListeners();
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  List<Order> get filterOrderList {
    final filtered = _ordersList.where((p) {
      final matchesSearch = p.name.toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      return matchesSearch;
    }).toList();

    return filtered;
  }

  String getDeliveryStatus(OrderData order) {
    if (order.fulfillments != null && order.fulfillments!.isNotEmpty) {
      // Check if tracking exists
      final hasTracking = order.fulfillments!.any(
        (f) => f.trackingNumber != null && f.trackingNumber!.isNotEmpty,
      );
      if (hasTracking) return 'Tracking Added / Shipped';
    }

    switch (order.fulfillmentStatus) {
      case 'fulfilled':
        return 'Delivered';
      case 'partial':
        return 'Partially Delivered';
      case 'unfulfilled':
        return 'Pending';
      default:
        return '-';
    }
  }

  String getPaymentStatus(OrderData order) {
    // Agar financial_status available hai
    switch (order.financialStatus) {
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending Payment';
      case 'refunded':
        return 'Refunded';
      case 'partially_refunded':
        return 'Partially Refunded';
      case 'authorized':
        return 'Authorized';
      default:
        return 'N/A';
    }
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  List<Map<String, dynamic>> _allOrderFilterList = [];

  List<Map<String, dynamic>> get allOrderFilterList => _allOrderFilterList;

  final AuthService _authService = AuthService();

  Future<void> getAllFilterOrderList() async {
    _setLoading(true);
    try {
      final contactCollection = await _authService.getStoreSubCollection(
        _authService.orderFilterCollection,
      );

      final querySnapshot = await contactCollection.get();
      _allOrderFilterList = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data["uid"] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint("Error fetching filters: $e");
    }
    _setLoading(false);
  }

  Future<void> getAllFilterOrderList1() async {
    _setLoading(true);
    try {
      final contactCollection = await _authService.getStoreSubCollection(
        _authService.orderFilterCollection,
      );

      final snapshot = await contactCollection
          .where('status', isEqualTo: true) // ✅ fetch only active ones
          .get();

      _allOrderFilterList = snapshot.docs.map((doc) {
        return {"title": doc['title'] ?? '', "status": doc['status'] ?? ''};
      }).toList();

      // Initialize counts to 0
      orderStatusCounts = {for (var f in allOrderFilterList) f['title']!: 0};

      // ✅ Set default tab to 0th index after fetching list
      if (_allOrderFilterList.isNotEmpty) {
        selectedTab = _allOrderFilterList.first['title'];
        debugPrint("Default selected tab: $selectedTab");
      }
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      notifyListeners();
      debugPrint("Error fetching filter list: $e");
    }
  }

  /// Return only filters where status == true
  List<Map<String, dynamic>> get activeFilters =>
      _allOrderFilterList.where((f) => f["status"] == true).toList();
}

class SalesData {
  final String orderNumber;
  final double totalPrice;

  SalesData({required this.orderNumber, required this.totalPrice});
}
