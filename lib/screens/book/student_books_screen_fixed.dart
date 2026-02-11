import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../../models/borrowing_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/book_service.dart';
import '../../services/borrowing_service.dart';

class StudentBooksScreen extends StatefulWidget {
  const StudentBooksScreen({super.key});

  @override
  State<StudentBooksScreen> createState() => _StudentBooksScreenState();
}

class _StudentBooksScreenState extends State<StudentBooksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<BookModel> availableBooks = [];
  List<BorrowingModel> borrowedBooks = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
      if (userId == null) return;

      // Charger les livres disponibles et les emprunts en parallèle
      final booksFuture = BookService.getBooks();
      final borrowingsFuture = BorrowingService.fetchUserBorrowings(userId);

      final results = await Future.wait([booksFuture, borrowingsFuture]);
      
      final booksData = results[0] as List<dynamic>;
      final borrowingsData = results[1] as List<BorrowingModel>;

      setState(() {
        availableBooks = booksData
            .map((e) => BookModel.fromJson(e))
            .where((book) => book.isAvailable)
            .toList();
        
        borrowedBooks = borrowingsData
            .where((b) => b.status.toLowerCase() == 'active')
            .toList();
        
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showPopup("Erreur", "Impossible de charger les données: $e",
          isSuccess: false);
    }
  }

  Future<void> _borrowBook(BookModel book) async {
    try {
      final success = await BookService.borrowBook(book.id ?? '');
      if (success) {
        _showPopup("Succès", "Livre emprunté avec succès! 📚", isSuccess: true);
        
        // Mettre à jour immédiatement les listes locales
        setState(() {
          // Vérifier s'il reste des exemplaires disponibles
          final updatedBook = book.copyWith(
            borrowedCount: (book.borrowedCount ?? 0) + 1,
          );
          
          // Si plus d'exemplaires disponibles, retirer de la liste
          if (updatedBook.availableCount <= 0) {
            availableBooks.removeWhere((b) => b.id == book.id);
          } else {
            // Sinon, mettre à jour le livre dans la liste
            final index = availableBooks.indexWhere((b) => b.id == book.id);
            if (index != -1) {
              availableBooks[index] = updatedBook;
            }
          }
          
          // Ajouter le livre aux emprunts
          final newBorrowing = BorrowingModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            book: updatedBook,
            user: Provider.of<AuthProvider>(context, listen: false).user!,
            borrowDate: DateTime.now(),
            dueDate: DateTime.now().add(const Duration(days: 7)),
            returnDate: null,
            status: 'active',
            isRead: false,
          );
          borrowedBooks.add(newBorrowing);
        });
        
        // Synchroniser le dashboard automatiquement
        final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
        if (userId != null) {
          final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
          
          // Incrémenter Borrowed Books
          final currentBorrowed = dashboardProvider.borrowedBooks;
          dashboardProvider.updateBorrowedBooks(currentBorrowed + 1);
          
          // Recharger depuis l'API pour synchronisation complète
          await dashboardProvider.refreshDashboard(userId);
        }
        
        // Forcer le rebuild de l'interface
        if (mounted) {
          setState(() {});
        }
      } else {
        _showPopup("Échec", "Impossible d'emprunter ce livre", isSuccess: false);
      }
    } catch (e) {
      _showPopup("Erreur", "Erreur lors de l'emprunt: $e", isSuccess: false);
    }
  }

  Future<void> _renewLoan(BorrowingModel borrowing) async {
    try {
      final success = await BorrowingService.renewBorrowing(borrowing.id ?? '');
      if (success) {
        _showPopup("Succès", "Emprunt prolongé! ⏰", isSuccess: true);
        await _loadData();
      } else {
        _showPopup("Échec", "Impossible de prolonger l'emprunt",
            isSuccess: false);
      }
    } catch (e) {
      _showPopup("Erreur", "Erreur lors du prolongement: $e", isSuccess: false);
    }
  }

  Future<void> _markAsRead(BorrowingModel borrowing) async {
    try {
      final success = await BorrowingService.markAsRead(borrowing.id ?? '');
      if (success) {
        _showPopup("Succès", "Livre marqué comme lu! ✅", isSuccess: true);
        
        // Mettre à jour immédiatement les listes locales
        setState(() {
          // Marquer l'emprunt comme lu
          final index = borrowedBooks.indexWhere((b) => b.id == borrowing.id);
          if (index != -1) {
            borrowedBooks[index] = borrowing.copyWith(isRead: true);
          }
        });
        
        // Synchroniser le dashboard automatiquement
        final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
        if (userId != null) {
          final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
          
          // Incrémenter Books Read
          final currentBooksRead = dashboardProvider.booksRead;
          dashboardProvider.updateBooksRead(currentBooksRead + 1);
          
          // Recharger depuis l'API pour synchronisation complète
          await dashboardProvider.refreshDashboard(userId);
        }
        
        // Forcer le rebuild de l'interface
        if (mounted) {
          setState(() {});
        }
      } else {
        _showPopup("Échec", "Impossible de marquer comme lu", isSuccess: false);
      }
    } catch (e) {
      _showPopup("Erreur", "Erreur: $e", isSuccess: false);
    }
  }

  Future<void> _returnBook(BorrowingModel borrowing) async {
    try {
      final success = await BorrowingService.returnBook(borrowing.id ?? '');
      if (success) {
        _showPopup("Succès", "Livre retourné! 📤", isSuccess: true);
        
        // Mettre à jour immédiatement les listes locales
        setState(() {
          // Retirer l'emprunt de la liste
          borrowedBooks.removeWhere((b) => b.id == borrowing.id);
          // Ajouter le livre aux disponibles
          if (borrowing.book.isAvailable) {
            availableBooks.add(borrowing.book);
          }
        });
        
        // Synchroniser le dashboard automatiquement
        final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
        if (userId != null) {
          final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
          
          // Décrémenter Borrowed Books
          final currentBorrowed = dashboardProvider.borrowedBooks;
          dashboardProvider.updateBorrowedBooks(currentBorrowed - 1);
          
          // Recharger depuis l'API pour synchronisation complète
          await dashboardProvider.refreshDashboard(userId);
        }
        
        // Forcer le rebuild de l'interface
        if (mounted) {
          setState(() {});
        }
      } else {
        _showPopup("Échec", "Impossible de retourner le livre", isSuccess: false);
      }
    } catch (e) {
      _showPopup("Erreur", "Erreur lors du retour: $e", isSuccess: false);
    }
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

  List<BookModel> get filteredAvailableBooks {
    return availableBooks.where((book) {
      final query = searchQuery.toLowerCase();
      final matchesTitle = book.title.toLowerCase().contains(query);
      final matchesAuthor = book.author?.toLowerCase().contains(query) ?? false;
      final matchesIsbn = book.isbn?.toLowerCase().contains(query) ?? false;
      final matchesBarcode = book.barcode?.toLowerCase().contains(query) ?? false;
      final matchesGenre = book.genre?.toLowerCase().contains(query) ?? false;
      
      return matchesTitle || matchesAuthor || matchesIsbn || matchesBarcode || matchesGenre;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Bibliothèque'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.library_books), text: 'Disponibles'),
            Tab(icon: Icon(Icons.menu_book), text: 'Mes emprunts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableBooksTab(),
          _buildBorrowedBooksTab(),
        ],
      ),
    );
  }

  Widget _buildAvailableBooksTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Rechercher par titre, auteur, ISBN, code-barres, cours...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: filteredAvailableBooks.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.library_books, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Aucun livre disponible',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredAvailableBooks.length,
                          itemBuilder: (context, index) {
                            final book = filteredAvailableBooks[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: Icon(
                                  Icons.book,
                                  color: Colors.blue.shade600,
                                  size: 32,
                                ),
                                title: Text(
                                  book.title ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.author ?? 'Auteur inconnu',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                    if (book.genre != null)
                                      Text(
                                        'Cours: ${book.genre}',
                                        style: TextStyle(
                                          color: Colors.blue.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${book.availableCount}/${book.quantity ?? 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: book.availableCount > 0 
                                            ? Colors.green 
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ElevatedButton.icon(
                                      onPressed: book.availableCount > 0 
                                          ? () => _borrowBook(book)
                                          : null,
                                      icon: const Icon(Icons.book_online),
                                      label: const Text('Emprunter'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: book.availableCount > 0 
                                            ? Colors.blue.shade600
                                            : Colors.grey,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }

  Widget _buildBorrowedBooksTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : borrowedBooks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucun emprunt en cours',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: borrowedBooks.length,
                  itemBuilder: (context, index) {
                    final borrowing = borrowedBooks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          Icons.menu_book,
                          color: borrowing.isRead ? Colors.green : Colors.orange.shade600,
                          size: 32,
                        ),
                        title: Text(
                          borrowing.book.title ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Auteur: ${borrowing.book.author ?? 'Inconnu'}'),
                            Text(
                              'Retour prévu: ${borrowing.dueDate.day}/${borrowing.dueDate.month}/${borrowing.dueDate.year}',
                              style: TextStyle(
                                color: borrowing.dueDate.isBefore(DateTime.now())
                                    ? Colors.red
                                    : Colors.grey.shade600,
                              ),
                            ),
                            if (borrowing.isRead)
                              Text(
                                '✅ Lu',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.access_time),
                              tooltip: 'Prolonger',
                              onPressed: () => _renewLoan(borrowing),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check_circle),
                              tooltip: 'Marquer comme lu',
                              onPressed: () => _markAsRead(borrowing),
                            ),
                            IconButton(
                              icon: const Icon(Icons.assignment_returned),
                              tooltip: 'Retourner',
                              onPressed: () => _returnBook(borrowing),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
