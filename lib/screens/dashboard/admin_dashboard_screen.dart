import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  AdminDashboardScreenState createState() => AdminDashboardScreenState();
}

class AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int totalBooks = 0;
  int totalUsers = 0;
  int totalBorrowings = 0;
  int totalReservations = 0;
  double totalBalanceCollected = 0.0;

  List<dynamic> topBorrowers = [];
  List<dynamic> overdueBooks = [];
  List<dynamic> recentActivity = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOverview();
  }

  /// Public method to refresh dashboard externally
  Future<void> refreshData() async {
    setState(() => isLoading = true);
    await fetchOverview();
  }

  void _signOut() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> fetchOverview() async {
    try {
      // Récupérer d'abord les données principales
      final data = await AdminService.getOverview();

      setState(() {
        totalBooks = data['totalBooks'] ?? 0;
        totalUsers = data['totalUsers'] ?? 0;
        totalBorrowings = data['totalBorrowings'] ?? 0;
        totalReservations = data['totalReservations'] ?? 0;
        totalBalanceCollected = data['totalBalanceCollected'] != null
            ? (data['totalBalanceCollected'] is num
                ? (data['totalBalanceCollected'] as num).toDouble()
                : 0.0)
            : 0.0;
        recentActivity = data['recentActivity'] ?? [];
        isLoading = false;
      });

      // Récupérer les autres données en arrière-plan
      try {
        final overdueData = await AdminService.getOverdueBooks();
        final borrowerData = await AdminService.getTopBorrowers();

        setState(() {
          topBorrowers = borrowerData;
          overdueBooks = overdueData;
        });
      } catch (e) {
        print('Error fetching additional data: $e');
        // Ne pas bloquer l'affichage principal si ces données échouent
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refreshData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Overview",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: [
                        _buildDashboardCard(
                            "Total Books", totalBooks, Icons.book, Colors.blue),
                        _buildDashboardCard("Total Users", totalUsers,
                            Icons.people, Colors.green),
                        _buildDashboardCard("Total Borrowings", totalBorrowings,
                            Icons.assignment, Colors.indigo),
                        _buildBalanceCard(
                            "Total Balance",
                            totalBalanceCollected,
                            Icons.account_balance_wallet,
                            Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Activity Section
                    const Text(
                      "Recent Activity",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildRecentActivity(),
                    const SizedBox(height: 24),

                    // Overdue Books Section
                    const Text(
                      "Overdue Books",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildOverdueBooks(),
                    const SizedBox(height: 24),

                    // Top Borrowers Section
                    const Text(
                      "Top Borrowers",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildTopBorrowers(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDashboardCard(
      String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
      String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12), // Plus petit padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color), // Icône plus petite
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600)), // Texte plus petit
          const SizedBox(height: 4),
          Text(
            "${amount.toStringAsFixed(0)} F", // Affiche en francs
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color), // Chiffre plus petit
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    if (recentActivity.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                "No recent activity",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentActivity.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final activity = recentActivity[index];
          final action = activity['action'] ?? 'Unknown';
          final book = activity['book'] ?? 'Unknown book';
          final dateStr = activity['date'] ?? '';

          Color actionColor = Colors.blue;
          IconData actionIcon = Icons.info;

          if (action == 'Borrowed') {
            actionColor = Colors.green;
            actionIcon = Icons.add_circle;
          } else if (action == 'Returned') {
            actionColor = Colors.orange;
            actionIcon = Icons.remove_circle;
          } else if (action.toLowerCase().contains('created')) {
            actionColor = Colors.purple;
            actionIcon = Icons.add_box;
          }

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: actionColor.withOpacity(0.1),
              child: Icon(actionIcon, color: actionColor, size: 20),
            ),
            title: Text(
              action,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              book,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: Text(
              _formatDate(dateStr),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverdueBooks() {
    if (overdueBooks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.check_circle, size: 48, color: Colors.green.shade400),
              const SizedBox(height: 8),
              Text(
                "No overdue books",
                style: TextStyle(color: Colors.green.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: overdueBooks.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.red.shade200,
        ),
        itemBuilder: (context, index) {
          final overdue = overdueBooks[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.shade100,
              child: Icon(Icons.warning, color: Colors.red.shade700, size: 20),
            ),
            title: Text(
              overdue['book_title'] ?? 'Unknown Book',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              "Borrowed by: ${overdue['user_name'] ?? 'Unknown'}\nDue: ${overdue['due_date'] ?? 'N/A'}",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: Text(
              "${overdue['penalty'] ?? '0'} F",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBorrowers() {
    if (topBorrowers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.people, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                "No borrowing data yet",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: topBorrowers.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final borrower = topBorrowers[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.person, color: Colors.blue.shade700, size: 20),
            ),
            title: Text(
              borrower['name'] ?? 'Unknown User',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              borrower['email'] ?? 'No email',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: Text(
              "${borrower['borrowed_count'] ?? 0} books",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return "${difference.inDays}d ago";
      } else if (difference.inHours > 0) {
        return "${difference.inHours}h ago";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes}m ago";
      } else {
        return "Just now";
      }
    } catch (e) {
      return dateStr;
    }
  }
}
