use strict;

use lib(".");
use bc;

my $bc=bc->new();

my $mode=shift;
my $pick_str=shift;
my $pre_set_str=shift;
my $DBG=0;
if($DBG){ 
    srand(10);print STDERR "randome number generator being fixed\n";
}

die usage()     if(!defined($mode)); 



if($mode=~/gendist/){ 
    $bc->gen_files();
    exit;
} elsif($mode=~/genbcs/){ 
    $bc->read_data();
    if(defined($pre_set_str)){ 
	$pre_set_str=~s/\s+//;
	my @pre_set=split(/,/,$pre_set_str);
	my $ret=$bc->validate_set(\@pre_set);
	if(!$ret){
	    print "ERROR:INVALID set\n";
	    my $str=$bc->mk_dist_matrix(\@pre_set);
	    print "ERROR:$str\n";
	    exit;
	}
	else {
	    #print "pre_set validates\n";
	} 
    }
    $pick_str=~s/\s+//;
    my $P_set= $bc->get_barcodes($pick_str,$pre_set_str);
    #    print join("\n",@{$P_set})."\n";
    my $ret_str="";
    my @set;
    foreach(@{$P_set}){ 
	my ($bc,$ind,$lset)=@{$_};
	$ret_str.="$bc,$ind,$lset\n";
	push(@set,$bc);
    }
    print "$ret_str\n";
    my $str=$bc->mk_dist_matrix(\@set);
    print "$str\n";
#    my $perf_str=$bc->mk_div(\@set);
#    print "$perf_str\n";
  my ($str,$strf)=$bc->mk_div(\@set);
    print "$str\n";
    print "frac\n";
    print "$strf\n";

    
    exit;
} elsif($mode=~/genmat/){ 
    $pick_str=~s/\s+//;
  my @set=split(/,/,$pick_str); 
  my $str=$bc->mk_dist_matrix(\@set);
  print "$str\n";
  exit;
} elsif($mode=~/gendiv/){ 
    $pick_str=~s/\s+//;
  my @set=split(/,/,$pick_str); 
  my ($str,$strf)=$bc->mk_div(\@set);
    print "$str\n";
    print "frac\n";
    print "$strf\n";
  exit;
} else {
    print "ERROR:Unknown mode\n";
    usage();
    exit;
    die "Unknown mode=$mode\n";
} 

exit;




sub usage{
    print "Usage: four modes, generate data files(gendist) or get barcodes(genbcs) or distance matrix (genmat) or generate diversity data (gendiv)\n $0 gendist \n OR \n $0 genbcs pick_str [pre_set_str]\n".
    " perl $0 gendist \n OR \n perl $0 genbcs amar:4,neb:4,tru:2 ACGGTA,TTGTCC".
    "\n OR \n perl $0 gendist \n OR \n perl $0 genbcs amar:4,neb:4,tru:2 ACGGTA:myown1,TTGTCC:myown2".
    " \n OR \n perl $0 genmat ACGGTA,TTGTCC\n".
    " \n OR \n perl $0 gendiv ACGGTA,TTGTCC\n";
    
} 


exit;
