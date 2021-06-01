REM windows
adb shell "rm -rf /sdcard/Android/data/info.breidenstein.rock_carrot/databases/sandsteinklettern.db"
adb shell "run-as info.breidenstein.rock_carrot cp -rf /data/user/0/info.breidenstein.rock_carrot/databases/sandsteinklettern.db /sdcard/Android/data/info.breidenstein.rock_carrot/databases/sandsteinklettern.db"
adb pull "/sdcard/Android/data/info.breidenstein.rock_carrot/databases/sandsteinklettern.db"