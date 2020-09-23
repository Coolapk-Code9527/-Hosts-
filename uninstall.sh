#!/system/bin/sh
sleep 20
#enable/disable/default-state
AD_Components=`dumpsys package --all-components | grep '/' | grep -iE '\.ad\.|ads\.|adsdk|adview|AdWeb|Advert|AdActivity|AdService|splashad|adsplash' | grep -viE ':|=|add|sync|load|read|setting' | sed 's/.* //g;s/}//g;s/^\/.*//g' | sort -u`
if [[ "$AD_Components" != "" ]];then
  for AD in $AD_Components;do
    pm enable $AD >/dev/null 2>&1
done
fi

Add_ADActivity=`cat ${0} | sed -n '/^#start/,/#end$/p' | awk '!/#/ {print $NF}' | sed 's/ //g'`
if [[ "$Add_ADActivity" != "" ]];then
for ADDAD in $Add_ADActivity;do
pm enable $ADDAD >/dev/null 2>&1
done
fi

data_storage=/data/data
media_storage=/data/media/0
find_ad_files=`find ${data_storage} ${media_storage} -type d -mindepth 1 -maxdepth 8 '(' -iname "ad" -o -iname "*.ad" -o -iname "ad.*" -o -iname "*.ad.*" -o -iname "*_ad" -o -iname "ad_*" -o -iname "*_ad_*" -o -iname "ad-*" -o -iname "ads" -o -iname "*.ads" -o -iname "ads.*" -o -iname "*.ads.*" -o -iname "*_ads" -o -iname "ads_*" -o -iname "*_ads_*" -o -iname "*adnet*" -o -iname "*splash*" ')' | grep -ivE 'rules|filter|block|white'`
if [[ "$find_ad_files" != "" ]];then
  for FADL in $find_ad_files;do
    if [[ -d "$FADL" ]];then
      chattr -R -i $FADL
      chmod -R 775 $FADL
  fi
done
fi

AD_FilesBlackList=`cat ${0} | sed -n '/^\#\#START/,/\#\#END$/p' | awk '!/#/ {print $NF}' | sed 's/ //g'`
if [[ "$AD_FilesBlackList" != "" ]];then
  for ADFL in $AD_FilesBlackList;do
    if [[ -d "$ADFL" ]];then
      chattr -R -i $ADFL
      chmod -R 775 $ADFL
  fi
done
fi

ad_miui_securitycenter=/data/data/com.miui.securitycenter/files/securityscan_homelist_cache
[[ -f "$ad_miui_securitycenter" ]] && { chattr -i $ad_miui_securitycenter;rm -f $ad_miui_securitycenter;am force-stop 'com.miui.securitycenter'; }

wait
exit 0



