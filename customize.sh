##########################################################################################
#
# Magisk模块自定义安装脚本
#
##########################################################################################


##########################################################################################
# 替换列表
##########################################################################################

# 列出要在系统中直接替换的所有目录
# 您可以在变量名中声明要直接替换的文件夹列表REPLACE。模块安装程序脚本将提取此变量并为您创建文件.replace。

# 按以下格式构建替换列表
# 示例
REPLACE_EXAMPLE="
/system/app/YouTube
/system/app/Bloatware
"
#上面的替换列表将导致创建以下文件：
#$MODPATH/system/app/YouTube/.replace
#$MODPATH/system/app/Bloatware/.replace

# 在这里构建自定义替换列表
REPLACE="
"

##########################################################################################
# 脚本内容
##########################################################################################
starttime=`date +"%Y-%m-%d %H:%M:%S"`
hosts=$MODPATH/system/etc/hosts
ModulesPath=/data/adb/modules
count=`wc -l $hosts | awk '{print $1}'`
usage=`du -h $hosts | awk '{print $1}'`
usageAB=`du $hosts | awk '{print $1}'`
modifytime=`unzip -v $ZIPFILE | grep 'system/etc/hosts' | awk 'NR==1{print $5}' | sed -r 's/(.*)-(.*)-(.*)$/\3-\1-\2/'`
systemavailC=`df /system | awk 'NR==2{print $4}'`
systemavailD=`df /system | awk 'NR==3{print $3}'`
system_examineA=`df -h /system | awk 'NR==2{print "大小："$2"  已用："$3"  剩余："$4"  占用率："$5""}'`
system_examineB=`df -h /system | awk 'NR==3{print "大小："$1"  已用："$2"  剩余："$3"  占用率："$4""}'`

  [[ -d $ModulesPath/dnss && ! -f $ModulesPath/dnss/disable ]] && ui_print "- 本模块已支持DNS更改,无需再使用其他DNS模块❗"
  [[ ! -f /system/xbin/busybox && ! -f /system/bin/busybox ]] && ui_print "- 未检测到[busybox]模块,许多Linux命令将不能被执行,可能会发生错误‼️"
  hostsTesting=`find $ModulesPath -name "hosts" | grep -v 'hostsjj' | awk 'NR==1'`
  [[ -e "$hostsTesting" ]] && ui_print "- 检测到已安装有其他hosts模块,请将其停用或卸载,不然可能会有冲突导致此模块hosts无法生效‼️"
  echoprint=' ------------------------------------------------------ '
  ui_print "$echoprint"
  ui_print "- 安装过程可能需较长的时间,请耐心等待……"
  ui_print "$echoprint"
  
  ui_print "- 【hosts文件】"
  ui_print "大小：$usage  行数：$count 行  修改日期：$modifytime"
  ui_print "$echoprint"
if [[ "$system_examineB" = "" ]];then
  ui_print "- 【system分区】"
  ui_print "$system_examineA"
  [[ "$systemavailC > $usageAB" ]] || ui_print "- 【system分区】剩余空间小于模块【hosts文件】大小,可能会发生错误‼️"
  ui_print "$echoprint"
elif [[ "$?" -ne 0 ]];then
  ui_print "- 【system分区】"
  ui_print "$system_examineB"
  [[ "$systemavailD > $usageAB" ]] || ui_print "- 【system分区】剩余空间小于模块【hosts文件】大小,可能会发生错误‼️"
  ui_print "$echoprint"
fi

  ui_print "- 【清除应用Cache】"
clearA=/data/data/*/cache/*
clearB=/data/media/0/Android/data/*/cache/*
clearU=/data/user_de/0/*/cache/*
if [[ -d /data/media/0/miad ]];then
rm -rf /data/media/0/miad/* >/dev/null 2>&1
chmod 000 /data/media/0/miad >/dev/null 2>&1
fi
findcacheA=`du -csk $clearA | awk 'END{print $(NF-1)}' | sed 's/[a-zA-Z]//g'`
findcacheB=`du -csk $clearB | awk 'END{print $(NF-1)}' | sed 's/[a-zA-Z]//g'`
findcacheU=`du -csk $clearU | awk 'END{print $(NF-1)}' | sed 's/[a-zA-Z]//g'`
findcacheAB=`echo | awk "{print ($findcacheA+$findcacheB+$findcacheU)/1024}"`
if `find --help >/dev/null 2>&1` && `xargs --help >/dev/null 2>&1` ;then
find $clearA $clearB $clearU | xargs rm -rf {} \ >/dev/null 2>&1
findcacheB=`du -csk $clearA | awk 'END{print $(NF-1)}' | sed 's/[a-zA-Z]//g'`
findcacheC=`du -csk $clearB | awk 'END{print $(NF-1)}' | sed 's/[a-zA-Z]//g'`
findcacheU=`du -csk $clearU | awk 'END{print $(NF-1)}' | sed 's/[a-zA-Z]//g'`
findcacheBC=`echo | awk "{print ($findcacheB+$findcacheC+$findcacheU)/1024}"`
findcacheDC=`echo | awk "{print $findcacheAB-$findcacheBC}" | awk '{printf("%.f\n",$1)}'`
  ui_print "清除：${findcacheDC} M"
  ui_print "$echoprint"
else
  ui_print "清理失败,缺少[find/xargs]工具支持,请安装[BusyBox]模块!"
  ui_print "$echoprint"
fi

  ui_print "- 【根据当前网络环境选择DNS】"
  
[ -f $TMPDIR/ipv4dns.prop ] && cp -af $TMPDIR/ipv4dns.prop $MODPATH/ipv4dns.prop
[ -f $TMPDIR/ipv6dns.prop ] && cp -af $TMPDIR/ipv6dns.prop $MODPATH/ipv6dns.prop
[ -f $TMPDIR/ipv4dnsovertls.prop ] && cp -af $TMPDIR/ipv4dnsovertls.prop $MODPATH/ipv4dnsovertls.prop
[ -f $TMPDIR/ipv6dnsovertls.prop ] && cp -af $TMPDIR/ipv6dnsovertls.prop $MODPATH/ipv6dnsovertls.prop
ipv4dns=`cat $MODPATH/ipv4dns.prop | awk '!/#/ {print $NF}' | cut -d "=" -f 2`
ipv6dns=`cat $MODPATH/ipv6dns.prop | awk '!/#/ {print $NF}' | cut -d "=" -f 2`
ipv4dnsovertls=`cat $MODPATH/ipv4dnsovertls.prop | awk '!/#/ {print $NF}' | cut -d "=" -f 2`
ipv6dnsovertls=`cat $MODPATH/ipv6dnsovertls.prop | awk '!/#/ {print $NF}' | cut -d "=" -f 2`
AndroidSDK=`getprop ro.build.version.sdk`
dotmode=`settings get global private_dns_mode`
iptdnsTesting=`iptables -t nat -nL OUTPUT --line-numbers | grep 'dpt:53 ' | awk 'NR==1{print $(NF)}' | cut -d ':' -f 2- | cut -d ':' -f 1`
ipt6dnsTesting=`ip6tables -t nat -nL OUTPUT --line-numbers | grep 'dpt:53 ' | awk 'NR==1{print $(NF)}' | cut -d ':' -f 2- | sed 's/\:53//g'`

[[ "$iptdnsTesting" != "" ]] && iptables -t nat -F OUTPUT >/dev/null 2>&1
[[ "$ipt6dnsTesting" != "" ]] && ip6tables -t nat -F OUTPUT >/dev/null 2>&1
sync
if [[ -s $MODPATH/ipv4dns.prop ]];then
for dns in $ipv4dns; do
    setsid ping -c 5 -A -w 1 $dns >> $MODPATH/ipv4dns.log
    sleep 0.2
done
fi

ip6tables -t nat -nL >/dev/null 2>&1
if [[ "$?" -eq 0 && -s $MODPATH/ipv6dns.prop ]];then
for dnss in $ipv6dns; do
    setsid ping6 -c 5 -A -w 1 $dnss >> $MODPATH/ipv6dns.log
    sleep 0.2
done
fi

if [[ "$AndroidSDK" -ge "28" && "$dotmode" != "" && -s $MODPATH/ipv4dnsovertls.prop ]];then
for dot in $ipv4dnsovertls; do
    setsid ping -c 5 -A -w 1 $dot >> $MODPATH/ipv4dnsovertls.log
    sleep 0.2
done
fi

if [[ "$AndroidSDK" -ge "28" && "$dotmode" != "" && -s $MODPATH/ipv6dnsovertls.prop ]];then
for dots in $ipv6dnsovertls; do
    setsid ping6 -c 5 -A -w 1 $dots >> $MODPATH/ipv6dnsovertls.log
    sleep 0.2
done
fi

avg=`cat $MODPATH/ipv4dns.log | grep 'min/avg/max' | cut -d "=" -f 2 | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
ewma=`cat $MODPATH/ipv4dns.log | grep -w 'ipg/ewma' | sed 's/.*ipg\/ewma//g' | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
avgtest=`echo $avg | awk -F"/" '{printf("%.f\n",$2)}' `
ewmatest=`echo $ewma | awk -F"/" '{printf("%.f\n",$2)}' `
dnsavg=`cat $MODPATH/ipv4dns.log | grep -B 2 "$avg" | awk 'NR==1{print $2}' `
dnsewma=`cat $MODPATH/ipv4dns.log | grep -B 2 "$ewma" | awk 'NR==1{print $2}' `
avgname=`cat $MODPATH/ipv4dns.prop | grep "$dnsavg" | cut -d "=" -f 1`
ewmaname=`cat $MODPATH/ipv4dns.prop | grep "$dnsewma" | cut -d "=" -f 1`

if [[ "$dnsavg" != "" && "$avgtest" -lt 150 ]];then
    iptables -t nat -F OUTPUT
    iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination $dnsavg:53
    iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination $dnsavg:53
    ui_print "IPV4_DNS：[$avgname] $dnsavg "
elif [[ "$dnsewma" != "" && "$ewmatest" -lt 150 ]];then
    iptables -t nat -F OUTPUT
    iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination $dnsewma:53
    iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination $dnsewma:53
    ui_print "IPV4_DNS：[$ewmaname] $dnsewma "
else
    iptables -t nat -F OUTPUT
fi

ipv6avg=`cat $MODPATH/ipv6dns.log | grep 'min/avg/max' | cut -d "=" -f 2 | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
ipv6ewma=`cat $MODPATH/ipv6dns.log | grep -w 'ipg/ewma' | sed 's/.*ipg\/ewma//g' | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
ipv6avgtest=`echo $ipv6avg | awk -F"/" '{printf("%.f\n",$2)}' `
ipv6ewmatest=`echo $ipv6ewma | awk -F"/" '{printf("%.f\n",$2)}' `
ipv6dnsavg=`cat $MODPATH/ipv6dns.log | grep -B 2 "$ipv6avg" | awk 'NR==1{print $2}' `
ipv6dnsewma=`cat $MODPATH/ipv6dns.log | grep -B 2 "$ipv6ewma" | awk 'NR==1{print $2}' `
ipv6avgname=`cat $MODPATH/ipv6dns.prop | grep "$ipv6dnsavg" | cut -d "=" -f 1`
ipv6ewmaname=`cat $MODPATH/ipv6dns.prop | grep "$ipv6dnsewma" | cut -d "=" -f 1`

if [[ "$ipv6dnsavg" != "" && "$ipv6avgtest" -lt 150 ]];then
    ip6tables -t nat -F OUTPUT
    ip6tables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination $ipv6dnsavg:53
    ip6tables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination $ipv6dnsavg:53
    ui_print "IPV6_DNS：[$ipv6avgname] $ipv6dnsavg "
elif [[ "$ipv6dnsewma" != "" && "$ipv6ewmatest" -lt 150 ]];then
    ip6tables -t nat -F OUTPUT
    ip6tables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination $ipv6dnsewma:53
    ip6tables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination $ipv6dnsewma:53
    ui_print "IPV6_DNS：[$ipv6ewmaname] $ipv6dnsewma "
else
    ip6tables -t nat -F OUTPUT
fi

dotavg=`cat $MODPATH/ipv4dnsovertls.log | grep 'min/avg/max' | cut -d "=" -f 2 | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
dotewma=`cat $MODPATH/ipv4dnsovertls.log | grep -w 'ipg/ewma' | sed 's/.*ipg\/ewma//g' | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
dotavgtest=`echo $dotavg | awk -F"/" '{printf("%.f\n",$2)}' `
dotewmatest=`echo $dotewma | awk -F"/" '{printf("%.f\n",$2)}' `
dotdnsavg=`cat $MODPATH/ipv4dnsovertls.log | grep -B 2 "$dotavg" | awk 'NR==1{print $2}' `
dotdnsewma=`cat $MODPATH/ipv4dnsovertls.log | grep -B 2 "$dotewma" | awk 'NR==1{print $2}' `
ewmadotRoundTripTime=`cat $MODPATH/ipv4dnsovertls.log | grep -o 'ipg/ewma' | awk 'NR==1' `
dotRoundTripTime=`cat $MODPATH/ipv4dnsovertls.log | grep -oE "min\/avg\/max|min\/avg\/max\/mdev" | awk 'NR==1' | sed 's/min/最低值/g;s/avg/平均值/g;s/max/最高值/g;s/mdev/平均偏差/g' `
ipv6dotavg=`cat $MODPATH/ipv6dnsovertls.log | grep 'min/avg/max' | cut -d "=" -f 2 | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
ipv6dotewma=`cat $MODPATH/ipv6dnsovertls.log | grep -w 'ipg/ewma' | sed 's/.*ipg\/ewma//g' | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
ipv6dotavgtest=`echo $ipv6dotavg | awk -F"/" '{printf("%.f\n",$2)}' `
ipv6dotewmatest=`echo $ipv6dotewma | awk -F"/" '{printf("%.f\n",$2)}' `
ipv6dotdnsavg=`cat $MODPATH/ipv6dnsovertls.log | grep -B 2 "$ipv6dotavg" | awk 'NR==1{print $2}' `
ipv6dotdnsewma=`cat $MODPATH/ipv6dnsovertls.log | grep -B 2 "$ipv6dotewma" | awk 'NR==1{print $2}' `

if [[ "$ipv6dotdnsavg" != "" && "$dotavgtest" -gt "$ipv6dotavgtest" && "$ipv6dotavgtest" -lt 150 ]];then
    ui_print "$echoprint"
    ui_print "- 【系统支持DNS Over TLS】"
    settings put global private_dns_specifier $ipv6dotdnsavg
    dotspecifier=`settings get global private_dns_specifier`
    dotavgname=`cat $MODPATH/ipv4dnsovertls.prop | grep "$dotspecifier" | cut -d "=" -f 1`
    ipv6dotavgname=`cat $MODPATH/ipv6dnsovertls.prop | grep "$dotspecifier" | cut -d "=" -f 1`
    ui_print "DNS_Over_TLS：[$ipv6dotavgname] $dotspecifier "
    [[ "$dotspecifier" = 'dns.cfiec.net' ]] && ui_print "此DNS服务商仅支持IPV6网络❗"
elif [[ "$dotdnsavg" != "" && "$dotavgtest" -lt 150 ]];then
    ui_print "$echoprint"
    ui_print "- 【系统支持DNS Over TLS】"
    settings put global private_dns_specifier $dotdnsavg
    dotspecifier=`settings get global private_dns_specifier`
    dotavgname=`cat $MODPATH/ipv4dnsovertls.prop | grep "$dotspecifier" | cut -d "=" -f 1`
    ipv6dotavgname=`cat $MODPATH/ipv6dnsovertls.prop | grep "$dotspecifier" | cut -d "=" -f 1`
    ui_print "DNS_Over_TLS：[$dotavgname] $dotspecifier "
    [[ "$dotspecifier" = 'dns.cfiec.net' ]] && ui_print "此DNS服务商仅支持IPV6网络❗"
elif [[ "$ipv6dotdnsewma" != "" && "$dotewmatest" -gt "$ipv6dotewmatest" && "$ipv6dotewmatest" -lt 150 ]];then
    ui_print "$echoprint"
    ui_print "- 【系统支持DNS Over TLS】"
    settings put global private_dns_specifier $ipv6dotdnsewma
    dotspecifier=`settings get global private_dns_specifier`
    dotewmaname=`cat $MODPATH/ipv4dnsovertls.prop | grep "$dotspecifier" | cut -d "=" -f 1`
    ipv6dotewmaname=`cat $MODPATH/ipv6dnsovertls.prop | grep "$dotspecifier" | cut -d "=" -f 1`
    ui_print "DNS_Over_TLS：[$ipv6dotewmaname] $dotspecifier "
    [[ "$dotspecifier" = 'dns.cfiec.net' ]] && ui_print "此DNS服务商仅支持IPV6网络❗"
elif [[ "$dotdnsewma" != "" && "$dotewmatest" -lt 150 ]];then
    ui_print "$echoprint"
    ui_print "- 【系统支持DNS Over TLS】"
    settings put global private_dns_specifier $dotdnsewma
    dotspecifier=`settings get global private_dns_specifier`
    dotewmaname=`cat $MODPATH/ipv4dnsovertls.prop | grep "$dotspecifier" | cut -d "=" -f 1`
    ipv6dotewmaname=`cat $MODPATH/ipv6dnsovertls.prop | grep "$dotspecifier" | cut -d "=" -f 1`
    ui_print "DNS_Over_TLS：[$dotewmaname] $dotspecifier "
    [[ "$dotspecifier" = 'dns.cfiec.net' ]] && ui_print "此DNS服务商仅支持IPV6网络❗"
fi

if [[ "$AndroidSDK" -ge "28" && "$dotmode" != "" && "$dotmode" == "opportunistic" ]];then
    ui_print "DNS_Over_TLS状态：[自动🔄]"
    ui_print "[DNS Over TLS]比普通DNS更安全但可能并不是很稳定,请酌情启用!"
    ui_print "仅更改服务器地址,未调整开关状态,加密DNS优先级大于iptables规则!"
    ui_print "如网络出问题请[关闭].(无法连接网络、无法加载图片、连接VPN没网等❗)"
elif [[ "$AndroidSDK" -ge "28" && "$dotmode" != "" && "$dotmode" == "off" ]];then
    ui_print "DNS_Over_TLS状态：[关闭❎]"
    ui_print "如需开启："
    ui_print "[MIUI]-设置-连接与共享-私人DNS"
    ui_print "[参考]-设置-无线和网络-加密DNS/私密DNS/私人DNS"
    ui_print "[其他]-设置-网络和互联网-高级-加密DNS/私密DNS/私人DNS"
    ui_print "[DNS Over TLS]比普通DNS更安全但可能并不是很稳定,请酌情启用!"
    ui_print "仅更改服务器地址,未调整开关状态,加密DNS优先级大于iptables规则!"
    ui_print "如网络出问题请[关闭].(无法连接网络、无法加载图片、连接VPN没网等❗)"
elif [[ "$AndroidSDK" -ge "28" && "$dotmode" != "" && "$dotmode" == "hostname" ]];then
    ui_print "DNS_Over_TLS状态：[开启✅]"
    ui_print "如需关闭："
    ui_print "[MIUI]-设置-连接与共享-私人DNS"
    ui_print "[参考]-设置-无线和网络-加密DNS/私密DNS/私人DNS"
    ui_print "[其他]-设置-网络和互联网-高级-加密DNS/私密DNS/私人DNS"
    ui_print "[DNS Over TLS]比普通DNS更安全但可能并不是很稳定,请酌情启用!"
    ui_print "仅更改服务器地址,未调整开关状态,加密DNS优先级大于iptables规则!"
    ui_print "如网络出问题请[关闭].(无法连接网络、无法加载图片、连接VPN没网等❗)"
fi

description=$MODPATH/module.prop
dotmode=`settings get global private_dns_mode`
dotspecifier=`settings get global private_dns_specifier`
iptdnsTesting=`iptables -t nat -nL OUTPUT --line-numbers | grep 'dpt:53 ' | awk 'NR==1{print $(NF)}' | cut -d ':' -f 2- | cut -d ':' -f 1`
ipt6dnsTesting=`ip6tables -t nat -nL OUTPUT --line-numbers | grep 'dpt:53 ' | awk 'NR==1{print $(NF)}' | cut -d ':' -f 2- | sed 's/\:53//g'`
ipv4Testingname=`cat $MODPATH/ipv4dns.prop | grep "$iptdnsTesting" | cut -d "=" -f 1`
ipv6Testingname=`cat $MODPATH/ipv6dns.prop | grep "$ipt6dnsTesting" | cut -d "=" -f 1`
dotTestingname=`cat $MODPATH/ipv4dnsovertls.prop | grep "$dotspecifier" | cut -d "=" -f 1`
ipv6dotTestingname=`cat $MODPATH/ipv6dnsovertls.prop | grep "$dotspecifier" | cut -d "=" -f 1`
refreshtime=`date +"%Y-%m-%d %H:%M:%S"`

if [[ "$ipv4Testingname" != "" && "$ipv6Testingname" != "" && "$ipv6dotTestingname" != "" ]];then
sed -i "s/- .*/- IPV4：\["$ipv4Testingname"："$iptdnsTesting"\] - IPV6：\["$ipv6Testingname"："$ipt6dnsTesting"\] - 私人DNS：\["$ipv6dotTestingname"："$dotspecifier"\]   --- 刷新时间：\[""$refreshtime""\] /g" $description
elif [[ "$ipv4Testingname" != "" && "$ipv6Testingname" != "" && "$dotTestingname" != "" ]];then
sed -i "s/- .*/- IPV4：\["$ipv4Testingname"："$iptdnsTesting"\] - IPV6：\["$ipv6Testingname"："$ipt6dnsTesting"\] - 私人DNS：\["$dotTestingname"："$dotspecifier"\]   --- 刷新时间：\[""$refreshtime""\] /g" $description
elif [[ "$ipv4Testingname" != "" && "$ipv6dotTestingname" != "" ]];then
sed -i "s/- .*/- IPV4：\["$ipv4Testingname"："$iptdnsTesting"\] - 私人DNS：\["$ipv6dotTestingname"："$dotspecifier"\]   --- 刷新时间：\[""$refreshtime""\] /g" $description
elif [[ "$ipv4Testingname" != "" && "$dotTestingname" != "" ]];then
sed -i "s/- .*/- IPV4：\["$ipv4Testingname"："$iptdnsTesting"\] - 私人DNS：\["$dotTestingname"："$dotspecifier"\]   --- 刷新时间：\[""$refreshtime""\] /g" $description
elif [[ "$ipv4Testingname" != "" && "$ipv6Testingname" != "" ]];then
sed -i "s/- .*/- IPV4：\["$ipv4Testingname"："$iptdnsTesting"\] - IPV6：\["$ipv6Testingname"："$ipt6dnsTesting"\]   --- 刷新时间：\[""$refreshtime""\] /g" $description
elif [[ "$ipv6Testingname" != "" && "$ipv6dotTestingname" != "" ]];then
sed -i "s/- .*/- IPV6：\["$ipv6Testingname"："$ipt6dnsTesting"\] - 私人DNS：\["$ipv6dotTestingname"："$dotspecifier"\]   --- 刷新时间：\[""$refreshtime""\] /g" $description
elif [[ "$ipv6Testingname" != "" && "$dotTestingname" != "" ]];then
sed -i "s/- .*/- IPV6：\["$ipv6Testingname"："$ipt6dnsTesting"\] - 私人DNS：\["$dotTestingname"："$dotspecifier"\]   --- 刷新时间：\[""$refreshtime""\] /g" $description
elif [[ "$ipv4Testingname" != "" ]];then
sed -i "s/- .*/- IPV4：\["$ipv4Testingname"："$iptdnsTesting"\]   --- 刷新时间：\[""$refreshtime""\] /g" $description
elif [[ "$ipv6Testingname" != "" ]];then
sed -i "s/- .*/- IPV6：\["$ipv6Testingname"："$ipt6dnsTesting"\]   --- 刷新时间：\[""$refreshtime""\] /g" $description
elif [[ "$ipv6dotTestingname" != "" ]];then
sed -i "s/- .*/- 私人DNS：\["$ipv6dotTestingname"："$dotspecifier"\]   --- 刷新时间：\[""$refreshtime""\] /g" $description
elif [[ "$dotTestingname" != "" ]];then
sed -i "s/- .*/- 私人DNS：\["$dotTestingname"："$dotspecifier"\]   --- 刷新时间：\[""$refreshtime""\] /g" $description
else
sed -i "s/- .*/- /g" $description
fi

echo > $MODPATH/ipv4dns.log
echo > $MODPATH/ipv6dns.log
echo > $MODPATH/ipv4dnsovertls.log
echo > $MODPATH/ipv6dnsovertls.log

  ui_print "$echoprint"
  ProjectAddress=`cat $hosts | grep 'https://' | awk '{print $2}'`
  ui_print "- 【订阅地址-GitHub/Gitee】"
  ui_print "$ProjectAddress"
  ui_print "$echoprint"

  ui_print "- 【禁用应用Components】"
[[ `settings get global personalized_ad_enabled` != "" ]] && settings put global personalized_ad_enabled '0'
[[ `settings get global personalized_ad_time` != "" ]] && settings put global personalized_ad_time '0'
[[ `settings get global passport_ad_status` != "" ]] && settings put global passport_ad_status 'OFF'
echo > $MODPATH/Components.log
#enable/disable
AD_Components=`dumpsys package --all-components | grep '/' | grep -iE '\.ad\.|ads\.|adsdk|AdWeb|Advert|AdActivity|AdService' | grep -viE ':|=|add|load|read|boot' | sed 's/.* //g;s/}//g;s/^\/.*//g'`
if [[ "$AD_Components" != "" ]];then
  for AD in $AD_Components;do
    pm disable $AD >/dev/null 2>&1
done
  ui_print "禁用应用关键字包含有|.ad.|ads.|adsdk|AdWeb|Advert|AdActivity|AdService|相关组件"
  echo -e "应用禁用组件列表：\n${AD_Components}\n" >> $MODPATH/Components.log
  ui_print "禁用相关应用Components列表保存路径：$MODPATH/Components.log"
fi

Add_ADActivity=`cat $MODPATH/adactivity.prop | awk '!/#/ {print $NF}' | sed 's/ //g'`
if [[ -s $MODPATH/adactivity.prop ]];then
  for ADDAD in $Add_ADActivity;do
    pm disable $ADDAD >/dev/null 2>&1
done
  ui_print " "
  ui_print "- 自定义禁用应用Components列表"
  ui_print "$Add_ADActivity"
  cat $MODPATH/adactivity.prop >> $MODPATH/uninstall.sh
fi
  ui_print "$echoprint"

endtime=`date +"%Y-%m-%d %H:%M:%S"`
start_seconds=`date -d "$starttime" +"%s"`
end_seconds=`date -d "$endtime" +"%s"`
interval_time=$((end_seconds-start_seconds))
firstday=`date +"%j"`
firstweek=`date +"%U"`
currenttime=`date +"%Y年%m月%d日 %H:%M:%S"`
author=`cat $MODPATH/module.prop | grep 'author' | cut -d "=" -f 2`
sleeptime=`cat $MODPATH/service.sh | grep 'sleep' | awk 'END{print $2}' | sed 's/s/秒/g;s/[0-9]$/&秒/g;s/m/分钟/g;s/h/小时/g;s/d/天/g' `
week=`date +"%w" | sed 's/0/星期日/g;s/1/星期一/g;s/2/星期二/g;s/3/星期三/g;s/4/星期四/g;s/5/星期五/g;s/6/星期六/g' `
#  ui_print "- 循环延时：$sleeptime"
if `date --help >/dev/null 2>&1` ;then
  [[ $(($interval_time%3600/60)) -ge "1" ]] && ui_print "- 安装耗时：$(($interval_time%3600/60))分$(($interval_time%3600%60))秒" || ui_print "- 安装耗时：$interval_time秒"
  ui_print "- 系统时间：$currenttime $week 今年第$firstweek周/$firstday天"
  ui_print "$echoprint"
fi

NewVersionA=`curl --connect-timeout 10 -m 10 -s 'https://raw.githubusercontent.com/Coolapk-Code9527/-Hosts-/master/README.md' | grep 'version=' | cut -d '=' -f 2`
NewVersionB=`echo $NewVersionA | sed 's/[^0-9]//g'`
NewVersionC=`curl --connect-timeout 10 -m 10 -s 'https://gitee.com/coolapk-code_9527/border/raw/master/README.md' | grep 'version=' | cut -d '=' -f 2`
NewVersionD=`echo $NewVersionC | sed 's/[^0-9]//g'`
Version=`cat $MODPATH/module.prop | grep 'version=' | sed 's/[^0-9]//g'`
coolapkTesting=`pm list package | grep -w 'com.coolapk.market'`

if [[ "$NewVersionB" != "" && "$NewVersionB" -gt "$Version" ]];then
  ui_print "- 检测到有新版本[️GitHub🆕$NewVersionA],可关注作者获取更新❗"
  ui_print "$echoprint"
  sleep 5
sed -i "s/！/！（检测到有新版本\[️GitHub🆕"$NewVersionA"\]❗）/g;s/！.*）/！（检测到有新版本\[️GitHub🆕"$NewVersionA"\]❗）/g" $description
am start -a android.intent.action.VIEW -d 'https://github.com/Coolapk-Code9527/-Hosts-' >/dev/null 2>&1
elif [[ "$NewVersionD" != "" && "$NewVersionD" -gt "$Version" ]];then
  ui_print "- 检测到有新版本[Gitee🆕$NewVersionC],可关注作者获取更新❗"
  ui_print "$echoprint"
  sleep 5
sed -i "s/！/！（检测到有新版本\[️Gitee🆕"$NewVersionC"\]❗）/g;s/！.*）/！（检测到有新版本\[️Gitee🆕"$NewVersionC"\]❗）/g" $description
am start -a android.intent.action.VIEW -d 'https://gitee.com/coolapk-code_9527/border' >/dev/null 2>&1
elif [[ "$?" -ne 0 ]];then
sed -i "s/！.*）/！/g" $description
#  sleep 5
#am start -d 'coolmarket://u/1539433' >/dev/null 2>&1
fi
  ui_print "- by $author"
  ui_print " "
  ui_print " "
  ui_print " "


##########################################################################################
#
# 安装框架将导出一些变量和函数。
# 您应该使用这些变量和函数进行安装。
# 
# !不要使用任何Magisk内部路径，因为它们不是公共API。
# !请勿在util_functions.sh中使用其他函数，因为它们不是公共API。
# !不保证非公共API可以保持版本之间的兼容性。
##########################################################################################
# 可用变量
##########################################################################################
#
# MAGISK_VER (string): 当前安装的Magisk的版本字符串（例如v20.0）
# MAGISK_VER_CODE (int): 当前安装的Magisk的版本代码（例如20000）
# BOOTMODE (bool): 如果模块当前正在Magisk Manager中安装,则为true
# MODPATH (path): 应安装模块文件的路径
# TMPDIR (path): 临时存储文件的地方
# ZIPFILE (path): 安装模块zip文件
# ARCH (string): 设备的CPU架构.值为arm,arm64,x86或x64
# IS64BIT (bool): 如果$ ARCH是arm64或x64,则为true
# API (int): 设备的API级别(Android版本)（例如，21对于Android 5.0）
#
##########################################################################################
# 可用功能
##########################################################################################
#
# ui_print <msg>
#     打印 <msg> 到安装界面
#     避免使用 'echo' 因为它不会显示在自定义安装界面
#
# abort <msg>
#     打印错误消息 <msg> 到安装界面和终止安装
#     避免使用 'exit' 因为它会跳过终止清理步骤
#
# set_perm <目标> <所有者> <组> <权限> [环境]
#     如果未设置[环境]，则默认值为 "u:object_r:system_file:s0"
#     该函数是以下命令的简写：
#       chown 所有者.组 目标
#       chmod 权限 目标
#       chcon 环境 目标
#
# set_perm_recursive <目录> <所有者> <组> <权限> <文件权限> [环境]
#     如果未设置[context]，则默认值为"u:object_r:system_file:s0"
#     对于<目录>中的所有文件，它将调用：
#       set_perm file 所有者 组 文件权限 环境
#     对于<目录>中的所有目录（包括自身），它将调用：
#       set_perm dir 所有者 组 权限 环境
#
##########################################################################################


##########################################################################################
# 权限设置
##########################################################################################


# 只有一些特殊文件需要特定权限
# 安装完成后，此功能将被调用
# 对于大多数情况，默认权限应该已经足够

  # 默认规则
  # set_perm_recursive $MODPATH 0 0 0755 0644
  # 以下是一些例子:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644


# 您可以添加更多功能来协助您的自定义脚本代码
















