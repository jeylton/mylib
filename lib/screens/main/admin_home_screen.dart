import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/dashboard/admin_dashboard_screen.dart';
import '../book/admin_book_list_screen.dart';
import '../admin/user_management_screen.dart';
import '../admin/admin_borrowings_screen.dart';
import '../admin/admin_history_screen.dart';
import '../admin/admin_activity_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  // GlobalKey for AdminDashboardScreenState (now public)
  final GlobalKey<AdminDashboardScreenState> _dashboardKey =
      GlobalKey<AdminDashboardScreenState>();

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      AdminDashboardScreen(key: _dashboardKey),
      const AdminBookListScreen(key: PageStorageKey('books')),
      const UserManagementScreen(key: PageStorageKey('users')),
      const AdminHistoryScreen(key: PageStorageKey('history')),
      const AdminActivityScreen(key: PageStorageKey('activity')),
    ];
  }

  final List<String> _titles = [
    "Dashboard",
    "Books",
    "Users",
    "History",
    "Activity",
  ];

  void _signOut() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          // Removed refresh icon here as requested
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'Activity'),
        ],
      ),
    );
  }
}
