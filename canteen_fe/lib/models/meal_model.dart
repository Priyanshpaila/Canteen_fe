class MealModel {
  final String id;
  final String user;
  final DateTime date;
  final String status; // one of "ate", "missed", "not_marked"
  final bool isAutoMarked;
  final String? markedBy;
  final bool isAdminOverride;
  final double price;

  MealModel({
    required this.id,
    required this.user,
    required this.date,
    required this.status,
    required this.isAutoMarked,
    this.markedBy,
    required this.isAdminOverride,
    required this.price,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'not_marked',
      isAutoMarked: json['isAutoMarked'] ?? false,
      markedBy: json['markedBy'],
      isAdminOverride: json['isAdminOverride'] ?? false,
      price: (json['price'] != null && json['price'] is num)
          ? (json['price'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'date': date.toIso8601String(),
      'status': status,
      'isAutoMarked': isAutoMarked,
      'markedBy': markedBy,
      'isAdminOverride': isAdminOverride,
      'price': price,
    };
  }
}
