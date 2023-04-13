#!/bin/bash

# 定義IPv4和IPv6的設定文件路徑
ipv4_conf_path="/etc/gai.conf"
ipv6_conf_path="/etc/gai.conf"

# 獲取當前IP優先級設置，並顯示在界面上
get_ip_priority () {
    ip_priority=$(grep -m 1 "^precedence " $ipv4_conf_path | sed 's/^precedence //' | tr -d '\n')
    if [ "$ip_priority" = "" ]; then
        ip_priority=$(grep -m 1 "^label ::ffff:" $ipv6_conf_path | sed 's/^label ::ffff://' | tr -d '\n')
        if [ "$ip_priority" = "" ]; then
            echo "當前未設置IP優先級"
        else
            echo "當前IP協議優先：IPv6 > IPv4"
        fi
    else
        echo "當前IP協議優先：IPv4 > IPv6"
    fi
}

# 切換IP優先級設置
switch_ip_priority () {
    read -p "請選擇要切換的IP協議優先級：1. IPv4優先 2. IPv6優先 3. 退出 " choice
    case $choice in
        1)
            sed -i 's/^\( *\)precedence \([0-9]*\)/\1#precedence \2/g' $ipv4_conf_path
            sed -i 's/^\( *\)label ::ffff:\([0-9]*\)/\1#label ::ffff:\2/g' $ipv6_conf_path
            echo "IP協議優先已設置為：IPv4 > IPv6"
            ;;
        2)
            sed -i 's/^\( *\)precedence \([0-9]*\)/\1#precedence \2/g' $ipv6_conf_path
            sed -i 's/^\( *\)label ::ffff:\([0-9]*\)/\1#label ::ffff:\2/g' $ipv4_conf_path
            echo "IP協議優先已設置為：IPv6 > IPv4"
            ;;
        3)
            exit 0
            ;;
        *)
            echo "選項無效，請重新輸入"
            switch_ip_priority
            ;;
    esac
}

# 主程序
while true; do
    get_ip_priority
    switch_ip_priority
done
