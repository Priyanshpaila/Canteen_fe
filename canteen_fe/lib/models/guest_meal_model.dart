class GuestMealModel {
  final String id;
  final String guestName;
  final DateTime date;
  final String mealType; // "lunch" or "dinner"
  final bool isPaid;
  final double amount;
  final String markedBy;
  final String? remarks;

  GuestMealModel({
    required this.id,
    required this.guestName,
    required this.date,
    required this.mealType,
    required this.isPaid,
    required this.amount,
    required this.markedBy,
    this.remarks,
  });

  factory GuestMealModel.fromJson(Map<String, dynamic> json) {
    return GuestMealModel(
      id: json['_id'] ?? '',
      guestName: json['guestName'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      mealType: json['mealType'] ?? 'lunch',
      isPaid: json['isPaid'] ?? false,
      amount: (json['amount'] != null && json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : 0.0,
      markedBy: json['markedBy'] ?? '',
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'guestName': guestName,
      'date': date.toIso8601String(),
      'mealType': mealType,
      'isPaid': isPaid,
      'amount': amount,
      'markedBy': markedBy,
      'remarks': remarks,
    };
  }
}
