#!/bin/bash
set -eu
export LANG=C
git --version
cvs --version
bash --version
sed --version
rm --version
cp --version
mktemp --version
patch --version
gcc --version
make --version
automake --version
autoconf --version
libtool --version
pkg-config --version
python --version || python2 --version || python3 --version #Required to yasm
getopt --version #Required to xmlto, in util-linux
xmlto --version #Required to nasm
asciidoc --version #Required to nasm
TDIR=`mktemp -d`
TROOT=`mktemp -d`
export PATH="${TROOT}/bin:${PATH}" #MSYS style
export C_INCLUDE_PATH="${TROOT}/include" #MinGW style
export CPLUS_INCLUDE_PATH="$C_INCLUDE_PATH" #MinGW style
export LIBRARY_PATH="${TROOT}/lib" #MSYS style(?)
export PKG_CONFIG_PATH="${TROOT}/lib/pkgconfig"
export CFLAGS='-march=native -pipe -O2'
export CXXFLAGS="$CFLAGS"
export LDFLAGS='-s'
export MAKEFLAGS='-j8'
HOST=`gcc -dumpmachine`
OPTS="--host=${HOST} --prefix=${TROOT}"
if [[ "${HOST}" == "x86_64-w64-mingw32" ]] ; then
	OST="mingw64"
else
	OST="mingw"
fi
cd "$TDIR"
# YASM
git clone --depth 1 git://github.com/yasm/yasm.git
cd yasm
./autogen.sh ${OPTS}
make
make install-strip
cd "$TDIR"
# NASM
git clone --depth 1 git://repo.or.cz/nasm.git
cd nasm
./autogen.sh
./configure ${OPTS}
make -j1
make strip
make install
cd "$TDIR"
# RTMPDump
git clone --depth 1 git://git.ffmpeg.org/rtmpdump.git
cd rtmpdump
make SYS=mingw SHARED=no CRYPTO= prefix=${TROOT}
make install SYS=mingw SHARED=no CRYPTO= prefix=${TROOT}
cd ${TROOT}/lib/pkgconfig
patch -p0 <<'_EOT_'
--- librtmp.pc      2013-08-16 14:13:20 +0900
+++ librtmp.pc.new  2013-08-16 14:17:58 +0900
@@ -8,6 +8,6 @@
 Version: v2.4
 Requires: 
 URL: http://rtmpdump.mplayerhq.hu
-Libs: -L${libdir} -lrtmp -lz 
-Libs.private: -lws2_32 -lwinmm -lgdi32
+Libs: -L${libdir} -lrtmp -lz -lws2_32 -lwinmm 
+Libs.private: -lgdi32
 Cflags: -I${incdir}
_EOT_
cd "$TDIR"
# fdk-aac
git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git
cd fdk-aac
./autogen.sh
./configure ${OPTS} --disable-shared --enable-static
make
make install
cd "$TDIR"
# lame
echo -en "/1 :pserver:anonymous@lame.cvs.sourceforge.net:2401/cvsroot/lame A\n" >lame.cvspass
CVS_PASSFILE=lame.cvspass cvs -z3 \
	-d:pserver:anonymous@lame.cvs.sourceforge.net:/cvsroot/lame \
	co -P lame
cd lame
./configure --disable-shared --enable-static ${OPTS} --disable-frontend
make
make install
cd "$TDIR"
# x264
#git clone --depth 1 git://git.videolan.org/x264.git
# I use repo.or.cz mirror because official repository is extremely slow for me
git clone --depth 1 git://repo.or.cz/x264.git
cd x264
./configure ${OPTS} --enable-win32thread \
	--enable-static --disable-cli --enable-strip
make
make install
cd "$TDIR"
# ffmpeg
# git clone --depth 1 git://source.ffmpeg.org/ffmpeg.git
# I use github mirror because official repository is extremely slow for me
git clone --depth 1 git://github.com/FFmpeg/FFmpeg.git
cd ffmpeg
patch -p0 <<'_EOT_'
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
./configure --fatal-warnings --enable-gpl --enable-nonfree \
--disable-everything --enable-libmp3lame --disable-ffprobe \
--disable-ffserver --disable-ffplay --disable-doc --disable-debug \
--enable-libfdk-aac --enable-libx264 --enable-librtmp --cpu=native \
--enable-static --disable-shared --enable-indev=dshow \
--enable-encoder='libx264,libfdk_aac,libmp3lame' --enable-muxer=flv \
--enable-protocol='file,librtmp,tcp' --enable-filter='scale,aresample' \
--enable-decoder='rawvideo,pcm_s16le' --disable-pthreads --disable-iconv \
--target-os=mingw32 --prefix=${TROOT}
make
cp ffmpeg.exe ~
cd
#rm -rf ${TDIR} ${TROOT}
echo "BUILD SUCCESSED"
