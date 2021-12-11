const String contributions_tablename = "Contributions";

class ContributionsFields {
  static final List<String> values = [id, id_goal, amount, comment, date];
  static const String id = 'id';
  static const String id_goal = 'id_goal';
  static const String amount = 'amount';
  static const String comment = 'comment';
  static const String date = 'date';
}

class Contributions {
  final int? id;
  final int id_goal;
  final String amount;
  final String comment;
  final String date;

  const Contributions(
      {this.id,
      required this.id_goal,
      required this.amount,
      required this.comment,
      required this.date});
  Map<String, Object?> toJson() => {
        ContributionsFields.id: id,
        ContributionsFields.id_goal: id_goal,
        ContributionsFields.amount: amount,
        ContributionsFields.comment: comment,
        ContributionsFields.date: date,
      };

  Contributions copy({
    int? id,
    int? id_goal,
    String? amount,
    String? comment,
    String? date,
  }) =>
      Contributions(
        id: id ?? this.id,
        id_goal: id_goal ?? this.id_goal,
        amount: amount ?? this.amount,
        comment: comment ?? this.comment,
        date: date ?? this.date,
      );

  static Contributions fromJson(Map<String, Object?> json) => Contributions(
        id: json[ContributionsFields.id] as int?,
        id_goal: json[ContributionsFields.id_goal] as int,
        amount: json[ContributionsFields.amount] as String,
        comment: json[ContributionsFields.comment] as String,
        date: json[ContributionsFields.date] as String,
      );
}
