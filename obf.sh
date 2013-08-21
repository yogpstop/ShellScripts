#!/bin/bash
IFS='
'
cd $1
indir=`pwd`
indir=${indir##*/}
infiles=(`find -mindepth 1 -type f | perl -e '@a = <STDIN>;
for ($i=@a-1;$i>=0;--$i){
 $j = int(rand($i+1));
 next if($i==$j);
 @a[$i, $j] = @a[$j, $i];
}
print join("\n",@a);'`)
outdir="${indir}_obf"
echo "mkdir \"${indir}\" || exit 1" >../deobf.sh
echo "cd \"${indir}\"" >>../deobf.sh
echo -n "mkdir -p ." >>../deobf.sh
find -mindepth 1 -type d -exec echo -n " \"{}\"" \; >>../deobf.sh
echo >>../deobf.sh
mkdir "../${outdir}" || exit 1
wgs=(`perl -e '
use POSIX;
@a=(0..9,a..z);
$c=ceil(log(@ARGV[0])/log(@a));
if($c < 1){$c=1;}
sub b{
  if((length @_[0]) < $c){foreach $i (@a){&b(@_[0].$i);}
  }else{print @_[0]."\n";}
}
&b();' ${#infiles[@]}`)
for i in `seq 0 \`expr ${#infiles[@]} - 1\`` ; do
  cp "${infiles[${i}]}" "../${outdir}/${wgs[${i}]}"
  echo "cp \"../${outdir}/${wgs[${i}]}\" \"${infiles[${i}]}\"" >>../deobf.sh
done
