#!/usr/bin/perl -w
use strict;
use warnings;
use bc;
use bc_plot;
use CGI;

my $cgi=CGI->new();
my $bc=bc->new();
my $bc_plot=bc_plot->new();

my %tr=qw(
amar Amaryllis
tru Truseq
bioo6 Bioo-6mer
bioo Bioo-8mer
biooSm BiooSmRNA
htcra HumanTCRa
htcrb HumanTCRb
mtcra MouseTCRa
mtcrb MouseTCRb
neb NEB
next Nextera
);

my %tr_rnk=qw(
amar 10
tru 1
bioo 5
bioo6 4
biooSm 5.5
htcra 6
htcrb 7
mtcra 8
mtcrb 9
neb 3
next 2
);

my $res=$cgi->param("res");

my $cmd_line=shift;

## Usager cmd_line  
## for generating distance  perl barcode.pl 1 gendist,
#   or to
## test interface, perl barcode.pl 1

if(defined($cmd_line)){ 
    my $mode=shift;
    if(defined($mode) && $mode=~/gendist/){ 
	mk_designs($mode);
	exit;
    } 
    $res=1;
    init_vars();
}

sub init_vars{
    $cgi->param("tru"=>24);
#    $cgi->param("user"=>"ATCACG");
}

sub mk_popup_lnk{
    my $lnk=shift;
    my $text=shift;
    return "<a href=\"$lnk\" onclick=\"javascript:void window.open('$lnk','1525474484891','width=700,height=500,toolbar=0,menubar=0,location=0,status=1,scrollbars=1,resizable=1,left=0,top=0');return false;\"> $text </a>\n";
} 

print "Content-type: text/html\n\n";
print "<html>\n";
print "<head> <style type=\"text/css\"> 
input { text-align:right; }
h5 { 
    display: block;
    font-size: 1.0em;
    margin-top: 1.67em;
    margin-bottom: 1.67em;
    margin-left: 0;
    margin-right: 0;
    font-weight: bold;
    color: red;
} 
h6 { 
    display: block;
    font-size: 1.3em;
    margin-top: 1.67em;
    margin-bottom: 1.67em;
    margin-left: 0;
    margin-right: 0;
    font-weight: bold;
    color: green;
}
body {background-color: powderblue;}
p {color: red;} 
</style>
</head>
\n";
print "<body>\n";


if(!defined($res)){
#    print " <H4>
#<a href=\"./help.html\" onclick=\"javascript:void window.open('./help.html','1525474484891','width=700,height=500,toolbar=0,menubar=0,location=0,status=1,scrollbars=1,resizable=1,left=0,top=0');return false;\"> help </a>\n";

    my $lnk=mk_popup_lnk("./help.html","help"); 
    print "<H4> $lnk";
    print " &nbsp;&nbsp;&nbsp; <a href=./doc/Barcode_caddy.pdf> writeup </a> ";
    print " &nbsp;&nbsp;&nbsp; <a style=\"font-size:12px;\" href=/tools.html> Tools Home </a>  
</H4> \n";  

    print "<H2>Barcode Caddy  </H2>";

    print "<p> Barcode Caddy selects an optimum set of barcodes for your 
sample pool. Custom (or pre-selected) barcode sets can also be validated 
and/or added while generating new sets\n";

    print "  <p><h4>Pick barcodes from the following sets:</h4></p>\n";

    mk_sets_form();
}else {
    my $bc_str="";

    foreach my $tr (keys %tr){
	if(defined($cgi->param($tr)) && $cgi->param($tr) > 0 ) { 
	    $bc_str.=$tr.":".$cgi->param($tr).",";
	} 
    }
    #perl $0 genbcs amar:4,neb:4,tru:2 ACGGTA:myown1,TTGTCC:myown2".
    $bc_str=~s/,$//;
    my $usr_str="";
    if(defined($cgi->param("user")) && $cgi->param("user") =~/\S+/){
	$usr_str=$cgi->param("user");
	$usr_str=~s/\s*,\s*/,/msg;
	$usr_str=~s/(\w)\s+(\w)/$1,$2/msg;
    } 

   # print "usr_str=$usr_str,bc_str=$bc_str\n";exit;
#    print "<h4> reached this point </h4>\n";

    print "<H4> <a href=./barcode.pl> Tool Home  </a>  &nbsp;  &nbsp;  &nbsp;  &nbsp;  &nbsp; <a href=http://girihlet.com/tools.html> Girihlet Tools </a></H4>\n";
 #   print "<h4> reached this point </h4>\n";

    if($bc_str=~/^\s*$/ && $usr_str=~/^\s*$/){
	print "<H5> Sorry, you are asking me to guess what you want, I am legally not permitted to serve you this way. Please go back and make a selection </H5>\n";
	print "</body></html>\n";
	exit;
    }

#    print "<h4> reached this point </h4>\n";
    
    my ($des_str,$mat_str,$perf_str,$valid,$v_str)=mk_designs("genbcs",$bc_str,$usr_str);

    if(!$valid){
	print "<H4> Input barcodes are invalid </H4>\n";

	my @rows=split(/,/,$v_str);
	print "<b> Invalid pairs in input</b>\n";
	print "<table border=1>\n";
	print "<tr> <th> barcode1</th><th> barcode2</th><th> distance </th></tr>\n";
	foreach my $r (@rows){
	    print "<tr> <td> ";
	    $r=~s/\:/<\/td><td>/;
	    print "$r</td></tr>\n";
	}
	print "</table>\n";
	print "</body></html>\n";
	exit;
    } else { 
	print "<H6> This  barcode set has our stamp of approval </H6>";
    } 

    my $ocsv="tmp/bc$$.csv";
    print "<H3>Barcodes (<a href=$ocsv>csv download</a>)</H3>\n";
    open OUT,">$ocsv" or die "FAIL:$ocsv";
    print OUT $des_str;
    close OUT;

    if(0){ 
	if($valid){ 
	    print "<H6> This  barcode set has our stamp of approval </H6>";
	} else {
	    print "<H5> We disapprove of this barcode set </H5>";
	}
    } 
    make_tbl($des_str);
    print "<h3>Diversity</h3>\n";
    make_fig($perf_str);
    print "<h3>Distances (between pairs)</h3>\n";

    my $matf="tmp/mat$$.html";

    my $lnk=mk_popup_lnk("./$matf","distance matrix"); 
#    print "
#<a href=\"./$matf\" onclick=\"javascript:void window.open('./$matf','1525474484891','width=700,height=500,toolbar=0,menubar=0,location=0,status=1,scrollbars=1,resizable=1,left=0,top=0');return false;\">  distance matrix </a>\n";
    print "$lnk";
    make_tbl($mat_str,$matf);

}
print "</body></html>\n";

exit;

sub make_tbl{
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
    }else { print $tbl_str;} 
} 

sub make_fig{
    my $perf_str=shift;
    #    print "<img width=500 alt=\"perf\" width=42 src=\"./bargraph.cgi?perf=dna2.perf\">\n"
    my $pfile="tmp/fig$$.perf";
    open OUT,">$pfile" or die "FAIL:$pfile";
    print OUT "$perf_str";
    close OUT;
    print "<img width=500 alt=\"perf\" width=42 src=\"./bargraph.cgi?perf=$pfile\">\n";
}

sub mk_sets_form{

    print "<form action=barcode.pl method=post>\n";
    print "<input type=\"hidden\" name=\"res\" value=\"1\">\n";
    my $str=`cut -d , -f 3 ./data/bc_list.csv| sort | uniq -c `;
    print "<table> <tr> <th align=\"left\"> Set name </th><th align=\"left\"> Number &nbsp;&nbsp; </th> <th align=\"left\">how many ?</th> </tr>\n";
    my @list;
    foreach my $r (split(/\n/,$str)){
	my ($cnt,$name)=$r=~/^\s*(\d+)\s+(\S+)/;
	push(@list,[$cnt,$name]);
    }
    foreach my $l(sort{$tr_rnk{$a->[1]} <=> $tr_rnk{$b->[1]}} @list){
	my ($cnt,$name)=@{$l};
	my $real_name=$name; if(defined($tr{$name})){ $real_name=$tr{$name};}
	print " <tr>  <td> <a href=./show_bc.pl?term=$name>$real_name</a></td><td>$cnt</td> <td>  
<input type=number min=0 max=$cnt name=$name  value=0 size=2 maxlength=2/></td> </tr>\n";
    }
    
    print "
       <tr> <td style=\"vertical-align: center;\"> Pre-selected barcodes <br> 
(as sequences (space/comma separated) </td> <td> </td> <td>
	    <textarea name=user rows=5 cols=20></textarea>
</table>
<input type=\"Submit\">
    </form>
";
    print "<a href=mailto:ravi\@girihlet.com> Contact </a> for criticisms/suggestions/bugs \n";
} 


sub mk_designs{
    my $mode=shift;
    my $pick_str=shift;
    my $pre_set_str=shift;

    my $DBG=0;
#    if($DBG){ 	srand(10);print STDERR "randome number generator being fixed\n";    }
    die usage()     if(!defined($mode)); 

    if($mode=~/gendist/){
	## only used to generate data files, (pairwise distance bc_dist.csv and barcode list bc_list.csv)
	$bc->gen_files();
	exit;
    } elsif($mode=~/genbcs/){ 
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
		
		print "ERROR:INVALID set\n";
	    }
	    else {
		#print "pre_set validates\n";
	    } 
	}
	$pick_str=~s/\s+//g;
	my ($P_set,$mess)= $bc->get_barcodes($pick_str,$pre_set_str);
	#print join("\n",@{$P_set})."\n"; exit;
	print "$mess\n";

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

	$bc_plot->bar_graph($perf_str);
	    
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

} 

sub usage{
    print "Usage: four modes, generate data files(gendist) or get barcodes(genbcs) or distance matrix (genmat) or generate diversity data (gendiv)\n $0 gendist \n OR \n $0 genbcs pick_str [pre_set_str]\n".
    " perl $0 gendist \n OR \n perl $0 genbcs amar:4,neb:4,tru:2 ACGGTA,TTGTCC".
    "\n OR \n perl $0 gendist \n OR \n perl $0 genbcs amar:4,neb:4,tru:2 ACGGTA:myown1,TTGTCC:myown2".
    " \n OR \n perl $0 genmat ACGGTA,TTGTCC\n".
    " \n OR \n perl $0 gendiv ACGGTA,TTGTCC\n";
    
} 


