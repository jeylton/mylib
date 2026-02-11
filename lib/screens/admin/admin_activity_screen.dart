import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';

class AdminActivityScreen extends StatefulWidget {
  const AdminActivityScreen({super.key});

  @override
  State<AdminActivityScreen> createState() => _AdminActivityScreenState();
}

class _AdminActivityScreenState extends State<AdminActivityScreen> {
  List<Map<String, dynamic>> activities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() => isLoading = true);
    try {
      // Simuler des vraies activités étudiants
      final studentActivities = [
        {
          'action': 'Livre emprunté',
          'details': 'Introduction à Flutter par Jean Dupont',
          'student': 'Jean Dupont',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
          'type': 'borrow',
        },
        {
          'action': 'Livre retourné',
          'details': 'Programmation Java par Marie Curie',
          'student': 'Marie Curie',
          'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
          'type': 'return',
        },
        {
          'action': 'Livre marqué comme lu',
          'details': 'Algorithmes et Structures par Paul Martin',
          'student': 'Paul Martin',
          'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
          'type': 'read',
        },
        {
          'action': 'Retard de livre',
          'details': 'Base de Données par Sophie Bernard',
          'student': 'Sophie Bernard',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'type': 'overdue',
        },
        {
          'action': 'Paiement effectué',
          'details': 'Pénalité de retard - 500F',
          'student': 'Pierre Durand',
          'timestamp': DateTime.now().subtract(const Duration(days: 2)),
          'type': 'payment',
        },
      ];

      setState(() {
        activities = studentActivities;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Erreur chargement activités: $e');
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'borrow':
        return Colors.blue;
      case 'return':
        return Colors.green;
      case 'read':
        return Colors.purple;
      case 'overdue':
        return Colors.red;
      case 'payment':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'borrow':
        return Icons.book_online;
      case 'return':
        return Icons.assignment_returned;
      case 'read':
        return Icons.check_circle;
      case 'overdue':
        return Icons.warning;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.info;
    }
  }

  String _getActivityTypeText(String type) {
    switch (type) {
      case 'borrow':
        return 'Emprunt';
      case 'return':
        return 'Retour';
      case 'read':
        return 'Lecture';
      case 'overdue':
        return 'Retard';
      case 'payment':
        return 'Paiement';
      default:
        return 'Autre';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📜 Activités Étudiants'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActivities,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadActivities,
              child: activities.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Aucune activité récente',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  _getActivityColor(activity['type'])
                                      .withOpacity(0.2),
                              child: Icon(
                                _getActivityIcon(activity['type']),
                                color: _getActivityColor(activity['type']),
                                size: 24,
                              ),
                            ),
                            title: Text(
                              activity['action'] ?? '',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity['details'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Étudiant: ${activity['student'] ?? ''}',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(activity['timestamp']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getActivityColor(activity['type'])
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getActivityTypeText(activity['type']),
                                    style: TextStyle(
                                      color:
                                          _getActivityColor(activity['type']),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
