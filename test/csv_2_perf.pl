use strict;

my $head=" 
# stacked 100% graph example from Derek Bruening's PhD thess
=stacked;C;G;A;T
column=last
max=100
#=arithmean
#=sortbmarks
=nogridy
=noupperright
legendx=right
legendy=center
=nolegoutline
legendfill=
yformat=%g%%
xlabel=Position
ylabel=Percentage of total
";
print "$head";
my $str="
,1,2,3,4,5,6
A,3,3,2,2,2,4
C,3,3,3,4,4,3
G,3,3,3,2,3,1
T,3,3,4,4,3,4
";
my $strf="
,1,2,3,4,5,6
A,0.250,0.250,0.167,0.167,0.167,0.333
C,0.250,0.250,0.250,0.333,0.333,0.250
G,0.250,0.250,0.250,0.167,0.250,0.083
T,0.250,0.250,0.333,0.333,0.250,0.333
";
$str=~s/^\s+//g;$str=~s/\s+$//g;
$strf=~s/^\s+//g;$strf=~s/\s+$//g;

my @r=split(/\n/,$str);
my @rf=split(/\n/,$strf);

my $h=$r[0];

for(my $i=1;$i<@r;$i++){
    my @rl=split(/,/,$r[$i]);
    my @rfl=split(/,/,$rf[$i]);

    if($i>1){
	print "=multi\n";
    }
    for(my $j=1;$j<@rl;$j++){
	my $let=$rl[0];
	$rfl[$j]*=100;
	print "$j\t$let:\t$rl[$j] => $rfl[$j]\%\n";
    }
}

exit;
