import Pkg; Pkg.add(url="https://github.com/harris-chris/Jot.jl#main")

responder = get_responder("/path/to/project", :response_func, String)
use_pc = true
use_pc = false
local_imagePC = create_local_image("GT7CarAlert", responder; package_compile = use_pc)
#local_image = create_local_image("GT7CarAlert", responder)
run_test(local_imagePC, "test", "test Responded")

remote_image = push_to_ecr!(local_imagePC)
lambda = create_lambda_function(remote_image)


