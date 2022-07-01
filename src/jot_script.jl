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
local_image = get_local_image("4cbb9184f65c")
local_image = create_local_image(responder,julia_base_version="1.6.6",package_compile = use_pc)
#@edit create_local_image(responder,julia_base_version="1.6.6",package_compile = use_pc)

#test1
#run_test(local_image, ["test","mihi x"], (true,String[]))
run_test(local_image, ["test","mihi x"], [true, Union{}[]])
#the next asswert will depend on the cars actually listed at the current time!
run_test(local_image,test_inputv2,(true,["Ferrari F40 '92", "Jaguar XJ13 '66"]))

show_lambdas()

aws_config = Jot.get_aws_config(local_image)
image_suffix = Jot.get_lambda_name(local_image)
c = Jot.get_ecr_login_script(aws_config, image_suffix)
run(`powershell -Command \" $c\"`)

image = local_image
@edit get_ecr_repo(image)
@edit create_ecr_repo(image)
existing_repo = get_ecr_repo(image)

labels = get_labels(image)
create_script = Jot.get_create_ecr_repo_script(Jot.get_lambda_name(image),Jot.get_aws_region(image),labels,)
create_script = replace(create_script,"\\\n"=>""); create_script = replace(create_script,"\n"=>"")
create_script= replace(create_script,"   "=>" ");create_script = replace(create_script,"  "=>" ")
run(`powershell -Command $create_script`)
repo_json = readchomp(`powershell -Command $create_script`)

"docker push 118565850953.dkr.ecr.region.amazonaws.com/my-repository:tag"
repo = if isnothing(existing_repo)
create_ecr_repo(image)
else
existing_repo
end
push_script = get_image_full_name_plus_tag(image) |> get_docker_push_script
readchomp(`bash -c $push_script`)
all_images = get_all_local_images()
img_idx = findfirst(img -> img.ID[1:docker_hash_limit] == image.ID[1:docker_hash_limit], all_images)
image.Digest = all_images[img_idx].Digest
out = get_remote_image(image)
@debug out
out

@edit push_to_ecr!(local_image)
remote_image = push_to_ecr!(local_image)
lambda = create_lambda_function(remote_image)


