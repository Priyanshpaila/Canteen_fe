class MealPriceModel {
  final String id;
  final DateTime date;
  final double price;
  final String? calculatedBy;
  final int participantCount;
  final String? notes;

  MealPriceModel({
    required this.id,
    required this.date,
    required this.price,
    this.calculatedBy,
    required this.participantCount,
    this.notes,
  });

  factory MealPriceModel.fromJson(Map<String, dynamic> json) {
    return MealPriceModel(
      id: json['_id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      price: (json['price'] != null && json['price'] is num)
          ? (json['price'] as num).toDouble()
          : 0.0,
      calculatedBy: json['calculatedBy'],
      participantCount: (json['participantCount'] != null && json['participantCount'] is int)
          ? json['participantCount']
          : 0,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'date': date.toIso8601String(),
      'price': price,
      'calculatedBy': calculatedBy,
      'participantCount': participantCount,
      'notes': notes,
    };
  }
}
