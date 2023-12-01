If ran periodically, this script shows changes in package rankings on pub.dev.
This script only looks at the current top 3000 packages whenever it's ran.

Currently, package ranking history is output as both a JSON file and a CSV file.
The JSON is used to compile data that's easy to work with. The CSV file 
can be imported into Google Sheets. 

The CSV looks like this:
```text
Name,All Time High,All Time Low,Change Since Previous,Overall Change,Date,Rank,Date,Rank,Contd...
shared_preferences,1,1,0,0,1/12/2023,1,30/11/2023,1,29/11/2023,1,28/11/2023,1,28/11/2023,1,28/11/2023,1,28/11/2023,1,28/11/2023,1
http,2,2,0,0,1/12/2023,2,30/11/2023,2,29/11/2023,2,28/11/2023,2,28/11/2023,2,28/11/2023,2,28/11/2023,2,28/11/2023,2
```


The json looks like this:
```json
[
  [
    {
      "name": "shared_preferences",
      "allTimeHighRanking": 1,
      "allTimeLowRanking": 1,
      "changeSinceLastRanking": 0,
      "overallChangeInRanking": 0,
      "rankHistory": [
        {
          "date": 1701188922952,
          "rank": 1
        },
        // ... more rankings
      ]
    },
    // ... other packages
]
```
**Note** that `date` is in millisecondsSinceEpoch in the JSON.


## Usage

```markdown
Usage: pub_analytics.dart [options] [filename]

Fetch pub packages ranked by overall score and write results as JSON to a
[filename].json, and writes results as CSV to [filename].txt.

[file] doesn't need an extension. If you add one, it will be stripped off.

-s, --sort-by     [currentRank (default), overallChange, recentChange]
-d, --sort-dir    [asc (default), desc]
--help        Print help text and exit

By default, packages will be sorted by their current ranking, and in ascending order.
```

### Sorting 

By default, The script sorts the packages in ascending order by the packages most recent rank.

You can change the sort order and direction with flags passed to the script.