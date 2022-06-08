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

The file gt7_missing_cars.csv should specify the cars which you are seeking. **Be CAREFUL** about special characters in your file.
The script loops over all cars in the legendary shop as follows:
1. "Brand Model" will be considered, e.g. "Porsche 356 A/1500 GS GT Carrera Speedster '56"
2. If the text of any line of your CSV occurs in (as per Julia function `occursin`) that string, it is a match.
3. Thus for the above it is sufficient if you specify 'Porsche 356 A' as an entry in your CSV

## Running the script

Once you execute the lines in main_script.jl, specifically `GT7CarAlert.main_script_with_init()` you will trigger an infinite loop that regularly checks the JSON data https://ddm999.github.io/gt7info/data.json, see also https://ddm999.github.io/gt7info/.
You can update "gt7_missing_cars.csv" at any time. It will be read each time the script runs. 

## Notes
* Note: the value of 'state' in the JSON data (limited, normal, sold out) is currently ignored. 
* For Testing purposes you may want to reduce the value of `ENV["NUMBER_OF_SECONDS_TO_SLEEP"]`.
* For the script to run, you can set this to a high value (such as 7200) as the cars change only daily.
* The code contains a Boolean `detailed`. If you set it to false, fewer details will be printed to the console.

## Outlook
It might be possible to run this script (one single instance on a single computer) and notify multiple users about their individual watch lists. Either, each user could specify their Pushover details, or a single pushover credential could be used. I am not sure about the terms and conditions of Pushover though.

I will leave this for another developer to think about / implement. 