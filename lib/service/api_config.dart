import 'package:neeknots/models/user_model.dart';

import '../core/hive/app_config_cache.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ApiConfig {

  static String get apiBASEURL => dotenv.env['API_BASE_URL'] ?? '';
  //=======================user and Login Api
  static String authAPi = "$apiBASEURL/user";
  static String loginAPi = "$apiBASEURL/login";
  static String generateOtpAPI = "$apiBASEURL/generate-otp";
  static String verifyOtpAPI = "$apiBASEURL/verify-otp";

  //=======================contact Us

  static String contactUs = "$apiBASEURL/contact-us";

  //=======================Product
  static String product = "$apiBASEURL/product";
  static String order = "$apiBASEURL/order";
  static String createOrder = "$order/create";
  static String updateOrder = "$order/update";
  static String deleteOrderByID = "$order/delete_order";

  //======Admin

  static String admin = "$apiBASEURL/adminRoutes";
  static String allStoreList = "$admin/store_list";
  static String storeWiseGetCount = "$admin/store_summary";
  static String getAllUser = "$admin/users/store";
  static String updateUserDetails = "$admin/users/update";
  static String getALlProduct = "$admin/products/store";
  static String getAllContact = "$admin/contacts/store";
  static String getAlOrder = "$admin/orders/store";
  static String approvedProductImage = "$admin/products";

  //==========================================================Shopify API=================================================================================================================
  static Future<String> get accessToken async {
    UserModel? user = await AppConfigCache.getUserModel(); // await the future

    return user?.accessToken ?? '';
  }

  static Future<Map<String, String>> getCommonHeaders() async {
    final token = await accessToken;
    return {
      'Content-Type': 'application/json',
      'accept': '*/*',
      "X-Shopify-Access-Token": token,
    };
  }


  //base url
  static Future<String> get baseUrl async {
    UserModel? user = await AppConfigCache.getUserModel(); // await the future
    final storeName = user?.storeName ?? '';
    final versionCode = user?.versionCode ?? '';
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
