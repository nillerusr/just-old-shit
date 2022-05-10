#!/bin/sh

sudo apt-get update
sudo apt install -y make unzip python3 ccache
wget https://dl.google.com/android/repository/android-ndk-r10e-linux-x86_64.zip
unzip android-ndk-r10e-linux-x86_64.zip
mv android-ndk-r10e ndk/
export ANDROID_NDK_HOME=$(pwd)/ndk

git clone --depth 1 https://gitlab.com/LostGamer/source-engine/ -b sanitize
cd source-engine/
mkdir libs/

build()
{
	./waf configure -T release --android=armeabi-v7a-hard,4.9,21 --prefix=android/ --out=build-android --togles --build-game=$1 --use-ccache
	./waf install --target=client,server 2> /dev/null
	mkdir -p fuck/$1
	cp android/lib/armeabi-v7a/libserver.so fuck/$1/
	cp android/lib/armeabi-v7a/libclient.so fuck/$1/
}

build episodic
build cstrike
build portal
build hl1

cp -r fuck ../
