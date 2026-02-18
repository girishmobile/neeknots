import '../core/hive/app_config_cache.dart';

class ApiConfig {
  static Future<String> get accessToken async {
    final config = await AppConfigCache.loadConfig();
    return config['accessToken'] ?? '';
  }

  static Future<Map<String, String>> getCommonHeaders() async {
    final token = await accessToken;

    return {
      'Content-Type': 'application/json',
      'accept': '*/*',
      "X-Shopify-Access-Token": token,
    };
  }

  static Future<String> get baseUrl async {
    final config = await AppConfigCache.loadConfig();
    final storeName = config['storeName'] ?? '';
    final versionCode = config['versionCode'] ?? '';

    //print('==storeName===${storeName}');

    return "https://$storeName.myshopify.com/admin/api/$versionCode";
  }

  static Future<String> get productsUrl async =>
      "${await baseUrl}/products.json";

  static Future<String> get ordersUrl async => "${await baseUrl}/orders.json";

  static Future<String> get customerUrl async =>
      "${await baseUrl}/customers.json";

  static Future<String> get totalCustomerUrl async =>
      "${await baseUrl}/customers/count.json";

  static Future<String> get totalProductUrl async =>
      "${await baseUrl}/products/count.json";

  static Future<String> get totalOrderUrl async =>
      "${await baseUrl}/orders/count.json";

  static Future<String> get getImageUrl async => "${await baseUrl}/products";

  static Future<String> get getCustomerImage async =>
      "${await baseUrl}/customers";

  static Future<String> get getOrderById async => "${await baseUrl}/orders";
}
