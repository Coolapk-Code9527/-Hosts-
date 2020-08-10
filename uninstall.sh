#!/system/bin/sh
sleep 20
# AD-Activity
packages=`dumpsys package | grep -iE 'Package \[|com\..*\.ads\..*Activity$' | grep -iB 1 'Activity' | grep -vE '\/|\-' | grep 'Package' | cut -d '[' -f 2 | cut -d ']' -f 1`
#pm enable/disable
for AD in $packages ;do
pm enable $AD/com.qq.e.ads.ADActivity >/dev/null 2>&1
pm enable $AD/com.qq.e.ads.PortraitADActivity >/dev/null 2>&1
pm enable $AD/com.qq.e.ads.LandscapeADActivity >/dev/null 2>&1
pm enable $AD/com.qq.e.ads.RewardvideoLandscapeADActivity >/dev/null 2>&1
pm enable $AD/com.qq.e.ads.RewardvideoPortraitADActivity >/dev/null 2>&1
pm enable $AD/com.google.android.gms.ads.AdActivity >/dev/null 2>&1
pm enable $AD/com.facebook.ads.AudienceNetworkActivity >/dev/null 2>&1
pm enable $AD/com.facebook.ads.internal.ipc.RemoteANActivity >/dev/null 2>&1
pm enable $AD/com.facebook.ads.InterstitialAdActivity >/dev/null 2>&1
done

Add_ADActivity=`cat ${0} | sed -n '/^#start/,/#end$/p' | awk '!/#/ {print $NF}' | sed 's/ //g'`
if [[ -s ${0} ]];then
for ADDAD in $Add_ADActivity;do
pm enable $ADDAD >/dev/null 2>&1
done
fi

