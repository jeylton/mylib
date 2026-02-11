class BookModel {
  final String? id; // made nullable to support adding
  final String title;
  final String? author;
  final String? genre;
  final String? isbn;
  final String? barcode;
  final String? description;
  final int? quantity;
  final int? borrowedCount;
  final bool available;
  final String? status;

  BookModel({
    this.id,
    required this.title,
    this.author,
    this.genre,
    this.isbn,
    this.barcode,
    this.description,
    this.quantity = 1,
    this.borrowedCount = 0,
    this.available = true,
    this.status,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final parsedQuantity =
        int.tryParse(json['quantity']?.toString() ?? '1') ?? 1;
    final parsedBorrowedCount = int.tryParse(
            (json['borrowed_count'] ?? json['borrowedCount'])?.toString() ??
                '0') ??
        0;
    final derivedStatus = (json['status']?.toString().isNotEmpty ?? false)
        ? json['status']?.toString()
        : (parsedBorrowedCount < parsedQuantity ? 'available' : 'borrowed');

    return BookModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      author: json['author']?.toString() ?? '',
      genre: json['genre']?.toString() ?? '',
      isbn: json['isbn']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      quantity: parsedQuantity,
      borrowedCount: parsedBorrowedCount,
      available: json['available'] ?? true,
      status: derivedStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'title': title,
      'author': author,
      'genre': genre,
      'isbn': isbn,
      'barcode': barcode,
      'description': description,
      'quantity': quantity ?? 1,
      'borrowedCount': borrowedCount ?? 0,
      'available': available,
      if (status != null) 'status': status,
    };
  }

  bool get isAvailable => status == 'available';

  int get availableCount {
    final total = quantity ?? 1;
    final borrowed = borrowedCount ?? 0;
    return (total - borrowed).clamp(0, total);
  }

  String get availabilityText {
    final total = quantity ?? 1;
    final borrowed = borrowedCount ?? 0;
    final available = total - borrowed;
    return '$available/$total';
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? genre,
    String? isbn,
    String? barcode,
    String? description,
    int? quantity,
    int? borrowedCount,
    bool? available,
    String? status,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      isbn: isbn ?? this.isbn,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      borrowedCount: borrowedCount ?? this.borrowedCount,
      available: available ?? this.available,
      status: status ?? this.status,
    );
  }
}
