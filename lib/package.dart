class Package {
  /// This name comes from pub
  final String name;

  /// Rank history is descending by date
  final List<Ranking> rankHistory;

  int allTimeHighRanking;
  int allTimeLowRanking;

  Package({
    required this.name,
    required this.rankHistory,
    this.allTimeHighRanking = -1,
    this.allTimeLowRanking = -1,
  });

  void addRankToRankHistory(DateTime date, int rank) {
    if (rank > allTimeHighRanking) allTimeHighRanking = rank;
    if (rank < allTimeLowRanking) allTimeLowRanking = rank;

    rankHistory.insert(0, Ranking(date, rank));
  }

  int get currentRank => rankHistory.first.rank;

  int get changeSinceLastRanking {
    if (rankHistory.length < 2) return 0;
    return rankHistory[1].rank - rankHistory[0].rank;
  }

  int get overallChangeInRanking {
    if (rankHistory.length < 2) return 0;
    return rankHistory.last.rank - rankHistory[0].rank;
  }

  // DateTime is passed in so all packages that are ranked on any given date
  // have the exact same date time
  factory Package.fromPub({
    required String packageName,
    required int rank,
    required DateTime now,
  }) {
    final package = Package(
      name: packageName,
      rankHistory: [],
      allTimeHighRanking: rank,
      allTimeLowRanking: rank,
    );
    return package;
  }

  factory Package.fromMap(
    Map<String, dynamic> map,
  ) {
    if (map
        case {
          'name': String name,
          'allTimeHighRanking': int high,
          'allTimeLowRanking': int low,
          'rankHistory': _,
        }) {
      return Package(
        name: name,
        allTimeHighRanking: high,
        allTimeLowRanking: low,
        rankHistory: (map['rankHistory'] as List)
            .map((r) => Ranking.fromMap(r))
            .toList(),
      );
    } else {
      throw "Data is malformed: ${map.toString()}";
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'allTimeHighRanking': allTimeHighRanking,
      'allTimeLowRanking': allTimeLowRanking,
      'changeSinceLastRanking': changeSinceLastRanking,
      'overallChangeInRanking': overallChangeInRanking,
      'rankHistory': rankHistory.map((r) => r.toMap()).toList()
    };
  }

  List<String> toCsvRow() {
    final historyToCsv = <String>[];
    for (var ranking in rankHistory) {
      historyToCsv.addAll(
        [
          '${ranking.date.day}/${ranking.date.month}/${ranking.date.year}',
          ranking.rank.toString(),
        ],
      );
    }

    return [
      name,
      allTimeHighRanking.toString(),
      allTimeLowRanking.toString(),
      changeSinceLastRanking.toString(),
      overallChangeInRanking.toString(),
      ...historyToCsv,
    ];
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

/// Creates a List of packages from a list of package names, and
/// adds the initial [Ranking] to each [Package.rankHistory].
///
/// This is only used when there is no existing data (the
/// first time this script is run), or if you want to save data to a new file
List<Package> createPackageListFromPub(List<String> orderedPackageNames) {
  final date = DateTime.now();
  final packages = <Package>[];
  for (var i = 0; i < orderedPackageNames.length; i++) {
    packages.add(
      Package.fromPub(
        packageName: orderedPackageNames[i],
        now: date,
        rank: i + 1,
      )..addRankToRankHistory(date, i + 1),
    );
  }

  return packages;
}

enum SortDirection {
  asc,
  desc,
}

enum SortPackagesBy {
  currentRank,
  changeSinceLastRanking,
  overallChangeInRanking
}
