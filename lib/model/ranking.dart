class Ranking {
  final DateTime date;
  final int rank;

  Ranking(this.date, this.rank);

  factory Ranking.fromMap(Map<String, dynamic> map) {
    final date = DateTime.fromMillisecondsSinceEpoch(map['date'] as int);
    final rank = map['rank'] as int;

    return Ranking(date, rank);
  }

  Map<String, int> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'rank': rank,
    };
  }
}
