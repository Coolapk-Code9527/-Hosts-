#!/system/bin/sh
# 不用猜测您的模块将安装在哪
# 如果您需要知道此脚本的位置，请始终使用$MODDIR设置模块
# 如果Magisk将来更改其安装点
# 这将确保您的模块仍能正常工作
MODDIR=${0%/*}

# 该脚本将在late_start服务模式下执行
sleep 20
# IPTABLES 规则
# 腾讯(添加多个IP用,隔开)
IP=119.39.80.248,58.251.150.40,119.39.80.43,119.39.80.42,58.251.150.31,119.39.120.64,58.251.150.37,119.39.80.56,36.250.8.220
# 百度(mss0.bdstatic.com)
IP2=120.83.183.41
# 屏蔽IP
#iptables -I INPUT -s $IP -j DROP
#iptables -I INPUT -s $IP2 -j DROP
# IP地址重定向
#iptables -t nat -I OUTPUT -d $IP -j DNAT --to-destination 120.0.0.1
# 域名拦截
#iptables -I OUTPUT -d mss0.bdstatic.com -j DROP
# 域名匹配拦截
#iptables -I OUTPUT -m string --string ad. --algo bm --to 65535 -j DROP
# 禁止本地回环连接
#iptables -A INPUT -i lo -j DROP
#iptables -A OUTPUT -o lo -j DROP
# 禁止ICMP ping
#iptables -A INPUT -p icmp -j DROP
#iptables -A OUTPUT -p icmp -j DROP
#iptables -A INPUT -p icmp -m icmp --icmp-type echo-request -j DROP
# 动态IP地址伪装
iptables -t nat -A POSTROUTING -j MASQUERADE
# 开放指定目标端口(DNS端口)
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
# 端口重定向
iptables -t nat -A PREROUTING -p tcp --dport 5353 -j REDIRECT --to-port 53
iptables -t nat -A PREROUTING -p udp --dport 5353 -j REDIRECT --to-port 53
# DNS目标地址重定向
iptables -t nat -I OUTPUT -p tcp --dport 53 -j DNAT --to-destination 223.5.5.5:53
iptables -t nat -I OUTPUT -p udp --dport 53 -j DNAT --to-destination 223.5.5.5:53
iptables -t nat -I PREROUTING -p tcp --dport 53 -j DNAT --to-destination 223.5.5.5:53
iptables -t nat -I PREROUTING -p udp --dport 53 -j DNAT --to-destination 223.5.5.5:53
# 过滤端口无效数据包
iptables -A OUTPUT -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
# 数据包链接检测匹配放行
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# 丢弃Fragments碎片数据包
iptables -A INPUT -f -j DROP
# 丢弃TCP空值数据包
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
# 丢弃不包含—syn初始创建的TCP数据包
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
# 丢弃转发TCP不包含—syn数据包
iptables -A FORWARD -p tcp ! --syn -m state --state NEW -j DROP
# 禁止ACK欺骗(拒绝TCP标记为SYN/ACK但连接状态为NEW的数据包)
iptables -A INPUT -p tcp --tcp-flags SYN,ACK SYN,ACK -m state --state NEW -j DROP
# 丢弃异常的 XMAS 数据包 
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
#丢弃无效的组合标记
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags FIN,ACK FIN -j DROP
# 丢弃无效数据包
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A OUTPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP









