# format the tf files
terraform fmt

# initialize terraform Azure modules
terraform init 

#  plan and save the infra changes into tfplan file
terraform plan -out=tfplan

# show the tfplan file
terraform show -json tfpan
terraform show -json tfpan >> tfplan.json
