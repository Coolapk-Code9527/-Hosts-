#!/system/bin/sh
# 不用猜测您的模块将安装在哪
# 如果您需要知道此脚本的位置，请始终使用$MODDIR设置模块
# 如果Magisk将来更改其安装点
# 这将确保您的模块仍能正常工作
MODDIR=${0%/*}

# 该脚本将在late_start服务模式下执行
sleep 20
LH=127.0.0.1
#添加多个名用,隔开
#腾讯
IP=119.39.80.248,58.251.150.40,119.39.80.43,119.39.80.42,58.251.150.31,119.39.120.64,58.251.150.37,119.39.80.56,36.250.8.220
#百度(mss0.bdstatic.com)
IP2=120.83.183.41
iptables -t nat -I OUTPUT -d $IP -j DNAT --to-destination $LH
iptables -t nat -I OUTPUT -d $IP2 -j DNAT --to-destination $LH
#iptables -I OUTPUT -d pgdt.gtimg.cn -j DROP
#iptables -I OUTPUT -m string --string ad. --algo bm -j DROP









