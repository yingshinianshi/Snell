#!/bin/bash

# 自动给脚本赋予执行权限
chmod +x "$0"

# 定义日志输出函数，方便调试
log() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# 获取当前脚本所在目录（用于后续的安装路径）
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SNELL_INSTALL_DIR="/opt/snell"
SNELL_SERVER_FILE="snell-server-v4.1.1-linux-amd64.zip"
SNELL_SERVER_URL="https://dl.nssurge.com/snell/snell-server-v4.1.1-linux-amd64.zip"
CONFIG_FILE="${SNELL_INSTALL_DIR}/config.json"

# 定义菜单
show_menu() {
    clear
    echo "——————————————————————————————"
    echo "1. 安装 Snell Server [v4]"
    echo "2. 卸载 Snell Server"
    echo "——————————————————————————————"
    echo "3. 启动 Snell Server"
    echo "4. 停止 Snell Server"
    echo "5. 重启 Snell Server"
    echo "——————————————————————————————"
    echo "6. 设置 配置信息"
    echo "7. 查看 配置信息"
    echo "8. 查看 运行状态"
    echo "——————————————————————————————"
    echo "9. 退出脚本"
    echo "——————————————————————————————"
}

# 安装 Snell Server
install_snell() {
    log "正在下载 Snell 服务器文件..."
    wget -q --show-progress $SNELL_SERVER_URL -O $SNELL_SERVER_FILE

    log "正在解压 Snell 服务器文件..."
    mkdir -p $SNELL_INSTALL_DIR
    unzip -o $SNELL_SERVER_FILE -d $SNELL_INSTALL_DIR

    log "安装完成，Snell 服务器已安装至 ${SNELL_INSTALL_DIR}"
}

# 卸载 Snell Server
uninstall_snell() {
    if [ -d "$SNELL_INSTALL_DIR" ]; then
        log "正在卸载 Snell 服务器..."
        rm -rf $SNELL_INSTALL_DIR
        log "卸载完成，Snell 服务器已被删除。"
    else
        log "Snell 服务器未安装，无法卸载。"
    fi
}

# 启动 Snell Server
start_snell() {
    if [ -f "$SNELL_INSTALL_DIR/snell-server" ]; then
        log "正在启动 Snell 服务器..."
        nohup $SNELL_INSTALL_DIR/snell-server -c $CONFIG_FILE &
        log "Snell 服务器已启动。"
    else
        log "Snell 服务器未安装，无法启动。"
    fi
}

# 停止 Snell Server
stop_snell() {
    pid=$(ps aux | grep "snell-server" | grep -v "grep" | awk '{print $2}')
    if [ -z "$pid" ]; then
        log "Snell 服务器未运行。"
    else
        log "正在停止 Snell 服务器..."
        kill -9 $pid
        log "Snell 服务器已停止。"
    fi
}

# 重启 Snell Server
restart_snell() {
    stop_snell
    start_snell
}

# 设置配置文件
set_config() {
    read -p "请输入端口号（默认：8388）: " PORT
    PORT=${PORT:-8388}

    read -p "请输入 PSK（Pre-shared key）: " PSK
    read -p "请输入协议版本（默认：v4）: " PROTOCOL_VERSION
    PROTOCOL_VERSION=${PROTOCOL_VERSION:-v4}

    read -p "请输入混淆方式（默认：tls）: " OBFS
    OBFS=${OBFS:-tls}

    read -p "请输入混淆域名（默认：www.example.com）: " OBFS_HOST
    OBFS_HOST=${OBFS_HOST:-www.example.com}

    read -p "是否启用 IPv6（默认：false，true 或 false）: " IPV6
    IPV6=${IPV6:-false}

    read -p "是否启用 TCP FastOpen（默认：true，true 或 false）: " TCP_FASTOPEN
    TCP_FASTOPEN=${TCP_FASTOPEN:-true}

    log "正在生成配置文件..."
    cat > $CONFIG_FILE <<EOF
{
    "listen": "0.0.0.0:${PORT}", 
    "server": "$(curl -s http://ifconfig.me)", 
    "psk": "${PSK}", 
    "protocol": "${PROTOCOL_VERSION}", 
    "obfs": "${OBFS}", 
    "obfs-host": "${OBFS_HOST}", 
    "ipv6": ${IPV6}, 
    "tcp-fast-open": ${TCP_FASTOPEN}
}
EOF
    log "配置文件已生成，配置如下："
    cat $CONFIG_FILE
}

# 查看配置文件
view_config() {
    if [ -f "$CONFIG_FILE" ]; then
        log "配置文件内容："
        cat $CONFIG_FILE
    else
        log "配置文件不存在。"
    fi
}

# 查看运行状态
view_status() {
    pid=$(ps aux | grep "snell-server" | grep -v "grep" | awk '{print $2}')
    if [ -z "$pid" ]; then
        log "Snell 服务器未运行。"
    else
        log "Snell 服务器正在运行，PID: $pid"
    fi
}

# 主菜单循环
while true; do
    show_menu
    read -p "请输入您的选择（1-9）: " choice
    case $choice in
        1) install_snell ;;
        2) uninstall_snell ;;
        3) start_snell ;;
        4) stop_snell ;;
        5) restart_snell ;;
        6) set_config ;;
        7) view_config ;;
        8) view_status ;;
        9) exit 0 ;;
        *) log "无效的选项，请重新选择。" ;;
    esac
done
