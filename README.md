## Pub analytics

If ran periodically, this script shows changes in package rankings on [pub.dev](https://pub.dev), based on pub's "score", which itself is based on popularity and it's [Pana score](https://pub.dev/packages/pana).

When ran, the script outputs several files as JSON and CSV, which attempt to
assess package ranking changes overtime.

### Rank history and metrics

The script, when ran, adds a new data point to any given packages "rank history", which contains a datetime and ranking. For example, a package's recent history could be:

```
package: {
   rankHistory: [
     { date: 1/1/24, rank: 2 }
     { date: 1/2/24, rank: 4 }
     { date: 1/3/24, rank: 7 }
     .... 
   ]
}
```

The script then uses the existing history to create the following metrics each time a new "ranking" is added to rank history. (All metrics are as of the most recent time the script was run.)
* Current rank 
* Mover score - A weighted average of all other metrics
* All-time low rank
* All-time high rank
* Changes since previous - the distance between the current rank and the rank the last time the script was run
* Overall change - the distance between the package's all-time low and the current rank
* All-time change - the distance between the package's least current rank and the most current rank
* Rank dispersion - a series of data-points that track the number of occurrences of any given rank for a particular package. For example, in the current dataset, as of February 28th, 2024, package `provider`'s rank dispersion looks like this:
  * Rank:4 occurrences:14	
  * Rank:3 occurrences:10	
  * Rank:2 occurrence:1

Many of these metrics are useful because they reveal "bad data". For unknown reasons, there are often sudden, massive swings in the ratings for a single package. For example, the top package is usually `http`. In December 2023, the package fell to 734 for ~2 days, but has otherwise always been #1. Having several metrics which show growth/loss makes it easy to spot bad data. 

## Output files

The script outputs the following files (note that `[filename]` below represents the user defined base filename, which is passed to the script.)

These Json files are not optional. They are essentially the database for the script.
* **[filename].json** - This file will update with new rank history everytime the script is run _with the same filename_. For example, I change the filename every quarter to start a new dataset.
* **alltime_rank_history_data.json** - This file will update everytime the
  script is run with the new ranking data, forever.

The following `txt` files are **optionally generated**, and only need to be generated when you're ready to assess the data.
* **[filename]_history.txt** - This file includes CSV data _only_ for the rank history. It doesn't include any of the metrics that the package creates from the data set (i.e. Overall gain). This file is formatted to optimize for easy chart-making in Google Sheets.
* **[filename]_assessment.txt** - This CSV file includes all the other metrics, but does not include rank history data.
* **alltime_rank_assessment.txt** - This file creates the assessment metrics against the all-time rank data.


## Usage

Ideally, the script is run often and at set intervals (i.e. daily or weekly), to build a robust data set. Then, when you're ready to assess the data, you run the script with the `--csv` flag to generate the appropriate files. 


The generated CSV assessment files looks like this:

```text
Name,Current rank,Change since previous,Overall gain,All time change,All time high,All time low,Most common rank,Most common rank occurrence,Second most common rank,Second most common rank occurrence,Continued...
googleapis_auth,1000,-12,1359,32,973,2359,1032,5,1058,4,1082,2,2312,2,1036,2,1000,1,988,1,973,1,2316,1,2359,1,1086,1,1081,1,1053,1,1050,1,1037,1
shared_preferences,2,0,738,721,1,740,1,12,2,11,740,1,723,1
```

The generated json looks like this:

```json
{
  "name": "http",
  "allTimeHighRanking": 1,
  "allTimeLowRanking": 734,
  "rankHistory": [
    {
      "date": 1709225014616,
      "rank": 1
    },
    {
      "date": 1709060660004,
      "rank": 1
    },
    {
      "date": 1708526151271,
      "rank": 1
    },
    {
      "date": 1707921606669,
      "rank": 1
    },
    {
      "date": 1707316874898,
      "rank": 1
    },
    ...
  ]
}
```

**Note** that `date` is in millisecondsSinceEpoch in the JSON.


```markdown
Usage: pub_analytics.dart [options] [filename]

Fetch pub packages ranked by overall score and write results as JSON to a
[filename].json, preserving historical data if this isn't the first time the
script has been run.

The package can also create metrics based on rank history, and writes results as
CSV file to [filename]_assessment.txt. Rank history is optionally saved as CSV
in a file called called [filename]_history.txt.

[file] doesn't need an extension. If you add one, it will be stripped off.

    --[no-]csv           When true, the script will also generate a CSV file with the data called <filename>_history.txt
-a, --[no-]assessment    When true, the script will also generate a CSV file with computed metrics called <filename>_assessment.txt
-s, --sort-by            [currentRank (default), allTimeChange, recentChange]
-d, --sort-dir           [asc (default), desc]
-c, --count              The number of the top N packages to be included in the dataset. (defaults to "3000")
-p, --[no-]print         Prints the packages with the all-time top 10 movers score. If true, no data will be written to any files. Useful for testing.
--help               Print help text and exit

By default, packages will be sorted by their current ranking, and in ascending order.
```

### Sorting

By default, The script sorts the packages in ascending order by the packages
most recent rank.

You can change the sort order and direction with flags passed to the script.