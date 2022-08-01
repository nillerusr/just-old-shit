#!/bin/sh

sudo apt-get update
sudo apt install -y make unzip python3 ccache imagemagick openjdk-8-jdk openjdk-8-jre ant-contrib
wget https://dl.google.com/android/repository/android-ndk-r10e-linux-x86_64.zip -o /dev/null
unzip android-ndk-r10e-linux-x86_64.zip > /dev/null
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.1.0/clang+llvm-11.1.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz -o /dev/null
tar xvf clang+llvm-11.1.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz > /dev/null
mv clang+llvm-11.1.0-x86_64-linux-gnu-ubuntu-16.04 clang/
export PATH=$(pwd)/clang/bin:$PATH

mv android-ndk-r10e ndk/
export ANDROID_NDK_HOME=$(pwd)/ndk

git clone --depth 1 https://github.com/nillerusr/source-engine/ --recursive
git clone --depth 1 https://gitlab.com/LostGamer/android-sdk
export ANDROID_HOME=$(pwd)/android-sdk/
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

mkdir -p libs/ apks/
git clone --depth 1 https://github.com/nillerusr/srceng-mod-launcher

#build()
#{
	MOD_NAME=$1
	MOD_VER=$2
	APP_NAME=$3
	VPK_NAME=$4
	VPK_VERSION=$5

	cd source-engine/
	./waf configure -T release --android=aarch64,host,21 --prefix=android/ --out=build-android --togles --build-game=$MOD_NAME --use-ccache --disable-warns || exit
	./waf install --target=client,server || exit
	mkdir -p ../libs/$1

	cp android/lib/arm64-v8a/libserver.so ../libs/$1/
	cp android/lib/arm64-v8a/libclient.so ../libs/$1/
	rm -rf android/

	cd ../srceng-mod-launcher/
	git checkout .
	sed -e "s/MOD_REPLACE_ME/$MOD_NAME/g" -i AndroidManifest.xml src/me/nillerusr/LauncherActivity.java
	sed -e "s/APP_NAME/$APP_NAME/g" -i res/values/strings.xml
	sed -e "s/1.05/$MOD_VER/g" -i AndroidManifest.xml
#	sed -e 's/"com.valvesoftware.source"/"com.valvesoftware.source64"/g' -i src/me/nillerusr/LauncherActivity.java

	scripts/conv.sh ../resources/$MOD_NAME/ic_launcher.png

	mkdir -p libs/arm64-v8a/
	cp ../libs/$MOD_NAME/libserver.so ../libs/$MOD_NAME/libclient.so libs/arm64-v8a

	if ! [ -z $VPK_NAME ];then
		mkdir -p assets
		cp ../resources/$MOD_NAME/$VPK_NAME assets/
		sed -e "s/PACK_NAME/$VPK_NAME/g" -i src/me/nillerusr/ExtractAssets.java
		sed -e "s/1337/$VPK_VERSION/g" -i src/me/nillerusr/ExtractAssets.java
	fi

	ant debug && cp bin/srcmod-debug.apk ../apks/$MOD_NAME-$MOD_VER.apk
	rm -rf gen bin lib assets
	cd ../
#}

