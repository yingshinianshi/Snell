#!/bin/bash

# 检查是否以 root 权限运行
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "请以 root 用户身份运行脚本"
        exit 1
    fi
}

# 安装 Snell 服务端
install_snell_server() {
    echo "下载 Snell 服务端 v4.1.1..."
    curl -Lo snell-server.zip https://dl.nssurge.com/snell/snell-server-v4.1.1-linux-amd64.zip
    unzip snell-server.zip
    chmod +x snell-server
    mv snell-server /usr/local/bin/
    rm snell-server.zip
}

# 创建 Snell 配置文件
create_config() {
    echo "请输入服务器地址（如：example.com 或 IP 地址）:"
    read -r server_address
    echo "请输入服务端端口（默认为 443）:"
    read -r port
    echo "请输入服务端 PSK（密码）:"
    read -r psk
    echo "请输入协议版本（V1、V2、V3、V4，默认 V4）:"
    read -r protocol_version
    echo "请选择是否启用混淆（默认关闭，输入 y 启用）:"
    read -r obfs_enable
    echo "请输入混淆域名（仅在启用混淆时有效）:"
    read -r obfs_domain
    echo "请输入是否启用 IPv6（默认关闭，输入 y 启用）:"
    read -r ipv6_enable
    echo "请输入是否启用 TCP FastOpen（默认关闭，输入 y 启用）:"
    read -r tcp_fastopen

    # 默认值处理
    [ -z "$port" ] && port=443
    [ -z "$protocol_version" ] && protocol_version="V4"
    [ -z "$obfs_enable" ] && obfs_enable="n"
    [ -z "$ipv6_enable" ] && ipv6_enable="n"
    [ -z "$tcp_fastopen" ] && tcp_fastopen="n"

    # 配置文件路径
    config_path="/etc/snell.conf"

    # 生成配置文件
    cat > "$config_path" <<EOF
server = $server_address
port = $port
psk = $psk
protocol_version = $protocol_version
obfs = $obfs_enable
obfs_domain = $obfs_domain
ipv6 = $ipv6_enable
tcp_fastopen = $tcp_fastopen
EOF
}

# 配置 systemd 服务
configure_service() {
    echo "创建 Snell 服务的 systemd 配置..."
    cat > /etc/systemd/system/snell.service <<EOF
[Unit]
Description=Snell Server
After=network.target

[Service]
ExecStart=/usr/local/bin/snell-server -c /etc/snell.conf
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable snell
    systemctl start snell
}

# 主程序
main() {
    check_root
    install_snell_server
    create_config
    configure_service
    echo "Snell 协议服务端 v4.1.1 已成功搭建并运行！"
}

main
