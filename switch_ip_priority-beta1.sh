#!/bin/bash

# 获取当前系统所有网卡名称
ifconfig | grep mtu | awk '{print $1}' > ./nics.txt

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
    echo -e "${green}當前可用網卡列表${plain}"
    cat nics.txt
    echo "----------------------------------------"
    if grep -q "precedence 1" /etc/gai.conf; then
        echo -e "${green}當前傾向使用 IPv4${plain}"
    elif grep -q "precedence 2" /etc/gai.conf; then
        echo -e "${green}當前傾向使用 IPv6${plain}"
    else
        echo -e "${green}未設置 IP 協議優先級${plain}"
    fi
    echo "----------------------------------------"
    echo -e "${green}請選擇優先使用的 IP 協議：${plain}"
    echo -e "${green}1.${plain} IPv4"
    echo -e "${green}2.${plain} IPv6"
    echo -e "${green}3.${plain} 退出脚本"
    read -p "請輸入對應數字 [1-3]: " selected_option

    case "$selected_option" in
        1)
            # 设置 IPv4 优先级
            for nic in `cat nics.txt`
            do
                echo "${green}正在將 ${nic} 的 IPv4 優先級提高...${plain}"                
                sed -i "/$nic/!d;s/^\(.*\)$/\1 precedence 1/g" /etc/gai.conf
            done            
            echo "${green}IPv4 優先級設置成功！${plain}"
            ;;
        2)
            # 设置 IPv6 优先级
            for nic in `cat nics.txt`
            do
                echo "${green}正在將 ${nic} 的 IPv6 優先級提高...${plain}"                
                sed -i "/$nic/!d;s/^\(.*\)$/\1 precedence 2/g" /etc/gai.conf
            done            
            echo "${green}IPv6 優先級設置成功！${plain}"
            ;;
        3)
            # 退出脚本
            rm -f ./nics.txt
            exit 0
            ;;
        *)
            # 输入错误提示
            echo -e "${red}輸入錯誤，請重新輸入！${plain}"
            ;;
    esac
done
