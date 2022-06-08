# GT7CarAlert.jl
Notification for GT7 Legendary Cars


## Installation
This script requires Julia to be installed, see https://julialang.org/downloads/

```julia
using Pkg
Pkg.add(url=raw"https://github.com/kafisatz/GT7CarAlert.jl")
```

## Configuration

You will need a Pushover account (https://pushover.net/) in order for this script to work properly.

See file https://github.com/kafisatz/GT7CarAlert.jl/blob/main/src/main_script.jl for details how to configure the script.  
You need to amend the entries of `ENV`. 

The file gt7_missing_cars.csv should specify the cars which you are seeking. *Be careful* about special characters in your file.

## Running the script

Once you execute the lines in main_script.jl, specifically `GT7CarAlert.main_script_with_init()` you will trigger an infinite loop that regularly checks the JSON data https://ddm999.github.io/gt7info/data.json, see also https://ddm999.github.io/gt7info/.
You can update "gt7_missing_cars.csv" at any time. It will be read each time the script runs. 

## Notes
Note: the value of 'state' in the JSON data (limited, normal, sold out) is currently ignored. 

## 