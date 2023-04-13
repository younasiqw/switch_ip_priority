#!/bin/bash

# 定义颜色常量
green="\e[32m"
red="\e[31m"
yellow="\e[33m"
plain="\e[0m"

clear

while :
do
    # 显示菜单
    echo -e "${yellow}歡迎使用 IP 協議優先級選擇工具${plain}"
    echo "----------------------------------------"
    echo -e "${green}當前可用網卡列表：${plain}"
    ifconfig | grep mtu | awk '{print $1}'
    echo "----------------------------------------"
    read -p "請輸入要設置 IP 優先級的網卡名稱（例如 eth0）: " selected_nic

    # 檢查輸入的網卡是否存在
    if ! ifconfig | grep -q "$selected_nic"; then
        echo -e "${red}輸入的網卡 ${selected_nic} 不存在，請重新輸入！${plain}"
        continue
    fi

    # 顯示菜單
    echo -e "${yellow}正在設置 ${selected_nic} 的 IP 優先級...${plain}"
    echo "----------------------------------------"
    echo -e "${green}請選擇優先使用的 IP 協議：${plain}"
    echo -e "${green}1.${plain} IPv4"
    echo -e "${green}2.${plain} IPv6"
    echo -e "${green}3.${plain} 取消設置並返回上一級菜單"
    read -p "請輸入對應數字 [1-3]: " selected_option

    # 根據用戶選擇設置對應的優先級
    case "$selected_option" in
        1)
            echo -e "${green}正在將 ${selected_nic} 的 IPv4 優先級提高...${plain}"                
            sed -i "/$selected_nic/!d;s/^\(.*\)$/\1 precedence 1/g" /etc/gai.conf          
            echo -e "${green}${selected_nic} 的 IPv4 優先級設置成功！${plain}"
            ;;
        2)
            echo -e "${green}正在將 ${selected_nic} 的 IPv6 優先級提高...${plain}"                
            sed -i "/$selected_nic/!d;s/^\(.*\)$/\1 precedence 2/g" /etc/gai.conf            
            echo -e "${green}${selected_nic} 的 IPv6 優先級設置成功！${plain}"
            ;;
        3)
            break
            ;;
        *)
            # 輸入錯誤提示
            echo -e "${red}輸入錯誤，請重新輸入！${plain}"
            ;;
    esac
done
