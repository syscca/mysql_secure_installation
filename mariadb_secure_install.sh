#!/bin/bash

# 脚本：MariaDB自动安装和安全配置
# 适用于：Debian 12
# 功能：安装MariaDB并自动执行mysql_secure_installation的配置（无密码版本）

# 确保脚本以root权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "此脚本需要root权限运行，请使用sudo或以root身份运行"
    exit 1
fi

# 更新软件包列表
echo "正在更新软件包列表..."
apt update -y

# 安装MariaDB服务器
echo "正在安装MariaDB服务器..."
apt install -y mariadb-server

# 确保MariaDB服务启动并设置为开机自启
echo "确保MariaDB服务启动并设置为开机自启..."
systemctl start mariadb
systemctl enable mariadb

# 检查MariaDB服务状态
echo "检查MariaDB服务状态..."
systemctl status mariadb

# 自动执行mysql_secure_installation的配置（不设置密码）
echo "执行安全配置（不设置密码）..."

# 应用安全设置（不设置root密码）
mysql -u root <<EOF
-- 删除匿名用户
DELETE FROM mysql.user WHERE User='';

-- 禁止root远程登录
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- 删除测试数据库
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_\%';

-- 刷新权限
FLUSH PRIVILEGES;
EOF

# 验证是否可以无密码登录
echo "验证是否可以无密码登录..."
if mysql -u root -e "SELECT 'MariaDB连接成功！'" &> /dev/null; then
    echo "MariaDB安装和安全配置已成功完成！"
    echo "您可以使用以下命令连接到MariaDB："
    echo "mysql -u root"
    echo "注意：当前配置为无密码登录模式，如需提高安全性，请考虑设置密码。"
else
    echo "MariaDB配置可能出现问题，请检查错误信息。"
fi

echo "脚本执行完毕！"
