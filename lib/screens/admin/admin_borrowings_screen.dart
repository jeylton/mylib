import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/borrowing_model.dart';
import '../../services/borrowing_service.dart';

class AdminBorrowingsScreen extends StatefulWidget {
  const AdminBorrowingsScreen({super.key});

  @override
  State<AdminBorrowingsScreen> createState() => _AdminBorrowingsScreenState();
}

class _AdminBorrowingsScreenState extends State<AdminBorrowingsScreen> {
  List<BorrowingModel> borrowings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final allBorrowings = await BorrowingService.fetchAllBorrowings();

      setState(() {
        borrowings = allBorrowings
            .where((b) => b.status.toLowerCase() == 'active')
            .toList();
      });
    } catch (e) {
      _showPopup("Error", "Failed to load data: $e", isSuccess: false);
    }
    setState(() => isLoading = false);
  }

  Future<void> returnBook(String borrowingId) async {
    final confirm = await _confirmDialog(
      "Mark as Returned",
      "Are you sure this book was returned?",
    );
    if (!confirm) return;

    try {
      final success = await BorrowingService.returnBook(borrowingId);
      if (!success) {
        _showPopup("Error", "Failed to mark book as returned.", isSuccess: false);
        return;
      }

      // Remove returned borrowing from the list
      setState(() {
        borrowings.removeWhere((b) => b.id == borrowingId);
      });

      _showPopup("Returned", "✅ Book marked as returned.", isSuccess: true);
    } catch (e) {
      _showPopup("Error", "❌ Failed to mark as returned: $e", isSuccess: false);
    }
  }

  Future<bool> _confirmDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _showPopup(String title, String message, {bool isSuccess = true}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Borrowings"),
        backgroundColor: Colors.blueGrey.shade400,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _sectionTitle("📘 Active Borrowings"),
            if (borrowings.isEmpty) const Text("No active borrowings found."),
            ...borrowings.map(
                  (b) => Card(
                elevation:3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(b.book.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Borrowed by: ${b.user.name}"),
                      Text("Due: ${DateFormat.yMMMd().format(b.dueDate)}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.assignment_turned_in),
                    tooltip: "Mark as Returned",
                    onPressed: () => returnBook(b.id!),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
