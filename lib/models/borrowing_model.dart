import 'package:library_borrowing_system/models/user_model.dart';
import 'book_model.dart';

class BorrowingModel {
  final String id;
  final BookModel book;
  final UserModel user;
  final DateTime borrowDate;
  final DateTime? returnDate;
  final DateTime dueDate;
  final String status;
  final bool isRead;

  BorrowingModel({
    required this.id,
    required this.book,
    required this.user,
    required this.borrowDate,
    this.returnDate,
    required this.dueDate,
    required this.status,
    this.isRead = false,
  });

  factory BorrowingModel.fromJson(Map<String, dynamic> json) {
    final borrowDateRaw = json['borrow_date'] ?? json['borrowDate'];
    final dueDateRaw = json['due_date'] ?? json['dueDate'];
    final returnDateRaw = json['return_date'] ?? json['returnDate'];

    return BorrowingModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      book: BookModel.fromJson(json['book']),
      user: UserModel.fromJson(json['user']),
      borrowDate: DateTime.parse(borrowDateRaw.toString()),
      returnDate: returnDateRaw != null
          ? DateTime.tryParse(returnDateRaw.toString())
          : null,
      dueDate: DateTime.parse(dueDateRaw.toString()),
      status: json['status']?.toString() ?? '',
      isRead: json['is_read'] ?? json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'book': book.toJson(),
      'user': user.toJson(),
      'borrowDate': borrowDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'isRead': isRead,
    };
  }

  BorrowingModel copyWith({
    String? id,
    BookModel? book,
    UserModel? user,
    DateTime? borrowDate,
    DateTime? returnDate,
    DateTime? dueDate,
    String? status,
    bool? isRead,
  }) {
    return BorrowingModel(
      id: id ?? this.id,
      book: book ?? this.book,
      user: user ?? this.user,
      borrowDate: borrowDate ?? this.borrowDate,
      returnDate: returnDate ?? this.returnDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
    );
  }
}
