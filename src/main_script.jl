#=
#run the following two lines for first time installation only:
using Pkg
Pkg.add(url=raw"https://github.com/kafisatz/GT7CarAlert.jl")
=#

#run the next line in order to trigger a package update
#using Pkg; Pkg.update()
using Pkg; 
Pkg.activate(".")
@assert VERSION >= v"1.6"
using GT7CarAlert

#example files can be found here
#https://raw.githubusercontent.com/kafisatz/GT7CarAlert.jl/main/pushover_config_example.txt
#https://raw.githubusercontent.com/kafisatz/GT7CarAlert.jl/main/gt7_missing_cars.csv
#hp = ENV["HOMEPATH"]
#ENV["PUSHOVER_CONFIG_GT7"] = joinpath(hp,raw".pushover","pushover_config.txt")
#ENV["CAR_LIST_GT7"] = normpath(joinpath(pathof(GT7CarAlert),"..","..","gt7_missing_cars.csv"))
#This is the number of seconds between each query. As the cars only change daily, a high value of 1 hour (or even considerably more) is sufficient (3600 seconds = 1 hour)
#ENV["NUMBER_OF_SECONDS_TO_SLEEP"] = "3600"
#@assert isfile(ENV["PUSHOVER_CONFIG_GT7"])
#@assert isfile(ENV["CAR_LIST_GT7"])

#run script
GT7CarAlert.main_script_with_init()
