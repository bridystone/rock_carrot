REM windows
adb shell "rm -rf /sdcard/Android/data/info.breidenstein.rock_carrot/filesupdatestati.json"
adb shell "mkdir /sdcard/Android/data/info.breidenstein.rock_carrot/"
adb shell "run-as info.breidenstein.rock_carrot cp -rf /data/user/0/info.breidenstein.rock_carrot/filesupdatestati.json /sdcard/Android/data/info.breidenstein.rock_carrot/filesupdatestati.json"
adb pull "/sdcard/Android/data/info.breidenstein.rock_carrot/filesupdatestati.json"