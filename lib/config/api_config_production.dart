class ApiEndpoints {
  // Configuration Production - Render API
  static const String baseUrl = "https://libroflow-api.onrender.com/api";

  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String verifyEmail = "$baseUrl/auth/verify-email";
  static const String resendVerification = "$baseUrl/auth/resend-verification";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String resetPassword = "$baseUrl/auth/reset-password";

  static const String updateProfile = "$baseUrl/auth/profile";

  static const String studentDashboard = "$baseUrl/dashboard/student";
  static const adminOverview = "$baseUrl/dashboard/admin/overview";
  static const String books = "$baseUrl/books";
  static const String borrowings = "$baseUrl/borrowings";
  static const String reservations = "$baseUrl/reservations";
  static const String users = "$baseUrl/users";
}
