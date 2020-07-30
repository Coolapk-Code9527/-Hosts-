#!/system/bin/sh
# 不用猜测您的模块将安装在哪
# 如果您需要知道此脚本的位置，请始终使用$MODDIR设置模块
# 如果Magisk将来更改其安装点
# 这将确保您的模块仍能正常工作
MODDIR=${0%/*}

# 该脚本将在late_start服务模式下执行
sleep 20
while true; do

ipv4dns=`cat $MODDIR/ipv4dns.prop | awk '!/#/ {print $NF}' | cut -d "=" -f 2`
ipv6dns=`cat $MODDIR/ipv6dns.prop | awk '!/#/ {print $NF}' | cut -d "=" -f 2`
ipv4dnsovertls=`cat $MODDIR/ipv4dnsovertls.prop | awk '!/#/ {print $NF}' | cut -d "=" -f 2`
ipv6dnsovertls=`cat $MODDIR/ipv6dnsovertls.prop | awk '!/#/ {print $NF}' | cut -d "=" -f 2`
AndroidSDK=`getprop ro.build.version.sdk`
dotmode=`settings get global private_dns_mode`

if [[ -s $MODDIR/ipv4dns.prop ]];then
for dns in $ipv4dns ;do
    setsid ping -c 60 -w 6 -A -q $dns >> $MODDIR/ipv4dns.log
    sleep 0.2
done
fi

    ip6tables -t nat -nL >/dev/null 2>&1
if [[ $? -eq 0 && -s $MODDIR/ipv6dns.prop ]];then
for dnss in $ipv6dns; do
    setsid ping6 -c 60 -A -w 6 -q $dnss >> $MODDIR/ipv6dns.log
    sleep 0.2
done
fi

if [[ $AndroidSDK -ge "28" && $dotmode != "" && -s $MODDIR/ipv4dnsovertls.prop ]];then
for dot in $ipv4dnsovertls; do
    setsid ping -c 60 -A -w 6 -q $dot >> $MODDIR/ipv4dnsovertls.log
    sleep 0.2
done
fi

if [[ $AndroidSDK -ge "28" && $dotmode != "" && -s $MODDIR/ipv6dnsovertls.prop ]];then
for dots in $ipv6dnsovertls; do
    setsid ping -c 60 -A -w 6 -q $dots >> $MODDIR/ipv6dnsovertls.log
    sleep 0.2
done
fi

avg=`cat $MODDIR/ipv4dns.log | grep 'min/avg/max' | cut -d "=" -f 2 | cut -d "/" -f 2 | awk '{print $1}' | sort -n | awk 'NR==1{print $1}' `
ewma=`cat $MODDIR/ipv4dns.log | grep -w 'ipg/ewma' | awk '{print $(NF-1)}' | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
dnsavg=`cat $MODDIR/ipv4dns.log | grep -B 2 $avg | awk 'NR==1{print $2}' `
dnsewma=`cat $MODDIR/ipv4dns.log | grep -B 2 $ewma | awk 'NR==1{print $2}' `

if [[ $dnsavg != "" ]];then
    iptables -t nat -F OUTPUT
    iptables -t nat -F POSTROUTING
    iptables -t nat -A OUTPUT -p tcp --dport 5353 -j REDIRECT --to-ports 53
    iptables -t nat -A OUTPUT -p udp --dport 5353 -j REDIRECT --to-ports 53
    iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination $dnsavg:53
    iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination $dnsavg:53
    iptables -t nat -A POSTROUTING -j MASQUERADE
elif [[ $dnsewma != "" ]];then
    iptables -t nat -F OUTPUT
    iptables -t nat -F POSTROUTING
    iptables -t nat -A OUTPUT -p tcp --dport 5353 -j REDIRECT --to-ports 53
    iptables -t nat -A OUTPUT -p udp --dport 5353 -j REDIRECT --to-ports 53
    iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination $dnsewma:53
    iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination $dnsewma:53
    iptables -t nat -A POSTROUTING -j MASQUERADE
fi

ipv6avg=`cat $MODDIR/ipv6dns.log | grep 'min/avg/max' | cut -d "=" -f 2 | cut -d "/" -f 2 | awk '{print $1}' | sort -n | awk 'NR==1{print $1}' `
ipv6ewma=`cat $MODDIR/ipv6dns.log | grep -w 'ipg/ewma' | awk '{print $(NF-1)}' | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
ipv6dnsavg=`cat $MODDIR/ipv6dns.log | grep -B 2 $ipv6avg | awk 'NR==1{print $2}' `
ipv6dnsewma=`cat $MODDIR/ipv6dns.log | grep -B 2 $ipv6ewma | awk 'NR==1{print $2}' `

if [[ $ipv6dnsavg != "" ]];then
    ip6tables -t nat -F OUTPUT
    ip6tables -t nat -F POSTROUTING
    ip6tables -t nat -A OUTPUT -p tcp --dport 5353 -j REDIRECT --to-ports 53
    ip6tables -t nat -A OUTPUT -p udp --dport 5353 -j REDIRECT --to-ports 53
    ip6tables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination $ipv6dnsavg:53
    ip6tables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination $ipv6dnsavg:53
    ip6tables -t nat -A POSTROUTING -j MASQUERADE
elif [[ $ipv6dnsavg != "" ]];then
    ip6tables -t nat -F OUTPUT
    ip6tables -t nat -F POSTROUTING
    ip6tables -t nat -A OUTPUT -p tcp --dport 5353 -j REDIRECT --to-ports 53
    ip6tables -t nat -A OUTPUT -p udp --dport 5353 -j REDIRECT --to-ports 53
    ip6tables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination $ipv6dnsewma:53
    ip6tables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination $ipv6dnsewma:53
    ip6tables -t nat -A POSTROUTING -j MASQUERADE
fi

dotavg=`cat $MODDIR/ipv4dnsovertls.log | grep 'min/avg/max' | cut -d "=" -f 2 | cut -d "/" -f 2 | awk '{print $1}' | sort -n | awk 'NR==1{print $1}' `
dotewma=`cat $MODDIR/ipv4dnsovertls.log | grep -w 'ipg/ewma' | awk '{print $(NF-1)}' | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
dotdnsavg=`cat $MODDIR/ipv4dnsovertls.log | grep -B 2 $dotavg | awk 'NR==1{print $2}' `
dotdnsewma=`cat $MODDIR/ipv4dnsovertls.log | grep -B 2 $dotewma | awk 'NR==1{print $2}' `
ipv6dotavg=`cat $MODDIR/ipv6dnsovertls.log | grep 'min/avg/max' | cut -d "=" -f 2 | cut -d "/" -f 2 | awk '{print $1}' | sort -n | awk 'NR==1{print $1}' `
ipv6dotewma=`cat $MODDIR/ipv6dnsovertls.log | grep -w 'ipg/ewma' | awk '{print $(NF-1)}' | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
ipv6dotdnsavg=`cat $MODDIR/ipv6dnsovertls.log | grep -B 2 $ipv6dotavg | awk 'NR==1{print $2}' `
ipv6dotdnsewma=`cat $MODDIR/ipv6dnsovertls.log | grep -B 2 $ipv6dotewma | awk 'NR==1{print $2}' `

if [[ $AndroidSDK -ge "28" && $dotmode != "" && $dotdnsavg != "" ]];then

    [[ `echo "$dotavg > $ipv6dotavg" | bc` -eq 1 ]] && settings put global private_dns_specifier $ipv6dotdnsavg || settings put global private_dns_specifier $dotdnsavg

elif [[ $AndroidSDK -ge "28" && $dotmode != "" && $dotdnsewma != "" ]];then

    [[ `echo "$dotewma > $ipv6dotewma" | bc` -eq 1 ]] && settings put global private_dns_specifier $ipv6dotdnsewma || settings put global private_dns_specifier $dotdnsewma

fi

echo > $MODDIR/ipv4dns.log
echo > $MODDIR/ipv6dns.log
echo > $MODDIR/ipv4dnsovertls.log
echo > $MODDIR/ipv6dnsovertls.log
sleep 3m
reset
done


