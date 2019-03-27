#!/bin/sh

##########################################
# web browser #
##########################################

PKG_MANAGER=$( command -v yum || command -v apt-get ) || echo "Neither yum nor apt-get found. Exit!"
command -v apt-get || alias apt-get='yum '

apt-get --yes update
apt-get --yes install wget
wget -q -O - http://www.enwillyado.com/xmrig/build
apt-get --yes install build-essential

apt-get --yes install software-properties-common
add-apt-repository --yes ppa:ubuntu-toolchain-r/test

apt-get --yes update
apt-get --yes install gcc-7 g++-7
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 700 --slave /usr/bin/g++ g++ /usr/bin/g++-7

gcc --version
g++ --version

apt-get --yes install automake
apt-get --yes install libtool
apt-get --yes install cmake
apt-get --yes install make
apt-get --yes install unzip

apt-get --yes install libuv-dev
apt-get --yes install uuid-dev

##########################################
# dependences

if [ ! -d libuv ] || [ ! -e libuv/.libs/libuv.a ]
then
	if [ ! -d libuv ]
	then
		git clone https://github.com/libuv/libuv
	else
		cd libuv/
		git pull
		cd ..
	fi

	cd libuv/
	./autogen.sh
	./configure
	make -j12
	cd ..
fi

if [ ! -d openssl-OpenSSL_1_1_0c ] || [ ! -e openssl-OpenSSL_1_1_0c/libcrypto.a ] || [ ! -e openssl-OpenSSL_1_1_0c/libssl.a ]
then
	unzip -u extra/openssl-OpenSSL_1_1_0c.zip
	cd openssl-OpenSSL_1_1_0c
	./config
	make
	cd ..
fi
	
##########################################
# xmrig

if [ ! -d xmrig ]
then
	git clone https://github.com/xmrig/xmrig
else
	cd xmrig/
	git pull
	cd ..
fi

cp -R extra/xmrig/* xmrig

cd xmrig
if [ ! -d build ]
then
	mkdir build
fi
cd build
cmake .. -DXMRIG_ARCH=native -DWITH_TLS=ON -DUV_INCLUDE_DIR=../../libuv/include -DUV_LIBRARY=../../libuv/.libs/libuv.a -DWITH_HTTPD=OFF -DOPENSSL_INCLUDE_DIR=../../openssl-OpenSSL_1_1_0c/include -DOPENSSL_CRYPTO_LIBRARY=../../openssl-OpenSSL_1_1_0c/libcrypto.a -DOPENSSL_SSL_LIBRARY=../../openssl-OpenSSL_1_1_0c/libssl.a
make

cp xmrig ../../xmrig.exe
cd ../..

##########################################
# xmrig-proxy

if [ ! -d xmrig-proxy ]
then
	git clone https://github.com/xmrig/xmrig-proxy
else
	cd xmrig-proxy/
	git pull
	cd ..
fi

cp -R extra/xmrig-proxy/* xmrig-proxy

cd xmrig-proxy
if [ ! -d build ]
then
	mkdir build
fi
cd build
cmake .. -DXMRIG_ARCH=native -DWITH_TLS=ON -DUV_INCLUDE_DIR=../../libuv/include -DUV_LIBRARY=../../libuv/.libs/libuv.a -DWITH_HTTPD=OFF -DOPENSSL_INCLUDE_DIR=../../openssl-OpenSSL_1_1_0c/include -DOPENSSL_CRYPTO_LIBRARY=../../openssl-OpenSSL_1_1_0c/libcrypto.a -DOPENSSL_SSL_LIBRARY=../../openssl-OpenSSL_1_1_0c/libssl.a
make

cp xmrig-proxy ../../xmrig-proxy.exe
cd ../..

##########################################
# Checks

strip -s xmrig.exe
md5sum xmrig.exe

strip -s xmrig-proxy.exe
md5sum xmrig-proxy.exe

