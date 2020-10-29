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
hosts=${MODPATH}/system/etc/hosts
ModulesPath=${MODPATH%/modules*}/modules
count=`wc -l $hosts | awk '{print $1}'`
usage=`du -h $hosts | awk '{print $1}'`
usageAB=`du $hosts | awk '{print $1}'`
systemavailC=`df /system | awk 'NR==2{print $4}'`
systemavailD=`df /system | awk 'NR==3{print $3}'`
system_examineA=`df -h /system | awk 'NR==2{print "大小："$2"  已用："$3"  剩余："$4"  占用率："$5""}'`
system_examineB=`df -h /system | awk 'NR==3{print "大小："$1"  已用："$2"  剩余："$3"  占用率："$4""}'`
hostsTesting=`find $ModulesPath -type f -name "hosts" | grep -v 'hostsjj' | awk 'NR==1'`
modifytime=`unzip -v $ZIPFILE | grep 'system/etc/hosts' | awk 'NR==1{print $5}' | sed -r 's/(.*)-(.*)-(.*)$/\3-\1-\2/'`
module_info=`unzip -v $ZIPFILE | grep -v '/' \
| awk '{line[NR]=$NF} END {for(i=4 ;i<=NR-2;i++) print line[i]}'\
|sed -e 's/module.prop/& -———- 模块信息文件/g'\
 -e 's/customize.sh/& -———- 自定义安装脚本/g'\
 -e 's/system.prop/& -———- 映射system\/build.prop/g'\
 -e 's/README.md/& -———- 模块说明文件/g'\
 -e 's/service.sh/& -———- 开机后自启脚本/g'\
 -e 's/post-fs-data.sh/& -———- 开机前自启脚本/g'\
 -e 's/uninstall.sh/& -———- 自定义卸载脚本/g'\
 -e 's/sepolicy.rule/& -———- 自定义sepolicy规则/g'\
 -e 's/ipv4dns.prop/& -———- IPV4_DNS配置文件/g'\
 -e 's/ipv6dns.prop/& -———- IPV6_DNS配置文件/g'\
 -e 's/ipv4dnsovertls.prop/& -———- IPV4_私人DNS配置文件/g'\
 -e 's/ipv6dnsovertls.prop/& -———- IPV6_私人DNS配置文件/g'\
 -e 's/ipblacklist.prop/& -———- IP地址禁网配置文件/g'\
 -e 's/packageswhitelist.prop/& -———- 应用放行DNS配置文件/g'\
 -e 's/packagesblacklist.prop/& -———- 应用包名禁网配置文件/g'\
 -e 's/cblacklist.prop/& -———- 自定义禁用组件文件/g'\
 -e 's/cwhitelist.prop/& -———- 自定义启用组件文件/g'\
 -e 's/adfilesblacklist.prop/& -———- 自定义禁用写入权限文件/g'\
 -e 's/adfileswhitelist.prop/& -———- 自定义启用写入权限文件/g'`
 
  set +eux
  [[ ! -f /system/xbin/busybox && ! -f /system/bin/busybox ]] && ui_print "- 未检测到[busybox]模块,许多Linux命令将不能被执行,可能会发生错误‼️"
  [[ -e "$hostsTesting" ]] && ui_print "- 检测到已安装有其他hosts模块,请将其停用或卸载,不然可能会有冲突导致此模块hosts无法生效‼️"
  [[ -d $ModulesPath/dnss && ! -f $ModulesPath/dnss/disable ]] && {
  touch $ModulesPath/dnss/disable
  chmod 644 $ModulesPath/dnss/disable
  ui_print "- 本模块已支持DNS更改,无需再使用其他DNS模块,已自动将其停用(重启生效)❗"
}
  echoprint='━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
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
clearA=/data/data/*/cache
clearB=/data/media/0/Android/data/*/cache
clearU=/data/user_de/0/*/cache
disk_cacheA=`du -csk ${clearA} ${clearB} ${clearU} | awk 'END{print $1/1024}' | sed 's/[a-zA-Z]//g'`
list_cache=`ls -d ${clearA} ${clearB} ${clearU}`
if [[ "$list_cache" != "" ]];then
  for CLEAR in $list_cache;do
    [[ -d "$CLEAR" ]] && rm -rf $CLEAR/*
  done
fi
disk_cacheB=`du -csk ${clearA} ${clearB} ${clearU} | awk 'END{print $1/1024}' | sed 's/[a-zA-Z]//g'`
disk_cacheC=`echo | awk "{print $disk_cacheA-$disk_cacheB}" | awk '{printf("%.f\n",$1)}'`
  ui_print "清除：${disk_cacheC} M"
  ui_print "$echoprint"

  ui_print "- 【根据当前网络环境选择DNS】"
  
[ -f $TMPDIR/ipv4dns.prop ] && cp -af $TMPDIR/ipv4dns.prop $MODPATH/ipv4dns.prop
[ -f $TMPDIR/ipv6dns.prop ] && cp -af $TMPDIR/ipv6dns.prop $MODPATH/ipv6dns.prop
[ -f $TMPDIR/ipv4dnsovertls.prop ] && cp -af $TMPDIR/ipv4dnsovertls.prop $MODPATH/ipv4dnsovertls.prop
[ -f $TMPDIR/ipv6dnsovertls.prop ] && cp -af $TMPDIR/ipv6dnsovertls.prop $MODPATH/ipv6dnsovertls.prop
[ -f $TMPDIR/packageswhitelist.prop ] && cp -af $TMPDIR/packageswhitelist.prop $MODPATH/packageswhitelist.prop
ipv4dns=`cat $MODPATH/ipv4dns.prop | awk '!/#/ {print $NF}' | cut -d "=" -f 2`
ipv6dns=`cat $MODPATH/ipv6dns.prop | awk '!/#/ {print $NF}' | cut -d "=" -f 2`
ipv4dnsovertls=`cat $MODPATH/ipv4dnsovertls.prop | awk '!/#/ {print $NF}' | cut -d "=" -f 2`
ipv6dnsovertls=`cat $MODPATH/ipv6dnsovertls.prop | awk '!/#/ {print $NF}' | cut -d "=" -f 2`
AndroidSDK=`getprop ro.build.version.sdk`
dotmode=`settings get global private_dns_mode`
iptdnsTesting=`iptables -t nat -nL OUTPUT --line-numbers | grep 'dpt:53 ' | awk 'NR==1{print $(NF)}' | cut -d ':' -f 2- | cut -d ':' -f 1`
ipt6dnsTesting=`ip6tables -t nat -nL OUTPUT --line-numbers | grep 'dpt:53 ' | awk 'NR==1{print $(NF)}' | cut -d ':' -f 2- | sed 's/\:53//g'`
accept_packages=`cat $MODPATH/packageswhitelist.prop | awk '!/#/ {print $NF}'`
get_package_uid(){ grep "${1}" /data/system/packages.list | awk '{print $2}' | sed 's/[^0-9]//g'; }

[[ "$iptdnsTesting" != "" ]] && iptables -t nat -F OUTPUT >/dev/null 2>&1
[[ "$ipt6dnsTesting" != "" ]] && ip6tables -t nat -F OUTPUT >/dev/null 2>&1

if [[ -s $MODPATH/ipv4dns.prop ]];then
for dns in $ipv4dns; do
    setsid ping -c 5 -A -w 1 $dns >> $MODPATH/ipv4dns.log
  done
wait
fi

ip6tables -t nat -nL >/dev/null 2>&1
if [[ "$?" -eq 0 && -s $MODPATH/ipv6dns.prop ]];then
for dnss in $ipv6dns; do
    setsid ping6 -c 5 -A -w 1 $dnss >> $MODPATH/ipv6dns.log
  done
wait
fi

if [[ "$AndroidSDK" -ge "28" && "$dotmode" != "" && -s $MODPATH/ipv4dnsovertls.prop ]];then
for dot in $ipv4dnsovertls; do
    setsid ping -c 5 -A -w 1 $dot >> $MODPATH/ipv4dnsovertls.log
  done
wait
fi

if [[ "$AndroidSDK" -ge "28" && "$dotmode" != "" && -s $MODPATH/ipv6dnsovertls.prop ]];then
for dots in $ipv6dnsovertls; do
    setsid ping6 -c 5 -A -w 1 $dots >> $MODPATH/ipv6dnsovertls.log
  done
wait
fi

avg=`cat $MODPATH/ipv4dns.log | grep 'min/avg/max' | cut -d "=" -f 2 | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
avgtest=`echo $avg | awk -F"/" '{printf("%.f\n",$2)}' `
dnsavg=`cat $MODPATH/ipv4dns.log | grep -B 2 "$avg" | awk 'NR==1{print $2}' `
avgname=`cat $MODPATH/ipv4dns.prop | grep "$dnsavg" | cut -d "=" -f 1`

if [[ "$dnsavg" != "" && "$avgtest" -lt 150 ]];then
    DPT_REDIRECT=`iptables -t nat -nL OUTPUT --line-numbers | grep 'REDIRECT' | grep 'dpt:5353 ' | awk '{print $NF}' | grep '53'`
    [[ "$DPT_REDIRECT" != "" ]] || {
    iptables -t nat -A OUTPUT -p tcp --dport 5353 -j REDIRECT --to-ports 53
    iptables -t nat -A OUTPUT -p udp --dport 5353 -j REDIRECT --to-ports 53
    }
    [[ "$accept_packages" != "" ]] && {
    for APP in $accept_packages;do
    UID=`get_package_uid $APP`
    [[ "$UID" != "" ]] && {
    iptables -t nat -D OUTPUT -p tcp --dport 53 -m owner --uid-owner ${UID} -j ACCEPT
    iptables -t nat -D OUTPUT -p udp --dport 53 -m owner --uid-owner ${UID} -j ACCEPT
    } || continue;done;}
    TCP_REDIRECT=`iptables -t nat -nL OUTPUT --line-numbers | grep 'tcp' | grep 'dpt:53 ' | awk -F '[:]' '{print $(NF-1)}'`
    UDP_REDIRECT=`iptables -t nat -nL OUTPUT --line-numbers | grep 'udp' | grep 'dpt:53 ' | awk -F '[:]' '{print $(NF-1)}'`
    [[ "$TCP_REDIRECT" != "" ]] && for TCP in ${TCP_REDIRECT};do iptables -t nat -D OUTPUT -p tcp --dport 53 -j DNAT --to-destination ${TCP}:53; done
    [[ "$UDP_REDIRECT" != "" ]] && for UDP in ${UDP_REDIRECT};do iptables -t nat -D OUTPUT -p udp --dport 53 -j DNAT --to-destination ${UDP}:53; done
    wait
    iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination $dnsavg:53
    iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination $dnsavg:53
    [[ "$accept_packages" != "" ]] && {
    for APP in $accept_packages;do
    UID=`get_package_uid $APP`
    [[ "$UID" != "" ]] && {
    iptables -t nat -I OUTPUT -p tcp --dport 53 -m owner --uid-owner ${UID} -j ACCEPT
    iptables -t nat -I OUTPUT -p udp --dport 53 -m owner --uid-owner ${UID} -j ACCEPT
    } || continue;done;}
    ui_print "IPV4_DNS：[$avgname] $dnsavg "
else
    DPT_REDIRECT=`iptables -t nat -nL OUTPUT --line-numbers | grep 'REDIRECT' | grep 'dpt:5353 ' | awk '{print $NF}' | grep '53'`
    [[ "$DPT_REDIRECT" != "" ]] && {
    iptables -t nat -D OUTPUT -p tcp --dport 5353 -j REDIRECT --to-ports 53
    iptables -t nat -D OUTPUT -p udp --dport 5353 -j REDIRECT --to-ports 53
    }
    [[ "$accept_packages" != "" ]] && {
    for APP in $accept_packages;do
    UID=`get_package_uid $APP`
    [[ "$UID" != "" ]] && {
    iptables -t nat -D OUTPUT -p tcp --dport 53 -m owner --uid-owner ${UID} -j ACCEPT
    iptables -t nat -D OUTPUT -p udp --dport 53 -m owner --uid-owner ${UID} -j ACCEPT
    } || continue;done;}
    TCP_REDIRECT=`iptables -t nat -nL OUTPUT --line-numbers | grep 'tcp' | grep 'dpt:53 ' | awk -F '[:]' '{print $(NF-1)}'`
    UDP_REDIRECT=`iptables -t nat -nL OUTPUT --line-numbers | grep 'udp' | grep 'dpt:53 ' | awk -F '[:]' '{print $(NF-1)}'`
    [[ "$TCP_REDIRECT" != "" ]] && for TCP in ${TCP_REDIRECT};do iptables -t nat -D OUTPUT -p tcp --dport 53 -j DNAT --to-destination ${TCP}:53; done
    [[ "$UDP_REDIRECT" != "" ]] && for UDP in ${UDP_REDIRECT};do iptables -t nat -D OUTPUT -p udp --dport 53 -j DNAT --to-destination ${UDP}:53; done
fi

ipv6avg=`cat $MODPATH/ipv6dns.log | grep 'min/avg/max' | cut -d "=" -f 2 | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
ipv6avgtest=`echo $ipv6avg | awk -F"/" '{printf("%.f\n",$2)}' `
ipv6dnsavg=`cat $MODPATH/ipv6dns.log | grep -B 2 "$ipv6avg" | awk 'NR==1{print $2}' `
ipv6avgname=`cat $MODPATH/ipv6dns.prop | grep "$ipv6dnsavg" | cut -d "=" -f 1`

if [[ "$ipv6dnsavg" != "" && "$ipv6avgtest" -lt 150 ]];then
    DPT_REDIRECT6=`ip6tables -t nat -nL OUTPUT --line-numbers | grep 'REDIRECT' | grep 'dpt:5353 ' | awk '{print $NF}' | grep '53'`
    [[ "$DPT_REDIRECT6" != "" ]] || {
    ip6tables -t nat -A OUTPUT -p tcp --dport 5353 -j REDIRECT --to-ports 53
    ip6tables -t nat -A OUTPUT -p udp --dport 5353 -j REDIRECT --to-ports 53
    }
    [[ "$accept_packages" != "" ]] && {
    for APP in $accept_packages;do
    UID=`get_package_uid $APP`
    [[ "$UID" != "" ]] && {
    ip6tables -t nat -D OUTPUT -p tcp --dport 53 -m owner --uid-owner ${UID} -j ACCEPT
    ip6tables -t nat -D OUTPUT -p udp --dport 53 -m owner --uid-owner ${UID} -j ACCEPT
    } || continue;done;}
    TCP_REDIRECT6=`ip6tables -t nat -nL OUTPUT --line-numbers | grep 'tcp' | grep 'dpt:53 ' | awk 'END{print $(NF)}' | cut -d ':' -f 2- | sed 's/\:53//g'`
    UDP_REDIRECT6=`ip6tables -t nat -nL OUTPUT --line-numbers | grep 'udp' | grep 'dpt:53 ' | awk 'END{print $(NF)}' | cut -d ':' -f 2- | sed 's/\:53//g'`
    [[ "$TCP_REDIRECT6" != "" ]] && for TCP6 in ${TCP_REDIRECT6};do ip6tables -t nat -D OUTPUT -p tcp --dport 53 -j DNAT --to-destination ${TCP6}:53; done
    [[ "$UDP_REDIRECT6" != "" ]] && for UDP6 in ${UDP_REDIRECT6};do ip6tables -t nat -D OUTPUT -p udp --dport 53 -j DNAT --to-destination ${UDP6}:53; done
    wait
    ip6tables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination $ipv6dnsavg:53
    ip6tables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination $ipv6dnsavg:53
    [[ "$accept_packages" != "" ]] && {
    for APP in $accept_packages;do
    UID=`get_package_uid $APP`
    [[ "$UID" != "" ]] && {
    ip6tables -t nat -I OUTPUT -p tcp --dport 53 -m owner --uid-owner ${UID} -j ACCEPT
    ip6tables -t nat -I OUTPUT -p udp --dport 53 -m owner --uid-owner ${UID} -j ACCEPT
    } || continue;done;}
    ui_print "IPV6_DNS：[$ipv6avgname] $ipv6dnsavg "
else
    DPT_REDIRECT6=`ip6tables -t nat -nL OUTPUT --line-numbers | grep 'REDIRECT' | grep 'dpt:5353 ' | awk '{print $NF}' | grep '53'`
    [[ "$DPT_REDIRECT6" != "" ]] && {
    ip6tables -t nat -D OUTPUT -p tcp --dport 5353 -j REDIRECT --to-ports 53
    ip6tables -t nat -D OUTPUT -p udp --dport 5353 -j REDIRECT --to-ports 53
    }
    [[ "$accept_packages" != "" ]] && {
    for APP in $accept_packages;do
    UID=`get_package_uid $APP`
    [[ "$UID" != "" ]] && {
    ip6tables -t nat -D OUTPUT -p tcp --dport 53 -m owner --uid-owner ${UID} -j ACCEPT
    ip6tables -t nat -D OUTPUT -p udp --dport 53 -m owner --uid-owner ${UID} -j ACCEPT
    } || continue;done;}
    TCP_REDIRECT6=`ip6tables -t nat -nL OUTPUT --line-numbers | grep 'tcp' | grep 'dpt:53 ' | awk 'END{print $(NF)}' | cut -d ':' -f 2- | sed 's/\:53//g'`
    UDP_REDIRECT6=`ip6tables -t nat -nL OUTPUT --line-numbers | grep 'udp' | grep 'dpt:53 ' | awk 'END{print $(NF)}' | cut -d ':' -f 2- | sed 's/\:53//g'`
    [[ "$TCP_REDIRECT6" != "" ]] && for TCP6 in ${TCP_REDIRECT6};do ip6tables -t nat -D OUTPUT -p tcp --dport 53 -j DNAT --to-destination ${TCP6}:53; done
    [[ "$UDP_REDIRECT6" != "" ]] && for UDP6 in ${UDP_REDIRECT6};do ip6tables -t nat -D OUTPUT -p udp --dport 53 -j DNAT --to-destination ${UDP6}:53; done
fi

dotavg=`cat $MODPATH/ipv4dnsovertls.log | grep 'min/avg/max' | cut -d "=" -f 2 | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
dotavgtest=`echo $dotavg | awk -F"/" '{printf("%.f\n",$2)}' `
dotdnsavg=`cat $MODPATH/ipv4dnsovertls.log | grep -B 2 "$dotavg" | awk 'NR==1{print $2}' `
ipv6dotavg=`cat $MODPATH/ipv6dnsovertls.log | grep 'min/avg/max' | cut -d "=" -f 2 | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
ipv6dotavgtest=`echo $ipv6dotavg | awk -F"/" '{printf("%.f\n",$2)}' `
ipv6dotdnsavg=`cat $MODPATH/ipv6dnsovertls.log | grep -B 2 "$ipv6dotavg" | awk 'NR==1{print $2}' `

DOT_Status() {
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
fi;}

if [[ "$ipv6dotdnsavg" != "" && "$dotavgtest" -gt "$ipv6dotavgtest" && "$ipv6dotavgtest" -lt 150 ]];then
    ui_print "$echoprint"
    ui_print "- 【系统支持DNS Over TLS】"
    settings put global private_dns_specifier $ipv6dotdnsavg
    dotspecifier=`settings get global private_dns_specifier`
    dotavgname=`cat $MODPATH/ipv4dnsovertls.prop | grep "$dotspecifier" | cut -d "=" -f 1`
    ipv6dotavgname=`cat $MODPATH/ipv6dnsovertls.prop | grep "$dotspecifier" | cut -d "=" -f 1`
    ui_print "DNS_Over_TLS：[$ipv6dotavgname] $dotspecifier "
    [[ "$dotspecifier" = 'dns.cfiec.net' ]] && ui_print "此DNS服务商仅支持IPV6网络❗"
    DOT_Status
elif [[ "$dotdnsavg" != "" && "$dotavgtest" -lt 150 ]];then
    ui_print "$echoprint"
    ui_print "- 【系统支持DNS Over TLS】"
    settings put global private_dns_specifier $dotdnsavg
    dotspecifier=`settings get global private_dns_specifier`
    dotavgname=`cat $MODPATH/ipv4dnsovertls.prop | grep "$dotspecifier" | cut -d "=" -f 1`
    ipv6dotavgname=`cat $MODPATH/ipv6dnsovertls.prop | grep "$dotspecifier" | cut -d "=" -f 1`
    ui_print "DNS_Over_TLS：[$dotavgname] $dotspecifier "
    [[ "$dotspecifier" = 'dns.cfiec.net' ]] && ui_print "此DNS服务商仅支持IPV6网络❗"
    DOT_Status
fi

description=$MODPATH/module.prop
dotmode=`settings get global private_dns_mode`
dotspecifier=`settings get global private_dns_specifier`
iptdnsTesting=`iptables -t nat -nL OUTPUT --line-numbers | grep 'dpt:53 ' | awk 'END{print $(NF)}' | cut -d ':' -f 2- | cut -d ':' -f 1`
ipt6dnsTesting=`ip6tables -t nat -nL OUTPUT --line-numbers | grep 'dpt:53 ' | awk 'END{print $(NF)}' | cut -d ':' -f 2- | sed 's/\:53//g'`
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

[ -f $TMPDIR/ipblacklist.prop ] && cp -af $TMPDIR/ipblacklist.prop $MODPATH/ipblacklist.prop
IP_Black=`cat $MODPATH/ipblacklist.prop | awk '!/#/ {print $NF}' | sed 's/ //g'`
if [[ "$IP_Black" != "" ]];then
  for IP in $IP_Black;do
   iptables -t nat -I OUTPUT -d ${IP} -j DNAT --to-destination 127.0.0.1
#REJECT --reject-with icmp-port-unreachable、icmp-net-unreachable 、icmp-host-unreachable 、icmp-proto-unreachable 、icmp-net-prohibited 、icmp-host-prohibited
#    iptables -I INPUT -s ${IP} -j REJECT
  done
fi

[ -f $TMPDIR/packagesblacklist.prop ] && cp -af $TMPDIR/packagesblacklist.prop $MODPATH/packagesblacklist.prop
reject_packages=`cat $MODPATH/packagesblacklist.prop | awk '!/#/ {print $NF}'`
if [[ "$reject_packages" != "" ]];then
  for APPS in $reject_packages;do
    UIDS=`get_package_uid $APPS`
      [[ "$UIDS" != "" ]] && iptables -t mangle -I OUTPUT -m owner --uid-owner ${UIDS} -j DROP || continue
  done
fi

  ui_print "$echoprint"
#  ProjectAddress=`grep 'https://' $hosts | awk '{print $2}'`
#  [[ "$ProjectAddress" != "" ]] && {
#   ui_print "- 【项目地址-GitHub/Gitee】" 
#   ui_print "$ProjectAddress"
#   ui_print "$echoprint"
#}

[[ `settings get global personalized_ad_enabled` != "" ]] && settings put global personalized_ad_enabled '0'
[[ `settings get global personalized_ad_time` != "" ]] && settings put global personalized_ad_time '0'
[[ `settings get global passport_ad_status` != "" ]] && settings put global passport_ad_status 'OFF'
ad_miui_securitycenter=/data/data/com.miui.securitycenter/files/securityscan_homelist_cache
[[ -f "$ad_miui_securitycenter" ]] && { echo > $ad_miui_securitycenter;chattr -i $ad_miui_securitycenter;chmod 440 $ad_miui_securitycenter;am force-stop 'com.miui.securitycenter'; }

  ui_print "- 【禁用应用Components】"

#enable/disable/default-state
AD_Components=`dumpsys package --all-components | grep '/' | grep -iE '\.ad\.|ads\.|adsdk|adview|AdWeb|Advert|AdActivity|AdService|splashad|adsplash' | grep -viE ':|=|add|sync|load|read|setting' | sed 's/.* //g;s/}//g;s/^\/.*//g' | sort -u`
if [[ "$AD_Components" != "" ]];then
IFW=/data/system/ifw
if [[ -e "$IFW" ]];then
[ -f $TMPDIR/cblacklist.prop ] && cp -af $TMPDIR/cblacklist.prop $MODPATH/cblacklist.prop
Add_ADActivity=`cat $MODPATH/cblacklist.prop | awk '!/#/ {print $NF}' | sed 's/ //g'`
  ui_print "[IFW方式]-禁用应用关键字包含有|.ad.|ads.|adsdk|adview|AdWeb|Advert|AdActivity|AdService|splashad|adsplash|相关组件"
  echo "<!-- 🧿结界禁用组件列表 -->" > $IFW/AD_Components_Blacklist.xml
  echo "<rules>" >> $IFW/AD_Components_Blacklist.xml
#Activity
  echo "   <activity block=\"true\" log=\"false\">" >> $IFW/AD_Components_Blacklist.xml
  for AD in $AD_Components;do
    echo "      <component-filter name=\"${AD}\"/>" >> $IFW/AD_Components_Blacklist.xml
  done
if [[ "$Add_ADActivity" != "" ]];then
  for ADDAD in $Add_ADActivity;do
    echo "      <component-filter name=\"${ADDAD}\"/>" >> $IFW/AD_Components_Blacklist.xml
  done
  fi
  echo "   </activity>" >> $IFW/AD_Components_Blacklist.xml
#Broadcast
  echo "   <broadcast block=\"true\" log=\"false\">" >> $IFW/AD_Components_Blacklist.xml
  for AD in $AD_Components;do
    echo "      <component-filter name=\"${AD}\"/>" >> $IFW/AD_Components_Blacklist.xml
  done
if [[ "$Add_ADActivity" != "" ]];then
  for ADDAD in $Add_ADActivity;do
    echo "      <component-filter name=\"${ADDAD}\"/>" >> $IFW/AD_Components_Blacklist.xml
  done
  fi
  echo "   </broadcast>" >> $IFW/AD_Components_Blacklist.xml
#Service
  echo "   <service block=\"true\" log=\"false\">" >> $IFW/AD_Components_Blacklist.xml
  for AD in $AD_Components;do
    echo "      <component-filter name=\"${AD}\"/>" >> $IFW/AD_Components_Blacklist.xml
  done
if [[ "$Add_ADActivity" != "" ]];then
  for ADDAD in $Add_ADActivity;do
    echo "      <component-filter name=\"${ADDAD}\"/>" >> $IFW/AD_Components_Blacklist.xml
  done
  fi
  echo "   </service>" >> $IFW/AD_Components_Blacklist.xml
  echo "</rules>" >> $IFW/AD_Components_Blacklist.xml
[ -f $TMPDIR/cwhitelist.prop ] && cp -af $TMPDIR/cwhitelist.prop $MODPATH/cwhitelist.prop
AD_Whitelist=`cat $MODPATH/cwhitelist.prop | awk '!/#/ {print $NF}' | sed 's/\// \\\ \/ /g;s/ //g'`
if [[ "$AD_Whitelist" != "" ]];then
  for ADCW in $AD_Whitelist;do
  sed -i '/'$ADCW'/d' $IFW/AD_Components_Blacklist.xml
  done
  fi
  for AD in $AD_Components;do
    pm enable $AD >/dev/null 2>&1
  done
  ui_print "禁用相关应用Components列表文件路径：$IFW/AD_Components_Blacklist.xml"
elif [[ "$?" -ne 0 ]];then
  ui_print "[PM方式]-禁用应用关键字包含有|.ad.|ads.|adsdk|adview|AdWeb|Advert|AdActivity|AdService|splashad|adsplash|相关组件"
  for AD in $AD_Components;do
    pm disable $AD >/dev/null 2>&1
done
  ui_print > $MODPATH/Components.log
  echo -e "应用禁用组件列表：\n${AD_Components}\n" >> $MODPATH/Components.log
  ui_print "禁用相关应用Components列表保存路径：$MODPATH/Components.log"
[ -f $TMPDIR/cwhitelist.prop ] && cp -af $TMPDIR/cwhitelist.prop $MODPATH/cwhitelist.prop
AD_Whitelist=`cat $MODPATH/cwhitelist.prop | awk '!/#/ {print $NF}' | sed 's/ //g'`
if [[ "$AD_Whitelist" != "" ]];then
  for ADCW in $AD_Whitelist;do
    pm enable $ADCW >/dev/null 2>&1
  done
  fi
[ -f $TMPDIR/cblacklist.prop ] && cp -af $TMPDIR/cblacklist.prop $MODPATH/cblacklist.prop
Add_ADActivity=`cat $MODPATH/cblacklist.prop | awk '!/#/ {print $NF}' | sed 's/ //g'`
if [[ "$Add_ADActivity" != "" ]];then
  for ADDAD in $Add_ADActivity;do
    pm disable $ADDAD >/dev/null 2>&1
  done
  cat $MODPATH/cblacklist.prop >> $MODPATH/uninstall.sh
  fi
fi
else
  ui_print "禁用应用关键字包含有|.ad.|ads.|adsdk|adview|AdWeb|Advert|AdActivity|AdService|splashad|adsplash|相关组件"
  ui_print "参数为空,设置失败❗"
fi

  ui_print "$echoprint"

  ui_print "- 【禁用应用广告文件夹写入权限】"
data_storage=/data/data
media_storage=/data/media/0
find_ad_files=`find ${data_storage} ${media_storage} -type d -mindepth 1 -maxdepth 8 '(' -iname "ad" -o -iname "*.ad" -o -iname "ad.*" -o -iname "*.ad.*" -o -iname "*_ad" -o -iname "ad_*" -o -iname "*_ad_*" -o -iname "ad-*" -o -iname "ads" -o -iname "*.ads" -o -iname "ads.*" -o -iname "*.ads.*" -o -iname "*_ads" -o -iname "ads_*" -o -iname "*_ads_*" -o -iname "*adnet*" -o -iname "*splash*" -o -iname "*advertise*" ')' | grep -ivE 'rules|filter|block|white|mxtech'`
if [[ "$find_ad_files" != "" ]];then
  ui_print "禁用文件夹关键字包含有|.ad.|ad-|_ad_|.ads.|_ads_|adnet|splash|advertise|相关文件夹写入权限"
  for FADL in $find_ad_files;do
    if [[ -d "$FADL" ]];then
      chattr -R -i $FADL
      chmod -R 440 $FADL
      rm -rf $FADL/*
  fi
done
  echo > $MODPATH/Adfileslist.log
  echo -e "禁用应用广告文件夹写入权限列表：\n${find_ad_files}\n" >> $MODPATH/Adfileslist.log
  ui_print "禁用应用广告文件夹写入权限列表保存路径：$MODPATH/Adfileslist.log"
else
  ui_print "禁用文件夹关键字包含有|.ad.|ad-|_ad_|.ads.|_ads_|adnet|splash|advertise|相关文件夹写入权限"
  ui_print "参数为空,设置失败❗"
fi

[ -f $TMPDIR/adfileswhitelist.prop ] && cp -af $TMPDIR/adfileswhitelist.prop $MODPATH/adfileswhitelist.prop
AD_FilesWhiteList=`cat $MODPATH/adfileswhitelist.prop | awk '!/#/ {print $NF}' | sed 's/ //g'`
if [[ "$AD_FilesWhiteList" != "" ]];then
  for ADFW in $AD_FilesWhiteList;do
    chattr -R -i $ADFW
    chmod -R 775 $ADFW
done
fi

[ -f $TMPDIR/adfilesblacklist.prop ] && cp -af $TMPDIR/adfilesblacklist.prop $MODPATH/adfilesblacklist.prop
AD_FilesBlackList=`cat $MODPATH/adfilesblacklist.prop | awk '!/#/ {print $NF}' | sed 's/ //g'`
if [[ "$AD_FilesBlackList" != "" ]];then
  for ADFL in $AD_FilesBlackList;do
    if [[ -d "$ADFL" ]];then
      chattr -R -i $ADFL
      chmod -R 440 $ADFL
      rm -rf $ADFL/*
    fi
  done
  cat $MODPATH/adfilesblacklist.prop >> $MODPATH/uninstall.sh
fi
  ui_print "$echoprint"
  
  [[ "$module_info" != "" ]] && ui_print "- 【模块文件信息参照表】" && ui_print "$module_info" && ui_print "$echoprint"
  
endtime=`date +"%Y-%m-%d %H:%M:%S"`
start_seconds=`date -d "$starttime" +"%s"`
end_seconds=`date -d "$endtime" +"%s"`
interval_time=$((end_seconds-start_seconds))
firstday=`date +"%j"`
firstweek=`date +"%U"`
currenttime=`date +"%Y年%m月%d日 %H:%M:%S"`
author=`cat $MODPATH/module.prop | grep 'author' | cut -d "=" -f 2`
#sleeptime=`cat $MODPATH/service.sh | grep 'sleep' | awk 'END{print $2}' | sed 's/s/秒/g;s/[0-9]$/&秒/g;s/m/分钟/g;s/h/小时/g;s/d/天/g' `
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
#coolapkTesting=`pm list package | grep -w 'com.coolapk.market'`

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
#     如果未设置[环境]，则默认值为"u:object_r:system_file:s0"
#     对于<目录>中的所有文件，它将调用：
#       set_perm 文件 所有者 组 文件权限 环境
#     对于<目录>中的所有目录（包括自身），它将调用：
#       set_perm 文件夹 所有者 组 权限 环境
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
















