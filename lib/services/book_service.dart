import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class BookService {
  // Fetch books with optional search and genre filters
  static Future<List<Map<String, dynamic>>> fetchBooks({
    String search = '',
    String genre = 'All',
  }) async {
    final query = {
      if (search.isNotEmpty) 'search': search,
      if (genre != 'All') 'genre': genre,
    };

    final uri = Uri.parse(ApiEndpoints.books).replace(queryParameters: query);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Le backend retourne { books: [...] } ou directement la liste
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data['books'] != null) {
        return List<Map<String, dynamic>>.from(data['books']);
      } else {
        return [];
      }
    } else {
      print('Fetch books failed: ${response.statusCode}');
      throw Exception('Failed to load books');
    }
  }

  static Future<List<Map<String, dynamic>>> getBooks() async {
    final response = await http.get(Uri.parse(ApiEndpoints.books));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Le backend retourne { books: [...] } ou directement la liste
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data['books'] != null) {
        return List<Map<String, dynamic>>.from(data['books']);
      } else {
        return [];
      }
    } else {
      print('Get books failed: ${response.statusCode}');
      throw Exception('Failed to fetch books');
    }
  }

  static Future<bool> addBook(Map<String, dynamic> bookData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    print('Sending book data: ${jsonEncode(bookData)}');

    final response = await http.post(
      Uri.parse(ApiEndpoints.books),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(bookData),
    );

    print('Add book response status: ${response.statusCode}');
    print('Add book response body: ${response.body}');

    return response.statusCode == 201 || response.statusCode == 200;
  }

  static Future<bool> updateBook(
      String id, Map<String, dynamic> bookData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    print('Updating book $id with data: ${jsonEncode(bookData)}');

    final response = await http.put(
      Uri.parse('${ApiEndpoints.books}/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(bookData),
    );

    print('Update book response status: ${response.statusCode}');
    print('Update book response body: ${response.body}');

    return response.statusCode == 200;
  }

  static Future<bool> deleteBook(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    print('Deleting book $id');

    final response = await http.delete(
      Uri.parse('${ApiEndpoints.books}/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Delete book response status: ${response.statusCode}');
    print('Delete book response body: ${response.body}');

    // Vérifier si la réponse contient un succès
    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true ||
            response.body.contains('success');
      } catch (e) {
        // Si le JSON ne peut être parsé, vérifier le statut HTTP
        return response.statusCode == 200;
      }
    }

    return false;
  }

  static Future<bool> borrowBook(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}/student/borrow'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'book_id': bookId}),
    );

    print('Borrow book response status: ${response.statusCode}');
    print('Borrow book response body: ${response.body}');

    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<Map<String, dynamic>> reserveBookWithMessage(
      String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse(ApiEndpoints.reservations),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'bookId': bookId}),
    );

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    print('Reserve book response: ${response.statusCode} | Body: $body');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'message': body['message'] ?? 'Reservation successful'
      };
    } else {
      return {
        'success': false,
        'message':
            body['message'] ?? 'Reservation failed (${response.statusCode})'
      };
    }
  }
}
