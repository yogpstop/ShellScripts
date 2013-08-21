cd
git clone --depth 1 git://source.ffmpeg.org/ffmpeg.git fmpg || exit 1
cd fmpg || exit 1
./configure --fatal-warnings --enable-gpl --enable-nonfree --disable-everything \
--disable-ffprobe --disable-ffserver --disable-ffplay --disable-doc --disable-debug \
--enable-libfdk-aac --enable-libx264 --enable-librtmp --enable-libv4l2 \
--arch=x86_64 --cpu=corei7-avx --enable-static --disable-shared \
--enable-encoder='libx264,libfdk_aac' --enable-muxer=flv --enable-protocol='file,librtmp,tcp' \
--enable-indev='alsa,v4l2' --enable-filter='scale,aresample' --enable-decoder='rawvideo,pcm_s16le' || exit 1
make || exit 1
cp ffmpeg .. || exit 1
cd || exit 1
rm -rf fmpg || exit 1
echo "BUILD SUCCESSED"

