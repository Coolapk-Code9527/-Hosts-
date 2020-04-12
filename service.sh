#!/system/bin/sh
# 不用猜测您的模块将安装在哪
# 如果您需要知道此脚本的位置，请始终使用$MODDIR设置模块
# 如果Magisk将来更改其安装点
# 这将确保您的模块仍能正常工作
MODDIR=${0%/*}

# 该脚本将在late_start服务模式下执行
sleep 20
# IP转发,伪装
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.ip_dynaddr=1
# IP(添加多个IP用,隔开)
IP=119.39.80.248,58.251.150.40,119.39.80.43,119.39.80.42,58.251.150.31,119.39.120.64,58.251.150.37,119.39.80.56,36.250.8.220
# 屏蔽IP
#iptables -I INPUT -s $IP -j DROP
# IP地址重定向
#iptables -t nat -I OUTPUT -d $IP -j DNAT --to-destination 120.0.0.1
# 域名拦截
#iptables -I OUTPUT -d mss0.bdstatic.com -j DROP
# 域名匹配拦截
#iptables -I OUTPUT -m string --string ad. --algo bm --to 65535 -j DROP
# 禁止本地回环连接
#iptables -A INPUT -i lo -j DROP
#iptables -A OUTPUT -o lo -j DROP
# 禁止ICMP Ping
#iptables -A INPUT -p 1 -j DROP
#iptables -A OUTPUT -p 1 -j DROP
# 端口匹配放行
iptables -t mangle -A INPUT -p 6 -m multiport --dport 53,5353 -j ACCEPT
iptables -t mangle -A INPUT -p 17 -m multiport --dport 53,5353 -j ACCEPT
iptables -t mangle -A PREROUTING -p 6 -m multiport --dport 53,5353 -j ACCEPT
iptables -t mangle -A PREROUTING -p 17 -m multiport --dport 53,5353 -j ACCEPT
iptables -t mangle -A OUTPUT -p 6 -m multiport --dport 53,5353 -j ACCEPT
iptables -t mangle -A OUTPUT -p 17 -m multiport --dport 53,5353 -j ACCEPT
iptables -t mangle -A FORWARD -p 6 -m multiport --dport 53,5353 -j ACCEPT
iptables -t mangle -A FORWARD -p 17 -m multiport --dport 53,5353 -j ACCEPT
iptables -t mangle -A PREROUTING -p 6 -m multiport --dport 53,5353 -j ACCEPT
iptables -t mangle -A PREROUTING -p 17 -m multiport --dport 53,5353 -j ACCEPT
# 端口匹配标记
iptables -t mangle -A INPUT -p 6 -m multiport --dport 53,5353 -j MARK --set-mark 9527
iptables -t mangle -A INPUT -p 17 -m multiport --dport 53,5353 -j MARK --set-mark 9527
iptables -t mangle -A PREROUTING -p 6 -m multiport --dport 53,5353 -j MARK --set-mark 9527
iptables -t mangle -A PREROUTING -p 17 -m multiport --dport 53,5353 -j MARK --set-mark 9527
iptables -t mangle -A OUTPUT -p 6 -m multiport --dport 53,5353 -j MARK --set-mark 9527
iptables -t mangle -A OUTPUT -p 17 -m multiport --dport 53,5353 -j MARK --set-mark 9527
iptables -t mangle -A FORWARD -p 6 -m multiport --dport 53,5353 -j MARK --set-mark 9527
iptables -t mangle -A FORWARD -p 17 -m multiport --dport 53,5353 -j MARK --set-mark 9527
iptables -t mangle -A POSTROUTING -p 6 -m multiport --dport 53,5353 -j MARK --set-mark 9527
iptables -t mangle -A POSTROUTING -p 17 -m multiport --dport 53,5353 -j MARK --set-mark 9527
# 建立路由策略
ip route flush table 1
ip route add local default dev lo table 1
ip rule add fwmark 9527 table 1 prio 1 lookup 1
#ip rule add from 223.5.5.5 prio 1 lookup 1
#ip rule add to 223.5.5.5 prio 1 lookup 1
ip route flush cache
# 端口匹配重定向
#iptables -t nat -A PREROUTING -p 6 -m multiport ! --dport 0:49151 -j REDIRECT --to-ports 53
#iptables -t nat -A PREROUTING -p 17 -m multiport ! --dport 0:49151 -j REDIRECT --to-ports 53
# DNS目标地址转换
iptables -t nat -A PREROUTING ! -s 223.5.5.5 ! -d 223.5.5.5 -p 6 -m multiport --dport 53,5353 -j DNAT --to-destination 223.5.5.5:53
iptables -t nat -A PREROUTING ! -s 223.5.5.5 ! -d 223.5.5.5 -p 17 -m multiport --dport 53,5353 -j DNAT --to-destination 223.5.5.5:53
iptables -t nat -A OUTPUT ! -s 223.5.5.5 ! -d 223.5.5.5 -p 6 -m multiport --dport 53,5353 -j DNAT --to-destination 223.5.5.5:53
iptables -t nat -A OUTPUT ! -s 223.5.5.5 ! -d 223.5.5.5 -p 17 -m multiport --dport 53,5353 -j DNAT --to-destination 223.5.5.5:53
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -t nat -A POSTROUTING ! -s 223.5.5.5 ! -d 223.5.5.5 -p 6 -m multiport --sport 53,5353 -j SNAT --to-source 223.5.5.5:53
iptables -t nat -A POSTROUTING ! -s 223.5.5.5 ! -d 223.5.5.5 -p 17 -m multiport --sport 53,5353 -j SNAT --to-source 223.5.5.5:53
# 数据包检测匹配放行
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,NEW,RELATED -j ACCEPT
# 丢弃碎片数据包
iptables -A INPUT -f -j DROP
# 丢弃TCP空值数据包
iptables -A INPUT -p 6 --tcp-flags ALL NONE -j DROP
# 丢弃TCP标记为SYN但不是新创建的数据包
iptables -A INPUT -p 6 ! --syn -m state --state NEW -j DROP
# 丢弃TCP标记为SYN/ACK但是新创建的数据包
iptables -A INPUT -p 6 --tcp-flags SYN,ACK SYN,ACK -m state --state NEW -j DROP
# 丢弃TCP标记组合异常的数据包
iptables -A INPUT -p 6 --tcp-flags ALL ALL -j DROP
iptables -A INPUT -p 6 --tcp-flags ALL FIN,PSH,URG -j DROP
iptables -A INPUT -p 6 --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
iptables -A INPUT -p 6 --tcp-flags ALL FIN,URG,PSH -j DROP
iptables -A INPUT -p 6 -m tcp --tcp-flags FIN,ACK FIN -j DROP
iptables -A INPUT -p 6 -m tcp --tcp-flags PSH,ACK PSH -j DROP
iptables -A INPUT -p 6 -m tcp --tcp-flags ACK,URG URG -j DROP
iptables -A INPUT -p 6 -m tcp --tcp-flags FIN,RST FIN,RST -j DROP
iptables -A INPUT -p 6 -m tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
iptables -A INPUT -p 6 -m tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -A INPUT -p 6 -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
iptables -A INPUT -p 6 -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,PSH,URG -j DROP
iptables -A INPUT -p 6 -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,PSH,ACK,URG -j DROP
# 丢弃无效数据包
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A OUTPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP

