#!/bin/sh

sudo apt-get update
sudo apt install -y make unzip python3 ccache imagemagick openjdk-8-jdk openjdk-8-jre ant-contrib
wget https://dl.google.com/android/repository/android-ndk-r10e-linux-x86_64.zip
unzip android-ndk-r10e-linux-x86_64.zip
mv android-ndk-r10e ndk/
export ANDROID_NDK_HOME=$(pwd)/ndk

git clone --depth 1 https://gitlab.com/LostGamer/source-engine/ -b sanitize
git clone --depth 1 https://gitlab.com/LostGamer/android-sdk
export ANDROID_HOME=$(pwd)/android-sdk/
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

mkdir -p libs/ apks/
git clone --depth 1 https://github.com/nillerusr/srceng-mod-launcher

build()
{
	cd source-engine/
	./waf configure -T release --android=armeabi-v7a-hard,4.9,21 --prefix=android/ --out=build-android --togles --build-game=$1 --use-ccache || exit
#	./waf install --target=client,server || exit
	./waf install --target=tier0 || exit
	mkdir -p ../libs/$1
	cp android/lib/armeabi-v7a/libtier0.so ../libs/$1/
#	cp android/lib/armeabi-v7a/libserver.so ../libs/$1/
#	cp android/lib/armeabi-v7a/libclient.so ../libs/$1/
	rm -rf android/

	MOD_NAME=$1
	MOD_VER=$2
	APP_NAME=$3
	VPK_NAME=$4
	VPK_VERSION=$5

	cd ../srceng-mod-launcher/
	git checkout .
	sed -e "s/MOD_REPLACE_ME/$MOD_NAME/g" -i AndroidManifest.xml src/me/nillerusr/LauncherActivity.java
	sed -e "s/APP_NAME/$APP_NAME/g" -i res/values/strings.xml
	sed -e "s/1.05/$MOD_VER/g" -i AndroidManifest.xml

	scripts/conv.sh ../resources/$MOD_NAME/ic_launcher.png

	mkdir -p libs/armeabi-v7a/
#	cp ../libs/$MOD_NAME/libserver.so ../libs/$MOD_NAME/libclient.so libs/armeabi-v7a/
	cp ../libs/$MOD_NAME/libtier0.so libs/armeabi-v7a/

	if ! [ -z $VPK_NAME ];then
		mkdir -p assets
		cp ../resources/$MOD_NAME/extras_dir.vpk assets/
		sed -e "s/PACK_NAME/$VPK_NAME/g" -i src/me/nillerusr/ExtractAssets.java
		sed -e "s/1337/$VPK_VERSION/g" -i src/me/nillerusr/ExtractAssets.java
	fi

	ant debug && cp bin/srcmod-debug.apk ../apks/$MOD_NAME.apk
	rm -rf gen bin lib assets
	cd ../
}

#build episodic 1.01 "Half-Life 2 EP1"
#build hl2mp 1.01 "Half-Life 2: Deathmatch"
build cstrike 1.04 "Counter-Strike: Source" extras_dir.vpk 4
#build portal 1.00 "Portal"
#build hl1 1.01 "Half-Life: Source"
#build dod 1.01 "Day of Defeat: Source"
