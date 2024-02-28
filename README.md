If ran periodically, this script shows changes in package rankings on pub.dev.

When ran, the script will output ranking history to specified JSON file. 

First, the script checks if that JSON file exists. If it does, the script 
loads the existing data and then adds the new ranking data to each packages 
`rankHistory`. Otherwise, it creates the file with the current 
rankings from pub.dev. 

If the `--csv` flag is passed, it also generates a CSV file (from the 
dataset in the JSON file, after it's updated).


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
[filename].json, preserving historical data if this isn't the first time the
script has been run.

The package can also create metrics based on rank history, and writes results as
CSV file to [filename]_assessment.txt. Rank history is optionally saved as CSV
in a file called called [filename]_history.txt.

[file] doesn't need an extension. If you add one, it will be stripped off.

    --[no-]csv    When true, the script will also generate the new CSV file
-s, --sort-by     [currentRank (default), allTimeChange, recentChange]
-d, --sort-dir    [asc (default), desc]
-c, --count       The number of the top N packages to be included in the dataset.
(defaults to "3000")
--help        Print help text and exit

By default, packages will be sorted by their current ranking, and in ascending order.

```

Note: Currently rank history data is always saved in an additional file called 
[filename]_history.txt, it is not optional.

### Sorting 

By default, The script sorts the packages in ascending order by the packages most recent rank.

You can change the sort order and direction with flags passed to the script.