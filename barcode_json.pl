#!/usr/bin/perl -w
use strict;
use warnings;
use bc;
use bc_plot;

my $bc=bc->new();
my $bc_plot=bc_plot->new();

use JSON;
use lib("/home/ravi");

use common::generic::myUtil;
my $my=common::generic::myUtil->new();

## test, should be sent from outside
my $json_str='{"HumanTCRa":"8","MouseTCRb":"0","Nextera":"0","HumanTCRb":"0","MouseTCRa":"0","Amaryllis":"0","NEB":"0","Bioo-8mer":"0","Bioo-6mer":"0","Truseq":"0",';
$json_str='{"amar":"18","bioo":"0","bioo6":"8","htcra":"0","htcrb":"0","mtcra":"0","mtcrb":"0","neb":"0","next":"0","tru":"0","barcodes":" - "}';
 
#$str.='"barcodes":" - "}';
#$json_str.='"barcodes":"TAACGGTC,CAAGATAT,"}';
#$str.='"barcodes":"TAACGGTC,CAAGATAT,TAACCGTC,CAATATAT,"}';
#
#15    193,TAACGGTC,htcra,H_TCRA_BC12
#    194,CAAGATAT,htcra,H_TCRA_BC13

#print "$json_str\n";exit;
my $json_str_cmd=shift;

if(defined($json_str_cmd)) { $json_str=$json_str_cmd;}

my ($usr_str,$bc_str,$err_str)=json_2_bc($json_str);

#print "usr_str=$usr_str\n";
#print "bc_str=$bc_str\n";
#print "err_str=$err_str\n";

if($err_str=~/\S/){
    print "{\"ERR\":\"$err_str\"}\n";
    exit;
}

if($bc_str !~ /\S/ && $usr_str !~ /\S/){ 
    $err_str.= "Sorry, you are asking me to guess what you want, I am legally not permitted to serve you this way. Please go back and make a selection ";
}  
if($err_str=~/\S/){
    print "{\"ERR\":\"$err_str\"}\n";
    exit;
}


my ($des_str,$mat_str,$perf_str,$valid,$v_str)=mk_designs($bc_str,$usr_str);

if(!$valid){
    $err_str.= "Input barcodes invalid,bad_distances,$v_str";
    #	"bad_dist:$v_str" ## bc1:bc2:dist
    my @rows=split(/,/,$v_str);
#    print "<b> Invalid pairs in input</b>\n";
#    print "<table border=1>\n";
#    print "<tr> <th> barcode1</th><th> barcode2</th><th> distance </th></tr>\n";
}

if($err_str=~/\S/){
    print '{"ERR":"$err_str"}';
    exit;
} 

#my $json_str_out='"help_link":"./help.html"';
#$json_str_out.=',"writeup_link":"./doc/Barcode_caddy.pdf"';
#$json_str_out.=',"toolhome_link":"/tools.html"';
#    "toolHome_lnk:./barcode.pl";
#"girihletTools_lnk:http://girihlet.com/tools.html";

if(0){
print "des_str=$des_str\n";
print "mat_str=$mat_str\n";
print "perf_str=$perf_str\n";
print "valid=$valid\n";
print "v_str=$v_str\n";
}

my $ocsv="tmp/bc$$.csv";
open OUT,">$ocsv" or die "FAIL:$ocsv";
print OUT $des_str;
close OUT;

my $ohtml=$ocsv;$ohtml=~s/\.csv/\.html/;
mk_tbl($des_str,$ohtml);
my $pfile=$ocsv;$pfile=~s/\.csv/\.perf/;
my $png=$pfile;$png=~s/.perf/.png/;
my $fig_lnk=mk_fig_n_lnk($perf_str,$pfile);
my $matf="tmp/mat$$.html";
mk_tbl($mat_str,$matf);

print "{\"csv\":\"$ocsv\",\"html\":\"$ohtml\",\"dist\":\"$matf\",\"fig_lnk\":\"$fig_lnk\",\"fig\":\"$png\"}\n";

exit;


sub mk_tbl{
    my $str=shift;

    my $file=shift;

    if(defined($file)){ 
	open OM,">$file" or die "FAIL:$file";
	print OM "<html> <body> \n";
    } 
    if(!defined($str)){ 
	$str=",ACGGTA,TTGTCC
	ACGGTA,0,5
	TTGTCC,,0
    ";
    } 
    my @str=split(/\n/,$str);

    my $tbl_str=     "<table border=1>\n";
    my $head=$str[0];$head=~s/,/<\/th><th>/g;
    $tbl_str.="<tr> <th> #</th> <th> $head </th></tr>\n";
    my $cnt=0;
    for(my $i=1;$i<@str;$i++){
	next if($str[$i]=~/^\s*$/);
	$str[$i]=~s/,/<\/td><td>/g;
	$cnt++;
	$tbl_str.= "<tr><td> $cnt</td> <td> $str[$i] </td></tr>\n";
    }
    $tbl_str.= "</table>\n";

    if(defined($file)){ 
	print OM $tbl_str;
	print OM "</body></html> \n";
	close OM;
    }else { return $tbl_str;} 
} 

sub mk_fig_n_lnk{
    my $perf_str=shift;
    my $pfile=shift;
#    my $pfile="tmp/fig$$.perf";
    open OUT,">$pfile" or die "FAIL:$pfile";
    print OUT "$perf_str";
    close OUT;
    system("perl bargraph.cgi $pfile")==0 or die "FAIL:bargraph.cgi $pfile";
    return "./bargraph.cgi?perf=$pfile";
}


sub mk_designs{
    my $pick_str=shift;
    my $pre_set_str=shift;

    my $DBG=0;
#    if($DBG){ 	srand(10);print STDERR "randome number generator being fixed\n";    }
    die usage()     if(!defined($pick_str)); 

    {
	$bc->read_data();
	
	if(defined($pre_set_str) && $pre_set_str=~/\w+/){ 
	    $pre_set_str=~s/\s+//;
	    my @pre_set=split(/,/,$pre_set_str);
	    my ($ret,$r_str)=$bc->find_bad_in_set(\@pre_set);
	    if(!$ret){
		my $ret_str="";
		my $mat_str="";
		my $perf_str="";
		return($ret_str,$mat_str,$perf_str,$ret,$r_str);
		
		print "ERR:INVALID set\n";
	    }
	    else {
		#print "pre_set validates\n";
	    } 
	}
	$pick_str=~s/\s+//g;
	my ($P_set,$mess)= $bc->get_barcodes($pick_str,$pre_set_str);
	#print join("\n",@{$P_set})."\n"; exit;
#	print "$mess\n";

	my $ret_str="Sequence,name,set\n";
	my @set;
	foreach(@{$P_set}){ 
	    my ($bc,$ind,$lset)=@{$_};
	    $ret_str.="$bc,$ind,$lset\n";
	    push(@set,$bc);
	}
	my ($ret,$r_str)=$bc->find_bad_in_set(\@set);
#	print "set=@set,ret=$ret\n";exit;
	if(!$ret){
	    my $ret_str="";
	    my $mat_str="";
	    my $perf_str="";
	    return($ret_str,$mat_str,$perf_str,$ret,$r_str);
	} 
	my $mat_str=$bc->mk_dist_matrix(\@set);
	my ($dstr,$dstrf)=$bc->mk_div(\@set);
	my $perf_str=$bc_plot->csv_2_perf($dstr,$dstrf);
	return($ret_str,$mat_str,$perf_str,1,"");
    }
} 

sub json_2_bc{
    my $json_str=shift;
    my $dcdd=JSON::XS::decode_json($json_str);
    #$my->pp($dcdd);
    #    #perl $0 genbcs amar:4,neb:4,tru:2 ACGGTA:myown1,TTGTCC:myown2".
     #    $bc_str=~s/,$//; 
   my $usr_str="";
  my $bc_str="";

my $mybcs=$dcdd->{"barcodes"};
if($mybcs=~/[ACGT]{6}/){
    $mybcs=~s/\,$//;
    #ACGGTA:myown1,TTGTCC:myown2".
    my @my=split(/,/,$mybcs);
    for(my $i=0;$i<@my;$i++){
	my $j=$i+1;
	if($j<10){ $usr_str.="$my[$i]:usr0$j,";}
    }
}else { $mybcs="";$usr_str="";}
$usr_str=~s/,$//;

delete($dcdd->{"barcodes"});

    my $err_str="";

foreach my $ky(keys %{$dcdd}){
    if($dcdd->{$ky} ==0){ next;}
    else {
	my $cnt=$dcdd->{$ky};
#	'' {"amar":"18","bioo":"0","bioo6":"8","htcra":"0","htcrb":"0","mtcra":"0","mtcrb":"0","neb":"0","next":"0","tru":"0","barcodes":" - "}" .
	if($ky=~/amar/i){$bc_str.="amar:$cnt,";}
	elsif($ky=~/tru/i){$bc_str.="tru:$cnt,";}
	elsif($ky=~/Bioo\-8|bioo$/i){$bc_str.="bioo:$cnt,";}
	elsif($ky=~/Bioo\-6|bioo6$/i){$bc_str.="bioo6:$cnt,";}
	elsif($ky=~/BiooSm$/i){$bc_str.="biooSm:$cnt,";}
	elsif($ky=~/neb/i){$bc_str.="neb:$cnt,";}
	elsif($ky=~/next/i){$bc_str.="next:$cnt,";}
	elsif($ky=~/h.*tcra/i){$bc_str.="htcra:$cnt,";}
	elsif($ky=~/h.*tcrb/i){$bc_str.="htcrb:$cnt,";}
	elsif($ky=~/m.*tcra/i){$bc_str.="mtcra:$cnt,";}
	elsif($ky=~/m.*tcrb/i){$bc_str.="mtcrb:$cnt,";}
	else {
	    $err_str.="UnknownBarcodeFamily:$ky,";
	    last;
	}
    } 
}
    $bc_str=~s/\,$//;
    return ($usr_str,$bc_str,$err_str);
} 
