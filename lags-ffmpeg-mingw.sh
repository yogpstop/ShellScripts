#!/bin/bash
HOST=`gcc -dumpmachine`
if [ "${HOST}" = "x86_64-w64-mingw32" ] ; then
	OST="mingw64"
else
	OST="mingw"
fi
cd
# YASM
wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz || exit 1
tar xvf yasm-1.2.0.tar.gz || exit 1
rm -f yasm-1.2.0.tar.gz || exit 1
cd yasm-1.2.0 || exit 1
./configure || exit 1
make || exit 1
make install-strip || exit 1
cd || exit 1
rm -rf yasm-1.2.0 || exit 1
# NASM
git clone --depth 1 git://repo.or.cz/nasm.git || exit 1
cd nasm || exit 1
./autogen.sh || exit 1
./configure || exit 1
make || exit 1
make strip || exit 1
make install || exit 1
cd || exit 1
rm -rf nasm || exit 1
# OpenSSL
git clone --depth 1 git://git.openssl.org/openssl.git || exit 1
cd openssl || exit 1
sed -i -e "s/\(##\|[0-9]\)UI64\([^0-9a-zA-Z]\?\)/\1ULL\2/g" `find . -iregex ".*\.\(c\|h\|cpp\)" -type f` || exit 1
./Configure ${OST} no-shared --prefix=/${HOST} || exit 1
make || exit 1
make install || exit 1
cd || exit 1
rm -rf openssl || exit 1
# RTMPDump
git clone --depth 1 git://git.ffmpeg.org/rtmpdump.git || exit 1
cd rtmpdump || exit 1
make SYS=mingw SHARED=no prefix=/${HOST} || exit 1
make install SYS=mingw SHARED=no prefix=/${HOST} || exit 1
cd /${HOST}/lib/pkgconfig || exit 1
patch -p0 <<'_EOT_'
--- libcrypto.pc        2013-08-16 13:46:37 +0900
+++ libcrypto.pc.new    2013-08-16 14:19:43 +0900
@@ -7,6 +7,6 @@
 Description: OpenSSL cryptography library
 Version: 1.0.1e
 Requires: 
-Libs: -L${libdir} -lcrypto
-Libs.private: -lws2_32 -lgdi32 -lcrypt32
+Libs: -L${libdir} -lcrypto -lws2_32 -lgdi32
+Libs.private: -lcrypt32
 Cflags: -I${includedir} 
--- librtmp.pc      2013-08-16 14:13:20 +0900
+++ librtmp.pc.new  2013-08-16 14:17:58 +0900
@@ -8,6 +8,6 @@
 Version: v2.4
 Requires: libssl,libcrypto
 URL: http://rtmpdump.mplayerhq.hu
-Libs: -L${libdir} -lrtmp -lz
-Libs.private: -lws2_32 -lwinmm -lgdi32
+Libs: -L${libdir} -lrtmp -lz -lwinmm
+Libs.private: -lws2_32 -lgdi32
 Cflags: -I${incdir}
_EOT_
cd || exit 1
rm -rf rtmpdump || exit 1
# x264
git clone --depth 1 git://git.videolan.org/x264.git || exit 1
cd x264 || exit 1
./configure --host=${HOST} --prefix=/${HOST} --enable-win32thread --enable-static --disable-cli || exit 1
make || exit 1
make install || exit 1
cd || exit 1
rm -rf x264 || exit 1
# ffmpeg
git clone --depth 1 git://source.ffmpeg.org/ffmpeg.git || exit 1
7za x ffmpeg_lagarith.7z || exit 1
mv lagarith_enc.c ffmpeg/libavcodec/ || exit 1
cd ffmpeg || exit 1
patch -p1 <../patch.diff || exit 1
rm -rf ../patch.diff || exit 1
PKG_CONFIG_PATH=/${HOST}/lib/pkgconfig \
./configure --fatal-warnings --enable-gpl --disable-everything \
--disable-ffprobe --disable-ffserver --disable-ffplay --disable-doc --disable-debug \
--enable-vfw --enable-libx264 --cpu=corei7-avx --enable-static --disable-shared \
--enable-encoder='lagarith,pcm_s16le' --enable-muxer=avi --enable-demuxer='flv,avi' --enable-protocol='file' \
--enable-filter='scale,aresample' --enable-decoder='h264,aac' || exit 1
make || exit 1
cp ffmpeg.exe .. || exit 1
cd || exit 1
rm -rf ffmpeg || exit 1
echo "BUILD SUCCESSED"
