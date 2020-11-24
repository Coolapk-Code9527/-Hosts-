#!/system/bin/sh
sleep 20
#enable/disable/default-state
AD_Components=`dumpsys package --all-components | grep '/' | grep -iE "$Component_Keyword_Blacklist_D" | grep -viE "$Component_Keyword_Whitelist_E" | sed 's/.* //g;s/}//g;s/^\/.*//g' | sort -u`
if [[ "$AD_Components" != "" ]];then
  for AD in $AD_Components;do
    pm enable $AD >/dev/null 2>&1
done
fi

Add_ADActivity=`cat ${0} | sed -n '/^#Disable_Components_Start/,/#Disable_Components_End$/p' | awk '!/#/ {print $NF}' | sed 's/ //g'`
if [[ "$Add_ADActivity" != "" ]];then
for ADDAD in $Add_ADActivity;do
pm enable $ADDAD >/dev/null 2>&1
done
fi

data_storage=/data/data
media_storage=/data/media/0
find_ad_files=`find ${data_storage} ${media_storage} -type d -mindepth 1 -maxdepth 8 '(' -iname "ad" -o -iname "*.ad" -o -iname "ad.*" -o -iname "*.ad.*" -o -iname "*_ad" -o -iname "ad_*" -o -iname "*_ad_*" -o -iname "ad-*" -o -iname "ads" -o -iname "*.ads" -o -iname "ads.*" -o -iname "*.ads.*" -o -iname "*_ads" -o -iname "ads_*" -o -iname "*_ads_*" -o -iname "*adnet*" -o -iname "*splash*" -o -iname "*advertise*" ')' | grep -ivE 'rules|filter|block|white|mxtech'`
if [[ "$find_ad_files" != "" ]];then
  for FADL in $find_ad_files;do
    if [[ -d "$FADL" ]];then
      chattr -R -i $FADL
      chmod -R 775 $FADL
  fi
done
fi

AD_FilesBlackList=`cat ${0} | sed -n '/^#Disable_Folder_Start/,/#Disable_Folder_End$/p' | awk '!/#/ {print $NF}' | sed 's/ //g'`
if [[ "$AD_FilesBlackList" != "" ]];then
  for ADFL in $AD_FilesBlackList;do
    if [[ -d "$ADFL" ]];then
      chattr -R -i $ADFL
      chmod -R 775 $ADFL
  fi
done
fi

ad_miui_securitycenter=/data/data/com.miui.securitycenter/files
if [[ -e "$ad_miui_securitycenter" ]];then
[[ -f "$ad_miui_securitycenter/securityscan_homelist_cache" ]] && { chattr -i $ad_miui_securitycenter/securityscan_homelist_cache; rm -f $ad_miui_securitycenter/securityscan_homelist_cache; }
am force-stop 'com.miui.securitycenter'
fi

IFW=/data/system/ifw
if [[ -f "$IFW/AD_Components_Blacklist.xml" ]];then
rm -f $IFW/AD_Components_Blacklist.xml
fi

wait
exit



