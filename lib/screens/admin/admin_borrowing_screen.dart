import 'package:flutter/material.dart';
import '../../models/borrowing_model.dart';
import '../../services/borrowing_service.dart';

class AdminBorrowingScreen extends StatefulWidget {
  const AdminBorrowingScreen({super.key});

  @override
  State<AdminBorrowingScreen> createState() => _AdminBorrowingScreenState();
}

class _AdminBorrowingScreenState extends State<AdminBorrowingScreen> {
  List<BorrowingModel> borrowings = [];
  List<BorrowingModel> filteredBorrowings = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchBorrowings();
  }

  Future<void> _fetchBorrowings() async {
    setState(() => isLoading = true);
    try {
      final data = await BorrowingService.fetchAllBorrowings();
      setState(() {
        borrowings = data;
        filteredBorrowings = borrowings.where((b) {
          return b.book.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              b.user.name.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showPopup(context, "Error", "Failed to load borrowings:\n$e",
          isSuccess: false);
    }
  }

  void _searchBorrowings(String query) {
    setState(() {
      searchQuery = query;
      filteredBorrowings = borrowings.where((b) {
        return b.book.title.toLowerCase().contains(query.toLowerCase()) ||
            b.user.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _showPopup(BuildContext context, String title, String message,
      {bool isSuccess = true}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            child:
                const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'En cours';
      case 'returned':
        return 'Retourné';
      case 'overdue':
        return 'En retard';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.blue;
      case 'returned':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Historique des Emprunts'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    onChanged: _searchBorrowings,
                    decoration: InputDecoration(
                      hintText: "Rechercher par livre ou utilisateur...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchBorrowings,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredBorrowings.length,
                      itemBuilder: (context, index) {
                        final borrowing = filteredBorrowings[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: Icon(
                              Icons.menu_book,
                              color: _getStatusColor(borrowing.status),
                              size: 32,
                            ),
                            title: Text(
                              borrowing.book.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Emprunté par: ${borrowing.user.name}'),
                                Text('Email: ${borrowing.user.email}'),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Date emprunt: ${borrowing.borrowDate.toLocal().toString().substring(0, 10)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Retour prévu: ${borrowing.dueDate.toLocal().toString().substring(0, 10)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(borrowing.status).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getStatusDisplayText(borrowing.status),
                                    style: TextStyle(
                                      color: _getStatusColor(borrowing.status),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                if (borrowing.isRead) ...[
                                  const SizedBox(height: 4),
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                ],
                              ],
                            ),
                            onTap: () {
                              // TODO: Ajouter la fonctionnalité de détails d'emprunt
                              _showPopup(context, 'Info', 
                                  'Fonctionnalité de détails d\'emprunt bientôt disponible');
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
