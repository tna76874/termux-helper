# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <ssh_user> <ip_address>"
    exit 1
fi

ssh_username="$1"
ip_address="$2"

ssh_user="${ssh_username}@${ip_address}"

BASEPATH="/data/data/com.termux/files/home/storage/shared"

scpsync() {
ARGPASS=""
for arg in "$@"; do
    ARGPASS+=" "\"${arg}\"
done

while true; do 
eval "rsync -zz -avhs -P --partial --stats --timeout=30 -e \"ssh -p 8022 -o 'StrictHostKeyChecking no'\" $ARGPASS" && break || (echo -e "Error. Wait 5 seconds and repeat ....." && sleep 5)
done
}

exit_code=1
while [ $exit_code -eq 1 ]; do
    ssh -p 8022 ${ssh_user} 'cd /data/data/com.termux/files/home/storage/shared/DCIM/Camera/; bash move.sh'
    exit_code=$?
done

## Define some copy routines ...
#scpsync --ignore-existing "$ssh_user":"$BASEPATH"/DCIM/ ./Handy/

