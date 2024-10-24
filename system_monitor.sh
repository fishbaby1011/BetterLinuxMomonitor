
#!/bin/bash

# 設定 Discord Webhook URL (使用環境變數避免洩漏敏感資訊)
DISCORD_WEBHOOK_URL="${DISCORD_WEBHOOK_URL:-https://discord.com/api/webhooks/your_webhook_url}"

# 監控閾值，可以透過環境變數設定
CPU_THRESHOLD=${CPU_THRESHOLD:-70}
MEMORY_THRESHOLD=${MEMORY_THRESHOLD:-70}
DISK_THRESHOLD=${DISK_THRESHOLD:-70}
NETWORK_THRESHOLD_GB=${NETWORK_THRESHOLD_GB:-1000}

# 取得設備資訊
country=$(curl -s ipinfo.io/country)
isp_info=$(curl -s ipinfo.io/org | sed -e 's/"//g' | awk -F' ' '{print $2}')
ipv4_address=$(curl -s ipv4.ip.sb)
masked_ip=$(echo $ipv4_address | awk -F'.' '{print "*."$3"."$4}')

# 發送 Discord 通知的函式
send_discord_notification() {
    local MESSAGE=$1
    if ! curl -H "Content-Type: application/json" -X POST -d "{"content": "$MESSAGE"}" $DISCORD_WEBHOOK_URL; then
        echo "通知發送失敗: $MESSAGE" >> /var/log/system_monitor.log
    fi
}

# CPU 使用率
get_cpu_usage() {
    awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else printf "%.0f
", (($2+$4-u1) * 100 / (t-t1))}'         <(grep 'cpu ' /proc/stat) <(sleep 1; grep 'cpu ' /proc/stat)
}

# 記憶體使用率
get_memory_usage() {
    free | awk '/Mem/ {printf("%.0f"), $3/$2 * 100}'
}

# 硬碟使用率
get_disk_usage() {
    df / | awk 'NR==2 {print $5}' | sed 's/%//'
}

# 取得接收的網路流量（以 GB 為單位）
get_rx_bytes() {
    awk 'BEGIN { rx_total = 0 }
        NR > 2 { rx_total += $2 }
        END {
            printf("%.2f", rx_total / (1024 * 1024 * 1024));
        }' /proc/net/dev
}

# 主迴圈：每 30 秒檢查一次
while true; do
    # CPU 監控
    cpu_usage=$(get_cpu_usage)
    if [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
        message="警告！CPU 使用率已超過 $CPU_THRESHOLD%: 當前使用率 $cpu_usage%"
        send_discord_notification "$message"
    fi

    # 記憶體監控
    memory_usage=$(get_memory_usage)
    if [ "$memory_usage" -gt "$MEMORY_THRESHOLD" ]; then
        message="警告！記憶體使用率已超過 $MEMORY_THRESHOLD%: 當前使用率 $memory_usage%"
        send_discord_notification "$message"
    fi

    # 硬碟監控
    disk_usage=$(get_disk_usage)
    if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
        message="警告！硬碟使用率已超過 $DISK_THRESHOLD%: 當前使用率 $disk_usage%"
        send_discord_notification "$message"
    fi

    # 網路流量監控
    rx_bytes=$(get_rx_bytes)
    if (( $(echo "$rx_bytes > $NETWORK_THRESHOLD_GB" | bc -l) )); then
        message="警告！網路流量已超過 $NETWORK_THRESHOLD_GB GB: 當前流量 $rx_bytes GB"
        send_discord_notification "$message"
    fi

    # 每次迴圈後休眠 30 秒
    sleep 30
done
