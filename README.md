If ran periodically, this script shows changes in package rankings on pub.dev. 

This script only looks at the current top 300 packages whenever it's ran. 
However, the script doesn't remove packages that have fallen below the 300th spot
since the script was last ran. Therefor, there could be more than 300 packages
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

--- 

Future updates:

- Add computed data to make the json more useful:
  - 'changeSinceLastUpdate' will show the rank increase or decrease each time the script is run
  - 'overAllChange' will show the rank increase or decrease since the first time the package appeared in the data
- Write data to a Google Sheet