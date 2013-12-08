#!/bin/bash
HOST=`gcc -dumpmachine`
if [ "${HOST}" = "x86_64-w64-mingw32" ] ; then
	OST="mingw64"
else
	OST="mingw"
fi
cd || exit 1
python --version || exit 1
# YASM
git clone --depth 1 git://github.com/yasm/yasm.git || exit 1
cd yasm || exit 1
./autogen.sh || exit 1
make || exit 1
make install-strip || exit 1
cd || exit 1
rm -rf yasm || exit 1
# NASM
git clone git://repo.or.cz/nasm.git || exit 1
cd nasm || exit 1
git checkout nasm-2.10.09
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
sed -i -e "s/\(##\|[0-9]\)UI64\([^0-9a-zA-Z]\?\)/\1ULL\2/g" \
		`find . -iregex ".*\.\(c\|h\|cpp\)" -type f` || exit 1
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
(patch -p0 <<'_EOT_'
--- libcrypto.pc        2013-08-16 13:46:37 +0900
+++ libcrypto.pc.new    2013-08-16 14:19:43 +0900
@@ -7,6 +7,6 @@
 Description: OpenSSL cryptography library
 Version: 1.1.0-dev
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
) || exit 1
cd || exit 1
rm -rf rtmpdump || exit 1
# fdk-aac
git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git || exit 1
cd fdk-aac || exit 1
./autogen.sh || exit 1
./configure --prefix=/${HOST} --disable-shared --enable-static || exit 1
make || exit 1
make install || exit 1
cd || exit 1
rm -rf fdk-aac || exit 1
# lame
echo -en "/1 :pserver:anonymous@lame.cvs.sourceforge.net:2401/cvsroot/lame A\n" >lame.cvspass
CVS_PASSFILE=lame.cvspass cvs -z3 \
	-d:pserver:anonymous@lame.cvs.sourceforge.net:/cvsroot/lame \
	co -P lame || exit 1
rm -rf lame.cvspass || exit 1
cd lame || exit 1
./configure --disable-shared --enable-static --prefix=/${HOST} \
	--disable-frontend || exit 1
make || exit 1
make install || exit 1
cd || exit 1
rm -rf lame || exit 1
# x264
git clone --depth 1 git://git.videolan.org/x264.git || exit 1
cd x264 || exit 1
./configure --host=${HOST} --prefix=/${HOST} --enable-win32thread \
	--enable-static --disable-cli --enable-strip || exit 1
make || exit 1
make install || exit 1
cd || exit 1
rm -rf x264 || exit 1
# ffmpeg
git clone --depth 1 git://source.ffmpeg.org/ffmpeg.git || exit 1
cd ffmpeg || exit 1
(patch -p0 <<'_EOT_'
--- libavcodec/Makefile        2013-08-16 13:46:37 +0900
+++ libavcodec/Makefile.new    2013-08-16 14:19:43 +0900
@@ -692,7 +692,7 @@
 OBJS-$(CONFIG_LIBGSM_MS_ENCODER)          += libgsm.o
 OBJS-$(CONFIG_LIBILBC_DECODER)            += libilbc.o
 OBJS-$(CONFIG_LIBILBC_ENCODER)            += libilbc.o
-OBJS-$(CONFIG_LIBMP3LAME_ENCODER)         += libmp3lame.o mpegaudiodecheader.o
+OBJS-$(CONFIG_LIBMP3LAME_ENCODER)         += libmp3lame.o mpegaudiodata.o mpegaudiodecheader.o
 OBJS-$(CONFIG_LIBOPENCORE_AMRNB_DECODER)  += libopencore-amr.o
 OBJS-$(CONFIG_LIBOPENCORE_AMRNB_ENCODER)  += libopencore-amr.o
 OBJS-$(CONFIG_LIBOPENCORE_AMRWB_DECODER)  += libopencore-amr.o
_EOT_
) || exit 1
PKG_CONFIG_PATH=/${HOST}/lib/pkgconfig \
./configure --fatal-warnings --enable-gpl --enable-nonfree \
--disable-everything --enable-libmp3lame --disable-ffprobe \
--disable-ffserver --disable-ffplay --disable-doc --disable-debug \
--enable-libfdk-aac --enable-libx264 --enable-librtmp --cpu=native \
--enable-static --disable-shared --enable-indev=dshow \
--enable-encoder='libx264,libfdk_aac,libmp3lame' --enable-muxer=flv \
--enable-protocol='file,librtmp,tcp' --enable-filter='scale,aresample' \
--enable-decoder='rawvideo,pcm_s16le' || exit 1
make || exit 1
cp ffmpeg.exe .. || exit 1
cd || exit 1
rm -rf ffmpeg || exit 1
echo "BUILD SUCCESSED"

