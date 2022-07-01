#install Jot 
#import Pkg; Pkg.add(url="https://github.com/harris-chris/Jot.jl#main")

using GT7CarAlert
using Jot

car_list_file = normpath(joinpath(pathof(GT7CarAlert),"..","..","gt7_missing_cars.csv"))
cars_want = read_carlist(car_list_file)
test_inputv = ["mihi","muhi x"]
test_inputv2 = cars_want = read_carlist(car_list_file)
@assert (true,String[]) == GT7CarAlert.response_func(test_inputv)
#the next asswert will depend on the cars actually listed at the current time!
@assert (true,["Ferrari F40 '92", "Jaguar XJ13 '66"]) == GT7CarAlert.response_func(test_inputv2)


responder = get_responder(GT7CarAlert, :response_func, Vector{String})
#dependencies=["GT7CarAlert"]
#responder = get_responder("/path/to/project", :response_func, String)
#responder = get_responder("https://github.com/kafisatz/GT7CarAlert.jl", :response_func, Vector)

import Jot.dockerfile_add_additional_registries
function dockerfile_add_additional_registries(additional_registries::Vector{String})::String
    using_pkg_script = "using Pkg; "
    add_registries_script = begin
      str = ""
      for reg in additional_registries
        str *= "Pkg.Registry.add(RegistrySpec(url = \\\"$(reg)\\\")); "
      end
      str *= "Pkg.Registry.add(\\\"General\\\")"
      str == "" ? str : str * "; "
    end
    pushover_url = "https://github.com/kafisatz/Pushover.jl#master"
    """
    RUN julia -e "import Pkg; Pkg.add(url=\\\"$pushover_url\\\"); $using_pkg_script$add_registries_script\"
    """
  end

use_pc = true
use_pc = false
#create_lambda_components
local_image = create_local_image(responder,julia_base_version="1.6.6",package_compile = use_pc)
#@edit create_local_image(responder,julia_base_version="1.6.6",package_compile = use_pc)

#test1 
run_test(local_image, ["test","mihi x"], (true,String[]))
#the next asswert will depend on the cars actually listed at the current time!
run_test(local_image,test_inputv2,(true,["Ferrari F40 '92", "Jaguar XJ13 '66"]))


show_lambdas()

remote_image = push_to_ecr!(local_image)
lambda = create_lambda_function(remote_image)


