import 'package:flutter/material.dart';
import 'package:neeknots/admin/admin_dashboad.dart';
import 'package:neeknots/contact_us/contact_us_screen.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/feature/admin/admin_home_page.dart';
import 'package:neeknots/feature/admin/admin_login_page.dart';
import 'package:neeknots/feature/auth/otp_verification_screen.dart';
import 'package:neeknots/feature/auth/signup/signup_screen.dart';
import 'package:neeknots/feature/change_password/change_password_screen.dart';
import 'package:neeknots/feature/customer_details/customer_detail_page.dart';
import 'package:neeknots/feature/customer_details/customer_order_page.dart';
import 'package:neeknots/feature/edit_profile/edit_profile_screen.dart';
import 'package:neeknots/feature/inactive_account_screen/inactive_account_screen.dart';
import 'package:neeknots/feature/notification/notification_screen.dart';
import 'package:neeknots/feature/order_details/order_details_screen.dart';
import 'package:neeknots/feature/pending_request_screen/pending_request_screen.dart';
import 'package:neeknots/feature/product_details/add_product_screen.dart';
import 'package:neeknots/feature/product_details/product_details_screen.dart';
import 'package:neeknots/feature/sales_details_screen.dart';
import 'package:neeknots/feature/total_order_screen.dart';
import 'package:neeknots/main.dart';
import 'package:neeknots/models/customer_model.dart';

import '../core/component/component.dart';
import '../feature/auth/login_screen.dart';
import '../feature/dashboard/dashboard_screen.dart';
import '../feature/splash/splash_screen.dart';
import '../feature/total_customer_screen.dart';
import '../feature/total_product_screen.dart';
import 'app_routes.dart';

class RouteGenerate {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteName.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RouteName.dashboardScreen:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case RouteName.customerDetail:
        final args = settings.arguments as Customer;
        return MaterialPageRoute(
          builder: (_) => CustomerDetailPage(customer: args),
        );

      case RouteName.notificationScreen:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());

      case RouteName.changePasswordScreen:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      case RouteName.editProfileScreen:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case RouteName.productDetailsScreen:
        final args = settings.arguments as String;

        return MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(productId: args),
        );

      case RouteName.orderDetailsScreen:
        final args = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => OrderDetailsScreen(orderID: args),
        );
      case RouteName.addProductScreen:
        return MaterialPageRoute(builder: (_) => const AddProductScreen());
      case RouteName.totalOrderScreen:
        return MaterialPageRoute(builder: (_) => const TotalOrderScreen());
      case RouteName.totalCustomerScreen:
        return MaterialPageRoute(builder: (_) => const TotalCustomerScreen());
      case RouteName.customerOrders:
        final args = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CustomerOrderPage(customerId: args),
        );
      case RouteName.totalProductScreen:
        return MaterialPageRoute(builder: (_) => const TotalProductScreen());
      case RouteName.salesDetailsScreen:
        final args = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => SalesDetailsScreen(todaySales: args),
        );

      case RouteName.signupScreen:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case RouteName.otpVerificationScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(userData: args),
        );

      case RouteName.inactiveAccountScreen:
        return MaterialPageRoute(builder: (_) => const InactiveAccountScreen());

      case RouteName.contactUsScreen:
        return MaterialPageRoute(builder: (_) => const ContactUsScreen());
      case RouteName.pendingRequestScreen:
        return MaterialPageRoute(builder: (_) => const PendingRequestScreen());
      case RouteName.adminDashboardScreen:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case RouteName.adminLoginPage:
        return MaterialPageRoute(builder: (_) => const AdminLoginPage());
      case RouteName.adminHomePage:
        return MaterialPageRoute(builder: (_) => const AdminHomePage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: commonAppBackground(
              child: Center(
                child: Image.asset(
                  icAppLogo,
                  width:
                      MediaQuery.sizeOf(navigatorKey.currentContext!).width *
                      0.7,

                  height: 72,
                ),
              ),
            ),
          ),
        );
    }
  }
}
