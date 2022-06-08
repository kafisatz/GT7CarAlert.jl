using GT7CarAlert
using DelimitedFiles
using JSON3

#initialization 
pushover_config_file = joinpath(ENV["HOMEPATH"],".pushover","pushover_config.txt")
@assert isfile(pushover_config_file)
pocreds = get_pushover_creds(pushover_config_file)
ret_val = send_notification(pocreds,"Pushover test message from GT7CarAlert.jl script.")
@test ret_val
    
car_list_file = normpath(joinpath(pathof(GT7CarAlert),"..","..","gt7_missing_cars.csv"))
@test isfile(car_list_file)

number_of_seconds_to_sleep = 120
@assert number_of_seconds_to_sleep>0

while true
    try
        main_loop_function(pocreds,car_list_file)
    catch er         
        @show er
        @warn("GT7CarAlert.jl script ran into an error (see message above this line)!\r\nThe script will retry in $(number_of_seconds_to_sleep) seconds:")
    end
    sleep(number_of_seconds_to_sleep)
end

