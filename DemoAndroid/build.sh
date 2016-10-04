source ./update_assets.sh


NDKBUILD=`which ndk-build`
if [ -z "$NDKBUILD" ];then
    echo "Could not find the ndk-build utility, install Android's NDK and add it to the path"
    exit 1
fi

ANDROID=`which android`
if [ -z "$ANDROID" ];then
    echo "Could not find the android utility, install Android's SDK and add it to the path"
    exit 1
fi

ANT=`which ant`

if [ -z "$ANT" ];then
    echo "Could not find the ant utility, install Android's SDK and add it to the path"
    exit 1
fi

NCPUS="1"
case "$OSTYPE" in
    darwin*)
        NCPU=`sysctl -n hw.ncpu`
        ;; 
    linux*)
        if [ -n `which nproc` ]; then
            NCPUS=`nproc`
        fi  
        ;;
  *);;
esac




$ANDROID update project --path . --target android-19
$NDKBUILD -j $NCPUS
ant debug
adb install -r bin/TBDemo-debug.apk
adb shell am start -n com.fiffigt.tb.demo/.TBActivity
