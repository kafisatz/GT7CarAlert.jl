#activate package (should only be needed when invoking batch file)
using Pkg
Pkg.activate(".")

using GT7CarAlert
using DelimitedFiles
using JSON3
using Pushover

##############################################
#Configuration
##############################################
#EDIT these paths as needed (and delete path the default path definitions below)
#examples
pushover_config_file = raw"C:\some folder\some_file.txt"
car_list_file = raw"C:\some folder\some_file.txt"

pushover_config_file = joinpath(ENV["HOMEPATH"],".pushover","pushover_config.txt")

car_list_file = normpath(joinpath(pathof(GT7CarAlert),"..","..","gt7_missing_cars.csv"))

number_of_seconds_to_sleep = 120

##############################################
#Initialization of script settings
##############################################
@assert isfile(car_list_file)
@assert isfile(pushover_config_file)

pocreds = get_pushover_creds(pushover_config_file)
@assert isa(pocreds,Dict)
@assert haskey(pocreds,"USER_KEY")
@assert haskey(pocreds,"API_TOKEN")

return_value_pushover_test = send_notification(pocreds,"Pushover test message from GT7CarAlert.jl script.")
@show return_value_pushover_test
    
@assert number_of_seconds_to_sleep>0

##############################################
#Start infinite loop
##############################################
while true
    try
        main_loop_function(pocreds,car_list_file)
    catch er         
        @show er
        @warn("GT7CarAlert.jl script ran into an error (see message above this line)!\r\nThe script will retry in $(number_of_seconds_to_sleep) seconds:")
    end
    sleep(number_of_seconds_to_sleep)
end

