class WaterIntake {
  final String id;
  final String userId;
  final DateTime date;
  final double amount; // in milliliters
  final String note;

  WaterIntake({
    required this.id,
    required this.userId,
    required this.date,
    required this.amount,
    this.note = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'amount': amount,
      'note': note,
      'timestamp': DateTime.now().millisecondsSinceEpoch, // Added for sorting
    };
  }

  factory WaterIntake.fromJson(Map<String, dynamic> json) {
    return WaterIntake(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      date: DateTime.parse(json['date']),
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : json['amount']?.toDouble() ?? 0.0,
      note: json['note'] ?? '',
    );
  }
}