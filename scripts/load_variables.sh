#!/bin/sh
#

function list_ssh_keys {
local result_array=()
local -n return_value=$1

for item in $(aws ec2 describe-key-pairs | jq -r '.KeyPairs[] | .KeyPairId + ":" + .KeyName'); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=$(echo ${result_array[$INPUT]} | cut -d: -f2)
}

function list_subnets {
local result_array=()
local -n return_value=$1

for item in $(aws ec2 describe-subnets | jq -r ".Subnets[] | select( .VpcId == \"$vpc_id\" ) | .SubnetId + \":\" + .CidrBlock + \":\" + (.Tags // [] | map(select(.Key == \"Name\") | .Value) | join(\":\"))"); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=$(echo ${result_array[$INPUT]} | cut -d: -f1)
}

function list_vpc {
local result_array=()
local -n return_value=$1

for item in $(aws ec2 describe-vpcs | jq -r '.Vpcs[] | .VpcId + ":" + .CidrBlock + ":" + (.Tags // [] | map(select(.Key == "Name") | .Value) | join(";"))'); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=$(echo ${result_array[$INPUT]} | cut -d: -f1)
}

function list_sg {
local result_array=()
local -n return_value=$1

for item in $(aws ec2 describe-security-groups | jq -r ".SecurityGroups[] | select( .VpcId == \"$vpc_id\" ) | .GroupId + \":\" + .GroupName" | sed -e 's/ /_/g'); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=$(echo ${result_array[$INPUT]} | cut -d: -f1)
}

function list_priv_keys {
local result_array=()
local -n return_value=$1

for item in $(ls -l -I "*.pub" /home/admin/.ssh/id* /home/admin/.ssh/*.pem | awk '{print $NF}'); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=${result_array[$INPUT]}
}

region_name="us-east-2"
instance_type="t3.medium"
ssh_user="centos"
ssh_key=""
ssh_private_key=""
subnet_id=""
vpc_id=""
security_group_ids=""
root_volume_iops="0"
root_volume_size="50"
root_volume_type="gp3"

aws s3 ls >/dev/null 2>&1
if [ $? -ne 0 ]; then
   echo "Please refresh AWS credentials."
   exit 1
fi

if [ ! -f variables.template ]; then
   echo "Please run the script from the directory with file variables.template."
   exit 1
fi

while getopts "c" opt
do
  case $opt in
    c)
      if [ ! -f variables.clean ]; then
         echo "Sanitized variable files not found."
         exit 1
      fi
      cp variables.clean variables.tf
      exit
      ;;
    \?)
      exit 1
      ;;
  esac
done

echo -n "Configure variables? (y/n) [y]:"
read INPUT
if [ "$INPUT" == "y" -o -z "$INPUT" ]; then

echo -n "region_name [$region_name]: "
read INPUT
if [ -n "$INPUT" ]; then
   region_name=$INPUT
fi
echo -n "instance_type [$instance_type]: "
read INPUT
if [ -n "$INPUT" ]; then
   instance_type=$INPUT
fi

echo -n "ssh_user [$ssh_user]: "
read INPUT
if [ -n "$INPUT" ]; then
   ssh_user=$INPUT
fi

echo "SSH Key:"
list_ssh_keys ssh_key

echo "SSH Private Key file:"
list_priv_keys ssh_private_key

echo "VPC ID:"
list_vpc vpc_id

echo "Subnet ID:"
list_subnets subnet_id

echo "Security Group ID:"
list_sg security_group_ids

echo -n "root_volume_iops [$root_volume_iops]: "
read INPUT
if [ -n "$INPUT" ]; then
   root_volume_iops=$INPUT
fi

echo -n "root_volume_size [$root_volume_size]: "
read INPUT
if [ -n "$INPUT" ]; then
   root_volume_size=$INPUT
fi

echo -n "root_volume_type [$root_volume_type]: "
read INPUT
if [ -n "$INPUT" ]; then
   root_volume_type=$INPUT
fi

echo ""
echo "region_name        : $region_name"
echo "instance_type      : $instance_type"
echo "ssh_user           : $ssh_user"
echo "ssh_key            : $ssh_key"
echo "ssh_private_key    : $ssh_private_key"
echo "subnet_id          : $subnet_id"
echo "vpc_id             : $vpc_id"
echo "security_group_ids : $security_group_ids"
echo "root_volume_iops   : $root_volume_iops"
echo "root_volume_size   : $root_volume_size"
echo "root_volume_type   : $root_volume_type"
echo ""
echo -n "Write these to the variables file? [y/n]: "
read INPUT
if [ "$INPUT" != "y" ]; then
   echo "No changes made."
   exit
fi

ssh_private_key=$(echo "$ssh_private_key" | sed -e 's/\//\\\//g')

sed -e "s/\bREGION_NAME\b/$region_name/" \
    -e "s/\bINSTANCE_TYPE\b/$instance_type/" \
    -e "s/\bSSH_USER\b/$ssh_user/" \
    -e "s/\bSSH_KEY\b/$ssh_key/" \
    -e "s/\bSSH_PRIVATE_KEY\b/$ssh_private_key/" \
    -e "s/\bSUBNET_ID\b/$subnet_id/" \
    -e "s/\bVPC_ID\b/$vpc_id/" \
    -e "s/\bSECURITY_GROUP_IDS\b/$security_group_ids/" \
    -e "s/\bROOT_VOLUME_IOPS\b/$root_volume_iops/" \
    -e "s/\bROOT_VOLUME_SIZE\b/$root_volume_size/" \
    -e "s/\bROOT_VOLUME_TYPE\b/$root_volume_type/" variables.template > variables.tf

echo "File variables.tf written."
fi
