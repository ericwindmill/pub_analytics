import 'dart:convert';

import 'package:test/test.dart';

final csv = [
  [
    'sharedPreferences',
    1,
    1,
    0,
    0,
    'date1',
    'rank1',
  ],
];

final data = '''
[
  {
    "name": "shared_preferences",
    "allTimeHighRanking": 1,
    "allTimeLowRanking": 1,
    "changeSinceLastRanking": 0,
    "overallChangeInRanking": 0,
    "rankHistory": [
      {
        "date": 1701363196491,
        "rank": 1
      },
      {
        "date": 1701277113303,
        "rank": 1
      },
      {
        "date": 1701188922952,
        "rank": 1
      },
      {
        "date": 1701188770177,
        "rank": 1
      },
      {
        "date": 1701187906998,
        "rank": 1
      },
      {
        "date": 1701187868437,
        "rank": 1
      },
      {
        "date": 1701185609772,
        "rank": 1
      }
    ]
  },
  {
    "name": "http",
    "allTimeHighRanking": 2,
    "allTimeLowRanking": 2,
    "changeSinceLastRanking": 0,
    "overallChangeInRanking": 0,
    "rankHistory": [
      {
        "date": 1701363196491,
        "rank": 2
      },
      {
        "date": 1701277113303,
        "rank": 2
      },
      {
        "date": 1701188922952,
        "rank": 2
      },
      {
        "date": 1701188770177,
        "rank": 2
      },
      {
        "date": 1701187906998,
        "rank": 2
      },
      {
        "date": 1701187868437,
        "rank": 2
      },
      {
        "date": 1701185609772,
        "rank": 2
      }
    ]
  }
]
''';

void main() {}
