#install Jot 
#import Pkg; Pkg.add(url="https://github.com/harris-chris/Jot.jl#main")

using GT7CarAlert
using Jot

responder = get_responder(GT7CarAlert, :response_func, Vector{String})
#dependencies=["GT7CarAlert"]
#responder = get_responder("/path/to/project", :response_func, String)
#responder = get_responder("https://github.com/kafisatz/GT7CarAlert.jl", :response_func, Vector)

use_pc = true
use_pc = false
#create_lambda_components
local_image = create_local_image(responder,julia_base_version="1.6.6",package_compile = use_pc)
@edit create_local_image(responder,julia_base_version="1.6.6",package_compile = use_pc)

run_test(local_imagePC, "test", "test Responded")

remote_image = push_to_ecr!(local_imagePC)
lambda = create_lambda_function(remote_image)


