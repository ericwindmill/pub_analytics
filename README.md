If ran periodically, this script shows changes in package rankings on pub.dev.

This script only looks at the current top 3000 packages whenever it's ran. 
However, the script doesn't remove packages that have fallen below the 3000th spot
since the script was last ran. Therefor, there could be more than 3000 packages
in the output data, and not all packages will have the same number of rankings.

Currently, package ranking history is output as a JSON file. 
The json looks like this:

```json lines
[
  {
    "name": "shared_preferences",
    "rankHistory": [
      {
        "date": 1701110153320,
        "rank": 1
      },
      {
        "date": 1701108697905,
        "rank": 1
      },
      // ... more rankings
    ]
  },
  {
    "name": "http",
    "rankHistory": [
      // ... rank history for 'http'
    ]
  }
]
```
**Note** that `date` is in millisecondsSinceEpoch in the JSON.

## Usage

```markdown
Usage: pub_analytics.dart [options] [file]

Fetch pub packages ranked by overall score and write results as JSON to a [file].

By default, packages will be sorted by their current ranking, and in ascending order.

-s, --sort-by     [currentRank (default), overallChange, recentChange]
-d, --sort-dir    [asc (default), desc]
    --help        Print help text and exit
```

### Sorting 

By default, The script sorts the packages in ascending order by the packages most 
recent rank.

You can change the sort order and direction with flags passed to the script.

## Future updates

- Write data to a Google Sheet