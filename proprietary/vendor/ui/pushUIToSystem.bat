@ECHO OFF
echo author: lych
title Replacement resource
mode con cp select=936
setlocal enabledelayedexpansion
echo waiting to connect the device
adb version
adb kill-server 
adb wait-for-device
adb devices
adb root
adb remount
cls

echo connected
::phone info
adb shell cat /system/build.prop>phone.info

for /F "tokens=1,2 delims==" %%a in (phone.info) do (

    if %%a == ro.build.version.release set androidOS=%%b

    if %%a == ro.product.model set model=%%b
	
	if %%a == ro.fota.version set Rom_version=%%b
	
	if %%a == ro.build.type set rom_type=%%b
)

del /a/f/q phone.info

echo ---------------------------------------------------------
echo phone model:    %model%
echo system version: Android %androidOS%
echo ROM version:    %Rom_version%
echo ROM type£º      %rom_type%
echo ---------------------------------------------------------


if %rom_type == user (
echo "this is a release version.  please brush userdebug version"
pause
goto :EOF
)



set SOURCE_DIR_ROOT=%cd%\
set TARGET_DIR_ROOT=vendor/ui/
set extension=*.png *.db
echo source dir root: %SOURCE_DIR_ROOT%
echo target dir root: %TARGET_DIR_ROOT%

::calculate the source dir path length
set str=%SOURCE_DIR_ROOT%

:count
if not "%str%"=="" (
set /a len+=1
set "str=%str:~1%"
goto :count
)
set n=%len%
echo the dir length is %n%


set folder=%TARGET_DIR_ROOT%

echo -------------------
echo remove or overwrite the old resources
echo 1.remove	2.overwrite
echo -------------------
set /p selmodel=¡·¡·plz select the module£º


:: remove all
if %selmodel% == 1 (
echo waiting to remove all resource
adb shell rm -rf %TARGET_DIR_ROOT%/*
echo end of remove.
)

if %selmodel% == 2 (
echo overwrite the resource
)

pause

goto :pushResource
:pushResource
Echo "push resources to %TARGET_DIR_ROOT%"
Echo "waiting....."

for /r %%i in (%extension%) do (
set "file_path=%%i"
rem echo file_path: !file_path!

set "folder=%%~dpi"
set "target_folder=%TARGET_DIR_ROOT%!folder:~%n%,-1!"
set "target_folder=!target_folder:\=/!"
rem echo target folder name: !target_folder!

rem create the target folder.
adb shell mkdir -p !target_folder!
adb push !file_path! !target_folder!
)

echo "push resource end"

echo "start to clear launcher data."

adb shell pm clear com.android.launcher3

echo ""

Echo "clear launcher data end."

Pause
EXIT