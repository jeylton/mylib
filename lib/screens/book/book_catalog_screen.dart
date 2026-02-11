import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/book_service.dart';

class BookCatalogScreen extends StatefulWidget {
  const BookCatalogScreen({super.key});

  @override
  State<BookCatalogScreen> createState() => _BookCatalogScreenState();
}

class _BookCatalogScreenState extends State<BookCatalogScreen> {
  List<BookModel> books = [];
  List<BookModel> filteredBooks = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> _borrow(BookModel book) async {
    final ok = await BookService.borrowBook(book.id ?? '');
    if (ok) {
      _showPopup(context, 'Success', 'Book borrowed successfully ✅');
      await fetchBooks();
      searchBooks(searchQuery);
    } else {
      _showPopup(context, 'Failed', '❌ Failed to borrow book',
          isSuccess: false);
    }
  }

  Future<void> _editBook(BookModel book) async {
    final result = await Navigator.pushNamed(
      context,
      '/edit-book',
      arguments: book.toJson(),
    );
    if (result == true) {
      await fetchBooks();
      searchBooks(searchQuery);
    }
  }

  Future<void> _deleteBook(BookModel book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await BookService.deleteBook(book.id ?? '');
      if (success) {
        _showPopup(context, 'Success', 'Book deleted successfully ✅');
        await fetchBooks();
        searchBooks(searchQuery);
      } else {
        _showPopup(context, 'Failed', '❌ Failed to delete book',
            isSuccess: false);
      }
    }
  }

  Future<void> fetchBooks() async {
    setState(() => isLoading = true);
    try {
      final data = await BookService.getBooks();
      setState(() {
        books = data.map((e) => BookModel.fromJson(e)).toList();
        filteredBooks = books.where((b) {
          return (b.title ?? '')
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              (b.author ?? '')
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              (b.barcode ?? '')
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showPopup(context, "Error", "Failed to load books:\n$e",
          isSuccess: false);
    }
  }

  void searchBooks(String query) {
    setState(() {
      searchQuery = query;
      filteredBooks = books.where((b) {
        return (b.title ?? '').toLowerCase().contains(query.toLowerCase()) ||
            (b.author ?? '').toLowerCase().contains(query.toLowerCase()) ||
            (b.barcode ?? '').toLowerCase().contains(query.toLowerCase());
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.user?.role == 'admin';

    return Scaffold(
      appBar: isAdmin
          ? AppBar(
              title: const Text('📚 Book Management'),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add New Book',
                  onPressed: () async {
                    final result =
                        await Navigator.pushNamed(context, '/add-book');
                    if (result == true) {
                      await fetchBooks();
                      searchBooks(searchQuery);
                    }
                  },
                ),
              ],
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    onChanged: searchBooks,
                    decoration: InputDecoration(
                      hintText: "Search by title, author or code-barres...",
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
                    onRefresh: fetchBooks,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        final book = filteredBooks[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: Icon(
                              Icons.book,
                              color: book.status == "available"
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            title: Text(book.title ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("by ${book.author ?? 'Unknown'}"),
                                if (book.barcode != null &&
                                    book.barcode!.isNotEmpty)
                                  Text("📷 Code: ${book.barcode}",
                                      style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12)),
                                Text("📚 Disponible: ${book.availabilityText}",
                                    style: TextStyle(
                                        color: book.availableCount > 0
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isAdmin) ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    tooltip: 'Edit Book',
                                    color: Colors.blue,
                                    onPressed: () => _editBook(book),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'Delete Book',
                                    color: Colors.red,
                                    onPressed: () => _deleteBook(book),
                                  ),
                                ] else ...[
                                  IconButton(
                                    icon: const Icon(Icons.book_online),
                                    tooltip: 'Borrow',
                                    color: book.availableCount > 0
                                        ? Colors.blue
                                        : Colors.grey,
                                    onPressed: book.availableCount > 0
                                        ? () => _borrow(book)
                                        : null,
                                  ),
                                ],
                                Text(book.status ?? ''),
                              ],
                            ),
                            onTap: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                '/book-detail',
                                arguments: book.toJson(),
                              );

                              if (result == true) {
                                await fetchBooks(); // Refresh data
                                searchBooks(
                                    searchQuery); // Apply current filter again
                              }
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
