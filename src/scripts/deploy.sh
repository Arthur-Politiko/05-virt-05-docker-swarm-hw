#! /bin/bash
#echo "*** Привет от IaaC! ***"

NET_ID="0"
NET_NAME="net5"
SUBNET_ID="0"
SUBNET_NAME=$(echo "$NET_NAME-sub1")
SUBNET_ZONE="ru-central1-a"
SUBNET_RANGE="10.0.0.0/24"

IMAGE_ID="0"
IMAGE_NAME=""

HOST_NAME=""

TAIL=""

check_vars() {
    [ -n "$YC_CLOUD_ID" ] || { echo "Cloud id is empty"; exit 1; }
    [ -n "$YC_FOLDER_ID" ] || { echo "Folder id is empty"; exit 1; }
    [ -n "$YC_ZONE" ] || { echo "Zone is empty"; exit 1; }    
}

check_cloud_access() {
    return 0
}


get_data_from_table_format() {
    [ -n $1 ] || { echo "#####> Internal error"; exit 1; }

}

create_net() {
    local NETWORK="$( yc vpc network list )"
    #local SUBNET="$( yc vpc subnet list )"
    #echo "$( echo "$NETWORK" |wc -l) "
    #echo "$( echo "$SUBNET" |wc -l) "
    if [ "$( echo "$NETWORK" |wc -l) " -le 4 ]; then
        echo "==> Network is not configured, creating new network...";
        yc vpc network create --name "$NET_NAME" --description "Auto created network $NET_NAME"
        if [ $? -eq 0 ]; then
            echo "==> Network '$NET_NAME' created successfuly"
        else
            echo "==> Failed to create network"
        fi
    else
        echo "==> Network already exist"
    fi
    read -r NET_ID NET_NAME TAIL <<<"$( echo "$NETWORK" |sed -n '4{s/ //g ; s/|/ /g ; p}' )"
    echo "==> Network ID: $NET_ID, Name: $NET_NAME"
    return 0
}

create_subnet() {
    local SUBNET="$( yc vpc subnet list )"
    if [ "$( echo "$SUBNET" |wc -l) " -le 4 ]; then
        echo "==> Subnet is not configured, creating new subnet...";
        yc vpc subnet create --name "$SUBNET_NAME" --network-name "$NET_NAME" --zone "$SUBNET_ZONE" --range "$SUBNET_RANGE" --description "Auto created subnet $SUBNET_NAME"
        if [ $? -eq 0 ]; then
            echo "==> Subnet '$SUBNET_NAME' created successfuly"
        else
            echo "==> Failed to create subnet"
        fi
    else
        echo "==> Subnet already exist"
    fi
    #read -r NET_ID NET_NAME TAIL <<<$( yc vpc net list |sed -n '4{s/ //g ; s/|/ /g ; p}' )
    read -r SUBNET_ID SUBNET_NAME NET_ID SUBNET_RANGE SUBNET_ZONE TAIL <<<"$( echo "$SUBNET" |sed -n '4{s/ //g ; s/||/ 0 /g ; s/|/ /g ; p}' )"
    echo "==> Subnet ID: $SUBNET_ID, Name: $SUBNET_NAME"
    return 0
}

select_image() {
    #echo "========== список доступных образов =========="
    local IMAGES="$( yc compute image list )"
    if [ "$( echo "$IMAGES" |wc -l) " -le 4 ]; then
        echo "==> Images not found. You should set IMAGE_ID. See https://yandex.cloud/ru/docs/compute/operations/image-create/upload"
    else
        local COUNT=$(( $(echo "$IMAGES" |wc -l)  - 4))
        echo "There are $COUNT images. Which one do you want to use?" 

        for i in $( seq 1 $COUNT); do
            read -r IMAGE_ID IMAGE_NAME TAIL <<<"$( echo "$IMAGES" |sed -n "$(($i + 3)){s/ //g ; s/|/ /g ; p}" )"
            echo "  $i) ID: $IMAGE_ID | Name: $IMAGE_NAME"
        done
        echo ""
        read -p "Enter num of image: " SELECTION
        if [[ "$SELECTION" =~ ^[0-9]+$ ]] && [ "$SELECTION" -ge 1 ] && [ "$SELECTION" -le "$COUNT" ]; then
            #echo "$SELECTION"
            # Filling in global vars according to the user's choice
            read -r IMAGE_ID IMAGE_NAME TAIL <<<"$( echo "$IMAGES" |sed -n "$(($SELECTION + 3)){s/ //g ; s/|/ /g ; p}" )"
        else
            echo "Please, select num from 1 to $COUNT" 
        fi
    fi

    return 0
}

create_vm() {
    CMD_RESULT=$( yc compute instance create --name $IMAGE_NAME --hostname $HOST_NAME --zone=$SUBNET_ZONE --create-boot-disk size=20GB,image-id=$YC_IMAGE_ID --cores=2 --memory=2G --core-fraction=20 --network-interface subnet-id=$SUBNET_ID,ipv4-address=auto,nat-ip-version=ipv4 --ssh-key $SSH_PUB )
}

#check_vars
#create_net
#create_subnet
#select_image

#exit 0


# case "$1" in
# 	spawn)
# 		CMD_RESULT=$( yc compute instance create --name "ubuntupc1" --hostname "ubuntupc1" --zone=$ZONE_NAME --create-boot-disk size=20GB,image-id=$YC_IMAGE_ID --cores=2 --memory=2G --core-fraction=20 --network-interface subnet-id=$SUBNET_ID,ipv4-address=auto,nat-ip-version=ipv4 --ssh-key $SSH_PUB )
# 	  	exit 0
# 		;;
# 	*)
# 		echo "Неизвестная команда $1"
# 		;;
# esac