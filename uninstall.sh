#!/system/bin/sh
sleep 20
#enable/disable
AD_Components=`dumpsys package --all-components | grep '/' | grep -iE '\.ad\.|ads\.|adsdk|AdWeb|Advert|AdActivity|AdService' | grep -viE ':|=|add|load|read' | sed 's/.* //g;s/}//g;s/^\/.*//g'`
if [[ "$AD_Components" != "" ]];then
  for AD in $AD_Components;do
    pm enable $AD >/dev/null 2>&1
done
fi

Add_ADActivity=`cat ${0} | sed -n '/^#start/,/#end$/p' | awk '!/#/ {print $NF}' | sed 's/ //g'`
if [[ -s "${0}" ]];then
for ADDAD in $Add_ADActivity;do
pm enable $ADDAD >/dev/null 2>&1
done
fi

AD_FilesList=`cat ${0} | sed -n '/^\#\#START/,/\#\#END$/p' | awk '!/#/ {print $NF}' | sed 's/ //g'`
if [[ -s "${0}" ]];then
  for ADFL in $AD_FilesList;do
    if [[ -d "$ADFL" ]];then
      chattr -R -i $ADFL
      chmod -R 775 $ADFL
    fi
  done
fi

