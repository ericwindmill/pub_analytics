class Package {
  final String name;

  /// Rank history is descending by date
  final List<Ranking> rankHistory;

  Package({
    required this.name,
    required this.rankHistory,
  });

  void addRankToRankHistory(DateTime date, int currentRank) {
    rankHistory.insert(0, Ranking(date, currentRank));
  }

  int get currentRank => rankHistory.first.rank;

  // DateTime is passed in so all packages that are ranked on any given date
  // have the exact same date time
  factory Package.withCurrentRanking({
    required String packageName,
    required int rank,
    required DateTime now,
  }) {
    final package = Package(name: packageName, rankHistory: [])
      ..addRankToRankHistory(now, rank);
    return package;
  }

  factory Package.fromMap(
    Map<String, dynamic> map,
  ) {
    return Package(
        name: map['name'],
        rankHistory: (map['rankHistory'] as List)
            .map((r) => Ranking.fromMap(r))
            .toList());
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rankHistory': rankHistory.map((r) => r.toMap()).toList()
    };
  }

  @override
  String toString() {
    return 'Package: $name, currentRank: $currentRank';
  }
}

class Ranking {
  final DateTime date;
  final int rank;

  Ranking(this.date, this.rank);

  factory Ranking.fromMap(Map json) {
    final date = DateTime.fromMillisecondsSinceEpoch(json['date'] as int);
    final rank = json['rank'] as int;

    return Ranking(date, rank);
  }

  Map<String, int> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'rank': rank,
    };
  }
}

/// Creates a List of packages from a list of package names, and
/// adds the initial [Ranking] to each [Package.rankHistory].
///
/// This is only used when there is no existing data (the
/// first time this script is run), or if you want to save data to a new file
List<Package> createPackageListFromPub(List<String> orderedPackageNames) {
  final date = DateTime.now();
  final packages = <Package>[];
  for (var i = 0; i < orderedPackageNames.length; i++) {
    packages.add(Package.withCurrentRanking(
      packageName: orderedPackageNames[i],
      now: date,
      rank: i + 1,
    ));
  }

  return packages;
}
