@assert VERSION >= v"1.6"
using Pkg
Pkg.add(url=raw"https://github.com/kafisatz/GT7CarAlert.jl")

using GT7CarAlert

ENV["PUSHOVER_CONFIG_GT7"] = raw"C:\Users\bernhard\.pushover\pushover_config.txt"
ENV["CAR_LIST_GT7"] = normpath(joinpath(pathof(GT7CarAlert),"..","..","gt7_missing_cars.csv"))

@assert isfile(ENV["PUSHOVER_CONFIG_GT7"])
@assert isfile(ENV["CAR_LIST_GT7"])

GT7CarAlert.main_script_with_init()