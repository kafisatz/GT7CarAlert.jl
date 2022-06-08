module GT7CarAlert

using DelimitedFiles
using Dates
using JSON3
using Pushover

export read_carlist
function read_carlist(car_list_file)
    @assert isfile(car_list_file)
    #carlist = CSV.read(car_list_file, DataFrame,header=false,strict=true,types=String)
    carlist = readdlm(car_list_file,',')
    carlist[1][1]
    if Int(carlist[1][1]) == 65279
        #remove bom
        nx = nextind(carlist[1],1)
        carlist[1] = carlist[1][nx:end]
    end
    @assert in(size(carlist,2),[1,0])
    carlist2 = reshape(carlist,length(carlist))
    carlist3 = convert(Vector{String},carlist2)
    return carlist3
end

export get_cars_currently_at_hagerty 
function get_cars_currently_at_hagerty()
    url = "https://ddm999.github.io/gt7info/data.json"
    fi = download(url)
    json_string = read(fi, String)
    json = JSON3.read(json_string)
    current = json["legend"]["cars"]
    current_BrandModel = map(c->string(c["manufacturer"]," ",c["name"]),current)
    return current,current_BrandModel
end

export match_cars 
function match_cars(current,current_BrandModel,cars_want)
    matched_cars = String[]
    #c = first(current_BrandModel)
    for c in current_BrandModel
        if any(map(x->occursin(lowercase(x),lowercase(c)),cars_want))
            push!(matched_cars,c)
        end
    end

    return matched_cars
end

export print_info
function print_info(cars_want,current_BrandModel,matched_cars,detailed::Bool)
    println(now())
    if detailed
        @info("Cars you seek (length = $(length(cars_want))):")
        println.(cars_want)
        println()

        @info("Cars currently at Hagerty (length = $(length(current_BrandModel))):")
        println.(current_BrandModel)
        println()
    end
    if length(matched_cars) > 0 
        @info("Several cars you want are currently at hagerty (length = $(length(matched_cars))):")
        println.(matched_cars)
        println()
    else 
        @info("No cars you seek are currently being offered by Hagerty.")
        println()
    end

    return nothing
end

export send_notification
function send_notification(pocreds,message::String)
    try
        client = PushoverClient(pocreds["USER_KEY"], pocreds["API_TOKEN"])
        response = Pushover.send(client, message,title = pocreds["TITLE"],priority = pocreds["PRIORITY"])
    catch pushover_er
        @warn("Failed to send pushover message.")
        @show pushover_er
        return false
    end 

    return true
end

export get_pushover_creds 
function get_pushover_creds(pushover_config_file)
    pushover_credentials = readdlm(pushover_config_file,',')

    local key,token
    priority = 0
    title = "GT7 Legendary Car Alert"

    for i=1:size(pushover_credentials,1)
        if uppercase(pushover_credentials[i,1]) =="USER_KEY"
            key = pushover_credentials[i,2]
        end
        if uppercase(pushover_credentials[i,1]) =="API_TOKEN"
            token = pushover_credentials[i,2]        
        end
        if uppercase(pushover_credentials[i,1]) =="PRIORITY"
            priority = pushover_credentials[i,2]        
        end
        if uppercase(pushover_credentials[i,1]) =="TITLE"
            title = pushover_credentials[i,2]        
        end    
    end

    pushoverCONFIG = Dict("USER_KEY" => key,"API_TOKEN" => token,"TITLE" => title,"PRIORITY" => priority)
    return pushoverCONFIG
end

export main_loop_function 
function main_loop_function(pocreds,car_list_file)
#read list of cars
    cars_want = read_carlist(car_list_file)
#read JSON
    current,current_BrandModel = get_cars_currently_at_hagerty()
#matched cars
    matched_cars = match_cars(current,current_BrandModel,cars_want)
#printing
    print_info(cars_want,current_BrandModel,matched_cars,true)
#send out pushover notification
    ret_val = false
    if length(matched_cars)>0
        msg = string("$(length(matched_cars)) cars you seek are available at Hagerty: ",join(matched_cars," ### "))
        ret_val = send_notification(pocreds,msg)
    end

    if length(matched_cars)>0
        return ret_val,matched_cars
    else
        return true,matched_cars
    end
end

export main_script_with_init 
function main_script_with_init()
#=
#activate package (should only be needed when invoking batch file)
using Pkg
Pkg.activate(".")

using GT7CarAlert
using DelimitedFiles
using JSON3
using Pushover
=#

##############################################
#Configuration
##############################################
pushover_config_file = joinpath(ENV["HOMEPATH"],".pushover","pushover_config.txt")
if haskey(ENV,"PUSHOVER_CONFIG_GT7") && isfile(ENV["PUSHOVER_CONFIG_GT7"])
    pushover_config_file = ENV["PUSHOVER_CONFIG_GT7"]
end

car_list_file = normpath(joinpath(pathof(GT7CarAlert),"..","..","gt7_missing_cars.csv"))
if haskey(ENV,"CAR_LIST_GT7") && isfile(ENV["CAR_LIST_GT7"])
    car_list_file = ENV["CAR_LIST_GT7"]
end

default_s = 1800
number_of_seconds_to_sleep = default_s
if haskey(ENV,"NUMBER_OF_SECONDS_TO_SLEEP")
    try 
        number_of_seconds_to_sleep = parse(Int,ENV["NUMBER_OF_SECONDS_TO_SLEEP"])
    catch ero 
        @show ero 
        @info("Unable to parse ENV[\"NUMBER_OF_SECONDS_TO_SLEEP\"]=$(ENV["NUMBER_OF_SECONDS_TO_SLEEP"]) as integer")
        number_of_seconds_to_sleep = default_s
    end
end
@show number_of_seconds_to_sleep

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

return nothing
end

end # module
