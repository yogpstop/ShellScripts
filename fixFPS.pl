#!/usr/bin/perl
open ( OF, "<$ARGV[0]");
while ($_ = <OF>){
$_ =~ s/start=([0-9]+)/sprintf "start=%d",1+int(($1-1)*20\/30)/e;
$_ =~ s/end=([0-9]+)/sprintf "end=%d",int($1*20\/30)/e;
print $_;
}
close(OF);