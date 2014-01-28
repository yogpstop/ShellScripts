#!/bin/bash
#builtin... cd echo
check() {
	if ! $1 --version &>/dev/null ; then
		echo "Please install $1" >&2
		exit 1
	fi
}
if ! 7za --help &>/dev/null ; then
	echo "Please install 7za" >&2
	exit 1
fi
check dirname
check readlink
check wget
check sed
check sort
check head
check rm
check mkdir
check gradle

cd `dirname \`readlink -mqsn "$0"\``
LINE=`wget -O - -q http://files.minecraftforge.net/minecraftforge/ | sed -e "s/[ \t\n\r]//g" | sed -e "s/</\n</g" | sed -ne "s~.*\(http://files.minecraftforge.net/maven/net/minecraftforge/forge/[0-9\.]\+-[0-9]\+.[0-9]\+.[0-9]\+.\([0-9]\+\)/forge-[0-9\.]\+-[0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+-src.zip\).*~\2 \1~p" | sort -rn | head -q -n 1`
DIR=`echo $LINE | sed -e "s/\([0-9]\+\) .\+/\1/"`
rm -rf ${DIR}
mkdir ${DIR}
cd ${DIR}
mkdir -p "src/main/java"
wget -O src.zip -q `echo $LINE | sed -e "s/[0-9]\+ \(.\+\)/\1/"`
7za x src.zip build.gradle
rm src.zip
echo -e "buildDir = file(new File(projectDir, \"../build\"))\nminecraft {\n    assetDir = new File(projectDir, \"../assets\").absolutePath\n}" >>build.gradle
gradle setupDecompWorkspace
gradle build
