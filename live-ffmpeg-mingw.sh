#!/bin/bash
set -eu
export LANG=C
perl --version
exec 1> >(perl -e 'use POSIX "strftime";open(FILE, ">>stdout.log");$/="\n";while(<>){$_=~s~[\r\n]+$~~g;$_=strftime "[%Y-%m-%dT%H:%M:%S]$_\n", localtime;print STDOUT "$_";print FILE "$_";}close(FILE);')
exec 2> >(perl -e 'use POSIX "strftime";open(FILE, ">>stderr.log");$/="\n";while(<>){$_=~s~[\r\n]+$~~g;$_=strftime "[%Y-%m-%dT%H:%M:%S]$_\n", localtime;print STDERR "$_";print FILE "$_";}close(FILE);')
mktemp --version
TUNE='sandybridge'
NATIVE='-march=sandybridge -mmmx -mno-3dnow -msse -msse2 -msse3 -mssse3 -mno-sse4a -mcx16 -msahf -mno-movbe -maes -mno-sha -mpclmul -mpopcnt -mno-abm -mno-lwp -mno-fma -mno-fma4 -mno-xop -mno-bmi -mno-bmi2 -mno-tbm -mavx -mno-avx2 -msse4.2 -msse4.1 -mno-lzcnt -mno-rtm -mno-hle -mno-rdrnd -mno-f16c -mno-fsgsbase -mno-rdseed -mno-prfchw -mno-adx -mfxsr -mxsave -mxsaveopt -mno-avx512f -mno-avx512er -mno-avx512cd -mno-avx512pf -mno-prefetchwt1 --param l1-cache-size=32 --param l1-cache-line-size=64 --param l2-cache-size=6144 -mtune=sandybridge' #for i5-2500
#TUNE='native'
#NATIVE="-march=${TUNE}"
ARCH='x86_64'
HOST="${ARCH}-w64-mingw32"
TDIR=`mktemp -d`
TROOT=`mktemp -d`
export C_INCLUDE_PATH="${TROOT}/include"        #gcc envvar
export CPLUS_INCLUDE_PATH="$C_INCLUDE_PATH"     #gcc envvar
export PKG_CONFIG_PATH="${TROOT}/lib/pkgconfig" #pkg-config envvar
export MAKEFLAGS='-j8'                          #make envvar
export pkg_config='pkg-config'                  #for ffmpeg
export CROSS_COMPILE="${HOST}-"                 #for rtmpdump
export CC="${CROSS_COMPILE}gcc"                 #configure envvar
export CXX="${CROSS_COMPILE}g++"                #configure envvar
export CPP="${CROSS_COMPILE}cpp"                #configure envvar
export CXXCPP="${CROSS_COMPILE}cpp"             #configure envvar
export CFLAGS="${NATIVE} -pipe -O3"             #configure envvar
export CXXFLAGS="$CFLAGS"                       #configure envvar
export LDFLAGS="-s -L${TROOT}/lib"              #configure envvar
OPTS="--host=${HOST} --prefix=${TROOT} --enable-static --disable-shared --disable-frontend --disable-cli --enable-win32thread --enable-strip --disable-debug"
if [[ "${HOST}" == "x86_64-w64-mingw32" ]] ; then
	OST="mingw64"
else
	OST="mingw"
fi
${CC} --version
${CXX} --version
${CPP} --version
${CXXCPP} --version
perl --version
git --version
cvs --version
bash --version
sed --version
rm --version
cp --version
patch --version
make --version
autoreconf --version
automake --version
autoconf --version
libtool --version
pkg-config --version
yasm --version
nasm -version
cd "$TDIR"
# RTMPDump
git clone --depth 1 git://repo.or.cz/rtmpdump.git
cd rtmpdump/librtmp
make SYS=mingw SHARED=no CRYPTO= OPT="${CFLAGS}" prefix=${TROOT}
make SYS=mingw SHARED=no CRYPTO= OPT="${CFLAGS}" prefix=${TROOT} install
patch -d ${TROOT}/lib/pkgconfig -p0 <<'_EOT_'
--- librtmp.pc      2013-08-16 14:13:20 +0900
+++ librtmp.pc.new  2013-08-16 14:17:58 +0900
@@ -8,6 +8,6 @@
 Version: v2.4
 Requires: 
 URL: http://rtmpdump.mplayerhq.hu
-Libs: -L${libdir} -lrtmp -lz 
-Libs.private: -lws2_32 -lwinmm -lgdi32
+Libs: -L${libdir} -lrtmp -lws2_32 -lwinmm 
+Libs.private: -lgdi32
 Cflags: -I${incdir}
_EOT_
cd "$TDIR"
# fdk-aac
git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git
cd fdk-aac
./autogen.sh
./configure ${OPTS}
make
make install-strip
cd "$TDIR"
# lame
echo -en "/1 :pserver:anonymous@lame.cvs.sourceforge.net:2401/cvsroot/lame A\n" >lame.cvspass
CVS_PASSFILE=lame.cvspass cvs -z3 \
	-d:pserver:anonymous@lame.cvs.sourceforge.net:/cvsroot/lame \
	co -P lame
cd lame
autoreconf -fiv
./configure ${OPTS}
make
make install-strip
cd "$TDIR"
# x264
#git clone --depth 1 git://git.videolan.org/x264.git
# I use repo.or.cz mirror because official repository is extremely slow for me
git clone --depth 1 git://repo.or.cz/x264.git
cd x264
./configure ${OPTS} --cross-prefix=${HOST}-
make
make install
cd "$TDIR"
# ffmpeg
# git clone --depth 1 git://source.ffmpeg.org/ffmpeg.git
# I use github mirror because official repository is extremely slow for me
git clone --depth 1 --branch release/2.5 git://github.com/FFmpeg/FFmpeg.git
cd FFmpeg
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
--enable-libfdk-aac --enable-libx264 --enable-librtmp --cpu=${TUNE} \
--enable-static --disable-shared --enable-indev=dshow --enable-stripping \
--enable-encoder='libx264,libfdk_aac,libmp3lame' --enable-muxer=flv \
--enable-protocol='file,librtmp,tcp' --enable-filter='scale,aresample' \
--enable-decoder='rawvideo,pcm_s16le' --disable-pthreads --disable-iconv \
--target-os=mingw32 --prefix=${TROOT} --cross-prefix=${HOST}- --arch=${ARCH}
make
cp ffmpeg.exe ~
rm -rf ${TDIR} ${TROOT}
echo "BUILD SUCCESSED"
