#!/system/bin/sh
sleep 20
#enable/disable
ad_package=`dumpsys package | grep -iE 'Package \[|\.ad\.' | grep -v '/' | grep -iB 1 '\.ad\.' | grep 'Package' | sed 's/.*\[//g;s/\].*//g'`
ad_activity=`dumpsys package | grep -i '\.ad\.' | grep -vE '\/|:' | sort -b | uniq | sed 's/ //g;s/^/\/&/g'`
if [[ "$ad_package" != "" && "$ad_activity" != "" ]];then
for AdPackage in $ad_package;do
  for AdActivity in $ad_activity;do
    pm enable ${AdPackage}${AdActivity} >/dev/null 2>&1
  done
done
fi

ads_package=`dumpsys package | grep -iE 'Package \[|\.ads\.' | grep -v '/' | grep -iB 1 '\.ads\.' | grep 'Package' | sed 's/.*\[//g;s/\].*//g'`
ads_adactivity=`dumpsys package | grep -i '\.ads\.' | grep -vE '\/|:' | sort -b | uniq | sed 's/ //g;s/^/\/&/g'`
if [[ "$ads_package" != "" && "$ads_adactivity" != "" ]];then
for AdsPackage in $ads_package;do
  for AdsActivity in $ads_adactivity;do
    pm enable ${AdsPackage}${AdsActivity} >/dev/null 2>&1
  done
done
fi

ad_component=`dumpsys package | grep -i '\.ad\.' | grep '/' | grep -viE ':|=|Download|Read|Upload' | sed 's/.* //g;s/}//g'`
if [[ "$ad_component" != "" ]];then
  for AdComponent in $ad_component;do
    pm enable $AdComponent >/dev/null 2>&1
done
fi
ads_component=`dumpsys package | grep -i '.ads\.' | grep '/' | grep -viE ':|=|Download|Read|Upload' | sed 's/.* //g;s/}//g'`
if [[ "$ads_component" != "" ]];then
  for AdsComponent in $ads_component;do
    pm enable $AdsComponent >/dev/null 2>&1
done
fi

adsdk=`dumpsys package | grep -i 'adsdk' | grep 'Provider{' | sed 's/.*Provider{.* //g;s/}//g'`
if [[ "$adsdk" != "" ]];then
  for Ad_sdk in $adsdk;do
    pm enable $Ad_sdk >/dev/null 2>&1
done
fi

ADActivity=`dumpsys package | grep -i 'ADActivity' | grep '/' | grep -viE ':|=|Download|Read|Upload' | sed 's/.* //g'`
if [[ "$ADActivity" != "" ]];then
  for AD_Activity in $ADActivity;do
    pm enable $AD_Activity >/dev/null 2>&1
done
fi

Add_ADActivity=`cat ${0} | sed -n '/^#start/,/#end$/p' | awk '!/#/ {print $NF}' | sed 's/ //g'`
if [[ -s "${0}" ]];then
for ADDAD in $Add_ADActivity;do
pm enable $ADDAD >/dev/null 2>&1
done
fi

