#!/bin/bash
set -eu
export LANG=C
perl --version
exec 1> >(perl -e 'use POSIX "strftime";open(FILE, ">>stdout.log");$/="\n";while(<>){$_=~s~[\r\n]+$~~g;$_=strftime "[%Y-%m-%dT%H:%M:%S]$_\n", localtime;print STDOUT "$_";print FILE "$_";}close(FILE);')
exec 2> >(perl -e 'use POSIX "strftime";open(FILE, ">>stderr.log");$/="\n";while(<>){$_=~s~[\r\n]+$~~g;$_=strftime "[%Y-%m-%dT%H:%M:%S]$_\n", localtime;print STDERR "$_";print FILE "$_";}close(FILE);')
perl --version
bash --version
curl --version
tar --version
make --version
git --version
hg --version
svn --version
rm --version
mkdir --version
gcc --version
TMP_DIR='/gcc-build-tmp'
RUN_DIR='/mingw32'
BUILD_CHOST='x86_64-w64-mingw32'
HOST_CHOST='x86_64-w64-mingw32'
TARGET_CHOST='i686-w64-mingw32'
ATOPTIONS_BASE="--build=${BUILD_CHOST} --host=${HOST_CHOST} --enable-static --disable-shared --disable-multilib --with-gmp-prefix=${TMP_DIR}/gmp --with-isl-prefix=${TMP_DIR}/isl --disable-isl-version-check --disable-cloog-version-check"
ATOPTIONS_WOT="$ATOPTIONS_BASE --with-gmp=${TMP_DIR}/gmp --with-mpfr=${TMP_DIR}/mpfr --with-mpc=${TMP_DIR}/mpc --with-cloog=${TMP_DIR}/cloog --with-isl=${TMP_DIR}/isl"
ATOPTIONS_WOP="$ATOPTIONS_BASE --target=$TARGET_CHOST"
ATOPTIONS="$ATOPTIONS_WOT --target=$TARGET_CHOST"
export PATH="${TMP_DIR}/dist${RUN_DIR}/bin:${TMP_DIR}/zlib/bin:${TMP_DIR}/iconv/bin:${PATH}" #MSYS style
export C_INCLUDE_PATH="${TMP_DIR}/zlib/include;${TMP_DIR}/iconv/include" #MinGW style
export CPLUS_INCLUDE_PATH="$C_INCLUDE_PATH" #MinGW style
export LIBRARY_PATH="${TMP_DIR}/zlib/lib:${TMP_DIR}/iconv/lib" #MSYS style(?)
export CFLAGS='-march=native -O2 -pipe'
export CXXFLAGS="$CFLAGS"
export LDFLAGS='-s'
export MAKEFLAGS='-j8'
build() {
	if [[ ! -f configure ]] ; then
		if [[ -f autogen.sh ]] ; then
			./autogen.sh
		elif [[ -f .bootstrap ]] ; then
			./.bootstrap
		else
			autoreconf -fiv
		fi
	fi
	./configure $@
	make
	if grep -Pq '^install-strip:' Makefile ; then
		make install-strip
	else
		make install
	fi
}
mkdir -p $TMP_DIR
cd $TMP_DIR
if [[ ! -d iconv ]] ; then
	curl -o libiconv-1.14.tar.gz \
		https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz #TODO
	tar xvf libiconv-1.14.tar.gz
	cd libiconv-1.14
	build --prefix=${TMP_DIR}/iconv $ATOPTIONS
	cd ..
fi
if [[ ! -d zlib ]] ; then
	git clone git://github.com/madler/zlib zlib-repo
	cd zlib-repo
	build --prefix=${TMP_DIR}/zlib --static
	cd ..
fi
if [[ ! -d gmp ]] ; then
	hg clone https://gmplib.org/repo/gmp gmp-repo
	cd gmp-repo
	build --prefix=${TMP_DIR}/gmp $ATOPTIONS_WOT --enable-cxx
	cd ..
fi
if [[ ! -d mpfr ]] ; then
	svn co svn://scm.gforge.inria.fr/svnroot/mpfr/trunk mpfr-repo
	cd mpfr-repo
	build --prefix=${TMP_DIR}/mpfr $ATOPTIONS
	cd ..
fi
if [[ ! -d mpc ]] ; then
	git clone https://gforge.inria.fr/git/mpc/mpc.git mpc-repo
	cd mpc-repo
	build --prefix=${TMP_DIR}/mpc $ATOPTIONS
	cd ..
fi
if [[ ! -d isl ]] ; then
	git clone --depth=1 -b maint git://repo.or.cz/isl.git isl-repo
	cd isl-repo
	build --prefix=${TMP_DIR}/isl $ATOPTIONS_WOP
	cd ..
fi
if [[ ! -d cloog ]] ; then
	git clone --depth=1 git://repo.or.cz/cloog.git cloog-repo
	cd cloog-repo
	build --prefix=${TMP_DIR}/cloog $ATOPTIONS_WOP
	cd ..
fi
if [[ ! -d mingw-w64 ]] ; then
	git clone --depth=1 git://git.code.sf.net/p/mingw-w64/mingw-w64
	cd mingw-w64/mingw-w64-headers
	build --prefix=${TMP_DIR}/dist${RUN_DIR}/${TARGET_CHOST} $ATOPTIONS --enable-secure-api --enable-sdk=all
	cd ../mingw-w64-crt
	build --prefix=${TMP_DIR}/dist${RUN_DIR}/${TARGET_CHOST} $ATOPTIONS --enable-lib32 --enable-wildcard --disable-lib64
	cd ../..
fi
if [[ ! -d binutils-gdb ]] ; then
	git clone --depth=1 git://sourceware.org/git/binutils-gdb.git
	cd binutils-gdb
	rm -rf gdb readline libdecnumber sim
	build --prefix=${TMP_DIR}/dist${RUN_DIR} $ATOPTIONS --enable-lto --enable-plugins --enable-gold --enable-install-libiberty --disable-rpath --disable-nls
	cd ..
fi
if [[ ! -d gcc-repo ]] ; then
	git clone --depth=1 -b gcc-4_9-branch git://gcc.gnu.org/git/gcc.git gcc-repo
	cd gcc-repo
	build --prefix=${RUN_DIR} $ATOPTIONS --with-sysroot=${TMP_DIR}/dist --enable-languages=c,c++,lto --enable-libstdcxx-time=yes --enable-threads=win32 --enable-libgomp --enable-libatomic --enable-lto --enable-graphite --enable-checking=release --enable-fully-dynamic-string --enable-version-specific-runtime-libs --disable-sjlj-exceptions --with-dwarf2 --disable-libstdcxx-pch --disable-libstdcxx-debug --enable-bootstrap --disable-rpath --disable-win32-registry --disable-nls --disable-werror --disable-symvers --with-gnu-as --with-gnu-ld --with-libiconv --with-system-zlib --enable-cloog-backend=isl --with-native-system-header-dir=${RUN_DIR}/${TARGET_CHOST}/include
	cd ..
fi
