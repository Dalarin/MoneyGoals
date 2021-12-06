const String goal_tablename = "Goals";

class GoalsFields {
  static final List<String> values = [id, title, amount, date, icon, status];
  static const String id = 'id';
  static const String title = 'title';
  static const String amount = 'money_amount';
  static const String date = 'date';
  static const String icon = 'icon';
  static const String status = 'status';
}

class Goals {
  final int? id;
  final String title;
  final String amount;
  final String date;
  final String icon;
  final int status;

  const Goals({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.icon,
    required this.status,
  });

  Map<String, Object?> toJson() => {
        GoalsFields.id: id,
        GoalsFields.title: title,
        GoalsFields.amount: amount,
        GoalsFields.date: date,
        GoalsFields.icon: icon,
        GoalsFields.status: status,
      };

  Goals copy({
    int? id,
    String? title,
    String? amount,
    String? date,
    String? icon,
    int? status,
  }) =>
      Goals(
          id: id ?? this.id,
          title: title ?? this.title,
          amount: amount ?? this.amount,
          date: date ?? this.date,
          icon: icon ?? this.icon,
          status: status ?? this.status);

  static Goals fromJson(Map<String, Object?> json) => Goals(
        id: json[GoalsFields.id] as int?,
        title: json[GoalsFields.title] as String,
        amount: json[GoalsFields.amount] as String,
        date: json[GoalsFields.date] as String,
        icon: json[GoalsFields.icon] as String,
        status: json[GoalsFields.status] as int,
      );
}
