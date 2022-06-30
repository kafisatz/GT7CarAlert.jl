using Test 
using GT7CarAlert
using DelimitedFiles
using JSON3

@warn("Tests are currently rudimentary")

@testset "Testset polar bear" begin
    #initialization 
    pushover_config_file = joinpath(ENV["HOMEPATH"],".pushover","pushover_config.txt")
    @test isfile(pushover_config_file)
    pocreds = get_pushover_creds(pushover_config_file)
    send_notification(pocreds,"Pushover test message from GT7CarAlert.jl script.")
        
    car_list_file = normpath(joinpath(pathof(GT7CarAlert),"..","..","gt7_missing_cars.csv"))
    @test  isfile(car_list_file)

    #read list of cars
    cars_want = read_carlist(car_list_file)
    @test length(cars_want)>0
        
    #read JSON
    current,current_BrandModel = get_cars_currently_at_hagerty()
    #define a car list, such that some cars must match:
    cars_want = vcat(current_BrandModel[1],current_BrandModel[end])
    tmpfi,io = mktemp()
    writedlm(tmpfi,cars_want)

    rv,matched_cars = compare_carlists(pocreds,tmpfi)
    @test rv
    @test length(matched_cars) == length(cars_want)

    #case where no cars should match
    tmpfi,io = mktemp()
    writedlm(tmpfi,["does_not_exist1","miha"])
    rv,matched_cars = compare_carlists(pocreds,tmpfi)
    @test rv
    @test length(matched_cars) == 0
end