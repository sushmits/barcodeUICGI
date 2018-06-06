#!/usr/bin/perl -w
use strict;
use CGI;
#my $unix_uid =geteuid();
#setresuid($unix_uid, $unix_uid, $unix_uid);
my $cgi=CGI->new();
#stacked_100.perf
my $perf=$cgi->param("perf");

my $pf=shift;

#print "pf=$pf\n";exit;

if(defined($pf)){
    my $png=$pf;
    $png=~s/\.perf//;
    $png.=".png";
    my $img=`perl bargraph.pl -png $pf > $png`;
    exit;
} 
elsif(defined($perf) && -e $perf){
    my $img=`perl bargraph.pl -png $perf`;
    my $len=length($img);
    print "Content-type: image/png\n";
    print "Content-length: $len \n\n";
    binmode STDOUT;
    print $img;
} else {
    print "Content-type: image/png\n";
#    print "Content-length: $len \n\n";
    binmode STDOUT;
    open IN,"test/tmp.png" or die "FAIL:test/tmp.png";
    while(my $l=<IN>){
	print $l;
    }
    close IN;
#    print STDERR "did not get perf=$perf\n";
} 
exit;
