#!/bin/bash

# 定義IPv4和IPv6的優先級值
ipv4_value="100"
ipv6_value="50"

# 確認gai.conf文件存在，否則退出
if [ ! -f /etc/gai.conf ]; then
    echo "File not found: /etc/gai.conf" >&2
    exit 1
fi

# 檢測當前的IP優先級，並顯示結果
current_priority=$(grep -E '^[^#]*precedence' /etc/gai.conf | awk '{print $NF}')
echo "Current IP priority value: ${current_priority}"

# 讓用戶選擇要切換的IP版本
echo "Select which IP version to switch:"
echo "1. IPv4"
echo "2. IPv6"
read -r ip_version_choice

# 根據選擇的IP版本，設置相應的優先級值到gai.conf文件中
if [ "${ip_version_choice}" = "1" ]; then
    sudo sed -i 's/^#precedence ::ffff:0:0.*$/precedence ::ffff:0:0\/96 '${ipv4_value}'/' /etc/gai.conf
    sudo sed -i 's/^precedence ::1.*$/#precedence ::1/' /etc/gai.conf
    echo "IPv4 priority set to ${ipv4_value}"
elif [ "${ip_version_choice}" = "2" ]; then
    sudo sed -i 's/^precedence ::ffff:0:0.*$/#precedence ::ffff:0:0\/96/' /etc/gai.conf
    sudo sed -i 's/^#precedence ::1.*$/precedence ::1 '${ipv6_value}'/' /etc/gai.conf
    echo "IPv6 priority set to ${ipv6_value}"
else
    echo "Invalid choice. Aborting." >&2
    exit 1
fi

# 重新加載gai.conf文件，使更改生效
sudo sysctl -p /etc/sysctl.d/*

# 確認優先級已經修改成功
new_priority=$(grep -E '^[^#]*precedence' /etc/gai.conf | awk '{print $NF}')
echo "New IP priority value: ${new_priority}"

