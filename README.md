## Pub analytics

If ran periodically, this script shows changes in package rankings on [pub.dev](https://pub.dev), based on pub's "score", which itself is based on popularity and it's [Pana score](https://pub.dev/packages/pana).

When ran, the script outputs several files as JSON and CSV, which attempt to
assess package ranking changes overtime.

### Rank history and metrics

The script, when ran, adds a new data point to any given packages "rank history" and "mover score", both of which contain a datetime and ranking. For example, a single record may look like this.

```json
  {
    "name": "image_picker",
    "allTimeHighRanking": 2,
    "allTimeLowRanking": 2,
    "rankHistory": [
      {
        "date": 1727885891909,
        "rank": 2
      },
      {
        "date": 1727885873687,
        "rank": 2
      }
    ],
    "moverScoreHistory": [
      {
        "date": 1727885891909,
        "rank": 754
      }
    ]
  }
```

The script then uses the existing history to create the following metrics each time a new "ranking" is added to rank history. (All metrics are as of the most recent time the script was run.)
* Current rank 
* Mover score - A weighted average of all other metrics
* All-time low rank
* All-time high rank

The script also calculates the following metrics, but they aren't written to the CSV files.
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

Ideally, the script is run often and at set intervals (i.e. daily or weekly), to build a robust data set. Then, when you're ready to assess the data, you run the script with the `--export` flag to generate the appropriate files.

```
Usage: pub_analytics.dart [options] [filename]

Fetch pub packages ranked by overall score and write results as JSON to a
[filename].json, preserving historical data if this isn't the first time the
script has been run.

The package can also generate metrics based on rank history,
and will optionally write results as CSV files.

The script automatically saves all data to a file all_time_data.json, in
addition to the file name that you pass in. In the future, you can pass in a
new file name, so you can have an 'all time' history and a time boxed history.

See README for more information.

[file] doesn't need an extension. If you add one, it will be stripped off.

    --[no-]export    When true, the script will also generate a CSV file with the data
-c, --count          The number of the top N packages to be included in the dataset.
(defaults to "3000")
-p, --[no-]print     Prints the packages with the all-time top 10 movers score. If true, no data will be written to any files. Useful for testing.
--help           Print help text and exit

By default, packages will be sorted by their current ranking, and in ascending order.
```
