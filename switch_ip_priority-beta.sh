#!/bin/bash

# 定義IPv4和IPv6的設定文件路徑
ipv4_conf_path="/etc/gai.conf"
ipv6_conf_path="/etc/gai.conf"

# 獲取當前IP優先級設置，並顯示在界面上
get_ip_priority () {
    ip_priority=""
    # 遍歷所有網卡
    for iface in $(ip -o link show | awk -F': ' '{print $2}'); do
        ipv4_priority=$(grep -m 1 "^precedence " /etc/gai.conf | grep "$iface" | sed 's/^precedence //' | tr -d '\n')
        if [ "$ipv4_priority" != "" ]; then
            ip_priority="$ip_priority $iface(IPv4:$ipv4_priority)"
        fi
        ipv6_priority=$(grep -m 1 "^label ::ffff:" /etc/gai.conf | grep "$iface" | sed 's/^label ::ffff://' | tr -d '\n')
        if [ "$ipv6_priority" != "" ]; then
            ip_priority="$ip_priority $iface(IPv6:$ipv6_priority)"
        fi
    done
    if [ "$ip_priority" = "" ]; then
        echo "當前未設置IP優先級"
    else
        echo "當前IP協議優先：$ip_priority"
    fi
}

# 切換IP優先級設置
switch_ip_priority () {
    read -p "請輸入要切換的網卡名稱（多個網卡用空格分隔）：" ifaces
    read -p "請選擇要切換的IP協議優先級：1. IPv4優先 2. IPv6優先 3. 退出 " choice
    case $choice in
        1)
            for iface in $ifaces; do
                sed -i "/^# precedence ::ffff:$iface/d" $ipv6_conf_path
                sed -i "/^[^#]*precedence.*$iface\//d" $ipv4_conf_path
                echo "已將網卡 $iface 的IP協議優先設置為：IPv4 > IPv6"
            done
            ;;
        2)
            for iface in $ifaces; do
                sed -i "/^# precedence $iface/d" $ipv4_conf_path
                sed -i "/^[^#]*label ::ffff:$iface/s/^# //" $ipv6_conf_path
                echo "已將網卡 $iface 的IP協議優先設置為：IPv6 > IPv4"
            done
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
