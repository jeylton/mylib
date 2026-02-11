import 'package:flutter/foundation.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  int _borrowedBooks = 0;
  int _booksRead = 0;
  int _overdue = 0;
  double _totalBalance = 0.0;
  List<Map<String, dynamic>> _recentActivity = [];

  // Getters
  int get borrowedBooks => _borrowedBooks;
  int get booksRead => _booksRead;
  int get overdue => _overdue;
  double get totalBalance => _totalBalance;
  List<Map<String, dynamic>> get recentActivity => _recentActivity;

  // Update methods
  void updateBorrowedBooks(int count) {
    _borrowedBooks = count;
    notifyListeners();
  }

  void updateBooksRead(int count) {
    _booksRead = count;
    notifyListeners();
  }

  void updateOverdue(int count) {
    _overdue = count;
    notifyListeners();
  }

  void updateTotalBalance(double balance) {
    _totalBalance = balance;
    notifyListeners();
  }

  void updateRecentActivity(List<Map<String, dynamic>> activity) {
    _recentActivity = activity;
    notifyListeners();
  }

  // Reset all data
  void reset() {
    _borrowedBooks = 0;
    _booksRead = 0;
    _overdue = 0;
    _totalBalance = 0.0;
    _recentActivity = [];
    notifyListeners();
  }

  // Refresh dashboard data
  Future<void> refreshDashboard(String userId) async {
    try {
      final data = await DashboardService.fetchStudentDashboard(userId);

      _borrowedBooks = data['currentBorrowings'] ?? 0;
      _booksRead = data['booksRead'] ?? 0;
      _overdue = data['overdueBorrowings']?.length ?? 0;
      _totalBalance =
          double.tryParse(data['user']['balance'].toString()) ?? 0.0;
      _recentActivity =
          List<Map<String, dynamic>>.from(data['recentActivity'] ?? []);

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing dashboard: $e');
      }
    }
  }
}
