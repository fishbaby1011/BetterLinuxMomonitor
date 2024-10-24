
# BetterLinuxMomonitor

這是一個用於監控系統資源的 Bash 腳本，當 CPU、記憶體、硬碟或網路流量超過預設的閾值時，會發送通知到 Discord。

## 功能

- 監控 CPU 使用率
- 監控記憶體使用率
- 監控硬碟使用率
- 監控網路流量
- 當資源使用超過設定的閾值時發送 Discord 通知

## 安裝與使用

1. 克隆這個倉庫到你的本地環境：
    ```bash
    git clone https://github.com/你的用戶名/你的倉庫名.git
    cd 你的倉庫名
    ```

2. 設定環境變數來配置 Discord Webhook：
    ```bash
    export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/你的_webhook_URL"
    ```

3. 使腳本可執行並運行：
    ```bash
    chmod +x system_monitor.sh
    ./system_monitor.sh
    ```

## 自定義

你可以修改以下的環境變數來自定義監控的閾值：

- `CPU_THRESHOLD`：CPU 使用率的閾值（預設 70%）
- `MEMORY_THRESHOLD`：記憶體使用率的閾值（預設 70%）
- `DISK_THRESHOLD`：硬碟使用率的閾值（預設 70%）
- `NETWORK_THRESHOLD_GB`：網路流量的閾值（以 GB 為單位，預設 1000 GB）

```bash
export CPU_THRESHOLD=80
export MEMORY_THRESHOLD=80
export DISK_THRESHOLD=80
export NETWORK_THRESHOLD_GB=500
```

## 貢獻

歡迎貢獻代碼！請 fork 這個倉庫，提交 pull request，或者提出 issue。

## 授權

此專案依照 MIT 授權條款發布。請參閱 [LICENSE](LICENSE) 了解更多資訊。
