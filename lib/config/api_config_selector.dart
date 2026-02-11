import 'package:flutter/foundation.dart';

class ApiConfigSelector {
  static bool get isMobileDebug => !kIsWeb && !kReleaseMode;

  static ApiEndpoints get endpoints {
    if (isMobileDebug) {
      print('🔧 Using Mobile Debug API (10.0.2.2:5001)');
      return ApiEndpointsMobile();
    } else {
      print('🌐 Using Web API (localhost:5001)');
      return ApiEndpointsWeb();
    }
  }
}

// Interface commune pour les endpoints
abstract class ApiEndpoints {
  String get baseUrl;
  String get login;
  String get register;
  String get verifyEmail;
  String get resendVerification;
  String get forgotPassword;
  String get resetPassword;
  String get updateProfile;
  String get studentDashboard;
  String get adminOverview;
  String get books;
  String get borrowings;
  String get reservations;
  String get users;
}

// Implémentation Web
class ApiEndpointsWeb implements ApiEndpoints {
  @override
  String get baseUrl => "http://localhost:5001/api";

  @override
  String get login => "$baseUrl/auth/login";
  @override
  String get register => "$baseUrl/auth/register";
  @override
  String get verifyEmail => "$baseUrl/auth/verify-email";
  @override
  String get resendVerification => "$baseUrl/auth/resend-verification";
  @override
  String get forgotPassword => "$baseUrl/auth/forgot-password";
  @override
  String get resetPassword => "$baseUrl/auth/reset-password";
  @override
  String get updateProfile => "$baseUrl/auth/profile";
  @override
  String get studentDashboard => "$baseUrl/dashboard/student";
  @override
  String get adminOverview => "$baseUrl/dashboard/admin/overview";
  @override
  String get books => "$baseUrl/books";
  @override
  String get borrowings => "$baseUrl/borrowings";
  @override
  String get reservations => "$baseUrl/reservations";
  @override
  String get users => "$baseUrl/users";
}

// Implémentation Mobile Debug
class ApiEndpointsMobile implements ApiEndpoints {
  @override
  String get baseUrl =>
      "http://10.0.2.2:5001/api"; // 10.0.2.2 = localhost depuis émulateur Android

  @override
  String get login => "$baseUrl/auth/login";
  @override
  String get register => "$baseUrl/auth/register";
  @override
  String get verifyEmail => "$baseUrl/auth/verify-email";
  @override
  String get resendVerification => "$baseUrl/auth/resend-verification";
  @override
  String get forgotPassword => "$baseUrl/auth/forgot-password";
  @override
  String get resetPassword => "$baseUrl/auth/reset-password";
  @override
  String get updateProfile => "$baseUrl/auth/profile";
  @override
  String get studentDashboard => "$baseUrl/dashboard/student";
  @override
  String get adminOverview => "$baseUrl/dashboard/admin/overview";
  @override
  String get books => "$baseUrl/books";
  @override
  String get borrowings => "$baseUrl/borrowings";
  @override
  String get reservations => "$baseUrl/reservations";
  @override
  String get users => "$baseUrl/users";
}
