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
systemsize=`df -h /system | awk 'NR==2{print $2}'`
systemused=`df -h /system | awk 'NR==2{print $3}'`
systemavail=`df -h /system | awk 'NR==2{print $4}'`
systemuse=`df -h /system | awk 'NR==2{print $5}'`
systemavailC=`df /system | awk 'NR==2{print $4}'`
systemsizeB=`df -h /system | awk 'NR==3{print $1}'`
systemusedB=`df -h /system | awk 'NR==3{print $2}'`
systemavailB=`df -h /system | awk 'NR==3{print $3}'`
systemuseB=`df -h /system | awk 'NR==3{print $4}'`
systemavailD=`df /system | awk 'NR==3{print $3}'`
#usagetets=`echo $usage | sed 's/.$//g'`
  [[ -d $ModulesPath/dnss && ! -f $ModulesPath/dnss/disable ]] && ui_print "- 本模块已支持DNS更改,无需再使用其他DNS模块❗"
  busybox --help >/dev/null 2>&1
  [ $? -ne 0 ] && ui_print "- 未检测到[BusyBox]模块,许多Linux命令将不能被执行,可能会发生错误‼️"
  hostsTesting=`find $ModulesPath -name "hosts" | grep -v 'hostsjj' | awk 'NR==1'`
  [[ -f $hostsTesting && -f $ModulesPath/hostsjj/system/etc/hosts ]] && ui_print "- 如已安装了同类其他hosts模块,请停用或卸载其他hosts模块,不然可能会有冲突导致此模块hosts无法生效❗"
  echoprint=' ------------------------------------------------------ '
  ui_print "$echoprint"
  
NewVersionA=`curl --connect-timeout 5 -m 5 -s 'https://raw.githubusercontent.com/Coolapk-Code9527/-Hosts-/master/README.md' | grep 'version' | cut -d 'V' -f 2`
NewVersionB=`curl --connect-timeout 5 -m 5 -s 'https://gitee.com/coolapk-code_9527/border/raw/master/README.md' | grep 'version' | cut -d 'V' -f 2`
Version=`cat $MODPATH/module.prop | grep 'version' | cut -d 'V' -f 2`
if [[ $NewVersionA != "" && `echo "$NewVersionA > $Version" | bc` -eq 1 ]];then
  ui_print "- 检测到有新版本[️GitHub🆕v$NewVersionA],可关注作者获取更新❗"
  ui_print "$echoprint"
elif [[ $? -ne 0 && `echo "$NewVersionB > $Version" | bc` -eq 1 ]];then
  ui_print "- 检测到有新版本[Gitee🆕v$NewVersionB],可关注作者获取更新❗"
  ui_print "$echoprint"
fi

  ui_print "- 安装过程可能需较长的时间,请耐心等待……"
  ui_print "$echoprint"
  
  ui_print "- 【hosts文件】"
  ui_print "大小：$usage  行数：$count 行  修改日期：$modifytime"
  ui_print "$echoprint"
if [[ $systemsize != "" || $systemused != "" || $systemavail != "" || $systemuse != "" ]];then
  ui_print "- 【system分区】"
  ui_print "大小：$systemsize  已用：$systemused  剩余：$systemavail  占用率：$systemuse"
  [[ "$systemavailC" > "$usageAB" ]] || ui_print "- 【system分区】剩余空间小于模块【hosts文件】大小,可能会发生错误‼️"
  ui_print "$echoprint"
elif [[ $systemsizeB != "" || $systemusedB != "" || $systemavailB != "" || $systemuseB != "" ]];then
  ui_print "- 【system分区】"
  ui_print "大小：$systemsizeB  已用：$systemusedB  剩余：$systemavailB  占用率：$systemuseB"
  [[ "$systemavailD" > "$usageAB" ]] || ui_print "- 【system分区】剩余空间小于模块【hosts文件】大小,可能会发生错误‼️"
  ui_print "$echoprint"
fi

  ui_print "- 【清除应用Cache】"
clearA=/data/data/*/cache/*
clearB=/data/media/0/Android/data/*/cache/*
findcacheA=`du -csk $clearA | awk 'END{print $(NF-1)}' | cut -d 'M' -f 1`
findcacheB=`du -csk $clearB | awk 'END{print $(NF-1)}' | cut -d 'M' -f 1`
findcacheAB=`echo | awk "{print ($findcacheA+$findcacheB)/1024}"`
find --help >/dev/null 2>&1
if [ $? -eq 0 ];then
find $clearA $clearB | xargs rm -rf {} \ >/dev/null 2>&1
rm -rf /data/media/0/miad/* >/dev/null 2>&1
chmod 000 /data/media/0/miad >/dev/null 2>&1
findcacheB=`du -csk $clearA | awk 'END{print $(NF-1)}' | cut -d 'M' -f 1`
findcacheC=`du -csk $clearB | awk 'END{print $(NF-1)}' | cut -d 'M' -f 1`
findcacheBC=`echo | awk "{print ($findcacheB+$findcacheC)/1024}"`
findcacheDC=`echo | awk "{print $findcacheAB-$findcacheBC}" | awk '{printf("%.f\n",$1)}'`
  ui_print "清除：$findcacheDC M"
  ui_print "$echoprint"
else
  ui_print "清理失败,缺少[find]工具支持,请安装[BusyBox]模块!"
  ui_print "$echoprint"
fi

  ui_print "- 【禁用应用ADActivity】"
findADActivity=`cat $MODPATH/customize.sh | grep 'pm disable ' | cut -d '>' -f 1 | awk '!/#/ {print $NF}' | cut -d '/' -f 2 | awk 'NR>1'`
settings put global personalized_ad_time '0'
settings put global personalized_ad_enabled '0'
settings put global passport_ad_status 'OFF'
# AD-Activity
packages=`dumpsys package | grep -iE 'Package \[|com\..*\.ads\..*Activity$' | grep -iB 1 'Activity' | grep -vE '\/|\-' | grep 'Package' | cut -d '[' -f 2 | cut -d ']' -f 1`
#enable/disable
for AD in $packages ;do
pm disable $AD/com.qq.e.ads.ADActivity >/dev/null 2>&1
pm disable $AD/com.qq.e.ads.PortraitADActivity >/dev/null 2>&1
pm disable $AD/com.qq.e.ads.LandscapeADActivity >/dev/null 2>&1
pm disable $AD/com.qq.e.ads.RewardvideoLandscapeADActivity >/dev/null 2>&1
pm disable $AD/com.qq.e.ads.RewardvideoPortraitADActivity >/dev/null 2>&1
pm disable $AD/com.google.android.gms.ads.AdActivity >/dev/null 2>&1
pm disable $AD/com.facebook.ads.AudienceNetworkActivity >/dev/null 2>&1
pm disable $AD/com.facebook.ads.internal.ipc.RemoteANActivity >/dev/null 2>&1
pm disable $AD/com.facebook.ads.InterstitialAdActivity >/dev/null 2>&1
done
  ui_print "$findADActivity"
  ui_print "$echoprint"
  
  
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
iptdnsTesting=`iptables -t nat -nL OUTPUT --line-numbers | grep DNAT | awk '{print $(NF)}' | cut -d ':' -f 2-`
ipt6dnsTesting=`ip6tables -t nat -nL OUTPUT --line-numbers | grep DNAT | awk '{print $(NF)}' | cut -d ':' -f 2-`
#[ $iptdnsTesting != "" ] && ui_print "- 检测到本机已设置DNS目标地址转换,如除本模块外还安装了同类模块请先停用,不然可能会起冲突!"

[[ $iptdnsTesting != "" ]] && iptables -t nat -F OUTPUT >/dev/null 2>&1
[[ $ipt6dnsTesting != "" ]] && ip6tables -t nat -F OUTPUT >/dev/null 2>&1

if [[ -s $MODPATH/ipv4dns.prop ]];then
for dns in $ipv4dns ;do
    setsid ping -c 5 -A -w 1 $dns >> $MODPATH/ipv4dns.log
    sleep 0.2
done
fi

ip6tables -t nat -nL >/dev/null 2>&1
if [[ $? -eq 0 && -s $MODPATH/ipv6dns.prop ]];then
for dnss in $ipv6dns; do
    setsid ping6 -c 5 -A -w 1 $dnss >> $MODPATH/ipv6dns.log
    sleep 0.2
done
fi

if [[ $AndroidSDK -ge "28" && $dotmode != "" && -s $MODPATH/ipv4dnsovertls.prop ]];then
for dot in $ipv4dnsovertls; do
    setsid ping -c 5 -A -w 1 $dot >> $MODPATH/ipv4dnsovertls.log
    sleep 0.2
done
fi

if [[ $AndroidSDK -ge "28" && $dotmode != "" && -s $MODPATH/ipv6dnsovertls.prop ]];then
for dots in $ipv6dnsovertls; do
    setsid ping6 -c 5 -A -w 1 $dots >> $MODPATH/ipv6dnsovertls.log
    sleep 0.2
done
fi

avg=`cat $MODPATH/ipv4dns.log | grep 'min/avg/max' | cut -d "=" -f 2 | cut -d "/" -f 2 | awk '{print $1}' | sort -n | awk 'NR==1{print $1}' `
ewma=`cat $MODPATH/ipv4dns.log | grep -w 'ipg/ewma' | awk '{print $(NF-1)}' | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
dnsavg=`cat $MODPATH/ipv4dns.log | grep -B 2 $avg | awk 'NR==1{print $2}' `
dnsewma=`cat $MODPATH/ipv4dns.log | grep -B 2 $ewma | awk 'NR==1{print $2}' `
avgname=`cat $MODPATH/ipv4dns.prop | grep $dnsavg | cut -d "=" -f 1`
ewmaname=`cat $MODPATH/ipv4dns.prop | grep $dnsewma | cut -d "=" -f 1`

if [[ $dnsavg != "" ]];then
    iptables -t nat -F OUTPUT
    iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination $dnsavg:53
    iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination $dnsavg:53
    ui_print "IPV4_DNS：[$avgname] $dnsavg "
elif [[ $dnsewma != "" ]];then
    iptables -t nat -F OUTPUT
    iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination $dnsewma:53
    iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination $dnsewma:53
    ui_print "IPV4_DNS：[$ewmaname] $dnsewma "
fi

ipv6avg=`cat $MODPATH/ipv6dns.log | grep 'min/avg/max' | cut -d "=" -f 2 | cut -d "/" -f 2 | awk '{print $1}' | sort -n | awk 'NR==1{print $1}' `
ipv6ewma=`cat $MODPATH/ipv6dns.log | grep -w 'ipg/ewma' | awk '{print $(NF-1)}' | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
ipv6dnsavg=`cat $MODPATH/ipv6dns.log | grep -B 2 $ipv6avg | awk 'NR==1{print $2}' `
ipv6dnsewma=`cat $MODPATH/ipv6dns.log | grep -B 2 $ipv6ewma | awk 'NR==1{print $2}' `
ipv6avgname=`cat $MODPATH/ipv6dns.prop | grep $ipv6dnsavg | cut -d "=" -f 1`
ipv6ewmaname=`cat $MODPATH/ipv6dns.prop | grep $ipv6dnsewma | cut -d "=" -f 1`

if [[ $ipv6dnsavg != "" ]];then
    ip6tables -t nat -F OUTPUT
    ip6tables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination $ipv6dnsavg:53
    ip6tables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination $ipv6dnsavg:53
    ui_print "IPV6_DNS：[$ipv6avgname] $ipv6dnsavg "
elif [[ $ipv6dnsavg != "" ]];then
    ip6tables -t nat -F OUTPUT
    ip6tables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination $ipv6dnsewma:53
    ip6tables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination $ipv6dnsewma:53
    ui_print "IPV6_DNS：[$ipv6ewmaname] $ipv6dnsewma "
fi

dotavg=`cat $MODPATH/ipv4dnsovertls.log | grep 'min/avg/max' | cut -d "=" -f 2 | cut -d "/" -f 2 | awk '{print $1}' | sort -n | awk 'NR==1{print $1}' `
dotewma=`cat $MODPATH/ipv4dnsovertls.log | grep -w 'ipg/ewma' | awk '{print $(NF-1)}' | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
dotdnsavg=`cat $MODPATH/ipv4dnsovertls.log | grep -B 2 $dotavg | awk 'NR==1{print $2}' `
dotdnsewma=`cat $MODPATH/ipv4dnsovertls.log | grep -B 2 $dotewma | awk 'NR==1{print $2}' `
ipv6dotavg=`cat $MODPATH/ipv6dnsovertls.log | grep 'min/avg/max' | cut -d "=" -f 2 | cut -d "/" -f 2 | awk '{print $1}' | sort -n | awk 'NR==1{print $1}' `
ipv6dotewma=`cat $MODPATH/ipv6dnsovertls.log | grep -w 'ipg/ewma' | awk '{print $(NF-1)}' | sort -t '/' -k 2n | awk 'NR==1{print $1}' `
ipv6dotdnsavg=`cat $MODPATH/ipv6dnsovertls.log | grep -B 2 $ipv6dotavg | awk 'NR==1{print $2}' `
ipv6dotdnsewma=`cat $MODPATH/ipv6dnsovertls.log | grep -B 2 $ipv6dotewma | awk 'NR==1{print $2}' `

if [[ $AndroidSDK -ge "28" && $dotmode != "" && $dotdnsavg != "" ]];then
    ui_print "$echoprint"
    ui_print "- 【系统支持DNS Over TLS】"
    [[ `echo "$dotavg > $ipv6dotavg" | bc` -eq 1 ]] && settings put global private_dns_specifier $ipv6dotdnsavg || settings put global private_dns_specifier $dotdnsavg
    dotspecifier=`settings get global private_dns_specifier`
    dotavgname=`cat $MODPATH/ipv4dnsovertls.prop | grep $dotspecifier | cut -d "=" -f 1`
    ipv6dotavgname=`cat $MODPATH/ipv6dnsovertls.prop | grep $dotspecifier | cut -d "=" -f 1`
    [[ `echo "$dotavg > $ipv6dotavg" | bc` -eq 1 ]] && ui_print "DNS_Over_TLS：[$ipv6dotavgname] $dotspecifier " || ui_print "DNS_Over_TLS：[$dotavgname] $dotspecifier "
    [[ $dotspecifier = 'dns.cfiec.net' ]] && ui_print "此DNS服务商仅支持IPV6网络❗"
    
elif [[ $AndroidSDK -ge "28" && $dotmode != "" && $dotdnsewma != "" ]];then
    ui_print "$echoprint"
    ui_print "- 【系统支持DNS Over TLS】"
    [[ `echo "$dotewma > $ipv6dotewma" | bc` -eq 1 ]] && settings put global private_dns_specifier $ipv6dotdnsewma || settings put global private_dns_specifier $dotdnsewma
    dotspecifier=`settings get global private_dns_specifier`
    dotewmaname=`cat $MODPATH/ipv4dnsovertls.prop | grep $dotspecifier | cut -d "=" -f 1`
    ipv6dotewmaname=`cat $MODPATH/ipv6dnsovertls.prop | grep $dotspecifier | cut -d "=" -f 1`
    [[ `echo "$dotewma > $ipv6dotewma" | bc` -eq 1 ]] && ui_print "DNS_Over_TLS：[$ipv6dotewmaname] $dotspecifier " || ui_print "DNS_Over_TLS：[$dotewmaname] $dotspecifier "
    [[ $dotspecifier = 'dns.cfiec.net' ]] && ui_print "此DNS服务商仅支持IPV6网络❗"
fi

if [[ $AndroidSDK -ge "28" && $dotmode != "" && $dotmode = "opportunistic" ]];then
    ui_print "DNS_Over_TLS状态：[自动🔄]"
    ui_print "[DNS Over TLS]比普通DNS更安全但可能并不是很稳定,请酌情启用!"
    ui_print "仅更改服务器地址,未调整开关状态,加密DNS优先级大于iptables规则!"
    ui_print "如网络出问题请[关闭].(无法连接网络、无法加载图片、连接VPN没网等❗)"
elif [[ $AndroidSDK -ge "28" && $dotmode != "" && $dotmode = "off" ]];then
    ui_print "DNS_Over_TLS状态：[关闭❎]"
    ui_print "如需开启："
    ui_print "[MIUI]-设置-连接与共享-私人DNS"
    ui_print "[参考]-设置-无线和网络-加密DNS/私密DNS/私人DNS"
    ui_print "[其他]-设置-网络和互联网-高级-加密DNS/私密DNS/私人DNS"
    ui_print "[DNS Over TLS]比普通DNS更安全但可能并不是很稳定,请酌情启用!"
    ui_print "仅更改服务器地址,未调整开关状态,加密DNS优先级大于iptables规则!"
    ui_print "如网络出问题请[关闭].(无法连接网络、无法加载图片、连接VPN没网等❗)"
elif [[ $AndroidSDK -ge "28" && $dotmode != "" && $dotmode = "hostname" ]];then
    ui_print "DNS_Over_TLS状态：[开启✅]"
    ui_print "如需关闭："
    ui_print "[MIUI]-设置-连接与共享-私人DNS"
    ui_print "[参考]-设置-无线和网络-加密DNS/私密DNS/私人DNS"
    ui_print "[其他]-设置-网络和互联网-高级-加密DNS/私密DNS/私人DNS"
    ui_print "[DNS Over TLS]比普通DNS更安全但可能并不是很稳定,请酌情启用!"
    ui_print "仅更改服务器地址,未调整开关状态,加密DNS优先级大于iptables规则!"
    ui_print "如网络出问题请[关闭].(无法连接网络、无法加载图片、连接VPN没网等❗)"
fi

echo > $MODPATH/ipv4dns.log
echo > $MODPATH/ipv6dns.log
echo > $MODPATH/ipv4dnsovertls.log
echo > $MODPATH/ipv6dnsovertls.log

  ui_print "$echoprint"
  ProjectAddress=`cat $hosts | sed -n '4,6p' | awk '{print $2}'`
  ui_print "- 【订阅地址-GitHub/Gitee】"
  ui_print "$ProjectAddress"
  ui_print "$echoprint"

endtime=`date +"%Y-%m-%d %H:%M:%S"`
start_seconds=`date -d "$starttime" +%s`
end_seconds=`date -d "$endtime" +%s`
interval_time=$(($end_seconds-$start_seconds))
firstday=`date +%j`
firstweek=`date +%U`
currenttime=`date +"%Y年%m月%d日 %H:%M:%S"`
author=`cat $MODPATH/module.prop | grep author | cut -d "=" -f 2`
sleeptime=`cat $MODPATH/service.sh | grep 'sleep' | awk 'END{print $2}' | sed -e 's/s/秒/g' -e 's/m/分钟/g' -e 's/h/小时/g' -e 's/d/天/g' `
week=`date +'%w' | sed -e 's/0/星期日/g' -e 's/1/星期一/g' -e 's/2/星期二/g' -e 's/3/星期三/g' -e 's/4/星期四/g' -e 's/5/星期五/g' -e 's/6/星期六/g' `
#  ui_print "- 循环延时：$sleeptime"
  [[ $(($interval_time%3600/60)) -ge "1" ]] && ui_print "- 安装耗时：$(($interval_time%3600/60))分$(($interval_time%3600%60))秒" || ui_print "- 安装耗时：$interval_time秒"
  ui_print "- 系统时间：$currenttime $week 今年第$firstweek周/$firstday天"
  [[ ! -f /system/xbin/busybox && ! -f /system/bin/busybox ]] && ui_print "- 对于ROOT设备,建议安装[BusyBox]模块以完整的支持更多命令‼️"
  ui_print "$echoprint"
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
















