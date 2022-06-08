#=
#run the following two lines for first time installation only:
using Pkg
Pkg.add(url=raw"https://github.com/kafisatz/GT7CarAlert.jl")
=#

#run the next line in order to trigger a package update
#using Pkg; Pkg.update(url=raw"https://github.com/kafisatz/GT7CarAlert.jl")

@assert VERSION >= v"1.6"
using GT7CarAlert

#example files can be found here
#https://raw.githubusercontent.com/kafisatz/GT7CarAlert.jl/main/pushover_config_example.txt
#https://raw.githubusercontent.com/kafisatz/GT7CarAlert.jl/main/gt7_missing_cars.csv

ENV["PUSHOVER_CONFIG_GT7"] = raw"C:\Users\bernhard\.pushover\pushover_config.txt"
ENV["CAR_LIST_GT7"] = normpath(joinpath(pathof(GT7CarAlert),"..","..","gt7_missing_cars.csv"))

@assert isfile(ENV["PUSHOVER_CONFIG_GT7"])
@assert isfile(ENV["CAR_LIST_GT7"])

GT7CarAlert.main_script_with_init()