export main_jot_call
export response_func

function main_jot_call(car_vec::Vector{String})
#=
car_vec=["250 GT Berlinetta passo corto", "Cobra Daytona", "XJ13", "F40", "Fairlady Z 432", "McLaren F1 GTR", "911 GT1 Strassenversion"]
 =#
    pocreds = Dict{String,Any}()
    pocreds["DISABLE_PUSHOVER"] = true
    #@assert isa(pocreds,Dict)

    r = compare_carlists_StringVec(pocreds,car_vec)
    return r 
end

response_func = main_jot_call
