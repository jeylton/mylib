import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'models/book_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/auth/resend_verification_screen.dart';
import 'screens/book/book_detail_screen.dart';
import 'screens/book/add_edit_book_screen.dart';
import 'screens/history/student_history_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/main/admin_home_screen.dart';
import 'screens/main/student_main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Library Borrowing System',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/resend-verification': (context) => const ResendVerificationScreen(),
          '/book-detail': (context) {
            final book = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return BookDetailScreen(book: book);
          },
          '/add-book': (context) => const AddEditBookScreen(),
          '/edit-book': (context) {
            final book = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return AddEditBookScreen(book: BookModel.fromJson(book));
          },
          '/profile': (context) => const ProfileScreen(),
          '/history': (context) => const StudentHistoryScreen(),
          // Main Routes
          '/admin': (context) => const AdminHomeScreen(),
          '/student': (context) => const StudentMainScreen(),
          '/edit-profile': (context) => const EditProfileScreen(),
        },
        onGenerateRoute: (settings) {
          final name = settings.name;
          if (name == null) return null;

          if (name.startsWith('/reset-password/')) {
            final token = name.split('/').last;
            return MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(token: token),
            );
          } else if (name.startsWith('/verify-email/')) {
            final token = name.split('/').last;
            return MaterialPageRoute(
              builder: (context) => VerifyEmailScreen(token: token),
            );
          }

          return null;
        },
      ),
    );
  }
}
