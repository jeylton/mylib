import 'dart:convert';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class FineService {
  // Récupérer le balance de l'utilisateur
  static Future<double> getUserBalance(String userId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/fines/balance/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Le balance peut être une chaîne, on doit la convertir en nombre
        final balanceStr = (data['balance'] ?? '0.0').toString();
        return double.tryParse(balanceStr) ?? 0.0;
      } else {
        throw Exception('Failed to load balance');
      }
    } catch (e) {
      print('Error fetching user balance: $e');
      return 0.0;
    }
  }

  // Récupérer les amendes de l'utilisateur
  static Future<List<dynamic>> getUserFines(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/fines/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load fines');
      }
    } catch (e) {
      print('Error fetching user fines: $e');
      return [];
    }
  }

  // Payer une amende
  static Future<bool> payFine(String fineId, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/fines/pay/$fineId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'amount': amount}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error paying fine: $e');
      return false;
    }
  }

  // Ajouter du balance au compte
  static Future<bool> addBalance(String userId, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/fines/add-balance/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'amount': amount}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error adding balance: $e');
      return false;
    }
  }
}
